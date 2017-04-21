//
//  ScopeFrame.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import Foundation

enum scopeDataType {
    case live
    case full
}

protocol FrameInterfaceDelegate: class {
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
    
    var frameInterfaceDelegate : FrameInterfaceDelegate?
    var frame : [UInt8] = []
    var frameSize : Int = 0
    var subTrig : Float = 0.0
    
    var rollFrame : Bool = false
    
//    var drawnSize : Float //size of frame to be displayed
//    var drawnLoc : Float //offset from front of
       // var translation : Float //data translation in X
    
    fileprivate let maxSubTrig = 63
    fileprivate var _frame : [UInt8] = []
    fileprivate var _rollFrame : Bool = false
    
    fileprivate var _subTrig : Float = 0.0
    
//    var offset : Int = 0                //vertical offset in Y
//    var subFrameSize : Int = 500          //number of points to be displayed on screen
//    var subFramePosition : Int = 6      //subFrame offset location referenced to front of frame
//
    
    fileprivate var _frameSize : Int = 512
    
//        didSet {
////            _frame.removeAll(keepCapacity: true)
//            //myframe.reserveCapacity(frame_size)
//            //frame.removeAll(keepCapacity: false)
//            //frame.reserveCapacity(frame_size)
//        }
    
    
    let packet_length = 20
    let frame_portion = (1..<20)
    
    
    //TODO: delete interface: from init function. add delegate manually after init
    init(interface: FrameInterfaceDelegate?) {
        //frame = [UInt8](count: frameSize, repeatedValue: 175)
        //myframe = [UInt8](count: frameSize, repeatedValue: 0)
        
        _frame.reserveCapacity(4096)
        frame.reserveCapacity(4096)
        frameInterfaceDelegate = interface
        
//        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(testFrame), userInfo: nil, repeats: false)
        

        
    }
    
    @objc func testFrame() {
        _frameSize = 512
        _subTrig = 0
        _rollFrame = false
        _frame = [127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 127, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200]
        
        updateFrame()
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
                _rollFrame = true
                _frame.append(contentsOf: packet[2..<18])
                if _frame.count > 10000 {
                    _frame = Array(_frame[_frame.count - 10000 ..< _frame.count])
                }
                updateFrame()

            }
            
            else {
                _rollFrame = false
                _frame.removeAll(keepingCapacity: true)
                //_frame.appendContentsOf(packet[frame_portion])
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
        _rollFrame = false
        _subTrig = 0.0
        updateFrame()
    }
    
    
    func updateFrame()
    {
        frame = _frame
        frameSize = _frameSize
        subTrig = _subTrig
        rollFrame = _rollFrame
        //_frame.removeAll(keepCapacity: true)
        
        if _frameSize == 4096 {
            
            frameInterfaceDelegate?.didReceiveFullFrame()
            NotificationCenter.default.post(name: notifications.fullFrame, object: self)
        }
            
        else if _frameSize == 16 {
            frameInterfaceDelegate?.didReceiveRollFrame()
            NotificationCenter.default.post(name: notifications.rollFrame, object: self)
        }
        
        else {
            frameInterfaceDelegate?.didReceiveFrame()
            NotificationCenter.default.post(name: notifications.frame, object: self)
        }
    }
}
