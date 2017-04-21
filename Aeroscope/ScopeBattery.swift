//
//  ScopeBattery.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 12/1/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class ScopeBattery {
    
    struct notifications {
        static let update = Notification.Name("com.Aeroscope.batteryUpdate")
        static let low = Notification.Name("com.Aeroscope.batteryLow")
        static let dead = Notification.Name("com.Aeroscope.batteryDead")
    }
    
    
    private static let k =  1062.5/(5+12.4)
    
    private struct BattLevel {
        static let full = Int(k * 3.9) //238
        static let mid = Int(k * 3.7)  //226
        static let low = Int(k * 3.6)  //220
        static let dead = 0
    }

    enum BattState {
        case fullyCharged
        case full
        case mid
        case low
        case dead
        case unknown
    }
    
    private(set) var level : Int? = nil
    
    private(set) var charging = false
    private(set) var chargerConnected = false
    private(set) var state = BattState.unknown
  
    func set(level: Int?, chargerConnected: Bool, charging: Bool) {
        self.charging = charging
        self.chargerConnected = chargerConnected
        self.level = level
        
        if let battLevel = level {
            if battLevel >= BattLevel.full && self.chargerConnected && !self.charging {
                state = .fullyCharged
            }
            else if battLevel >= BattLevel.full {
                state = .full
            }
                
            else if battLevel >= BattLevel.mid {
                state = .mid
            }
                
            else if battLevel >= BattLevel.low {
                state = .low
            }
                
            else {
                state = .dead
                NotificationCenter.default.post(name: notifications.dead, object: self)
            }
        }
        
        else {
            state = .unknown
        }
        
        NotificationCenter.default.post(name: notifications.update, object: self)
    }
    


    
    
    
}
