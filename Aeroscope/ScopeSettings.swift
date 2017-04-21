//
//  ScopeSettings.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import Foundation

enum TriggerMode {
    case pos
    case neg
    case any
    case none
}

typealias vert_mapping = (toReal: Double, voltsPerBit: Double, reg: UInt8,  offsetConv: Double)

typealias horiz_mapping = (toReal: Double, timePerSample: Double, divRatio: Int, reg: UInt8, subFrameSize: Int)


class ScopeSettings : Copyable  {
    
    var comms : ScopeComms!
    
    struct notifications {
        static let triggerXPos = Notification.Name("com.Aeroscope.updateTriggerXPos")
        static let trigger = Notification.Name("com.Aeroscope.updateTrigger")
        static let windowPos = Notification.Name("com.Aeroscope.updateWindowPos")
        static let offset = Notification.Name("com.Aeroscope.updateOffset")
        static let vert = Notification.Name("com.Aeroscope.updateVert")
        static let horiz = Notification.Name("com.Aeroscope.updateHoriz")
        static let runState = Notification.Name("com.Aeroscope.runState")
        static let acdc = Notification.Name("com.Aeroscope.acdc")
    }
    


//    fileprivate struct Fpga1Reg {
//        static let offset_prefix = 0
//        static let trigger_ctrl = 1
//        static let trigger = 2
//        static let pll = 3
//        static let front_end = 4
//        static let sampler = 5
//        static let trig_xposh = 6
//        static let trig_xposl = 7
//        static let window_posh = 8
//        static let window_posl = 9
//        static let writeDepth = 10
//        static let readDepth = 11
//        static let offset_h = 12
//        static let offset_l = 13
//    }
    fileprivate struct Fpga1Reg {
        static let trigger_ctrl = 0
        static let trigger = 1
        static let pll = 2
        static let front_end = 3
        static let sampler = 4
        static let trig_xposh = 5
        static let trig_xposl = 6
        static let window_posh = 7
        static let window_posl = 8
        static let writeDepth = 9
        static let readDepth = 10
        static let offset_h = 11
        static let offset_l = 12
    }

    
    fileprivate struct FpgaBits {
        static var dc_en : UInt8 = 7
    }
    
    var fpga_settings_updated = false;
    
    fileprivate var fpga1_settings_updated = false {
        didSet {
            if (fpga1_settings_updated) { fpga_settings_updated = true }
        }
    }
    
    
    func send_fpga_settings() {
        if (inited) {
            comms.sendFpga1(self.fpga1_regs)
            fpga1_settings_updated = false;
            fpga_settings_updated = false;
        }
    }
    
    func update_fpga_settings() {
        fpga1_settings_updated = true;
    }
    
    var fpga1_regs = [UInt8](repeating: 0, count: 20)
    var cpu_regs = [UInt8](repeating: 0, count: 20)
    
    
    fileprivate var inited = false
    
    struct TrigCtrl {
        var autoTrig = RegField(position:0, value: true)
        var posSlopeTrig = RegField(position: 1, value: true)
        var negSlopeTrig = RegField(position: 2, value: false)
        var noiseRejectTrig = RegField(position: 4, value: false)
        var lowPassTrig = RegField(position: 5, value: false)
    }
    
    var trigCtrl = TrigCtrl() {
        didSet {
            fpga1_regs[Fpga1Reg.trigger_ctrl] = trigCtrl.autoTrig.byte |
                trigCtrl.posSlopeTrig.byte |
                trigCtrl.negSlopeTrig.byte |
                trigCtrl.noiseRejectTrig.byte |
                trigCtrl.lowPassTrig.byte
            fpga1_settings_updated = true
            
        }
    }
    
