//
//  ScopeSettingsViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 9/29/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit


class ScopeSettingsViewController: UIViewController {

    let scope = Scope.sharedInstance
    let comms = Scope.sharedInstance.comms
    let frame = Scope.sharedInstance.frame
    //let fpgaUpdate = ScopeFpgaUpdate(comms: Scope.sharedInstance.comms)
    
    @IBAction func done(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    
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
    
    
    
    
    @IBOutlet weak var showPtsSwitch: UISwitch!
    @IBAction func showPtsChanged(_ sender: UISwitch) {
        if showPtsSwitch.isOn {
            scope.appSettings.showPts = true
        }
        else {
            scope.appSettings.showPts = false
        }
    }
    
    
    @IBOutlet weak var sincInterpSwitch: UISwitch!
    
    @IBAction func sincInterpChanged(_ sender: UISwitch) {
        if sincInterpSwitch.isOn {
            scope.appSettings.interpolation = true
        }
        
        else {
            scope.appSettings.interpolation = false
        }
    }
    
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fullFrameSwitch.isOn = scope.appSettings.fullFrameDL
        sincInterpSwitch.isOn = scope.appSettings.interpolation
        showPtsSwitch.isOn = scope.appSettings.showPts
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
