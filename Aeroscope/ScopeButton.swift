//
//  ScopeButton.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 12/2/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class ScopeButton {
    
    let settings: ScopeSettingsInterface
    
    struct notifications {
        static let buttonDown = Notification.Name("com.Aeroscope.buttonDown")
        static let buttonDownLong = Notification.Name("com.Aeroscope.buttonDownLong")
        static let buttonUp = Notification.Name("com.Aeroscope.buttonUp")
    }
    
    //TODO: Temporary, delete and replace with delegate or notifications to scope settings
    
    func pressed() {
        NotificationCenter.default.post(name: notifications.buttonDown, object: self)
        
        
        if settings.cmd.runStopSingle == .stop { settings.setRunState(.run) }
//
        else { settings.setRunState(.stop) }
        
        
    }
    
    func longPressed() {
        
    }
    
    func released() {
        NotificationCenter.default.post(name: notifications.buttonUp, object: self)
    }
    
    init(settings: ScopeSettingsInterface) {
        self.settings = settings
    }
    
    
    
}
