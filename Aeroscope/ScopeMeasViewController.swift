//
//  ScopeMeasViewController.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 1/5/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit
import Themeable

class ScopeMeasViewController : UIViewController, Themeable{
    
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
        
        ScopeTheme.manager.register(themeable: self)
        
        if self.view.bounds.width < 600 {
            scope.measure.maxMeasurements = 2
        }
        
        else if self.view.bounds.width < 900 {
            scope.measure.maxMeasurements = 3
        }
        else {
            scope.measure.maxMeasurements = 4

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.apply(theme: ScopeTheme.manager.activeTheme)
    }
    
    @objc func updateMeasLabel() {
        measLabel.text = nil

        for el in scope.measure.measList {
            measLabel.text = (measLabel.text ?? "") + String(format: "%18s", (scope.measure.getText(meas: el) as NSString).cString(using: 8)!)
        }
        
    }
    
    func apply(theme: ScopeTheme) {
         measLabel.textColor = theme.textMeas
    }
    

    
}
