//
//  ScopeStripViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/17/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Themeable

class ScopeStripViewController: UIViewController, ScopeStripViewDataSource, Themeable {

    
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
        
        ScopeTheme.manager.register(themeable: self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scopeStripView)
        
        let rangeMax = CGFloat(scope.settings.getWriteDepth())
        let translationGain = rangeMax / scopeStripView.track_width

        let windowFloatTranslation : CGFloat  = (translation.x * translationGain)

        let remainingX = CGFloat(scope.frame.incrementSubFramePos(delta: Float(windowFloatTranslation), respectScaling: false))
            / translationGain
        
        let remaining = CGPoint(x: remainingX, y: 0)
        
        gesture.setTranslation(remaining, in: scopeStripView)

    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: scopeStripView)
        
        let width = scopeStripView.bounds.size.width
        
        if location.x <= width/8 && location.x >= width/16 {
            scope.settings.setTrigMemPos(scope.settings.getTrigMemPosMax() / 10)
        }
        
        else if location.x <= (width/2 + width/16) && location.x >= (width/2 - width/16) {
            scope.settings.setTrigMemPos((scope.settings.getTrigMemPosMax() + 1) / 2)
            scope.frame.setSubFramePosToCenter()
        }
        
        else if location.x >= scopeStripView.bounds.size.width*7/8 {
            scope.settings.setTrigMemPos(scope.settings.getTrigMemPosMax() * 9/10)
        }
    }
    
    @objc func triggerXPosUpdate() {
        scopeStripView.updateTrigger()
        scopeStripView.updateTrace()
    }
    
    @objc func windowPosUpdate() {
        scopeStripView.updateSlider()
        scopeStripView.updateTrace()

    }
    
    @objc func horizUpdate() {
        scopeStripView.updateSliderWidth()
        scopeStripView.updateTrace()

    }
    
    @objc func subFrameUpdate() {
        scopeStripView.updateSliderWidth()
        scopeStripView.updateTrace()

    }
    
    @objc func frameUpdate() {
        if scope.frame.getRawFrame().isEmpty {
            scopeStripView.clearTrace()
        }
        else {
            scopeStripView.updateTrace()

        }
    }
    
    @objc func fullFrameUpdate() {
        scopeStripView.updateTraceFullframe()
    }
    
    @objc func rollFrameUpdate() {
        scopeStripView.updateTrace()
        scopeStripView.updateSliderWidth()
    }
    
    func framePositionForScopeStripView() -> CGFloat? {
        let framePos = CGFloat(scope.frame.getScaledFrameStart())
        return (framePos / CGFloat(scope.settings.getWriteDepth())) * 100.0
    }
    
    func frameWidthForScopeStripView() -> CGFloat? {
        //return CGFloat(scope.settings.settings.readDepth.value)/4096.0 * 100.0
        if scope.frame.frame.type == .roll {
            return nil
        }
        else {
            return CGFloat(scope.frame.getScaledFrameSize()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
        }
    }
    
    func triggerPositionForScopeStripView() -> CGFloat? {
        return CGFloat(scope.settings.getTrigMemPos()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
    }
    
    
    func tracePositionForScopeStripView() -> CGFloat? {
        return CGFloat(scope.frame.getScaledTraceStart()) / CGFloat(scope.settings.getWriteDepth()) * 100.0
    }
    
    func traceWidthForScopeStripView() -> CGFloat? {
        if scope.frame.frame.type == .roll {
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
    
    func apply(theme: ScopeTheme) {
        
        scopeStripView.sliderColor  = theme.accentSecondary
        
        scopeStripView.bgColor = theme.bgGrid
        
        scopeStripView.borderColor = theme.stripBorder
        
        scopeStripView.traceColor = theme.trace
        scopeStripView.triggerColor = theme.accentSecondary
        
        scopeStripView.caretColor = theme.caretColor
    }

    

    
}
