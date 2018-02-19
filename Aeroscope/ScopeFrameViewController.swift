//
//  ScopeFrameViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Foundation
import Themeable

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


@IBDesignable
class ScopeFrameViewController: UIViewController, ScopeFrameViewDataSource, Themeable  {
    
    let scope = Scope.sharedInstance
    
    let frame = Scope.sharedInstance.frame
    
    var fps : Int = 0
    
    var fpsCapture : Double = 0
    
    var peakToPeak : Int = 0
    
    var cal : Int = 0
    
    let appSettings = Scope.sharedInstance.appSettings
    
    //ScopeFrame(comms: Scope.sharedInstance.comms, frameSize: 512)
    
    var nf = NumberFormatter() {
        didSet {
            nf.numberStyle = .decimal
        }
    }
    

    
    
    @IBOutlet weak var triggerSlider: UISlider! {
        didSet {
            triggerSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2);
            triggerSlider.minimumTrackTintColor = UIColor.gray
            triggerSlider.maximumTrackTintColor = UIColor.gray
            triggerSlider.minimumValue = Float(scope.settings.getTrigRange().lowerBound)
            triggerSlider.maximumValue = Float(scope.settings.getTrigRange().upperBound - 1)
            triggerSlider.value = Float(scope.settings.getTrig())
            triggerSlider.thumbTintColor = UIApplication.shared.windows.last?.tintColor
            //UIColor(red: 0/255, green: 144/255, blue: 144/255, alpha: 1.0)

//            let image = UIImage(named: "thumb")
//            image!.imageWithRenderingMode(.AlwaysTemplate)
//
//            triggerSlider.setThumbImage(image, forState: .Normal)
//            triggerSlider.setThumbImage(image, forState: .Selected)
        }
    }
    
    @IBAction func triggerChanged(_ sender: UISlider) {
        scope.settings.setTrig(Int(triggerSlider.value))
    }
    
 
    @IBOutlet weak var scopeFrameView: ScopeFrameView!{
        didSet {

        }
    }
    
    
    //let rightTrig = ArrowLabelView(
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScopeFrameViewController.updateFrame), name: ScopeFrame.notifications.frame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScopeFrameViewController.updateFrame), name: ScopeFrame.notifications.fullFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFrame), name: ScopeFrame.notifications.rollFrame, object: nil)
        
        //TODO: Break update window out into own updateSubFramePos Func
        NotificationCenter.default.addObserver(self, selector: #selector(updateSubFrame), name: ScopeFrameInterface.notifications.updateSubFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVert) , name:  ScopeSettings.notifications.vert, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHoriz), name:  ScopeSettings.notifications.horiz, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOffset), name:  ScopeSettings.notifications.offset, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrig), name: ScopeSettings.notifications.trigger, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrigXPos), name: ScopeSettings.notifications.triggerXPos, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWindow), name:  ScopeSettings.notifications.windowPos, object: nil)
        
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ScopeFrameViewController.updateFPS), userInfo: nil, repeats: true)
        //arrowLabel.frame.origin
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateShowPts), name: ScopeAppSettings.notifications.showPts, object:nil)
        


//        leftTrig = ArrowLabelView(frame: leftFrame,text: "Trigger: 1.00 us", loc: .Left, dir: .Left, color: UIColor.redColor())
//        
//        rightTrig = ArrowLabelView(frame: leftFrame,text: "Trigger: 1.00 us", loc: .Right, dir: .Right, color: UIColor.redColor())
//
     
//
        
        
        scopeFrameView.dataSource = self
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ScopeFrameViewController.pan))
        scopeFrameView.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ScopeFrameViewController.pinch))
        scopeFrameView.addGestureRecognizer(pinchRecognizer)
        
        
        ScopeTheme.manager.register(themeable: self)

   

