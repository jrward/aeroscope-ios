//
//  ScopeStatusBarViewController.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 3/4/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import UIKit
import Foundation
import Themeable

class ScopeStatusBarViewController : UIViewController, ScopeBatteryViewDataSource, Themeable {
    let scope = Scope.sharedInstance
    
    @IBOutlet weak var battView : ScopeBatteryView! {
        didSet {
            battView.dataSource = self
            battView.updateBattState()
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.textColor = UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0)
            updateStatusLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVert) , name:  ScopeSettings.notifications.vert, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHoriz), name:  ScopeSettings.notifications.horiz, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateACDC), name: ScopeSettings.notifications.acdc, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBattery), name: ScopeBattery.notifications.update, object: nil)

        battView.updateBattState()
        
        ScopeTheme.manager.register(themeable: self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
    }
    
    @objc func updateACDC() {
        updateStatusLabel()
    }
    
    @objc func updateVert() {
        updateStatusLabel()
    }
    
    @objc func updateHoriz() {
        updateStatusLabel()
    }
    
    func updateStatusLabel() {
        let dc_mode : String
        if scope.settings.nextFrameSettings.dc_en.value {
            dc_mode = "DC"
        }
        else {
            dc_mode = "AC"
        }
        
        //        let vertSetting = (scope.settings.settings.vert.value + " /div").stringByPaddingToLength(12, withString: " ", startingAtIndex: 0)
        //        let horizSetting = (scope.settings.settings.horiz.value + " /div").stringByPaddingToLength(12, withString: " ", startingAtIndex: 0)
        
        //        let horizSetting = scope.settings.settings.horiz.value.cStringUsingEncoding(NSUTF8StringEncoding)!
        
        //        statusLabel.text = "\(dc_mode) \(vertSetting) \(horizSetting)"
        
        let coupling = (dc_mode as NSString).utf8String
        let vertSetting = (scope.settings.nextFrameSettings.vert.value as NSString).utf8String
        
        let horizSetting = (scope.settings.nextFrameSettings.horiz.value as NSString).utf8String
        
        //        let rawOffset = scope.settings.settings.offset.value
        
        //        statusLabel.text = String(format: "%2s %5s/div  %5s/div    FPS: %3.2f    P-P: %3i", coupling!, vertSetting!, horizSetting!, fpsCapture, peakToPeak)
        statusLabel.text = String(format: "%2s %5s/div  %5s/div", coupling!, vertSetting!, horizSetting! )
        
        
    }
    
    @objc func updateBattery() {
        battView.updateBattState()
    }
    
    func battStateForBatteryView() -> ScopeBattery.BattState {
        return scope.telemetry.batt.state
//        enum BattState {
//            case fullyCharged
//            case full
//            case mid
//            case low
//            case dead
//            case unknown
//        }
//        return .dead
    }
    func chargeStateForBatteryView() -> Bool {
        return scope.telemetry.batt.chargerConnected
//        return true
    }
    
    func apply(theme: ScopeTheme) {
        statusLabel.textColor = theme.text
        battView.color = theme.batt
        battView.bgColor = theme.bgBatt
        self.view.backgroundColor = theme.bgSecondary
    }
    
}
