//
//  ScopeDebugViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 10/1/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import iOSDFULibrary


class ScopeDebugViewController: UIViewController, DFUProgressDelegate, LoggerDelegate {

    let scope = Scope.sharedInstance
    let telem = Scope.sharedInstance.telemetry
    var dfuController : DFUServiceController?
    
    @IBAction func done(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var setCalButton: UIButton!
    
    @IBOutlet weak var field20mV: UITextField!
    @IBOutlet weak var field50mV: UITextField!
    @IBOutlet weak var field100mV: UITextField!
    @IBOutlet weak var field200mV: UITextField!
    @IBOutlet weak var field500mV: UITextField!
    @IBOutlet weak var field1V: UITextField!
    @IBOutlet weak var field2_5V: UITextField!
    @IBOutlet weak var field5V: UITextField!
    @IBOutlet weak var field10V: UITextField!
    
    @IBAction func setCal(_ sender: UIButton) {
        
        
        let prefs = UserDefaults.standard
        if field20mV.text != "" {
            prefs.set(Int(field20mV.text!), forKey: "20mV")
        }
        
        if field50mV.text != "" {
            prefs.set(Int(field50mV.text!), forKey: "50mV")
        }
        
        if field100mV.text != ""{
            prefs.set(Int(field100mV.text!), forKey: "100mV")
        }
        
        if field200mV.text != ""{
            prefs.set(Int(field200mV.text!), forKey: "200mV")
        }
        
        if field500mV.text != ""{
            prefs.set(Int(field500mV.text!), forKey: "500mV")
        }
        
        if field1V.text != "" {
            prefs.set(Int(field1V.text!), forKey: "1V")
        }
        
        if field2_5V.text != ""{
            prefs.set(Int(field2_5V.text!), forKey: "2.5V")
        }
        
        if field5V.text != "" {
            prefs.set(Int(field5V.text!), forKey: "5V")

        }
        
        if field10V.text != ""{
            prefs.set(Int(field10V.text!), forKey: "10V")

        }
        
    }
    
    @IBOutlet weak var regAddr: UITextField!
    @IBOutlet weak var regValue: UITextField!
    @IBAction func send(_ sender: UIButton) {
        
        var error = false
        
        let regAddrInt = strtoul(regAddr.text!, nil, 16) 
        if (regAddrInt < 0 || regAddrInt > 19) {
            error = true
        }
        
        let regValInt = strtoul(regValue.text!, nil, 16) 
        if (regValInt < 0 || regValInt > 255) {
            error = true
        }
        
        if (error) {
            let alert = UIAlertController(title: "Alert", message: "Bad Commands", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        else {
            scope.settings.nextFrameSettings.fpga1_regs[Int(regAddrInt)] = UInt8(regValInt)
            scope.settings.nextFrameSettings.fpga_settings_updated = true
        }
        
        
        //Check for valid input in text fields
    }
    
    
    
    @IBOutlet weak var battReading: UILabel!
    @IBOutlet weak var tempReading: UILabel!
    @IBOutlet weak var accelReading: UILabel!
    
    @IBAction func telemScan(_ sender: UIButton) {
        scope.settings.cmd.reqTelemetry()
    }
    
    func updateMeasurements() {
        battReading.text = String(telem.batt.level ?? 0)
        tempReading.text = String(telem.temp.celsius ?? 0 )
        
    }
    
    @IBOutlet weak var hwVersReading: UILabel!
    @IBOutlet weak var fpgaVersReading: UILabel!
    @IBOutlet weak var firmVersReading: UILabel!
    @IBOutlet weak var serNumReading: UILabel!
    
    @IBAction func versScan(_ sender: UIButton) {
        scope.settings.cmd.reqVersion()
    }
    
    func updateVersions() {
        hwVersReading.text = String(telem.hwRev)
        fpgaVersReading.text = String(telem.fpgaRev)
        firmVersReading.text = String(telem.fwRev)
        serNumReading.text = String(telem.serNum)
    }
    
    var buttonCount : Int = 0
    
    @IBOutlet weak var buttonReading: UILabel!
    
    func updateButton() {
        buttonCount += 1
        buttonReading.text = String(buttonCount)
    }
    
    @IBOutlet weak var fpgaUpdateLabel: UILabel!
    @IBOutlet weak var fpgaUpdateButton: UIButton!
    
    @IBAction func fpgaUpdateTouched(_ sender: UIButton) {
        scope.fpgaUpdate.fpgaUpdate(NSDataAsset(name: "Fpga_Image")!.data)
    }
    
    func fpgaEraseComplete() {
        fpgaUpdateLabel.text = "Erase Complete"
    }
    
    func fpgaUpdateComplete() {
        fpgaUpdateLabel.text = "Update Complete"
    }
    
    func fpgaPacketsSent() {
        fpgaUpdateLabel.text = "\(scope.fpgaUpdate.numSent) / \(scope.fpgaUpdate.fpgaImage.count)"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regAddr.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeasurements), name: ScopeTelemetry.notifications.measurements, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVersions), name: ScopeTelemetry.notifications.versions, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateButton), name: ScopeTelemetry.notifications.buttonDown, object: nil)
        
