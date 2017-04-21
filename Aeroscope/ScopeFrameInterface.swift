//
//  ScopeFrameInterface.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 5/12/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

//import UIKit
import Foundation

//protocol FrameSettingsReader {
//    func getSubFrameSize() -> Int
//    func getTrigMemPos() -> Int
//    func getWindowPos() -> Int
//    func getRunState() -> RunState
//    func getStoppedWindowPos() -> Int
//    func getStoppedTrigMemPos() -> Int
//}

typealias frameData = (frame: Samples, frameSize: Int, xPos: Int, subTrig: Float)


class SubFrame {
    
}

class ScopeFrameInterface: FrameInterfaceDelegate, FrameSettingsDelegate {
    
    struct notifications {
        static let updateSubFrame = Notification.Name("com.Aeroscope.updateSubFrame")
    }
    
    var scopeFrame : ScopeFrame!
    fileprivate var frameInterpolator = ScopeFrameInterpolator()
    
    
//    let settings : ScopeSettingsInterface
    var settings : ScopeSettingsInterface// Scope.sharedInstance.settings
    var appSettings : AppSettingsReader!// Scope.sharedInstance.appSettings

    var offset : Int = 0
   // var subFrameSize: Int = 500
    var subFramePosition: Int = 6
//        didSet {
//            NotificationCenter.default.post(name: notifications.updateSubFramePos, object: self)
//        }
    
    
//    var subFrameSize : Int = 500
//    var subFramePosition : Int
    
    //windowPosition = stoppedWindowPosition + subFramePosition - subFrameOffset
    var stoppedSubFramePosition: Int = 6
    let displayedFrameSize = 500
    
    //xScale and yScale are as follows:
    //Bigger numbers : zoomed out
    //Smaller numbers : zoomed in
    private(set) var xScale : Float = 1.0
    var yScale : Float = 1.0
    

    init(settings: ScopeSettingsInterface, appSettings: AppSettingsReader)
    {
        self.settings = settings
        self.settings.frameSettingsDelegate = self
        self.appSettings = appSettings
        self.scopeFrame = ScopeFrame(interface: self)
        //self.scopeFrame.frameDelegate = self

    }
    
    func clearTrace() {
        scopeFrame.clearFrame()
    }
    
    func getRawFrame() -> [UInt8] {
        return scopeFrame.frame
    }
    
    func getFrameSize() -> Int {
        return scopeFrame.frameSize
    }
    
    func getSubTrig() -> Float {
        return scopeFrame.subTrig
    }
    
 /*   func getScaledTrigXPos() -> Int {
        let trigXPos = settings.getTrigMemPos()
        let windowPos : Int
        let subFrameSize = getScaledSubFrameSize()
        let subFramePos = getScaledSubFramePos()
        
        if settings.getRunState() == .stop {
            windowPos = settings.getStoppedWindowPos()
        }
        else {
            windowPos = settings.getWindowPos()
        }
        
        let trigDiff = trigXPos - (windowPos + getScaledSubFramePos() + getScaledSubFrameSize()/2)
        
        
    }*/
    
    func getScaledSubFrameSize() -> Int {
        if settings.getRunState() == .stop {
            if xScale < 1.0 {
                return Int(ceil(Float(settings.getSubFrameSize()) * xScale))
            }
            else if xScale >= 1.0 {
                //return min(Int(ceil(Float(settings.getStoppedSubFrameSize()) * xScale)),displayedFrameSize)
                return settings.getSubFrameSize()
            }
        }
        
        //else {
            return settings.getSubFrameSize()
       // }
        
    }
//    
//    let subFrameMid = subFramePosition + (settings.getStoppedSubFrameSize()/2)
//    let scaledSubFrameSize = max(Int(round(Float(settings.getStoppedSubFrameSize()) * xScale)),1)
//    let scaledSubFramePos = subFrameMid - Int(round(Float(settings.getStoppedSubFrameSize()) * xScale/2.0))
    
    func getScaledSubFramePos() -> Int {
        if xScale < 1.0 {
            let subFrameSize = settings.getSubFrameSize()
            let subFrameMid = subFramePosition + subFrameSize/2
            let scaledSubFramePos = subFrameMid - Int(round(Float(subFrameSize)*xScale/2))
            return scaledSubFramePos
        }
        else if xScale > 1.0 {
//            subFrameMid = subFramePosition + (settings.getSubFrameSize()/2)
//            scaledSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()) * xScale)),1)
//            scaledSubFramePos = subFrameMid - Int(round(Float(settings.getSubFrameSize()) * xScale/2.0))
            
            let subFrameSize = settings.getSubFrameSize()
            let windowPos = settings.getStoppedWindowPos()
            let subFrameMidMem = windowPos + subFramePosition + subFrameSize/2
            let trigPos = settings.getStoppedTrigMemPos()
            let trigDiff =  subFrameMidMem - trigPos
            
            //TODO: replace this with current subframe pos that is set to this
            //value previously
            return subFramePosition - Int(Float(trigDiff)*(1-1/xScale))
        }
            
        else {
            return subFramePosition
        }
        
    }
    
