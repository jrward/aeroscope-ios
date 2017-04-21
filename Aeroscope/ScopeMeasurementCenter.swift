//
//  ScopeMeasurementCenter.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 1/4/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation

enum Measurement {
    case vpp
    case vmin
    case vmax
    case vavg
}

class ScopeMeasurementCenter {
    
    struct notifications {
        static let listChanged = Notification.Name("com.Aeroscope.listChanged")
        static let measUpdated = Notification.Name("com.Aeroscope.measUpdated")
    }
    
    struct defines {
        static let adcZero = 127
        static let offsetZero = 32768
    }
    
    let settings : ScopeSettingsInterface
    let frame : ScopeFrameInterface
    
    var  measList = [Measurement]()
    
    var vpp : Double?
    var vmin : Double?
    var vmax : Double?
    var vavg : Double?
    
    private var rawVpp : Int = 0
    private var rawVmin : Int = 0
    private var rawVmax : Int = 0
    private var rawVavg : Int = 0
    
    init(settings: ScopeSettingsInterface, frame: ScopeFrameInterface) {
        self.settings = settings
        self.frame = frame
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeasurements), name: ScopeFrame.notifications.frame, object: nil)
    }
    
    func add(meas: Measurement) {
        measList.append(meas)
        NotificationCenter.default.post(name: notifications.listChanged, object: nil)
    }
    
    func remove(meas: Measurement) {
        measList = measList.filter() { $0 != meas }
        NotificationCenter.default.post(name: notifications.listChanged, object: nil)
    }
    
    func getText(meas: Measurement) -> String{
        switch meas{
        case .vpp: return ("Vpp: " + ScopeMeasurementCenter.translate(voltage: vpp) )
        case .vmin: return ("Vmin: " + ScopeMeasurementCenter.translate(voltage: vmin) )
        case .vmax: return ("Vmax: " + ScopeMeasurementCenter.translate(voltage: vmax) )
        case .vavg: return ("Vavg: " + ScopeMeasurementCenter.translate(voltage: vavg) )
        }
    }


    
    var signedOffset : Double {
        get {
            return Double(settings.getOffset() - defines.offsetZero)
        }
    }
    var offsetConv : Double {
        get {
            return Double(settings.getVertMeta().offsetConv)
        }
    }
    var voltConv : Double {
        get {
            return Double(settings.getVertMeta().voltsPerBit)
        }
    }
    
    var offsetToVolts : Double{
        get {
            return (signedOffset / offsetConv) * voltConv
        }
    }
    
    
    static func translate(voltage: Double?) -> String {
        var voltageString : String
        
        if let voltUW = voltage {
            if abs(voltUW) >= 1.0 {
                voltageString = String(format: "%.03f", voltUW)
                voltageString += " V"
            }
            else {
                voltageString = String(format: "%.0f", voltUW*1000.0)
                voltageString += " mV"
            }
        }
            
        else {
            voltageString = "???? V"
        }
        
        return voltageString
    }
    
    @objc func updateMeasurements() {
        let currFrame = frame.getRawFrame()
        if currFrame.count > 0 {
        
            rawVmax = Int(currFrame.max() ?? 0)
            rawVmin = Int(currFrame.min() ?? 0)
            rawVpp = rawVmax - rawVmin
            
            var accum = 0
            for el in currFrame {
                accum += Int(el)
            }
            rawVavg = accum / currFrame.count
            
            let signedOffset = Double(settings.getOffset() - defines.offsetZero)
            let offsetConv = Double(settings.getVertMeta().offsetConv )
            let rawVmaxRel = Double(rawVmax - defines.adcZero)
            let rawVminRel = Double(rawVmin - defines.adcZero)
            let rawVavgRel = Double(rawVavg - defines.adcZero)
            let voltConv = Double(settings.getVertMeta().voltsPerBit)
            
            let scaledOffset = (signedOffset / offsetConv).rounded(.toNearestOrAwayFromZero)
            //let scaledOffset = signedOffset / offsetConv
        
            
            vmax = rawVmax >= 255 || rawVmax <= 0 ? nil : (scaledOffset + rawVmaxRel) * voltConv
            vmin = rawVmin >= 255 || rawVmin <= 0 ? nil : (scaledOffset + rawVminRel) * voltConv
            vpp  = vmax == nil || vmin == nil ? nil : (vmax ?? 0) - (vmin ?? 0)
            vavg = vmax == nil || vmin == nil ? nil : abs(scaledOffset + rawVavgRel) > 1 ? (scaledOffset + rawVavgRel) * voltConv : 0
        }
        else {
            vmax = nil
            vmin = nil
            vpp = nil
            vavg = nil
        }
        NotificationCenter.default.post(name: notifications.measUpdated, object: nil)

    }
    
    
}
