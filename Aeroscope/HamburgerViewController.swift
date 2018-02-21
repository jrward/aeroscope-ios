//
//  HamburgerViewController.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 3/5/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit
import Themeable


class HamburgerViewController: UIViewController, Themeable {

    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func donePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var vertControl: VertControl!
    @IBOutlet weak var horizControl: HorizControl!
    @IBOutlet weak var triggerControl: TriggerControl!
    @IBOutlet weak var offsetControl: OffsetControl!
    @IBOutlet weak var measureControl: MeasureControl!
    @IBOutlet weak var wirelessControl: WirelessControl!
    @IBOutlet weak var settingsControl: SettingsControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vertControl.registerVC(source: self)
        
        horizControl.registerVC(source: self)
        
        triggerControl.registerVC(source: self)
        
        offsetControl.registerVC(source: self)
        
        measureControl.registerVC(source: self)
        
        wirelessControl.registerVC(source: self)
        
        settingsControl.registerVC(source: self)
        

        ScopeTheme.manager.register(themeable: self)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func apply(theme: ScopeTheme) {
        self.view.backgroundColor = theme.bgApp
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
