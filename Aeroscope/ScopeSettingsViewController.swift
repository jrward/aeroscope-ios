//
//  ScopeSettingsViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 9/29/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Themeable

class ScopeSettingsViewController: UIViewController, Themeable {

    let scope = Scope.sharedInstance
    let comms = Scope.sharedInstance.comms
    let frame = Scope.sharedInstance.frame
    //let fpgaUpdate = ScopeFpgaUpdate(comms: Scope.sharedInstance.comms)
    
    
    
    @IBOutlet weak var clearTraceButton: UIButton!
    
    @IBAction func clearTraceTouched(_ sender: UIButton) {
        frame.clearTrace()
        
    }
    
    
    @IBOutlet weak var fullFrameSwitch: UISwitch!
    
//    @IBOutlet weak var readChar: UIButton!
//    @IBAction func readCharPressed(sender: AnyObject) {
//        
//        
//    }
    
//    @IBOutlet weak var readCharText: UITextView!
    
//    @IBOutlet weak var eraseProm: UIButton!
//    @IBAction func erasePromPressed(sender: UIButton) {
//        eraseProm.enabled = false
//        progProm.enabled = false
//        fpgaUpdate.fpgaErase()
//    }
   
    
//    @IBOutlet weak var progProm: UIButton!
//    @IBAction func progPromPressed(sender: UIButton) {
//        eraseProm.enabled = false
//        progProm.enabled = false
//        if let asset = NSDataAsset(name: "Fpga_Image") {
//            let data = asset.data
//            fpgaUpdate.fpgaUpdate(data);
//        }
//        
//    }
//    
//    @IBOutlet weak var promStatus: UILabel!
//    
//    @IBOutlet weak var promProgress: UIProgressView!
//    
//    
    
    @IBOutlet weak var fullCalButton: UIButton!
    
    @IBAction func fullCalButtonTouched(_ sender: UIButton) {
        //scope.settings.settings.cal.value = true
        scope.settings.cmd.reqFullCal()
        
    }
    
    
    @IBOutlet weak var clearCalButton: UIButton!
    
    @IBAction func clearCalButtonTouched(_ sender: UIButton) {
        //scope.settings.settings.cal.value = true
        scope.settings.cmd.clearCal()
        
    }
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func resetTouched(_ sender: UIButton) {
        scope.settings.cmd.reset()
    }
    
    
    @IBOutlet weak var deepSleepButton: UIButton!
    
    @IBAction func deepSleepTouched(_ sender: UIButton) {
        scope.settings.cmd.deepSleep()
    }
    
    
    
    
    @IBOutlet weak var showPtsLabel: UILabel!
    @IBOutlet weak var showPtsSwitch: UISwitch!
    @IBAction func showPtsChanged(_ sender: UISwitch) {
        if showPtsSwitch.isOn {
            scope.appSettings.showPts = true
        }
        else {
            scope.appSettings.showPts = false
        }
    }
    
    
    @IBOutlet weak var sincInterpLabel: UILabel!
    @IBOutlet weak var sincInterpSwitch: UISwitch!
    
    @IBAction func sincInterpChanged(_ sender: UISwitch) {
        if sincInterpSwitch.isOn {
            scope.appSettings.interpolation = true
        }
        
        else {
            scope.appSettings.interpolation = false
        }
    }
    
    
    
    @IBOutlet weak var fullFrameLabel: UILabel!
    @IBAction func fullFrameSwitchChanged(_ sender: UISwitch) {
        if fullFrameSwitch.isOn {
//            scope.settings.settings.scopeCtrl.full_frame.value = true
//            scope.settings.settings.update_cpu_settings()
            scope.appSettings.fullFrameDL = true
        }
            
        else {
//            scope.settings.settings.scopeCtrl.full_frame.value = false
//            scope.settings.settings.update_cpu_settings()
            scope.appSettings.fullFrameDL = false
        }
    }
    
    
//    func fpgaEraseComplete() {
//        promStatus.text = "Erase Complete"
//        progProm.enabled = true
//        eraseProm.enabled = true
//    }
//    
//    func fpgaProgramComplete() {
//        promStatus.text = "Program Complete"
//        progProm.enabled = true
//        eraseProm.enabled = true
//        
//    }

//    @IBOutlet weak var memorySizeSelector: UISegmentedControl!
//    
//    @IBAction func memorySizeChanged(_ sender: UISegmentedControl) {
//        if memorySizeSelector.selectedSegmentIndex == 0 {
//            scope.settings.setWriteDepth(512)
//        }
//        
//        else {
//            scope.settings.setWriteDepth(4096)
//        }
//    }
    
    @IBOutlet weak var themeLabel: UILabel!
    
    @IBOutlet weak var themeSelector: UISegmentedControl!
    
    @IBAction func themeSelectorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: ScopeTheme.manager.activeTheme = .dark
        case 1: ScopeTheme.manager.activeTheme = .darklight
        case 2: ScopeTheme.manager.activeTheme = .bright
        case 3: ScopeTheme.manager.activeTheme = .day
        default: ScopeTheme.manager.activeTheme = .dark
        }
        
        

    }
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fullFrameSwitch.isOn = scope.appSettings.fullFrameDL
        sincInterpSwitch.isOn = scope.appSettings.interpolation
        showPtsSwitch.isOn = scope.appSettings.showPts
        
        ScopeTheme.manager.register(themeable: self)
        
        switch ScopeTheme.manager.activeTheme {
        case ScopeTheme.dark: themeSelector.selectedSegmentIndex = 0
        case ScopeTheme.darklight: themeSelector.selectedSegmentIndex = 1
        case ScopeTheme.bright: themeSelector.selectedSegmentIndex = 2
        case ScopeTheme.day: themeSelector.selectedSegmentIndex = 3
        default: themeSelector.selectedSegmentIndex = 0
        }
//        if scope.settings.getWriteDepth() == 512 {
//            memorySizeSelector.selectedSegmentIndex = 0
//        }
//        else if scope.settings.getWriteDepth() == 4096 {
//            memorySizeSelector.selectedSegmentIndex = 1
//        }
                
        
//        readCharText.text = nil
//        promStatus.text = nil
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.fpgaEraseComplete), name: ScopeFpgaUpdate.Notifications.EraseComplete, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.fpgaProgramComplete), name: ScopeFpgaUpdate.Notifications.UpdateComplete, object: nil)
//    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
        ScopeTheme.manager.register(themeable: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func apply(theme: ScopeTheme) {
        clearTraceButton.borderColor = theme.tint
        clearTraceButton.setTitleColor(theme.tint, for: UIControlState.normal)
        fullCalButton.borderColor = theme.tint
        fullCalButton.setTitleColor(theme.tint, for: UIControlState.normal)
        clearCalButton.borderColor = theme.tint
        clearCalButton.setTitleColor(theme.tint, for: UIControlState.normal)
        resetButton.borderColor = theme.tint
        resetButton.setTitleColor(theme.tint, for: UIControlState.normal)
        deepSleepButton.borderColor = theme.tint
        deepSleepButton.setTitleColor(theme.tint, for: UIControlState.normal)
        
        fullFrameLabel.textColor = theme.text
        showPtsLabel.textColor = theme.text
        sincInterpLabel.textColor = theme.text
        
        themeLabel.textColor = theme.text
        themeSelector.tintColor = theme.tint
        
        self.view.backgroundColor = theme.bgPrimary
        
        
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
