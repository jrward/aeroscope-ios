//
//  ScopeTemp.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 12/1/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class ScopeTemp {
    
    struct notifications {
        static let update = Notification.Name("com.Aeroscope.tempUpdate")
        static let overLimit = Notification.Name("com.Aeroscope.tempOver")
        static let underLimit = Notification.Name("com.Aeroscope.tempUnder")

    }
    
    struct limits {
        static let over = 450
        static let under = 50
    }
    
    var celsius : Double? {
        get {
            if rawValue != nil { return Double(rawValue!) / 10.0 }
            else { return nil }
        }
    }
    
    var rawValue : Int? = 0 {
        didSet {
            if rawValue != nil, rawValue != oldValue {
                NotificationCenter.default.post(name: notifications.update, object: self)
            }
            if let temp = rawValue, temp > limits.over {
                NotificationCenter.default.post(name: notifications.overLimit, object: self)
            }
            else if let temp = rawValue, temp < limits.under {
                NotificationCenter.default.post(name: notifications.underLimit, object: self)
            }
        }
    }
    
}