//        print("old Size: \(rightTrig.frame.size)")
//        rightTrig.sizeToFit()
//        print("new Size: \(rightTrig.frame.size)")
//        rightTrig.frame.origin.x = scopeFrameView.frame.size.width - rightTrig.frame.size.width - 20
////
//        downGnd.frame.origin.y = scopeFrameView.frame.size.height - downGnd.frame.size.height - 14
//        print("downGnd")
//        print(downGnd.frame.size)
//        print(scopeFrameView.frame.size.height)
//        print(downGnd.frame.origin)
    }
    
    override func viewDidLayoutSubviews() {
//        let Left = NSLayoutConstraint(item: downGnd, attribute: .Leading, relatedBy: .Equal, toItem: scopeFrameView, attribute: .Leading, multiplier: 1.0, constant: 2)//.active = true
//        
//        let Top = NSLayoutConstraint(item: downGnd, attribute: .Top , relatedBy: .Equal, toItem: scopeFrameView, attribute: .Top, multiplier: 1.0, constant: 8)//.active = true
//        
//        scopeFrameView.addConstraint(Left)
//        scopeFrameView.addConstraint(Top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)

    }

    @objc func updateShowPts() {
        scopeFrameView.updateShowPts()
        updateTracePos()
    }
    
    @objc func updateWindow() {
        scopeFrameView.updateTrigXPos()
        updateTracePos()

    }
    
    @objc func updateTrigXPos() {
//        updateSettingsText()
        scopeFrameView.updateTrigXPos()
        updateTracePos()

        
//        let trigXPos = Int(scope.settings.trigger_x_pos.value)
//        let windowPos = Int(scope.settings.window_pos.value)
//        let frameSize = Int(scope.frame.frame_size)
//        
//        let trigDiff = trigXPos - (windowPos + frameSize/2)
//        
//        leftTrig.text = translateSampleTime(trigDiff)
//        rightTrig.text = translateSampleTime(trigDiff)
        
    }
    

    
    @objc func updateTrig() {
        scopeFrameView.updateTrig()
    }
    
    @objc func updateOffset() {
        scopeFrameView.updateGnd()
//        updateStatusLabel()
        updateTracePos()
//        cal = scope.settings.offset.value - (scope.settings.offset.range.endIndex/2)
//        
//        let calString = String(cal)
//        calLabel.text = "CAL: \(cal)"
    }
    
    @objc func updateVert() {
//        updateStatusLabel()
//        updateSettingsText()
        
        updateTracePos()
        scopeFrameView.updateGnd()
    }
    
    @objc func updateHoriz() {
//        updateStatusLabel()
//        updateSettingsText()
        //frame.zoomX()
        updateTracePos()
        scopeFrameView.updateTrigXPos()
        
    }
    
    @objc func updateSubFrame() {
        updateTracePos()

        scopeFrameView.updateTrigXPos()

    }
    


    
    func updateTracePos() {
        
        scopeFrameView.updateTrace()
    }
    
    

    func dataForScopeFrameView() -> frameData?  {
        return frame.getDisplayedFrame()
    }
    
    func calcPeakToPeak(frame: [UInt8]) -> Int {
        let min = frame.min()!
        let max = frame.max()!
        
        return Int(max - min)
    }
    
    func highlightSamples() -> Bool? {
        return appSettings.showPts
    }
    
    // MARK: Work
    func positionForGndSymbol() -> CGFloat? {
        let offset = offsetTranslation()
        var position : CGFloat
        if offset < -127 {
            position = -1.0
        }
        else if offset > 128 {
            position =  101.0
        }
        else {
            position = ((offset + 127) / 255.0) * 100
        }
        
   
        return position
    }
    
    func positionForTrigSymbol() -> CGFloat? {
        return (CGFloat(scope.settings.getTrig()) / 255.0) * 100
    }
    
    func getTrigDiff() -> CGFloat {
        let trigXPos = CGFloat(scope.frame.frameSettings.trigger_x_pos.value)//CGFloat(scope.settings.getTrigMemPos())
//        let scaledSubFrameStart = CGFloat(scope.frame.getScaledSubFrameStart())
//        let scaledSubFrameSize = CGFloat(scope.frame.getScaledSubFrameSize())
//        let offset = CGFloat(scope.frame.xOffset)
        let subFrameMid = CGFloat(scope.frame.getSubFrameMidInMemCoords())

        
        let trigDiff = trigXPos - (subFrameMid)
        
        return trigDiff
    }
    
    func positionForTrigXPos() -> CGFloat? {
        let position : CGFloat

        let trigDiff = getTrigDiff()
        let scaledSubFrameSize = CGFloat(scope.frame.getScaledSubFrameSize())

        if trigDiff > scaledSubFrameSize/2 {

            position = 101.0
        }
        else if trigDiff < -scaledSubFrameSize/2 {

            position = -1.0
        }
        else {
            position = (trigDiff + (scaledSubFrameSize/2)) / scaledSubFrameSize * 100.0
        }
        
        return position
    }
    
    func dataForTrigXLabel() -> String? {

        let trigDiff : CGFloat
//        if (scope.frame.xScale < 1.0) {
//            trigDiff = getTrigDiff() / CGFloat(scope.frame.xScale)
//        }
//        else {
//            trigDiff = getTrigDiff()
//        }
        
        trigDiff = getTrigDiff()
        
        let halfWindow = Double(scope.settings.getHorizMeta().toReal*5)

        //let trigDiff = min(trigDiffLeft, trigDiffRight)
       /* let trigDiff : Float
        if positionForTrigXPos() < 0 {
            trigDiff = trigDiffLeft
        }
        
        else {
            trigDiff = trigDiffRight
        }
         
 */
        
        let time = Translator.toTimeFrom(samples: abs(Int(trigDiff)),
                conv: scope.frame.frameSettings.horiz.mappedSetting().timePerSample)
        return Translator.toStringFrom(time: time - halfWindow)
        
    }
    
    func dataForGndLabel() -> String? {
        return gndLabelOffset()
    }
    
    @objc func updateFPS() {
        fpsCapture = Double(fps) / 2.0
//        print("fps: \(fpsCapture)")
        fps = 0
    }
  
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//                case "Scope Control":
//                    if let vc = segue.destinationViewController as? ScopeCtrlViewController {
//                        
//                }
//                default: break
//            }
    