        battReading.text = String(describing: telem.batt.level)
        tempReading.text = String(describing: telem.temp)
        accelReading.text = String("XXX")
        
        
        hwVersReading.text = String(telem.hwRev)
        fpgaVersReading.text = String(telem.fpgaRev)
        firmVersReading.text = String(telem.fwRev)
        
        
        buttonReading.text = String(buttonCount)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(fpgaEraseComplete), name: ScopeFpgaUpdate.notifications.eraseComplete, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fpgaUpdateComplete), name: ScopeFpgaUpdate.notifications.updateComplete, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fpgaPacketsSent), name: ScopeFpgaUpdate.notifications.packetsSent, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dfuStateDidChange), name: FirmwareUpdate.notifications.dfuState, object: nil)
        
        fpgaUpdateLabel.text = nil


        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dfuUploadProgressView.progress = 0.0
        dfuUploadStatus.text = ""
        dfuStatusLabel.text  = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    @IBOutlet weak var dfuActivityIndicator  : UIActivityIndicatorView!
    @IBOutlet weak var dfuStatusLabel        : UILabel!
    @IBOutlet weak var dfuUploadProgressView : UIProgressView!
    @IBOutlet weak var dfuUploadStatus       : UILabel!
    
    @IBOutlet weak var firmUpdateButton: UIButton!
    
    @IBAction func firmUpdatePressed(_ sender: UIButton) {
        dfuActivityIndicator.startAnimating()

        scope.firmUpdate.startDFUProcess(delegate: self)
        dfuController = scope.firmUpdate.dfuController

    }

    func dfuStateDidChange() {
    
        if let state = scope.firmUpdate.dfuState {
            switch state {
            case .completed, .disconnecting:
                    self.dfuActivityIndicator.stopAnimating()
                    self.dfuUploadProgressView.setProgress(0, animated: true)
            case .aborted:
                    self.dfuActivityIndicator.stopAnimating()
                    self.dfuUploadProgressView.setProgress(0, animated: true)
            default:
                break
            }
        
            dfuStatusLabel.text = state.description()
            print("Changed state to: \(state.description())")
        }
    
    }
    
    func dfuError() {
        if let dfuErrorMessage = scope.firmUpdate.dfuErrorMessage {
            let message : String = dfuErrorMessage.message
            let error = dfuErrorMessage.error
            dfuStatusLabel.text = "Error \(error.rawValue): \(message)"
            dfuActivityIndicator.stopAnimating()
            dfuUploadProgressView.setProgress(0, animated: true)
            print("Error \(error.rawValue): \(message)")
        }
    }


    
    //MARK: - DFUProgressDelegate
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        dfuUploadProgressView.setProgress(Float(progress)/100.0, animated: true)
        dfuUploadStatus.text = String(format: "Part: %d/%d\nSpeed: %.1f KB/s\nAverage Speed: %.1f KB/s",
                                      part, totalParts, currentSpeedBytesPerSecond/1024, avgSpeedBytesPerSecond/1024)
    }
    
    //MARK: - LoggerDelegate
    
    func logWith(_ level: LogLevel, message: String) {
        print("\(level.name()): \(message)")
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
