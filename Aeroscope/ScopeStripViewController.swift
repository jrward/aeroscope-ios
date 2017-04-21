//
//  ScopeStripViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/17/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit

class ScopeStripViewController: UIViewController, ScopeStripViewDataSource {

    
    let scope = Scope.sharedInstance
    
    @IBOutlet weak var scopeStripView: ScopeStripView! {
        didSet {
            scopeStripView.dataSource = self
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
            scopeStripView.addGestureRecognizer(panRecognizer)
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
            scopeStripView.addGestureRecognizer(tapRecognizer)
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(triggerXPosUpdate), name: ScopeSettings.notifications.triggerXPos, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowPosUpdate), name: ScopeSettings.notifications.windowPos, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(horizUpdate), name: ScopeSettings.notifications.horiz, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subFrameUpdate), name: ScopeFrameInterface.notifications.updateSubFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(frameUpdate), name: ScopeFrame.notifications.frame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fullFrameUpdate), name: ScopeFrame.notifications.fullFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rollFrameUpdate), name: ScopeFrame.notifications.rollFrame, object: nil)

    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scopeStripView)
                //print(translation.x)
                //let frameTranslation = (translation.x / scopeStripView.track_width) * 100.0
                //framePosition = min(max((framePosition + frameTranslation),0),100)
//        let rangeMax = scope.settings.getWindowPosRange().upperBound - 1
//        let rangeMin = scope.settings.getWindowPosRange().lowerBound
//        
//        let frameTranslation = Int(translation.x / scopeStripView.track_width * CGFloat(rangeMax))
//        let frameFloatTranslation = translation.x / scopeStripView.track_width * CGFloat(rangeMax)
        
        //scope.settings.setWindowPos(max(min(scope.settings.getWindowPos() + frameTranslation, rangeMax), rangeMin) )
        
    
        let rangeMax = CGFloat(scope.settings.getWriteDepth())
        let translationGain = rangeMax / scopeStripView.track_width

        let windowFloatTranslation : CGFloat  = (translation.x * translationGain)

        let remainingX = CGFloat(scope.frame.incrementSubFramePos(delta: Float(windowFloatTranslation))) / translationGain
        
        let remaining = CGPoint(x: remainingX, y: 0)
        
                //        let remainingX = scopeStripView.track_width * (frameFloatTranslation - CGFloat(frameTranslation))
        

        
        gesture.setTranslation(remaining, in: scopeStripView)
                //updateUI()
                
        //        let triggerFloatTranslation : CGFloat  = -1 * (translation.x / scopeFrameView.x_size * xTranslationGain)
        //        let triggerTranslation = Int(-1 * translation.x / scopeFrameView.x_size * xTranslationGain)
        //        let triggerXMax = scope.settings.window_pos.range.endIndex - 1
        //        let triggerXMin = scope.settings.window_pos.range.startIndex
        //        scope.settings.window_pos.value = max(min(scope.settings.window_pos.value + triggerTranslation, triggerXMax), triggerXMin)
        //        print(scope.settings.window_pos.value)
        //        //framePosition = min(max((framePosition + frameTranslation),0),100)
        //        remainingX = scopeFrameView.x_size/xTranslationGain * (triggerFloatTranslation - CGFloat(triggerTranslation))
        //        //remainingX = (triggerFloatTranslation - CGFloat(triggerTranslation))
        //        remainingY = 0

    }
    
    func tap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: scopeStripView)
        
        let width = scopeStripView.bounds.size.width
        
        if location.x <= width/8 && location.x >= width/16 {
            scope.settings.setTrigMemPos(scope.settings.getTrigMemPosRange().upperBound / 10)
        }
        
        else if location.x <= (width/2 + width/16) && location.x >= (width/2 - width/16) {
            scope.settings.setTrigMemPos(scope.settings.getTrigMemPosRange().upperBound / 2)
            
            //TODO: Move window through subframepos
            scope.settings.setWindowPos(scope.settings.getWindowPosRange().upperBound / 2)
            scope.frame.setSubFramePosToCenter()
        }
        
        else if location.x >= scopeStripView.bounds.size.width*7/8 {
            scope.settings.setTrigMemPos(scope.settings.getTrigMemPosRange().upperBound * 9/10)
        }
        print(location)
    }
    
    func triggerXPosUpdate() {
        scopeStripView.updateTrigger()
        scopeStripView.updateTrace()
    }
    
    func windowPosUpdate() {
        scopeStripView.updateSlider()
        scopeStripView.updateTrace()

    }
    
    func horizUpdate() {
        scopeStripView.updateSliderWidth()
        scopeStripView.updateTrace()

        
//        if scope.settings.getRunState() == .stop {
//            scopeStripView.updateTrace()
//        }
    }
    
    func subFrameUpdate() {
        scopeStripView.updateSliderWidth()
        scopeStripView.updateTrace()

    }
    
    func frameUpdate() {
        if scope.frame.getRawFrame().isEmpty {
            scopeStripView.clearTrace()
        }
        else {
            scopeStripView.updateTrace()

        }
    }
    
    func fullFrameUpdate() {
        scopeStripView.updateTraceFullframe()
    }
    
    func rollFrameUpdate() {
        scopeStripView.updateTrace()
        scopeStripView.updateSliderWidth()
    }

    
//    func updateUI() {
//        scopeStripView.updateSlider()
//        //scopeStripView.setNeedsDisplay()
//    }

    
    func framePositionForScopeStripView() -> CGFloat? {
        let windowPos = CGFloat(scope.frame.getScaledFramePos())
//        if scope.settings.getRunState() == .stop {
//            windowPos = CGFloat(scope.settings.getStoppedWindowPos() + scope.frame.getScaledSubFramePos())
//        }
//        else {
//            windowPos = CGFloat(scope.settings.getWindowPos() + scope.frame.getScaledSubFramePos())
//        }
  
        return (windowPos / CGFloat(scope.settings.getWriteDepth())) * 100.0
    }
    
    func frameWidthForScopeStripView() -> CGFloat? {
        //return CGFloat(scope.settings.settings.readDepth.value)/4096.0 * 100.0
        if scope.frame.scopeFrame.rollFrame {
            return nil
        }
        else {
            return CGFloat(scope.frame.getScaledSubFrameSize()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
        }
    }
    
    func triggerPositionForScopeStripView() -> CGFloat? {
        return CGFloat(scope.settings.getTrigMemPos()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
    }
    
    
    func tracePositionForScopeStripView() -> CGFloat? {
        return CGFloat(scope.frame.getScaledTracePos()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
    }
    
    func traceWidthForScopeStripView() -> CGFloat? {
        if scope.frame.scopeFrame.rollFrame {
            return nil
        }
        else {
            return CGFloat(scope.frame.getScaledTraceSize()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
        }
    }
    
    func traceScaleForScopeStripView() -> CGFloat? {
        if scope.frame.xScale > 1.0 {
            return CGFloat(min(scope.frame.xScale,100.0))
        }
        else {
            return 1.0
        }
    }
    
    func traceDataForScopeStripView() -> [UInt8]? {
        return []
    }

    

    
}