    func getScaledFramePos() -> Int {
        let windowPos : Int
        if settings.getRunState() == .stop {
//            if scopeFrame.frameSize == 4096 {
//                windowPos = getScaledSubFramePos()
//            }
//            else {
                windowPos = settings.getStoppedWindowPos() + getScaledSubFramePos()
//            }
        }
        else {
            windowPos = settings.getWindowPos() + subFramePosition
        }
        
        return windowPos
    }

    
    func getScaledTracePos() -> Int {
        if settings.getRunState() != .stop{
            return settings.getWindowPos()
        }
        else if xScale > 1.0 {
            let trigPos = settings.getStoppedTrigMemPos()
            let tracePos = settings.getStoppedWindowPos()
            let newPos = Int(ceil(Float(tracePos - trigPos)) / xScale) + trigPos
            return newPos
        }
            
        else {
                return settings.getStoppedWindowPos()
        }
    }
    
    func getScaledTraceSize() -> Int {
        if xScale > 1.0 {
            let newSize = Int(ceil(Float(scopeFrame.frameSize) / xScale))
            if newSize == 0 {
                return 1
            }
            else {
                return newSize
            }
        }
        else {
            return scopeFrame.frameSize
        }
    }
    
    func getDisplayedFrame() ->  frameData? {
        
        let myFrame = scopeFrame.frame
        let rollFrame = scopeFrame.rollFrame
        var returnedFrame = Samples()//[Float]() //frame may be interpolated or not
       // var samples = [Float]() //Just the original samples with offsets but no interpolation
        let xPos : Int
        let frameStartIndex : Int
        var subTrig = scopeFrame.subTrig
        let frameSize : Int
        
        //Convert to Float
        //TODO: Refactor
        
        
//        for el in myFrame {
//            returnedFrame.append(Float(max(min(Int(el) + offset, 255),0)))
//        }
        
        if rollFrame {
            frameSize = self.displayedFrameSize
            let frameOverrun : Int = frameSize - myFrame.count
            xPos = max(frameOverrun, 0)
            subTrig = 0.5
            if frameOverrun < 0 {
                let absFrameOverrun = abs(frameOverrun)
                let myFrameFloat = myFrame.suffix(from: absFrameOverrun).map { (el) in Float(el) }
                returnedFrame = Samples(rawData: myFrameFloat)
            }
            return (frame: returnedFrame, frameSize: frameSize, xPos: xPos, subTrig: subTrig)
        }
        
        else {
            let subFrameMid : Int
            let scaledSubFrameSize : Int
            let scaledSubFramePos : Int
            
            if (settings.getRunState() == .stop) {
                subFrameMid = subFramePosition + (settings.getSubFrameSize()/2)
                scaledSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()) * xScale)),1)
                scaledSubFramePos = subFrameMid - Int(round(Float(settings.getSubFrameSize()) * xScale/2.0))
            }
            else {
                subFrameMid = subFramePosition + (settings.getSubFrameSize()/2)
                scaledSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()) * xScale)),1)
                scaledSubFramePos = subFrameMid - Int(round(Float(settings.getSubFrameSize()) * xScale/2.0))
                
            }
            
            //if self.subFramePosition < 0 {
            if scaledSubFramePos < 0 {

                //xPos =  abs(self.subFramePosition)
                xPos =  abs(scaledSubFramePos)

                frameStartIndex = 0
            }
            else {
                xPos = 0
                //frameStartIndex = max(min(abs(self.subFramePosition), scopeFrame.frameSize),0)
                frameStartIndex = max(min(abs(scaledSubFramePos), scopeFrame.frameSize),0)

            }
            
            let maxIndex : Int = min(scaledSubFrameSize + frameStartIndex, myFrame.count)
            
            
            if maxIndex == 0 || frameStartIndex == maxIndex {
                //No frame to return
                return nil
               
            }
                
            
            else {
                
                returnedFrame = Samples(rawData: myFrame[frameStartIndex ..< maxIndex].map { (el) in Float(el) * yScale })
                
                
                
                if (appSettings.interpolation && settings.getRunState() != .stop && settings.getSubFrameSize() < displayedFrameSize) ||
                    (appSettings.interpolation && settings.getRunState() == .stop && settings.getStoppedHorizMeta().divRatio <= 1 && settings.getSubFrameSize() < displayedFrameSize) {
                    
                    let factor = Int(displayedFrameSize/self.settings.getSubFrameSize())
                    let interpFactor :  InterpFactor
                    
                    switch factor {
                    case 2: interpFactor = .x2
                    case 5: interpFactor = .x5
                    case 10: interpFactor = .x10
                    case 20: interpFactor = .x20
                    default: interpFactor = .x1
                    }
                    returnedFrame = frameInterpolator.interpolate(returnedFrame, factor: interpFactor)
                    frameSize = displayedFrameSize
                    subTrig = subTrig * Float(factor)

                }
                
                else {
                    frameSize = max(Int(Float(self.settings.getSubFrameSize()) * xScale), 1)
                    subTrig = subTrig * xScale
                }
                
                
                //clip final returned frame
                returnedFrame.addOffset(Float(offset))
                returnedFrame.clipToBounds()
                //returnedFrame = returnedFrame.data.map{ (el) in Float(max(min(Int(el.value) + offset, 255),0)) }
                
                //print("myFrame.count: \(myFrame.count) frameXOffset: \(frameXOffset)  maxIndex: \(maxIndex)   xPos: \(xPos)   subTrig: \(subTrig)")
                
                return (frame: returnedFrame, frameSize: frameSize, xPos: xPos, subTrig: subTrig)
            }
        }
    }
    
