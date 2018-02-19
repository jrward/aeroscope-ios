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
        }
    }
    
    @IBAction func triggerChanged(_ sender: UISlider) {
        scope.settings.setTrig(Int(triggerSlider.value))
    }
    
    @IBOutlet weak var scopeFrameView: ScopeFrameView!{
        didSet {

        }
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateShowPts), name: ScopeAppSettings.notifications.showPts, object:nil)

        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ScopeFrameViewController.updateFPS), userInfo: nil, repeats: true)
        
        scopeFrameView.dataSource = self
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ScopeFrameViewController.pan))
        scopeFrameView.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ScopeFrameViewController.pinch))
        scopeFrameView.addGestureRecognizer(pinchRecognizer)
        ScopeTheme.manager.register(themeable: self)

    }
    
    override func viewDidLayoutSubviews() {

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
        scopeFrameView.updateTrigXPos()
        updateTracePos()
    }
    

    
    @objc func updateTrig() {
        scopeFrameView.updateTrig()
    }
    
    @objc func updateOffset() {
        scopeFrameView.updateGnd()
        updateTracePos()
    }
    
    @objc func updateVert() {
        updateTracePos()
        scopeFrameView.updateGnd()
    }
    
    @objc func updateHoriz() {
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
        let trigXPos = CGFloat(scope.frame.frameSettings.trigger_x_pos.value)
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
        trigDiff = getTrigDiff()
        let halfWindow = Double(scope.settings.getHorizMeta().toReal*5)
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

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let yTranslationGain : CGFloat = 256 //30
        let xTranslationGain = CGFloat(scope.frame.displayedFrameSize) / scopeFrameView.x_size
        var remainingX : CGFloat = 0
        var remainingY : CGFloat = 0
        
        //TODO: let translationInView Build up before setting it to zero
        let translation = gesture.translation(in: scopeFrameView)
        
        
        if abs(translation.x) > abs(translation.y) { //trigger Delay
            let windowFloatTranslation : CGFloat  = (-1 * translation.x * xTranslationGain)
          

            
            remainingX = CGFloat(frame.incrementSubFramePos(delta: Float(windowFloatTranslation), respectScaling: true))
                / xTranslationGain

            remainingY = 0
            
        }
        
        else { //offset
            let offsetFloatTranslation : CGFloat = (translation.y * yTranslationGain / scopeFrameView.y_size)

            
            
            remainingY = scopeFrameView.y_size/yTranslationGain * setOffset(translationInView: offsetFloatTranslation)
            
            if scope.settings.getRunState() == .stop {
                updateTracePos()
            }

            remainingX = 0
        }
        let remainingTranslation = CGPoint(x: (remainingX), y: (remainingY) )

        gesture.setTranslation(remainingTranslation, in: scopeFrameView)
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
    
    func convertToOffset(translation: CGFloat) -> CGFloat {
        var amplifiedTranslation : CGFloat
        let translationGain : CGFloat = getOffsetGain()
        
        amplifiedTranslation = translationGain * translation
        return amplifiedTranslation
    }
    
    func getOffsetGain() -> CGFloat {
        let offsetGain = scope.settings.getVertMeta().offsetConv
        return CGFloat(offsetGain)
    }
    
    func setOffset(translationInView: CGFloat) -> CGFloat {
        let amplifiedTranslation : CGFloat = convertToOffset(translation: translationInView)
        let translationGain = getOffsetGain()
        
        let offsetMax = scope.settings.getOffsetRange().upperBound - 1
        let offsetMin = scope.settings.getOffsetRange().lowerBound
        
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

    func gndLabelOffset() -> String {
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
        //TODO: Refactor this into model!!
        let doubleOffset = Double(32768 - scope.settings.getOffset()) / scope.settings.getVertMeta().offsetConv
    
        return CGFloat(doubleOffset)
    }
    
    func translateSampleTime(_ samples: Int) -> String {
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
