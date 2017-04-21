//
//  ScopeViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit

class ScopeCtrlViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let scope = Scope.sharedInstance
    
    
    @IBOutlet weak var pickerSettings: UIPickerView!
    
    enum pickerComponent : Int {
        case vert
        case horiz
        case Count
        
        static var count : Int {
            get {
                return pickerComponent.Count.rawValue
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(550, 300)
        
        pickerSettings.delegate = self
        pickerSettings.dataSource = self
        
        print(scope.settings.record_length.value)
        pickerSettings.selectRow(scope.settings.vertSettings.indexOf(scope.settings.vert.value) ?? 0, inComponent: pickerComponent.vert.rawValue, animated: false)
        
        
        pickerSettings.selectRow(scope.settings.horizSettings.indexOf(scope.settings.horiz.value) ?? 0, inComponent: pickerComponent.horiz.rawValue, animated: false)
        print("I Loaded")
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

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == pickerComponent.vert.rawValue {
            print(scope.settings.vertSettings[row])
            scope.settings.vert.value  = scope.settings.vertSettings[row]
        }
        
        else {
            print(scope.settings.horizSettings[row])
            scope.settings.horiz.value = scope.settings.horizSettings[row]
        }
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerComponent.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == pickerComponent.vert.rawValue {
            return scope.settings.vertSettings.count
        }
            
        else {
            return scope.settings.horizSettings.count
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == pickerComponent.vert.rawValue {
           return scope.settings.vertSettings[row]
        }
            
        else {
            return scope.settings.horizSettings[row]
        }
        
    }

}