    var dc_en = RegField(position: FpgaBits.dc_en, value: true) {
        didSet {
            let oldVal = fpga1_regs[Fpga1Reg.front_end] & dc_en.mask
            fpga1_regs[Fpga1Reg.front_end] = oldVal | dc_en.byte
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.acdc, object: self)
        }
    }
    


    var vert : StringSetting<vert_mapping>  {
        didSet {
//            if let offsetCal = offset {
//                offset.value = offsetCal.value - offsetCalTable[vert.value]!
//            }
            offset.value = offset.value
            let currMapping = vert.mapping[vert.value]?.reg
            fpga1_regs[Fpga1Reg.front_end] = currMapping! //| (dc_en.toInt() << dc_en.position)
            dc_en.value = dc_en.value
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.vert, object: self)
        }
    }
    var horiz : StringSetting<horiz_mapping> {
        didSet {
            processHorizSetting(horiz.mappedSetting())
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.horiz, object: self)
            
        }
    }
    var trigger : IntRangeSetting {
        didSet {
            fpga1_regs[Fpga1Reg.trigger] = UInt8(trigger.value)
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.trigger, object: self)
        }
    }
    

    
    var offset : IntRangeSetting{
        didSet {
            //var myvert : StringSetting<UInt8>? = scope.settings.vert as StringSetting<UInt8>?
//            if let vertical = vert {
//                offset.value = offset.value - offsetCalTable[vertical.value]!
//            }
            var calOffset = offset.value
            
//            if let vertical = vert {
//                calOffset = offset.value + offsetCalTable[vertical.value]!
//            }
            
            let vertical = vert.value
            let prefs = UserDefaults.standard
            //if let myNSUUID = prefs.valueForKey("My Aeroscope") {
            let cal : Int = (prefs.value(forKey: vertical) as! Int?) ?? 0
            calOffset = offset.value + cal
            
//            let high_byte = (offset.value >> 8) & 0xFF
//            let low_byte = offset.value & 0xFF
            let high_byte = (calOffset >> 8) & 0xFF
            let low_byte = calOffset & 0xFF

            fpga1_regs[Fpga1Reg.offset_h] = UInt8(high_byte)
            fpga1_regs[Fpga1Reg.offset_l] = UInt8(low_byte)
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.offset, object: self)
            
            //update_cpu_settings()
        }
    }
    var trigger_x_pos : IntRangeSetting {
        didSet{
            let high_byte = (trigger_x_pos.value >> 8) & 0xFF
            let low_byte = (trigger_x_pos.value) & 0xFF
            
            //let low_bits = trigger_x_pos.value & 0x7
            fpga1_regs[Fpga1Reg.trig_xposh] = UInt8(high_byte)
            fpga1_regs[Fpga1Reg.trig_xposl] = UInt8(low_byte)
            
            //fpga1_regs[Fpga1Reg.trig_xpos_sel] = UInt8(low_bits)
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.triggerXPos, object: self)
        }
    }
    
    
    var window_pos : IntRangeSetting {
        didSet {
            let high_byte = (window_pos.value >> 8) & 0xFF
            let low_byte = (window_pos.value) & 0xFF
            
            fpga1_regs[Fpga1Reg.window_posh] = UInt8(high_byte)
            fpga1_regs[Fpga1Reg.window_posl] = UInt8(low_byte)
            
            fpga1_settings_updated = true
            NotificationCenter.default.post(name: notifications.windowPos, object: self)
        }
    }
    
    var writeDepth : IntListSetting {
        didSet {
            switch writeDepth.value {
            case 512: fpga1_regs[Fpga1Reg.writeDepth] = 0x06
            case 4096: fpga1_regs[Fpga1Reg.writeDepth] = 0x09
            default: fpga1_regs[Fpga1Reg.writeDepth] = 0x06
            }
            fpga1_settings_updated = true
        }
    }
    
    var readDepth : IntListSetting {
        didSet {
            //scope.frame.frame_size = readDepth.value
            switch readDepth.value {
            case 512: fpga1_regs[Fpga1Reg.readDepth] = 0x06
            case 4096: fpga1_regs[Fpga1Reg.readDepth] = 0x09
//                case 512: fpga1_regs[Fpga1Reg.readDepth] = 0
//                case 1024: fpga1_regs[Fpga1Reg.readDepth] = 1
//                case 2048: fpga1_regs[Fpga1Reg.readDepth] = 2
//                case 4096: fpga1_regs[Fpga1Reg.readDepth] = 3
//                default: fpga1_regs[Fpga1Reg.readDepth] = 0
            default: fpga1_regs[Fpga1Reg.readDepth] = 0x06
            }
            fpga1_settings_updated = true
        }
    }
    
    

    
    
    let trigger_range = Range(0...255)
    let offset_range = Range(0...65535)
    let trigger_x_pos_range = Range(0...4095)
    let window_pos_range = Range(0...3583)
    
    let writeDepth_list = [512, 4096]
    let readDepth_list = [512, 4096]
    

    
    
    
    /********************
     BALANCED METHOD 1
     +FS        |   0xFF
                |   127 values
     0.0 V      |   0x80
                |   127 values
     -FS + 1    |   0x01
     -FS        |   0x00
    
    To balance offset binary, clip at 0x01 code

     8 division: 9 mesurement lines
     
    -|- +400 mV     |   0xFF
     |-             |
     |-             |
     |-             |
    -|- 0.0 mV      |   0x10
     |-             |
     |-             |
     |-             |
    -|- -400 mV     |   0x01
     
     Increment per bit = 400 mV / 127
     
     ********************/
    
    
    /********************
     BALANCED METHOD 2
     
    -|- +400 mV     |   0xFF
     |-             |
     |-             |
     |-             |   0x80
    -|- 0.0 mV      |   XXXX
     |-             |   0x0F
     |-             |
     |-             |
    -|- -400 mV     |   0x00

     No True Zer0
     Increment per bit = 800 mV / 256
     
     
     
    ********************/
    
    
   
    // String       toReal  voltsPerBit     reg     offsetConv
    let vertMapping : Mapping<String, vert_mapping> = [
        ("100mV",   (0.1,   0.8/255,        0x60,   2.048)),
        ("200mV",   (0.2,   1.6/255,        0x41,   4.096)),
        ("500mV",   (0.5,   4.0/255,        0x20,   10.24)),
        ("1V",      (1.0,   8.0/255,        0x22,   20.48)),
        ("2V",      (2.0,   16.0/255,       0x03,   40.96)),
        ("5V",      (5.0,   40.0/255,       0x04,   102.4)),
        ("10V",     (10.0,  80.0/255,       0x05,   204.8))
    ]

    

    //String        toReal      timePerSample   divRatio    reg   subFrameSize
    let horizMapping : Mapping<String, horiz_mapping> = [
        ("50ns",    (50e-9,     5000e-9/500,    1,          0x01, 50)),
        ("100ns",   (100e-9,    5000e-9/500,    1,          0x01, 100)),
        ("250ns",   (250e-9,    5000e-9/500,    1,          0x01, 250)),
        ("500ns",   (500e-9,    5000e-9/500,    1,          0x01, 500)),
        ("1us",     (1e-6,      10e-6/500,      2,          0x10, 500)),
        ("2us",     (2e-6,      20e-6/500,      4,          0x20, 500)),
        ("5us",     (5e-6,      50e-6/500,      10,         0x09, 500)),
        ("10us",    (10e-6,     100e-6/500,     20,         0x11, 500)),
        ("20us",    (20e-6,     200e-6/500,     40,         0x21, 500)),
        ("50us",    (50e-6,     500e-6/500,     100,        0x0A, 500)),
        ("100us",   (100e-6,    1000e-6/500,    200,        0x12, 500)),
        ("200us",   (200e-6,    2000e-6/500,    400,        0x22, 500)),
        ("500us",   (500e-6,    5000e-6/500,    1000,       0x0B, 500)),
        ("1ms",     (1e-3,      10e-3/500,      2000,       0x13, 500)),
        ("2ms",     (2e-3,      20e-3/500,      4000,       0x23, 500)),
        ("5ms",     (5e-3,      50e-3/500,      10000,      0x0C, 500)),
        ("10ms",    (10e-3,     100e-3/500,     20000,      0x14, 500)),
        ("20ms",    (20e-3,     200e-3/500,     40000,      0x24, 500)),
        ("50ms",    (50e-3,     500e-3/500,     100000,     0x0D, 500)),
        ("100ms",   (100e-3,    1000e-3/500,    200000,     0x15, 500)),
        ("200ms",   (200e-3,    2000e-3/500,    400000,     0x25, 500)),
        // Roll Mode Settings:
        ("500ms",   (500e-3,    5000e-3/500,    1000000,    0xE7, 500)),
        ("1s",      (1,         10/500,         2000000,    0xEF, 500)),
        ("2s",      (2,         20/500,         4000000,    0xF7, 500)),
        ("5s",      (5,         50/500,         10000000,   0xFF, 500))
    ]
    

    
    func processHorizSetting(_ setting: horiz_mapping) {
//        let mappedPll = pllMapping[setting.pll]!
//        fpga1_regs[Fpga1Reg.pll] = mappedPll
        let mappedDiv = horiz.mappedSetting().reg
        fpga1_regs[Fpga1Reg.sampler] = mappedDiv
       // scope.frame.subFrameSize = setting.subFrameSize
       // scope.frame.subFramePosition = (scope.frame.frame_size - setting.subFrameSize) / 2
        
    }
    

    
    
    init(comms: ScopeComms) {
        self.comms = comms
        vert = StringSetting<vert_mapping>(value: "1V", mapping: vertMapping)
        horiz = StringSetting<horiz_mapping>(value: "500ns", mapping: horizMapping)
        trigger = IntRangeSetting(value: 128, range: trigger_range)
        offset = IntRangeSetting(value: 32768, range: offset_range)
        trigger_x_pos = IntRangeSetting(value: 2048, range: trigger_x_pos_range)
        window_pos = IntRangeSetting(value: 1792, range: window_pos_range)
        writeDepth = IntListSetting(value: 4096, list: writeDepth_list)
        readDepth = IntListSetting(value: 512, list: readDepth_list)
        
//        stoppedOffset = offset
//        stoppedXPos = trigger_x_pos
//        stoppedWinPos = window_pos
        
        
        //reinitialize all regs to build initial register value
        makeRegs()
    }
    
    required init(original: ScopeSettings) {
        vert = original.vert
        horiz = original.horiz
        trigger = original.trigger
        offset = original.offset
        trigger_x_pos = original.trigger_x_pos
        window_pos = original.window_pos
        writeDepth = original.writeDepth
        readDepth = original.readDepth
    }
    
    

    
//    var runStopSingle : RunState {
//        didSet {
//            switch runStopSingle {
//            case .run:
//                setRun()
//            case .stop:
//                setStopped()
//            case .single:
//                setSingle()
//            }
//            
//            update_cpu_settings()
//            update_fpga_settings()
//            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.runState, object: self)
//        }
//    }
    

    
    func makeRegs() {
        trigCtrl.autoTrig.value = trigCtrl.autoTrig.value
        vert.value = vert.value
        horiz.value = horiz.value
        trigger.value = trigger.value
        offset.value = offset.value
        trigger_x_pos.value = trigger_x_pos.value
        writeDepth.value = writeDepth.value
        readDepth.value = readDepth.value
        window_pos.value = window_pos.value
        
        inited = true
        
    }
    
    
    func copy() -> ScopeSettings {
        let copy = ScopeSettings(comms: self.comms)
        copy.vert = vert
        copy.horiz = horiz
        copy.window_pos = window_pos
        copy.trigger = trigger
        copy.trigger_x_pos = trigger_x_pos
        copy.offset = offset
        copy.writeDepth = writeDepth
        copy.readDepth = readDepth
        return copy
    }

}


