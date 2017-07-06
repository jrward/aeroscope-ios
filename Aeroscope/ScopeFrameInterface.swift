//
//  ScopeFrameInterface.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 5/12/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

//import UIKit
import Foundation


typealias frameData = (frame: Samples, frameSize: Int, xPos: Int, subTrig: Float)


class ScopeFrameInterface: FrameDelegate, FrameSettingsDelegate {
    
    struct notifications {
        static let updateSubFrame = Notification.Name("com.Aeroscope.updateSubFrame")
    }
    
    var frame : ScopeFrame!
    private(set) var frameSettings: ScopeSettings!
    
    private var frameInterpolator = ScopeFrameInterpolator()
    
//    let settings : ScopeSettingsInterface
    var settings : ScopeSettingsInterface
    var appSettings : AppSettingsReader!

    let displayedFrameSize = 500
        
    //offset from center of frame
    
    private(set) var yOffset : Int = 0 {
        didSet {
//            print("yOffset: \(yOffset)")
            subFrameDidUpdate()
        }
    }
    //xOffset is offset we need to apply to captured frame to
    //match the current capture settings
    private(set) var xOffset: Int = 0 {
        didSet {
            subFrameDidUpdate()
        }
    }

    
    //xScale and yScale are as follows:
    //Bigger numbers : zoomed out
    //Smaller numbers : zoomed in
    private(set) var xScale : Float = 1.0 {
        didSet {
//            print("xScale: \(xScale)")
            subFrameDidUpdate()
        }
    }
    private(set) var yScale : Float = 1.0 {
        didSet {
//            print("yScale: \(yScale)")
            subFrameDidUpdate()
        }
    }
    

    
    
    func incrementXOffset(_ delta: Int) {
        xOffset = min(max(xOffset + delta, -frameSettings.window_pos.value - frameSettings.readDepth.value/2), frameSettings.window_pos.range.upperBound - 1 - frameSettings.window_pos.value + frameSettings.readDepth.value/2)

    }
    

    init(settings: ScopeSettingsInterface, appSettings: AppSettingsReader)
    {
        self.settings = settings
        self.frameSettings = settings.nextFrameSettings.copy()
        self.settings.frameSettingsDelegate = self
        self.appSettings = appSettings
        self.frame = ScopeFrame(interface: self)
        //self.scopeFrame.frameDelegate = self

    }
    
    func isPaused() -> Bool {
        return frame.paused
    }
    
    func pause() {
        frame.paused = true
    }
    
    func resume() {
        frame.paused = false
    }
    
    func clearTrace() {
        frame.clearFrame()
    }
    
    func getRawFrame() -> [UInt8] {
        return frame.frame
    }
    
    func getFrameSize() -> Int {
        return frame.frameSize
    }
    
    func getSubTrig() -> Float {
        return frame.subTrig
    }
    
    func subFrameDidUpdate() {
        NotificationCenter.default.post(name: notifications.updateSubFrame, object: self)
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

        return Int(ceil(Float(displayedFrameSize) * xScale))
        
    }

    //returns start index of subframe in frame reference
    func getScaledSubFrameStart() -> Int {
        let subFrameSize = displayedFrameSize
        let frameSize = frameSettings.readDepth.value
        let subFrameMid = xOffset + frameSize/2
        let subFrameStart = subFrameMid - Int(round(Float(subFrameSize)*xScale/2))
  
        return subFrameStart
    }
    
    func getScaledSubFrameMid() -> Int {
        let frameSize = frameSettings.readDepth.value
        let subFrameMid = xOffset + frameSize/2
        return subFrameMid
    }
    
    func getSubFrameMidInMemCoords() -> Int {
        return frameSettings.window_pos.value + getScaledSubFrameMid()
    }
    
    //****************************************
    //MARK: - Strip View Functions
    func getScaledFrameSize() -> Int {
        //should frame representation be modified in viewcontroller?
        //zoomed in, window size is smaller
        if xScale < 1.0 {
            return Int(ceil(Float(displayedFrameSize) * xScale))
        }
        
        else {
            return displayedFrameSize
        }
    }
    
    func getScaledOffset() -> Int {
        if xScale > 1.0 {
            return Int(ceil(Float(xOffset) * (1/xScale)))
        }
            
        else {
            return xOffset
        }
    }
    
