//
//  ScopeConnection.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 3/7/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation

enum ConnectStatus : Int {
    case disconnected = 0
    case connected
    case poweredOn
}

protocol PowerRequesting {
    func reqPower()
}

protocol Connection {
    var status : ConnectStatus { get }
}

class ScopeConnection : ConnectionDelegate, PowerDelegate, Connection {
    
    let cmd : PowerRequesting
    
    private(set) var status : ConnectStatus = .disconnected
    
    struct notifications {
        static let disconnect = Notification.Name("com.Aeroscope.disconnect")
        static let connect = Notification.Name("come.Aeroscope.connect")
        static let poweredOn = Notification.Name("com.Aeroscope.poweredOn")
    }
    
    init(cmd: PowerRequesting)
    {
        self.cmd = cmd
    }
    
    //Mark: ScopeConnectionDelegate
    //TODO: Add timout to popup error message after 10 seconds
    func didConnect() {
        if status == .disconnected {
            status = .connected
            NotificationCenter.default.post(name: notifications.connect, object: self)
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(connectingTimout), userInfo: nil, repeats: false)
        }

    }
    
    func didReconnect() {
        cmd.reqPower()
    }
    
    func didDisconnect() {
        status = .disconnected
        NotificationCenter.default.post(name: notifications.disconnect, object: self)

    }
    
    //Mark: ScopePowerProtocol
    func didPowerOn() {
        if status == .connected {
            status = .poweredOn
            NotificationCenter.default.post(name: notifications.poweredOn, object: self)

        }
    }
    
    func didPowerOff() {
        if status == .poweredOn {
            status = .connected
        }
    }
    
    @objc func connectingTimout() {
        if status != .poweredOn {
            cmd.reqPower()
        }
    }
    
}
