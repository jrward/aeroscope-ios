 //
//  ScopeModel.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/11/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

//let scope = Scope.scope
 
 enum RunState {
    case run
    case stop
    case single
 }

 class Scope : ConnectionDelegate, PacketDelegate, PowerDelegate {
    let settings : ScopeSettingsInterface
    let appSettings : ScopeAppSettings
    let frame : ScopeFrameInterface
    let telemetry : ScopeTelemetry
    let comms : ScopeComms
    let connection : ScopeConnection
    let measure : ScopeMeasurementCenter
    
    
    var runState : RunState {
        get {
            return settings.getRunState()
        }
    }
        
    static var globalTintColor = UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0)
    
    static let sharedInstance = Scope()
    
    init() {
        comms = ScopeComms()

        appSettings = ScopeAppSettings()
        settings = ScopeSettingsInterface(comms: comms, appSettings: appSettings)
        frame = ScopeFrameInterface(settings: settings, appSettings: appSettings)
        settings.frame = frame
        telemetry = ScopeTelemetry(settings: settings)
        connection = ScopeConnection(cmd: settings.cmd)
        measure = ScopeMeasurementCenter(settings: settings, frame: frame)
        comms.packetDelegate = self
        comms.connectionDelegate = self
        telemetry.powerDelegate = self

    }
    
    func updateSettings() {

        settings.updateSettings()
    }
    
    //Mark: PowerDelegate
    
    func didPowerOn() {
        connection.didPowerOn()
        telemetry.getTelemetry()
        settings.pushSettings()
        settings.updateRunState()
    }
    
    func didPowerOff() {
        connection.didPowerOff()
    }
    
    //Mark: ConnectionDelegate
    func didConnect() {
        connection.didConnect()
        telemetry.didConnect()
    }
    
    func didReconnect() {
        connection.didReconnect()
    }
    
    func didDisconnect() {
        telemetry.didDisconnect()
        connection.didDisconnect()
    }
    
    //Mark: PacketDelegate
    func didReceive(packet: [UInt8], type: PacketType) {
        switch type {
        case .comms: telemetry.didReceive(packet: packet, type: type)
        case .data: frame.frame.didReceive(packet: packet, type: type)
        case .fpga: break
        }
    }
    
}