    //start index of subframe in scope memory reference
    func getScaledFrameStart() -> Int {
//        if frame.type == .full {
//            let subFrameMid = frameSettings.window_pos.value + getScaledOffset() + frameSettings.readDepth.value/2
//            return subFrameMid - getScaledFrameSize()/2
//
//            //return frame.frameSize/2 + xOffset - getScaledFrameSize()/2
//        }
//        else {
        
       // }
        
        if xScale > 1.0 {
            let trigPos = frameSettings.trigger_x_pos.value //settings.getTrigMemPos()
            let tracePos = frameSettings.window_pos.value
            let newPos = Int(ceil(Float(tracePos - trigPos)) / xScale) + trigPos
            return newPos + Int(round(Float(frameSettings.readDepth.value) / xScale))/2 +
                getScaledOffset() - getScaledFrameSize()/2
        }
        else {
            return frameSettings.window_pos.value + frameSettings.readDepth.value/2
                + getScaledOffset() - getScaledFrameSize()/2
        }
    }
    
    func getScaledTraceSize() -> Int {
        
        if xScale <= 1.0 {
            //return frameSettings.readDepth.value
            return frame.frameSize
        }
            
        //zoomed out, size is smaller
        else {
            let newSize = Int(round(Float(frame.frameSize) / xScale))
            if newSize == 0 {
                return 1
            }
            else {
                return newSize
            }
        }
        
    }
    
    //start index of frame in scope memory reference
    func getScaledTraceStart() -> Int {
        let tracePos : Int
    
        if frame.type == .full {
            tracePos = 0
        }
        else {
            tracePos = frameSettings.window_pos.value
        }
        
        if xScale > 1.0 {
            let trigPos = frameSettings.trigger_x_pos.value//settings.getTrigMemPos()
//            let tracePos = frameSettings.window_pos.value
            let newPos = Int(ceil(Float(tracePos - trigPos)) / xScale) + trigPos
            return newPos
        }
        
        else {
            return tracePos + frame.frameSize/2 - getScaledTraceSize()/2

        }
//        if frame.type == .full {
//            return frame.frameSize/2 - getScaledTraceSize()/2
//        }
//        else {
//            return frameSettings.window_pos.value + frame.frameSize/2 - getScaledTraceSize()/2
//        }
    }
    

    //MARK: -
    //****************************************
    
