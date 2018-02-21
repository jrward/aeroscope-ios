//
//  ScopeFrame.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import Foundation

enum FrameType {
    case roll
    case normal
    case full
}

protocol FrameDelegate: class {
    func didReceiveFrame()
    func didReceiveFullFrame()
    func didReceiveRollFrame()
}


class ScopeFrame : PacketDelegate{
    
    struct notifications {
        static let frame = Notification.Name("com.Aeroscope.updateFrame")
        static let fullFrame = Notification.Name("com.Aeroscope.updateFull")
        static let rollFrame = Notification.Name("com.Aeroscope.updateRoll")
    }
    
    var frameDelegate : FrameDelegate?
    var frame : [UInt8] = []
    var frameSize : Int = 0
    var subTrig : Float = 0.0
    
    var paused : Bool = false
    
    var type : FrameType = .normal
    
    fileprivate let maxSubTrig = 63
    fileprivate var _frame : [UInt8] = []
    fileprivate var _type : FrameType = .normal
    fileprivate var _subTrig : Float = 0.0
    fileprivate var _frameSize : Int = 512
 
    let packet_length = 20
    let frame_portion = (1..<20)
    
    
    //TODO: delete interface: from init function. add delegate manually after init
    init(interface: FrameDelegate?) {
        _frame.reserveCapacity(4096)
        frame.reserveCapacity(4096)
        frameDelegate = interface
    }
    
    
    func didReceive(packet: [UInt8], type: PacketType) {
        assert(packet.count == packet_length, "Packet Wrong Size! \(packet.count) : \(packet_length)")
        
        if (packet[0] != 0x00) {    //start of frame
                switch (packet[0]) {
                case 0x01: _frameSize = 16
                case 0x02: _frameSize = 32
                case 0x03: _frameSize = 64
                case 0x04: _frameSize = 128
                case 0x05: _frameSize = 256
                case 0x06: _frameSize = 512
                case 0x07: _frameSize = 1024
                case 0x08: _frameSize = 2048
                case 0x09: _frameSize = 4096
                default: _frameSize = 512 //need to throw error
            }

            _subTrig = Float(packet[1]) / Float(maxSubTrig)
            
            if _frameSize == 16 {
                _type = .roll
                _frame.append(contentsOf: packet[2..<18])
                if _frame.count > 10000 {
                    _frame = Array(_frame[_frame.count - 10000 ..< _frame.count])
                }
                updateFrame()

            }
            
            else {
                _type = _frameSize > 512 ? .full : .normal
                
                _frame.removeAll(keepingCapacity: true)
                _frame.append(contentsOf: packet[2..<20])
            }
        }
            
        else {
            if (_frame.count < _frameSize-19) {
                _frame.append(contentsOf: packet[frame_portion])
            }
            else {
                let frame_remainder = _frameSize - _frame.count
                assert(frame_remainder<=19, "wrong frame remainder size \(frame_remainder)")
                //TODO: Check if frame_remainder is 0
                //CHEAP HACK
                if frame_remainder > 0 {
                    _frame.append(contentsOf: packet[1...frame_remainder])
                    assert(_frame.count == _frameSize, "Wrong Frame Length: \(#file) : \(#line)")
                    updateFrame()
                }
            }
        }
    }
    
    func clearFrame() {
        _frame = []
        _frameSize = 512
        _type = .normal
        _subTrig = 0.0
        updateFrame()
    }
    
    
    func updateFrame()
    {
        if !paused  || _type == .full{
            frame = _frame
            frameSize = _frameSize
            subTrig = _subTrig
            type = _type
            
            if _frameSize > 512 {
                
                frameDelegate?.didReceiveFullFrame()
                NotificationCenter.default.post(name: notifications.fullFrame, object: self)
            }
                
            else if _frameSize == 16 {
                frameDelegate?.didReceiveRollFrame()
                NotificationCenter.default.post(name: notifications.rollFrame, object: self)
            }
            
            else {
                frameDelegate?.didReceiveFrame()
                NotificationCenter.default.post(name: notifications.frame, object: self)
            }
        }
    }
}
