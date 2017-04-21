//
//  ScopeAppSettings.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 7/11/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

protocol AppSettingsReader {
    var interpolation : Bool {get}
    var showPts : Bool {get}
    var fullFrameDL : Bool {get}
}

class ScopeAppSettings : AppSettingsReader {
    
    struct notifications {
        static let interpolation = Notification.Name("com.Aeroscope.interpolation")
        static let showPts = Notification.Name("com.Aeroscope.showPts")
    }

    
    var interpolation : Bool = true {
        didSet {
            NotificationCenter.default.post(name: notifications.interpolation, object: self)
        }
    }
    
    var showPts : Bool = false {
        didSet {
            NotificationCenter.default.post(name: notifications.showPts, object: self)
        }
    }
    
    var fullFrameDL : Bool = false
    
    
}