//        }
//    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let yTranslationGain : CGFloat = 256 //30
        let xTranslationGain = CGFloat(scope.frame.displayedFrameSize) / scopeFrameView.x_size
        var remainingX : CGFloat = 0
        var remainingY : CGFloat = 0
        
        //TODO: let translationInView Build up before setting it to zero
        let translation = gesture.translation(in: scopeFrameView)
        
        
        if abs(translation.x) > abs(translation.y) { //trigger Delay
            let windowFloatTranslation : CGFloat  = (-1 * translation.x * xTranslationGain)
            let windowTranslation : Int = Int(-1 * translation.x / scopeFrameView.x_size * xTranslationGain)
            let windowMax = scope.settings.getWindowPosMax()
            let windowMin = scope.settings.getWindowPosMin()

            
            remainingX = CGFloat(frame.incrementSubFramePos(delta: Float(windowFloatTranslation), respectScaling: true))
                / xTranslationGain

            remainingY = 0
            
        }
        
        else { //offset
            let offsetFloatTranslation : CGFloat = (translation.y * yTranslationGain / scopeFrameView.y_size)
            let offsetTranslation : Int = Int(translation.y * yTranslationGain  / scopeFrameView.y_size)

            
            
            remainingY = scopeFrameView.y_size/yTranslationGain * setOffset(translationInView: offsetFloatTranslation)
            
            if scope.settings.getRunState() == .stop {
                //let offsetGain = getOffsetGain()
                updateTracePos()
                
                //TODO: Look at how we subtract here. Offset is inverted, but I'm not sure where right now
                //let stoppedChange = CGFloat(scope.settings.stoppedOffset.value - scope.settings.offset.value) / offsetGain
//                let stoppedChange = translateStoppedOffset()
//                frame.offset = Int(stoppedChange)
//                print(frame.offset)
//                scopeFrameView.updateTrace()
            }

            
            //remainingY = setOffset(translationInView: offsetFloatTranslation)
            remainingX = 0
        }
        //let remainingY = setOffset(translationInView: offsetFloatTranslation)
        //let remainingY = scopeFrameView.y_size/yTranslationGain * (offsetFloatTranslation - CGFloat(offsetTranslation))
        let remainingTranslation = CGPoint(x: (remainingX), y: (remainingY) )

        gesture.setTranslation(remainingTranslation, in: scopeFrameView)
