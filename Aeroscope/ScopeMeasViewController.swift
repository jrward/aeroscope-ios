//
//  ScopeMeasViewController.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 1/5/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

class ScopeMeasViewController : UIViewController{
    
    let scope = Scope.sharedInstance
    
    @IBOutlet weak var measLabel: UILabel! {
        didSet {
            //measLabel.textColor = UIColor(red: 171.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            measLabel.textColor = UIColor.gray
            measLabel.text = nil
            updateMeasLabel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeasLabel), name: ScopeMeasurementCenter.notifications.listChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeasLabel), name: ScopeMeasurementCenter.notifications.measUpdated, object: nil)
    }
    
    func updateMeasLabel() {
        measLabel.text = nil
        //statusLabel.text = String(format: "%s\t\t", scope.measure.getText(meas: el)))
        for el in scope.measure.measList {
            measLabel.text = (measLabel.text ?? "") + scope.measure.getText(meas: el).padding(toLength: 18, withPad: " ", startingAt: 0)
        }
        
        //measLabel.text = String(format: "%2s %5s/div  %5s/div    FPS: %3.2f    P-P: %3i", coupling!, vertSetting!, horizSetting!, fpsCapture, peakToPeak)
    }
    

    
}
