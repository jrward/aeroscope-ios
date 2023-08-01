//
//  ScopeTelemetry.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 11/30/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var ascii : [CChar]? {
        return self.cString(using: String.Encoding.ascii)
    }
}

extension Character {
    var ascii : CChar? {
        return String(self).cString(using: String.Encoding.ascii)?[0]
    }
}

enum ScopeError : UInt8 {
    case critical
    case fpgaConfig = 0xC0
    case fpgaState = 0xC1
    case fpgaReset = 0xC2
    case cal = 0xC5
    case calAccuracy = 0xC6
    case badState = 0xC9
    
    func description() -> String {
        switch self {
        case .critical: return "Critical Error"
        case .fpgaConfig: return "FPGA Config Error"
        case .fpgaState: return "FPGA Unkown State"
        case .fpgaReset: return "FPGA Reset Unexpectedly"
        case .cal: return "Cal Error"
        case .calAccuracy: return "Cal Accuracy Error"
        case .badState: return "Wrong State For Action"
        }
    }
}

protocol PowerDelegate : AnyObject {
    func didPowerOn()
    func didPowerOff()
}

class ScopeTelemetry : ConnectionDelegate, PacketDelegate {
    
    let settings: ScopeSettingsInterface
    weak var powerDelegate : PowerDelegate?
    
    let batt = ScopeBattery()
    let temp = ScopeTemp()
    
    let button : ScopeButton
    
    //TODO: Refactor, move notificatinos in individual classes
    struct notifications {
        static let measurements = Notification.Name("com.Aeroscope.updateMeasurements")
        static let versions = Notification.Name("com.Aerosocpe.updateVersion")
        static let debug = Notification.Name("com.Aeroscope.updateDebug")
        static let buttonDown = Notification.Name("com.Aeroscope.buttonDown")
        static let error = Notification.Name("com.Aeroscope.error")
    
    }
    
    struct telemBytes {
        static let battH = 0
        static let battL = 1
        static let tempH = 2
        static let tempL = 3
        static let hw = 0
        static let fpga = 1
        static let fw = 2
        static let ser4 = 3
        static let ser3 = 4
        static let ser2 = 5
        static let ser1 = 6
    }
    
    struct telemBits {
        static let chargerConnected = 7
        static let charging = 6
    }

    
    var hwRev : Int = 0
    var fpgaRev : Int = 0
    var fwRev : Int = 0
    var serNum : Int = 0
    
    var debugLog : [String] = []
    
    init(settings: ScopeSettingsInterface) {
        self.settings = settings
        self.button = ScopeButton(settings: settings)

    }
    
    func didConnect() {
    }
    
    func didReconnect() {
    }
    
    func didDisconnect() {
        batt.set(level: nil, chargerConnected: false, charging: false)
    }
    
    
    func didReceive(packet: [UInt8], type: PacketType) {
        if type == .comms {
            print("TELEM PACKET: \(packet)")
            if CChar(packet[0]) == Character("T").ascii! {
                setMeasurements(packet: Array(packet.dropFirst(1)))
            }
            
            else if CChar(packet[0]) == Character("V").ascii {
                setVersions(packet: Array(packet.dropFirst(1)))
            }
            
            else if CChar(packet[0]) == Character("D").ascii {
                setDebugLog(packet: Array(packet.dropFirst(1)))
            }
            
            else if CChar(packet[0]) == Character("B").ascii {
                setButton(packet: Array(packet.dropFirst(1)))
            }
                
            else if CChar(packet[0]) == Character("C").ascii {
                //cal response
            }
            
            else if CChar(packet[0]) == Character("P").ascii {
                setPower(packet: Array(packet.dropFirst(1)))
            }
            
            else if CChar(packet[0]) == Character("E").ascii {
                setError(packet: Array(packet.dropFirst(1)))
            }
        }
    }
    

    
    func setError(packet: [UInt8]) {
        if CChar(packet[0]) == Character("C").ascii {
            if let err = ScopeError(rawValue: packet[1]) {
                let errorDict : [String : ScopeError] = ["error" : err]
                NotificationCenter.default.post(name: notifications.error, object: self, userInfo: errorDict)

            }
        }
        
    }
    
    //TODO: Send this to ScopeConnection
    func setPower(packet: [UInt8]) {
        if CChar(packet[0]) == Character("F").ascii {
            powerDelegate?.didPowerOn()
        }
        else if CChar(packet[0]) == Character("O").ascii  {
            powerDelegate?.didPowerOff()
        }
    }
    
    func setMeasurements(packet: [UInt8]) {
        let chargerConnected = (packet[telemBytes.battH] & UInt8(1 << telemBits.chargerConnected) > 0)
        let charging = (packet[telemBytes.battH] & UInt8(1 << telemBits.charging) > 0)
        let level = Int(bitPattern: (UInt(0x03 & packet[telemBytes.battH]) << 8) + UInt(packet[telemBytes.battL]))
        batt.set(level: level, chargerConnected: chargerConnected, charging: charging)
        
        temp.rawValue = Int(bitPattern: (UInt(packet[telemBytes.tempH]) << 8) + UInt(packet[telemBytes.tempL]))
        NotificationCenter.default.post(name: notifications.measurements, object: self)

    }
    
    func setVersions(packet: [UInt8]) {
        hwRev = Int(bitPattern: UInt(packet[telemBytes.hw]))
        fpgaRev = Int(bitPattern: UInt(packet[telemBytes.fpga]))
        fwRev = Int(bitPattern: UInt(packet[telemBytes.fw]))
        serNum = Int(packet[telemBytes.ser4]) << 24
        serNum += Int(packet[telemBytes.ser3]) << 16
        serNum += Int(packet[telemBytes.ser2]) << 8
        serNum += Int(packet[telemBytes.ser1])
        NotificationCenter.default.post(name: notifications.versions, object: self)

    }
    
    func setDebugLog(packet: [UInt8]) {
        if let debugStr = String(bytes: packet, encoding: String.Encoding.ascii) {
            debugLog.append(debugStr)
            NotificationCenter.default.post(name: notifications.debug, object: self)

        }
        
        if debugLog.count > 50 {
            debugLog = Array(debugLog.dropFirst(debugLog.count - 50))
        }
    }
    
    func setButton(packet: [UInt8]) {
        if CChar(packet[0]) == Character("D").ascii {
            if CChar(packet[1]) != Character("T").ascii {
                button.pressed()
            }
        }
        
        else if CChar(packet[0]) == Character("U").ascii {
            button.released()
        }

    }
    
    @objc func getTelemetry() {
        settings.cmd.reqTelemetry()
    }
    
    func getVersion() {
        settings.cmd.reqVersion()
    }
    
    
    
}
