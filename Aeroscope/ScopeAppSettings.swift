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
    
    private let interpolationIdentifier = "interpolationIdentifier"
    private let showPtsIdentifier = "showPtsIdentifier"
    private let fullFrameIdentifier = "fullFrameIdentifier"

    
    struct notifications {
        static let interpolation = Notification.Name("com.Aeroscope.interpolation")
        static let showPts = Notification.Name("com.Aeroscope.showPts")
    }

    
    var interpolation : Bool = true {
        didSet {
            NotificationCenter.default.post(name: notifications.interpolation, object: self)
            UserDefaults.standard.set(String(interpolation), forKey: interpolationIdentifier)
        }
    }
    
    var showPts : Bool = false {
        didSet {
            NotificationCenter.default.post(name: notifications.showPts, object: self)
            UserDefaults.standard.set(String(showPts), forKey: showPtsIdentifier)
        }
    }
    
    var fullFrameDL : Bool = false {
        didSet {
            UserDefaults.standard.set(String(fullFrameDL), forKey: fullFrameIdentifier)

        }
    }
    
    
    init() {
        if let val = UserDefaults.standard.string(forKey: interpolationIdentifier),
            let setting = Bool(val) {
            interpolation = setting
        }
        if let val = UserDefaults.standard.string(forKey: showPtsIdentifier),
            let setting = Bool(val) {
            showPts = setting
        }
        if let val = UserDefaults.standard.string(forKey: fullFrameIdentifier),
            let setting = Bool(val) {
            fullFrameDL = setting
        }
    }
    
    
}