    func getDisplayedFrame() ->  frameData? {
        
        let myFrame = frame.frame
        let frameType = frame.type
        var returnedFrame = Samples()//[Float]() //frame may be interpolated or not
       // var samples = [Float]() //Just the original samples with offsets but no interpolation
        let xPos : Int
        let frameStartIndex : Int
        var subTrig = frame.subTrig
        let frameSize : Int
        
        //Convert to Float
        //TODO: Refactor
        
        
//        for el in myFrame {
//            returnedFrame.append(Float(max(min(Int(el) + offset, 255),0)))
//        }
        
        if frameType == .roll {
            frameSize = self.displayedFrameSize
            let frameOverrun : Int = frameSize - myFrame.count
            xPos = max(frameOverrun, 0)
            subTrig = 0.0
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
            
//            if (settings.getRunState() == .stop) {
//                subFrameMid = xOffset + (settings.getSubFrameSize()/2)
//                scaledSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()) * xScale)),1)
//                scaledSubFramePos = subFrameMid - Int(round(Float(settings.getSubFrameSize()) * xScale/2.0))
//            }
//            else {
//                subFrameMid = xOffset + (settings.getSubFrameSize()/2)
//                scaledSubFrameSize = max(Int(round(Float(settings.getSubFrameSize()) * xScale)),1)
//                scaledSubFramePos = subFrameMid - Int(round(Float(settings.getSubFrameSize()) * xScale/2.0))
            
//            }
            
            if frame.type == .normal {
                subFrameMid = xOffset + (frame.frameSize/2)
            }
            else {
                subFrameMid = frameSettings.window_pos.value - frameSettings.window_pos.range.upperBound/2 + xOffset + (frame.frameSize/2)
            }
            
            scaledSubFrameSize = max(Int(round(Float(displayedFrameSize) * xScale)),1)
            scaledSubFramePos = subFrameMid - scaledSubFrameSize/2
            
            //if self.subFramePosition < 0 {
            if scaledSubFramePos < 0 {

                //xPos =  abs(self.subFramePosition)
                xPos =  abs(scaledSubFramePos)

                frameStartIndex = 0
            }
            else {
                xPos = 0
                //frameStartIndex = max(min(abs(self.subFramePosition), scopeFrame.frameSize),0)
                frameStartIndex = max(min(abs(scaledSubFramePos), frame.frameSize),0)

            }
            
            let maxIndex : Int = min(scaledSubFrameSize + frameStartIndex, myFrame.count)
//            let maxIndex : Int = min(scaledSubFramePos + scaledSubFrameSize, myFrame.count)

            
            if maxIndex == 0 || frameStartIndex == maxIndex {
                //No frame to return
                return nil
               
            }
                
            
            else {
                returnedFrame = Samples(rawData: Array(myFrame[frameStartIndex ..< maxIndex]))
                returnedFrame.addOffset(Float(yOffset))

                returnedFrame.zoomY(Float(yScale))

                
                
                
                
                if (appSettings.interpolation &&  frameSettings.horiz.mappedSetting().divRatio <= 1 && frameSettings.horiz.mappedSetting().subFrameSize < displayedFrameSize) {
                    
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
                    frameSize = max(Int(Float(displayedFrameSize) * xScale), 1)
                    //subTrig = subTrig * xScale
                }
            
            
                //clip final returned frame
                
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


//    func zoomX(_ amount: Float) {
//        xScale *= amount
//    }
//
//    func zoomY(_ amount: Float) {
//        yScale *= amount
//    }
//
//    func panX(_ amount: Float) {
//        xOffset += amount
//    }
//
//    func panY(_ amount: Float) {
//        yOffset += amount
//    }



    func incrementSubFramePos(delta: Float, respectScaling: Bool) -> Float {
//        let maxPos = settings.getWindowPosMax() + scopeFrame.frameSize - settings.getSubFrameSize() - settings.getWindowPos()
//        let minPos =  -1 * settings.getWindowPos()
        let frameScale = Float(settings.getSubFrameSize())/Float(displayedFrameSize)
        let scale : Float = respectScaling ? xScale : 1.0
        let intDelta = Int(round(delta * frameScale))
        let intScaledDelta = Int(round(delta * scale))
 
        incrementXOffset(intScaledDelta)
        
        
        //trigDiff Method for setting next Frame's window position
        let frameSize = settings.getReadDepth()
        let windowPos = settings.getWindowPos()
        let windowMid = windowPos + frameSize/2
        let trigPos = frameSettings.trigger_x_pos.value// settings.getTrigMemPos()
        let trigDiff =  windowMid - trigPos
        let trigDiffTime = Double(trigDiff) * settings.getHorizMeta().timePerSample

        let frameSize1 = frameSettings.readDepth.value
        let windowPos1 = frameSettings.window_pos.value
        let windowMid1 = windowPos1 + frameSize1/2 + xOffset
        let trigPos1 = frameSettings.trigger_x_pos.value
        let trigDiff1 =  windowMid1 - trigPos1
        let trigDiffTime1 = Double(trigDiff1) * frameSettings.horiz.mappedSetting().timePerSample

        let sampleConv = settings.nextFrameSettings.horiz.mappedSetting().timePerSample
//        let sampleConv = frameSettings.horiz.mappedSetting().timePerSample

        let windowPosDiff = Int((trigDiffTime1 - trigDiffTime)/sampleConv)
        
        settings.setWindowPos(settings.getWindowPos() + windowPosDiff)

        
        return (Float(intDelta)/frameScale - delta)
//        return (Float(intScaledDelta) - delta)
    }
    
    func setSubFramePosToCenter() {
        settings.setWindowPos((settings.getWindowPosMax()+1)/2)
        xOffset = (settings.getWindowPosMax()+1)/2 - frameSettings.window_pos.value
        print("To Center: xOffset: \(xOffset)  windowPos: \(settings.getWindowPos())")
    }
    
    
    func resetFrameMeta() {
        yOffset = 0
        xOffset = 0
        xScale = 1.0
        yScale = 1.0
    }
    
    func captureFrameSettings() {
        self.frameSettings = settings.nextFrameSettings.copy()
        self.didChangeVert()
        self.didChangeHoriz(oldValue: settings.nextFrameSettings.horiz.mappedSetting())
        self.didChangeOffset()
        xOffset = 0
        //resetFrameMeta()

    }

    //MARK: - FrameInterfaceDelegate Methods
    func didReceiveFrame() {
        //resetFrameMeta()
        captureFrameSettings()


        if settings.getRunState() == .single  {
            settings.setRunState(.stop)
        }
    }
    
    func didReceiveFullFrame() {
//        resetFrameMeta()
      //  captureFrameSettings()
        self.didChangeVert()
        self.didChangeHoriz(oldValue: settings.nextFrameSettings.horiz.mappedSetting())
        self.didChangeOffset()
//        xOffset += frameSettings.window_pos.value
        self.reconcileWindowPos()

        
//        xOffset =  (settings.getWindowPos() + settings.getReadDepth()/2) -  frame.frameSize/2
//        setSubFramePos(Float(settings.getWindowPos() + xOffset))
    }
    
    func didReceiveRollFrame() {
//        resetFrameMeta()
        captureFrameSettings()
//        setSubFramePos(Float(settings.getWindowPos() + 6))
    }
    
    func reconcileWindowPos() {
        let frameSize = settings.getReadDepth()
        let windowPos = settings.getWindowPos()
        let windowMid = windowPos + frameSize/2
        let trigPos = settings.getTrigMemPos()
        let trigDiff =  windowMid - trigPos
        let trigDiffTime = Double(trigDiff) * settings.getHorizMeta().timePerSample
        
        let frameSize1 = frameSettings.readDepth.value
        let windowPos1 = frameSettings.window_pos.value
        let windowMid1 = windowPos1 + frameSize1/2
        let trigPos1 = frameSettings.trigger_x_pos.value
        let trigDiff1 =  windowMid1 - trigPos1
        let trigDiffTime1 = Double(trigDiff1) * frameSettings.horiz.mappedSetting().timePerSample
        
        //let sampleConv = settings.nextFrameSettings.horiz.mappedSetting().timePerSample
        let sampleConv = frameSettings.horiz.mappedSetting().timePerSample
//        if windowPos < settings.getWindowPosMax() && windowPos > settings.getWindowPosMin() {
            xOffset = Int((trigDiffTime - trigDiffTime1)/sampleConv)
        
//        if frameSettings.window_pos.value + xOffset > (frameSettings.window_pos.range.upperBound - 1)
//            {
//            xOffset = frameSettings.window_pos.value + xOffset - (frameSettings.window_pos.range.upperBound - 1)
//        }
//        else if frameSettings.window_pos.value + xOffset < frameSettings.window_pos.range.lowerBound  {
//            xOffset = xOffset + frameSettings.window_pos.value
//        }
//        else {
//            xOffset = 0
//        }
        
        print("reconciled xOffset: \(xOffset)")

        
    }
    
    //********************************************************
    //MARK: -
    
    //MARK: - FrameSettingseDelegate Methods

    func didChangeVert() {
        let zoom : Double = settings.nextFrameSettings.vert.mappedSetting().toReal /
            frameSettings.vert.mappedSetting().toReal
            
        yScale = 1/Float(zoom)
    }

    func didChangeHoriz(oldValue: horiz_mapping) {
        let zoom : Double = (settings.nextFrameSettings.horiz.mappedSetting().toReal /
            frameSettings.horiz.mappedSetting().toReal) * Double(frameSettings.horiz.mappedSetting().subFrameSize)/Double(displayedFrameSize)

        xScale = Float(zoom)
        
        let frameSize = settings.getReadDepth()
        let windowPos = settings.getWindowPos()
        let windowMid = windowPos + frameSize/2
        let trigPos = frameSettings.trigger_x_pos.value // settings.getTrigMemPos()
//        let trigDiff =  windowMid - trigPos
        let trigDiff = frameSettings.window_pos.value + frameSize/2 + xOffset - trigPos
        
        
        let trigDiffTime = Double(trigDiff) * settings.getHorizMeta().timePerSample
        
        //let incrementScale = Float(settings.nextFrameSettings.horiz.mappedSetting().timePerSample / oldValue.timePerSample)
        
        if settings.getSubFrameSize() >= displayedFrameSize && oldValue != settings.nextFrameSettings.horiz.mappedSetting(){
            
            let newWindowPos = frameSettings.window_pos.value + xOffset  - Int(round(Float(trigDiff)*(1-1/xScale)))
//            let newWindowPos = windowPos - Int(round(Float(trigDiff)*(1-1/incrementScale)))
            
            
//            if newWindowPos > settings.getWindowPosMax() || newWindowPos < settings.getWindowPosMin() {
                settings.setWindowPos(newWindowPos)
            
//            }
            
//            else {
//                settings.setWindowPos(newWindowPos)
//            }
            
            
        }
    }

    func didChangeOffset() {
        //TODO: Do we need to calculate offsetConvGain time timeGain in didChangeWindowPos?
        
        let offsetDiff = settings.nextFrameSettings.offset.value -
            frameSettings.offset.value
        
        let offsetConv = settings.nextFrameSettings.vert.mappedSetting().offsetConv
        //invert
        yOffset = -1 * Int(Double(offsetDiff) / offsetConv / Double(yScale))
        
    }

    
    func didChangeWindowPos() {
//        print("========Did Change Window Pos========")
//        print("xOffset: \(xOffset) xScale: \(xScale)")
//        print("frameWindowPos: \(frameSettings.window_pos.value)    windowPos: \(settings.getWindowPos())")
    }
     //********************************************************
     //MARK: -
    
    
    

}
