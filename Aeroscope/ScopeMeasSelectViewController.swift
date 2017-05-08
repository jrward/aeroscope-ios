//
//  ScopeMeasurementVC.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 1/4/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit
import Themeable

class ScopeMeasSelectViewController: UIViewController, Themeable {
    let scope = Scope.sharedInstance

    @IBOutlet weak var vppLabel: UILabel!
    @IBOutlet weak var vppSwitch: UISwitch!
    @IBAction func vppSwitchChanged(_ sender: UISwitch) {
        if vppSwitch.isOn {
            scope.measure.add(meas: .vpp)
        }
        else {
            scope.measure.remove(meas: .vpp)
        }
    }
    
    @IBOutlet weak var vmaxLabel: UILabel!
    @IBOutlet weak var vmaxSwitch: UISwitch!
    @IBAction func vmaxSwitchChanged(_ sender: UISwitch) {
        if vmaxSwitch.isOn {
            scope.measure.add(meas: .vmax)
        }
        else {
            scope.measure.remove(meas: .vmax)
        }
    }
    
    @IBOutlet weak var vminLabel: UILabel!
    @IBOutlet weak var vminSwitch: UISwitch!
    @IBAction func vminSwitchChanged(_ sender: UISwitch) {
        if vminSwitch.isOn {
            scope.measure.add(meas: .vmin)
        }
        else {
            scope.measure.remove(meas: .vmin)
        }
    }
    
    @IBOutlet weak var vavgLabel: UILabel!
    @IBOutlet weak var vavgSwitch: UISwitch!
    @IBAction func vavgSwitchChanged(_ sender: UISwitch) {
        if vavgSwitch.isOn {
            scope.measure.add(meas: .vavg)
        }
        else {
            scope.measure.remove(meas: .vavg)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vppSwitch.isOn = scope.measure.measList.contains(.vpp)
        vmaxSwitch.isOn = scope.measure.measList.contains(.vmax)
        vminSwitch.isOn = scope.measure.measList.contains(.vmin)
        vavgSwitch.isOn = scope.measure.measList.contains(.vavg)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
    }
    
    func apply(theme: ScopeTheme) {
        vppLabel.textColor = theme.text
        vmaxLabel.textColor = theme.text
        vminLabel.textColor = theme.text
        vavgLabel.textColor = theme.text
    }


}
