//
//  ScopeOffsetViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 4/8/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import UIKit
import Themeable

class ScopeOffsetViewController: UIViewController, ScopeOffsetViewDataSource, Themeable {
    
    let scope = Scope.sharedInstance

    @IBOutlet weak var scopeOffsetView: ScopeOffsetView! {
        didSet {
            scopeOffsetView.dataSource = self
        }
    }
    
    @IBOutlet weak var offsetLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 180, height: 500)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOffset), name: ScopeSettings.notifications.offset, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSliderHeight), name:  ScopeSettings.notifications.vert, object: nil)
        
//        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
//        scopeOffsetView.addGestureRecognizer(panRecognizer)
//        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        scopeOffsetView.addGestureRecognizer(panRecognizer)
        updateSliderHeight()
        updateOffset()
        self.apply(theme: ScopeTheme.manager.activeTheme)

    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scopeOffsetView)
        //print(translation.x)
        //let frameTranslation = (translation.x / scopeStripView.track_width) * 100.0
        //framePosition = min(max((framePosition + frameTranslation),0),100)
        let rangeMax = scope.settings.getOffsetRange().upperBound - 1
        let rangeMin = scope.settings.getOffsetRange().lowerBound
        
        let frameTranslation = Int(translation.y / scopeOffsetView.frame.size.height * CGFloat(rangeMax))
        let frameFloatTranslation = translation.y / scopeOffsetView.height * CGFloat(rangeMax)
        
        //TODO: Fix offset mechanism so that the caller doesn't have to invert. Hardware implementation details shouldn't bubble up to this leel
        
        scope.settings.setOffset( max(min(scope.settings.getOffset() - frameTranslation, rangeMax), rangeMin) )
        
//        //        let remainingX = scopeStripView.track_width * (frameFloatTranslation - CGFloat(frameTranslation))
        
        
        
        gesture.setTranslation(CGPoint.zero, in: scopeOffsetView)
    }
    
    func updateOffset() {
        let offsetVolts : Double = Translator.toVoltsFrom(
            offset: scope.settings.getOffset(),
            conv: scope.settings.getVertMeta().offsetConv,
            voltConv: scope.settings.getVertMeta().voltsPerBit)
        offsetLabel.text = "Offset: " + Translator.toStringFrom(voltage: offsetVolts) 
        scopeOffsetView.updateSlider()

    }
    
    func updateSliderHeight() {
        scopeOffsetView.updateSliderHeight()
    }
    
    
    //0.0 - 100.0
    func frameHeightForScopeOffsetView(_ sender: ScopeOffsetView) -> CGFloat?
    {
        let fullScaleVoltage : CGFloat
        switch scope.settings.getVert() {
        case "20mV": fullScaleVoltage = 0.16
        case "50mV":  fullScaleVoltage = 0.4
        case "100mV": fullScaleVoltage = 0.8
        case "200mV": fullScaleVoltage = 1.6
        case "500mV":  fullScaleVoltage = 4.0
        case "1V":  fullScaleVoltage = 8.0
        case "2V": fullScaleVoltage = 16.0
        case "5V":  fullScaleVoltage = 40.0
        case "10V": fullScaleVoltage = 80.0
        default: fullScaleVoltage = 8.0
        }
        
        return fullScaleVoltage / 80.0 * 100.0
    }
    
    //0.0 - 100.0
    func offsetForScopeOffsetView(_ sender: ScopeOffsetView) -> CGFloat?
    {
        let offset = CGFloat(scope.settings.getOffsetMax() - scope.settings.getOffset()) / CGFloat(scope.settings.getOffsetRange().upperBound - 1) * 100.0
        
        print("delegate offset: \(offset)")
        
        return offset
    }

    func apply(theme: ScopeTheme) {
        scopeOffsetView.sliderColor = theme.accentSecondary
        scopeOffsetView.bgColor = theme.bgGrid
        scopeOffsetView.gridColor = theme.grid
        scopeOffsetView.sliderColor = theme.accentSecondary
        scopeOffsetView.labelColor = theme.text
        offsetLabel.textColor = theme.text
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