//    func zoomX() {
//        xScale = Float(settings.getHorizMeta().divRatio) / Float(settings.getStoppedHorizMeta().divRatio)
//        let scaledWindowPos = Int(Float(settings.getWindowPos()) * xScale)
//        let scaledStoppedFramePos = Int(Float(stoppedSubFramePosition) * xScale)
//        let stoppedWindowPos = settings.getStoppedWindowPos()
//        let scaledSubFrameSize =
//        subFramePosition = (scaledWindowPos - stoppedWindowPos) + (scaledStoppedFramePos)
//
//    }
    
    func zoomY(_ amount: Float) {
        
    }
    
    
    func incrementSubFramePos(delta: Float) -> Float {
//        let maxPos = settings.getWindowPosMax() + scopeFrame.frameSize - settings.getSubFrameSize() - settings.getWindowPos()
//        let minPos =  -1 * settings.getWindowPos()
        
        let intDelta = Int(round(delta * xScale))
        let scopeStopped = settings.getRunState() == .stop
        let subFrameWinMid : Int
        
        if scopeStopped {
            self.setSubFramePos(Float(self.subFramePosition + intDelta))
            subFrameWinMid = settings.getStoppedWindowPos() + subFramePosition + settings.getSubFrameSize()/2
        }
        else {
            subFrameWinMid = settings.getWindowPos() + subFramePosition + settings.getSubFrameSize()/2
        }
    
        let windowMax = settings.getWindowPosMax()
        let windowMin = settings.getWindowPosMin()
        let windowMid = settings.getWindowPos() + settings.getReadDepth()/2
        let winDelta =  subFrameWinMid - windowMid
        
       // getScaledSubFramePos()
        
        if (scopeStopped) {
            settings.setWindowPos(max(min(settings.getWindowPos() + Int(round(delta)), windowMax), windowMin))
        }
        else {
            settings.setWindowPos(max(min(settings.getWindowPos() + Int(round(delta)), windowMax), windowMin))
        }

    
        //return Float(intDelta) - (delta*xScale)
        return (Float(round(delta)) - delta)/xScale
    }
    
    func setSubFramePos(_ position: Float) {
        let windowPos : Int
        if settings.getRunState() == .stop {
            windowPos = settings.getStoppedWindowPos()
        }
        else {
            windowPos = settings.getWindowPos()
        }
        
        let maxPos = settings.getWriteDepth() - windowPos - Int(Float(settings.getSubFrameSize())/2)

        let minPos =  -1 * windowPos - Int(Float(settings.getSubFrameSize())/2)

        //let maxPos = settings.getWriteDepth()
        //let minPos = 0
        var newPosition = Int(position)
        
        if newPosition > maxPos {
            newPosition = maxPos
            print("*******MAX SUBFRAME HIT******")
        }
        else if newPosition < minPos {
            newPosition = minPos
            print("*******MIN SUBFRAME HIT******")
        }
        subFramePosition = newPosition
        
        NotificationCenter.default.post(name: notifications.updateSubFrame, object: self)

    }
    
    func setSubFramePosToCenter() {
        if settings.getRunState() == .stop {
            let subFramePosAbs = settings.getStoppedWindowPos() + subFramePosition
            let frameMid = settings.getWriteDepth()/2 - settings.getSubFrameSize()/2
            
            let diff = frameMid - subFramePosAbs
            
            setSubFramePos(Float(subFramePosition + diff))
        }
 
        
//        let currSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()))),1)
//        setSubFramePos(Float(scopeFrame.frameSize/2) - Float(currSubFrameSize/2) )
        //((Float(scopeFrame.frameSize) - (Float(currSubFrameSize)*xScale)) / 2.0)
        //subFramePosition = (scopeFrame.frameSize - Int(Float(currSubFrameSize)*xScale)) / 2
    }
    
    //increment offset by delta and return leftover
    func incrementOffset(delta: Float) -> Float {
     
        return 0.0
    }
    
    func setOffset(_: Float) {
        
    }
    
    
    func resetFrameMeta()
    {
        offset = 0
        xScale = 1.0
        yScale = 1.0
        //subFrameSize = settings.getSubFrameSize()
        stoppedSubFramePosition = subFramePosition

    }

    func didReceiveFrame() {
        resetFrameMeta()
        setSubFramePos(Float(scopeFrame.frameSize - settings.getSubFrameSize()) / 2)
        if settings.getRunState() == .single  {
            settings.setRunState(.stop)
        }
    }
    
    func didReceiveFullFrame() {
        resetFrameMeta()
        settings.setCurrFrameToFullFrame()

        setSubFramePos(Float(settings.getWindowPos() + subFramePosition))
    }
    
    func didReceiveRollFrame() {
        resetFrameMeta()
        setSubFramePos(Float(settings.getWindowPos() + 6))
    }
    
    func didChangeHoriz(oldValue: horiz_mapping) {
        let oldSubFrameSize = oldValue.subFrameSize
        let currSubFrameSize = settings.getSubFrameSize()
        
        if (settings.getRunState() == .stop) {
            let xScaleOld = xScale
            
//            xScale =  Float((Double(settings.getHorizMeta().subFrameSize) / Double(settings.getStoppedHorizMeta().divRatio)) /  (Double(settings.getStoppedHorizMeta().subFrameSize) / Double(settings.getHorizMeta().divRatio)))
            
            xScale = Float (Double(settings.getHorizMeta().divRatio) / Double(settings.getStoppedHorizMeta().divRatio))
            
//            if oldSubFrameSize != currSubFrameSize {
//                //subFramePosition += (scopeFrame.frameSize - (oldValue - currSubFrameSize)) / 2
//                setSubFramePos(Float(subFramePosition + oldSubFrameSize/2 - currSubFrameSize/2))
//            }
            
           
            let frameSize = settings.getReadDepth()
            let windowPos = settings.getWindowPos()
            let windowMid = windowPos + frameSize/2
            let trigPos = settings.getTrigMemPos()
            let trigDiff =  windowMid - trigPos
            
                //TODO: replace this with current subframe pos that is set to this
                //value previously
//                 settings.setWindowPos(windowPos - Int(round(Float(trigDiff)*(1-1/xScale))))
            //settings.setWindowPos(windowPos + Int(round(Float(trigDiff)*(1/xScale))))
            

        }
        
//        else {
            let tempXScale = Float (Double(settings.getHorizMeta().divRatio) / Double(oldValue.divRatio))
            
            
            
            let frameSize = settings.getReadDepth()
            let windowPos = settings.getWindowPos()
            let windowMid = windowPos + frameSize/2
            let trigPos = settings.getTrigMemPos()
            let trigDiff =  windowMid - trigPos
            
            //TODO: replace this with current subframe pos that is set to this
            //value previously
            settings.setWindowPos(windowPos - Int(round(Float(trigDiff)*(1-1/tempXScale))))
            
            if oldSubFrameSize != currSubFrameSize {
                //subFramePosition += (scopeFrame.frameSize - (oldValue - currSubFrameSize)) / 2
                setSubFramePos(Float(subFramePosition + oldSubFrameSize/2 - currSubFrameSize/2))
            }
            
            NotificationCenter.default.post(name: notifications.updateSubFrame, object: self)
//        }
        
    }
    func didChangeVert() {
        
    }

    

}