//        updateSettingsText()
    }
    
    
    @objc func pinch(_ gesture: UIPinchGestureRecognizer) {
        struct Static {
            static var changed = false
            static var level = 0 {
                didSet {
                    if level != oldValue {
                        changed = true
                    }
                    else {
                        changed = false
                    }
                }
            }
            static var vert = false
        }
        
        let increment : () -> (Void) = {
            if (Static.changed) {
                if Static.vert {
                    self.scope.settings.incrementVert()
                    self.scope.updateSettings()
                }
                else {
                    self.scope.settings.incrementHoriz()
                    self.scope.updateSettings()
                }
            }
        }
        
        let decrement : () -> (Void) = {
            if (Static.changed) {
                if Static.vert {
                    self.scope.settings.decrementVert()
                    self.scope.updateSettings()
                }
                else {
                    self.scope.settings.decrementHoriz()
                    self.scope.updateSettings()
                }
            }
        }

        
        switch(gesture.state) {
            
            case .began:
                Static.level = 0
                Static.changed = false
                
                let loc1 = gesture.location(ofTouch: 0, in: scopeFrameView)
                let loc2 = gesture.location(ofTouch: 1, in: scopeFrameView)
                
                if (abs(loc1.x - loc2.x) > abs(loc1.y - loc2.y)) { //pinch x
                    Static.vert = false
                }
                
                else {
                    Static.vert = true
                }
                
                
            case .changed: fallthrough
            case .failed: fallthrough
            case .cancelled: fallthrough
            case .ended:
                
                
            if gesture.scale < 0.2 {
                Static.level = 3
                increment()
            }
                
            else if gesture.scale < 0.5 {
                Static.level = 2
                increment()
            }
                
            else if gesture.scale < 0.75 {
                Static.level = 1
                increment()
            }
                
            else if gesture.scale > 5.0 {
                Static.level = -3
                decrement()
            }
                
            else if gesture.scale > 3.0 {
                Static.level = -2
                decrement()
            }
                
            else if gesture.scale > 1.5 {
                Static.level = -1
                decrement()
            }        
        
            default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateFrame() {
        scopeFrameView.updateTrigXPos()
        scopeFrameView.updateTrace()
//        updateStatusLabel()
        fps += 1
    }
    
//    func updateSettingsText() {
////        vertLabel.text = "\(scope.settings.vert.value)"
////        horizLabel.text = "\(scope.settings.horiz.value)"
//        //offsetLabel.text = "Offset: \(scope.settings.offset.value)"
//        //offsetLabel.text = "Offset: \(offsetLabelTranslated())"
//        //trigDelayLabel.text = "Trig Delay: \(scope.settings.trigger_x_pos.value)"
//       // trigDelayLabel.text = "Trig Delay: \(trigDelayLabelTranslated())"
//
//    }
    
    func convertToOffset(translation: CGFloat) -> CGFloat {
        var amplifiedTranslation : CGFloat
        let translationGain : CGFloat = getOffsetGain()
        
        amplifiedTranslation = translationGain * translation
        
//        if abs(translation) > 2 {
//            let old_amplifiedTranslation = amplifiedTranslation
//            amplifiedTranslation = amplifiedTranslation * 3 * (abs(translation) - 1)
//            print("old Translation: \(old_amplifiedTranslation)    new Translation: \(amplifiedTranslation)")
//        }
        
        return amplifiedTranslation
    }
    
    func getOffsetGain() -> CGFloat {
//        var translationGain : CGFloat = 1
//        switch scope.settings.getVert() {
//        case "20mV":
//            //amplifiedTranslation =   translationInView
//            translationGain = 0.99659
//        case "50mV":
//            //amplifiedTranslation =   translationInView
//            translationGain = 1.024
//        case "100mV":
//            //amplifiedTranslation =  (4.7 / 2.3) * translationInView
////            translationGain = (4.7 / 2.3)
//            translationGain = 2.048 //4.7/2.3
//        case "200mV":
//            //amplifiedTranslation =  (4.7 / 0.9) * translationInView
////            translationGain = (4.7 / 0.9)
//            translationGain = 4.096//(4.7 / 1.1)
//        case "500mV":
//            //amplifiedTranslation =  (4.7 / 0.5) * translationInView
//            translationGain = 10.24//(4.7 / 0.5)
//        case "1V":
//            //amplifiedTranslation =  (4.7 / 0.2) * translationInView
//            //translationGain = (4.7 / 0.2)
//            translationGain = 20.48//(4.7 / 0.23)
//        case "2V":
//            //amplifiedTranslation =  (4.7 / 0.1) * translationInView
//            translationGain = 40.96//(4.7 / 0.1)
//        case "5V":
//            //amplifiedTranslation =  (4.7 / 0.046) * translationInView
//            translationGain = 102.4//(4.7 / 0.046)
//        case "10V":
//            //amplifiedTranslation =  (4.7 / 0.023) * translationInView
//            translationGain = 204.8//(4.7 / 0.023)
//            
//        default:
//            //amplifiedTranslation = 0
//            translationGain = 1
//        }
//        
//        return translationGain
        let offsetGain = scope.settings.getVertMeta().offsetConv
        return CGFloat(offsetGain)
        
        
    }
    
    //translationInvView: pan translation in units of vertical samples
    func setOffset(translationInView: CGFloat) -> CGFloat {
        let amplifiedTranslation : CGFloat = convertToOffset(translation: translationInView)
        let translationGain = getOffsetGain()
        
        let offsetMax = scope.settings.getOffsetRange().upperBound - 1
        let offsetMin = scope.settings.getOffsetRange().lowerBound
        
        //let amplifiedTranslationInt = Int(amplifiedTranslation)
        let amplifiedTranslationInt = Int(round(amplifiedTranslation))
        let remainingTranslation : CGFloat = amplifiedTranslation - CGFloat(amplifiedTranslationInt)
                
        scope.settings.setOffset(max(min(scope.settings.getOffset() + amplifiedTranslationInt, offsetMax), offsetMin))
        
        return remainingTranslation/translationGain
    }
    
    
    func setTriggerXPos(translationInView: Int) {
        
    }
    
    func setVert(pinchLevel: Int) {
        
    }
    
    func setHoriz(pinchLevel: Int) {
        
        
    }
    
    //Move this into model?
//    func offsetLabelTranslated() -> String {
//        let offset = -10 * ((0.000152588 * Double(scope.settings.getOffset())) - 5.0)
//
//        var offsetString : String
//        if abs(offset) >= 1.0 {
//            offsetString = String(format: "%.03f", offset)
//            offsetString += " V"
//        }
//        else {
//            offsetString = String(format: "%.0f", offset*1000.0)
//            offsetString += " mV"
//        }
//        
//        print("\(offset)    \(offsetString)")
//        return offsetString
//    }
    
    
//    func translate
    func gndLabelOffset() -> String {
//        let offset = -10 * ((0.000152588 * Double(scope.settings.getOffset())) - 5.0)
//        let halfScaleV : Double
//        
//        switch scope.settings.getVert() {
//        case "20mV": halfScaleV = 0.08
//        case "50mV":  halfScaleV = 0.2
//        case "100mV": halfScaleV = 0.4
//        case "200mV": halfScaleV = 0.8
//        case "500mV":  halfScaleV = 2.0
//        case "1V":  halfScaleV = 4.0
//        case "2V": halfScaleV = 8.0
//        case "5V":  halfScaleV = 20.0
//        case "10V": halfScaleV = 40.0
//        default: halfScaleV = 4.0
//        }
//        
//        let gndOffset = abs(offset) - halfScaleV
//        
//        print("offset: \(abs(offset))  halfScaleV: \(halfScaleV)")
        
        //return scope.settings.translateVoltage(Double(gndOffset))
        //return scope.measure.translate(voltage:(Double(gndOffset))
        
        
        let gndOffsetVolts = Translator.toVoltsFrom(
            offset: scope.settings.getOffset(),
            conv: scope.settings.getVertMeta().offsetConv,
            voltConv: scope.settings.getVertMeta().voltsPerBit)
        
        let refGndOffsetVolts = abs(abs(gndOffsetVolts) - (scope.settings.getVertMeta().toReal * 4))
        
        return Translator.toStringFrom(voltage: refGndOffsetVolts)
        
    }
    

    
    
    //MARK: Work
    //translates offset into onscreen units
    func offsetTranslation() -> CGFloat {
//        var translatedOffset : CGFloat
//        var fullscaleVoltage : Double
////        let calTable = scope.settings.offsetCalTable
////        let vert = scope.settings.vert.value
//        let offset = -10 * ((0.000152588 * Double(scope.settings.getOffset() /*- calTable[vert]!*/)) - 5.0)
//        switch scope.settings.getVert() {
//        case "20mV": fullscaleVoltage = -0.08
//        case "50mV":  fullscaleVoltage = -0.2
//        case "100mV": fullscaleVoltage = -0.4
//        case "200mV": fullscaleVoltage = -0.8
//        case "500mV":  fullscaleVoltage = -2.0
//        case "1V":  fullscaleVoltage = -4.0
//        case "2V": fullscaleVoltage = -8.0
//        case "5V":  fullscaleVoltage = -20.0
//        case "10V": fullscaleVoltage = -40.0
//        default: fullscaleVoltage = -4.0
//        }
//        
//        print(offset)
//        translatedOffset = CGFloat(offset/fullscaleVoltage) * (-128)
//        
//        return translatedOffset
    
//        let doubleOffset = Translator.toVoltsFrom(
//                offset: scope.settings.getOffset(),
//                conv: scope.settings.getVertMeta().offsetConv,
//                voltConv: scope.settings.getVertMeta().voltsPerBit)
        
//            let signedOffset = Double(offset - 32768)
//            return (signedOffset / conv) * voltConv
//        
        //TODO: Refactor this into model!!
        let doubleOffset = Double(32768 - scope.settings.getOffset()) / scope.settings.getVertMeta().offsetConv
    
        return CGFloat(doubleOffset)
    
    }
    
//    func translateStoppedOffset() -> CGFloat {
//
//        
//        //TODO: Refactor this into model!!
//        let offsetDiff = scope.settings.getStoppedOffset() - scope.settings.getOffset()
//        
//      voltConv: scope.settings.getVertMeta().voltsPerBit)
//        
//        let doubleOffsetDiff = Double(offsetDiff) / scope.settings.getVertMeta().offsetConv
//        
//        return CGFloat(doubleOffsetDiff)
//            
//    }
    
//    func trigDelayLabelTranslated() -> String {
//        let normalizedDelay = Double(scope.settings.getTrigMemPos() - 2048) / 51.2
//        var delayGain : Double = 0
//        let msThresh : Double = 1000000
//        let usThresh : Double = 1000
//        
//        switch scope.settings.getHoriz() {
//        case "25ns": delayGain = 25
//        case "50ns": delayGain = 50
//        case "100ns": delayGain = 100
//        case "200ns": delayGain = 200
//        case "400ns": delayGain = 400
//        case "1us": delayGain = 1000
//        case "2us": delayGain = 2000
//        case "5us": delayGain = 5000
//        case"10us": delayGain = 10000
//        case "20us": delayGain = 20000
//        case "50us": delayGain = 50000
//        case "100us": delayGain = 100000
//        case "200us": delayGain = 200000
//        case "500us": delayGain = 500000
//        case "1ms": delayGain = 1000000
//        case "2ms": delayGain = 2000000
//        case "5ms": delayGain = 5000000
//        case "10ms": delayGain = 10000000
//        case "20ms": delayGain = 20000000
//        case "50ms": delayGain = 50000000
//        case "100ms": delayGain = 100000000
//        default : delayGain = 100
//        }
//        
//        let calibratedDelay = normalizedDelay * delayGain
//        var stringDelay : String
//        
//        if abs(calibratedDelay) > msThresh {
//            stringDelay = String(format: "%.02f", calibratedDelay / msThresh)
//            stringDelay += " ms"
//        }
//            
//        else if abs(calibratedDelay) > usThresh {
//            stringDelay = String(format: "%.02f", calibratedDelay / usThresh)
//            stringDelay += " us"
//        }
//            
//        else {
//            stringDelay = String(format: "%.0f", calibratedDelay)
//            stringDelay += " ns"
//        }
//        
//        return stringDelay
//    }
    
    //TODO: There is some fucked up shit here. Look at it!
    
    func translateSampleTime(_ samples: Int) -> String {
        //let normalizedDelay = Double(scope.settings.trigger_x_pos.value - 2048) / 51.2
//        var timeGain : Double = 0
//        let msThresh : Double = 1000000
//        let usThresh : Double = 1000
//        
//        switch scope.settings.getHoriz() {
//        case "25ns": timeGain = 2
//        case "50ns": timeGain = 2
//        case "100ns": timeGain = 2
//        case "200ns": timeGain = 4
//        case "400ns": timeGain = 8
//        case "1us": timeGain = 20
//        case "2us": timeGain = 40
//        case "5us": timeGain = 100
//        case"10us": timeGain = 200
//        case "20us": timeGain = 400
//        case "50us": timeGain = 1000
//        case "100us": timeGain = 2000
//        case "200us": timeGain = 4000
//        case "500us": timeGain = 10000
//        case "1ms": timeGain = 20000
//        case "2ms": timeGain = 40000
//        case "5ms": timeGain = 100000
//        case "10ms": timeGain = 200000
//        case "20ms": timeGain = 400000
//        case "50ms": timeGain = 1000000
//        case "100ms": timeGain = 2000000
//        default : timeGain = 2
//        }
//        
//        let calibrateddTime = Double(samples) * timeGain
//        
//        var stringTime : String
//        
//        if abs(calibrateddTime) > msThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / msThresh)
//            stringTime += " ms"
//        }
//        
//        else if abs(calibrateddTime) > usThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / usThresh)
//            stringTime += " us"
//        }
//        
//        else {
//            stringTime = String(format: "%.0f", calibrateddTime)
//            stringTime += " ns"
//        }
        
        let time = Translator.toTimeFrom(samples: samples, conv: scope.settings.getHorizMeta().timePerSample)
        
        return Translator.toStringFrom(time: time)
    }
    
    
    func apply(theme: ScopeTheme) {
        triggerSlider.minimumTrackTintColor = theme.accentSecondary
        triggerSlider.maximumTrackTintColor = theme.accentSecondary
        triggerSlider.thumbTintColor = theme.accentPrimary
        scopeFrameView.gridColor = theme.grid
        scopeFrameView.borderColor = theme.scopeBorder
        scopeFrameView.bgColor = theme.bgGrid
        scopeFrameView.traceColor = theme.trace
        scopeFrameView.gndColor = theme.traceAccent
        scopeFrameView.caretColor = theme.caretColor
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
