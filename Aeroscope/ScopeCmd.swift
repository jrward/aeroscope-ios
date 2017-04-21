//
//  ScopeCmd.swift
//  Aeroscope Lite
//
//  Created by Jonathan Ward on 11/16/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class ScopeCmd : PowerRequesting {
    
    var comms: ScopeComms
    
    var appSettings : AppSettingsReader
    
    var cancelFrameTimer : Timer?
    
    struct notifications {
        static let runState = Notification.Name("com.Aeroscope.runState")
    }
    
    
    var runStopSingle : RunState {
        didSet {
            switch runStopSingle {
            case .run:
                run()
            case .stop:
                stop()
            case .single:
                if oldValue == .run {
                    softStop()
                }
                else {
                    singleFrame()
                }
            }
            
            NotificationCenter.default.post(name: notifications.runState, object: self)
        }
    }
    
    
    func run() {
        send(cmd: "R")
        cancelFrameTimer?.invalidate()
    }
    
    func softStop() {
        send(cmd: "S")
    }
    
    func stop() {
        send(cmd: "S")

        if appSettings.fullFrameDL {
            reqFullFrame()
            cancelFrameTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(cancelFrame), userInfo: nil, repeats: false)
        }
        else {
            cancelFrame()
        }
    }
    
    func singleFrame() {
        send(cmd: "F")
        cancelFrameTimer?.invalidate()
    }
    
    func reqFullFrame() {
        send(cmd: "L")
        cancelFrameTimer?.invalidate()
    }
    
    func reqVersion() {
        send(cmd: "QVR")
    }
    
    func reqTelemetry() {
        send(cmd: "QTR")
    }
    
    func reqPower() {
        send(cmd: "QP")
    }
    
    func reqFullCal() {
        send(cmd: "CF")
    }
    
    @objc func cancelFrame() {
        send(cmd: "X")
    }
    
    
    func clearCal() {
        send(cmd: "CX")
    }
    
    func set(name: String) {
        send(cmd: "N".appending(name))
    }
    
    func deepSleep() {
        send(cmd: "ZZ")
    }
    
    func reset() {
        send(cmd: "ZR")
    }
    
    func powerOn() {
        send(cmd: "PF")
    }
    
    func didReceive(packet: [UInt8]) {
    
        
    }
    
    private func send(cmd: String) {
        var packet = [UInt8](cmd.utf8)
        packet = addPaddingTo(packet: packet)
        comms.sendCpu(packet)
    }
    
    private func addPaddingTo(packet: [UInt8]) -> [UInt8] {
        //assert(packet.count <= 20)
        if (packet.count <= 20) {
            let paddingSize = comms.commsOutCharLength - packet.count
            return packet + [UInt8](repeating: 0, count: paddingSize)
        }
        
        else {
            return Array(packet[0..<20])
        }

    }
    
    
    init(comms: ScopeComms, appSettings: AppSettingsReader) {
        self.comms = comms
        self.appSettings = appSettings
        runStopSingle = .stop
        

    }
    
    
    
}
