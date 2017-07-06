//
//  ScopeMessage.swift
//  Aeroscope
//
//  Created by Jonathan Ward on 7/3/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation

class ScopeMessage {
    
    struct notifications {
        static let messageChanged = Notification.Name("com.Aeroscope.messageChanged")
    }
    
    var message : String? = nil
    let defaultTime : Double = 3.0
    
    static var _default = ScopeMessage()
    
    class var `default` : ScopeMessage {
        get {
            return _default
        }
    }
    
    func set(message: String) {
        set(message: message, time: defaultTime)
    }
    
    func set(message: String, time: Double) {
        self.message = message
        Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(clear), userInfo: nil, repeats: false)
        NotificationCenter.default.post(name: notifications.messageChanged, object: self)
    }
    
    @objc func clear() {
        message = nil
        NotificationCenter.default.post(name: notifications.messageChanged, object: self)
    }
    
    
}
