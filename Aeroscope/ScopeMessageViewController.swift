//
//  ScopeMessageViewController.swift
//  Aeroscope
//
//  Created by Jonathan Ward on 7/3/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import UIKit
import Themeable

class ScopeMessageViewController: UIViewController, Themeable {

    let scope = Scope.sharedInstance
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        messageLabel.textColor = UIColor.gray
        messageLabel.text = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(messageChanged), name: ScopeMessage.notifications.messageChanged, object: nil)
    }
    
    @objc func messageChanged() {
        messageLabel.text = ScopeMessage.default.message
        print("Message Changed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.apply(theme: ScopeTheme.manager.activeTheme)
    }
    

    func apply(theme: ScopeTheme) {
        messageLabel.textColor = theme.textMessage
    }

}
