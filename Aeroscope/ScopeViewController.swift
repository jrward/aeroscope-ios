//
//  ScopeViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 10/4/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit

extension UIViewController{
    func presentViewControllerFromVisibleViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let navigationController = self as? UINavigationController, let topViewController = navigationController.topViewController {
            topViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent: viewControllerToPresent, animated: true, completion: completion)
        }
        else if (presentedViewController != nil) {
            presentedViewController!.presentViewControllerFromVisibleViewController(viewControllerToPresent: viewControllerToPresent, animated: true, completion: completion)
        }
        else {
            present(viewControllerToPresent, animated: true, completion: completion)
        }
    }
}

class ScopeViewController: UIViewController {
    
    let scope = Scope.sharedInstance


    
    @IBOutlet weak var horizControl: HorizControl!
    @IBOutlet weak var vertControl: VertControl!
    @IBOutlet weak var triggerControl: TriggerControl!
    @IBOutlet weak var offsetControl: OffsetControl!
    @IBOutlet weak var measureControl: MeasureControl!
    @IBOutlet weak var wirelessControl: WirelessControl!
    @IBOutlet weak var settingsControl: SettingsControl!
    @IBOutlet weak var hamburgerControl: HamburgerControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showError(_:)), name: ScopeTelemetry.notifications.error, object: nil)
        
        
        //TODO: Move this into Scope Top model
        Timer.scheduledTimer(timeInterval: 0.09, target: self, selector: #selector(ScopeViewController.updateSettings), userInfo: nil, repeats: true)

        vertControl.registerVC(source: self)
        
        horizControl.registerVC(source: self)
        
        triggerControl.registerVC(source: self)
        
        offsetControl.registerVC(source: self)
        
        measureControl.registerVC(source: self)
        
        wirelessControl.registerVC(source: self)
        
        settingsControl.registerVC(source: self)
        
        hamburgerControl.registerVC(source: self)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if !scope.comms.isPoweredOn() {
//            let alertView = UIAlertController(title: "Error", message: "Bluetooth is not enabled. Please enable bluetooth to connect to Aeroscope.", preferredStyle: .alert)
//            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
//            print("presenting BTLE warning")
//            //self.presentViewControllerFromVisibleViewController(viewControllerToPresent: alertView, animated: true)
//            self.present(alertView, animated: true, completion: nil)
//        }
        
        //scope.comms.startScanning()
        print("view appeared")
        
    }
    
    

    
    func updateSettings() {
        scope.updateSettings()
    }

    
    func showError(_ notification: Notification) {
        if let error = notification.userInfo?["error"] as? ScopeError {
            let alertView = UIAlertController(title: "Error", message: error.description(), preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
            
            self.presentViewControllerFromVisibleViewController(viewControllerToPresent: alertView, animated: true)
            
        }
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
