//
//  WirelessControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/22/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class WirelessControl : ScopeUIControl {
    
    let connectStatus = Scope.sharedInstance.connection.status
    var ctrlItem = UIImageView()
    var bundle : Bundle!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bundle = Bundle(for: type(of: self))

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        bundle = Bundle(for: type(of: self))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(WirelessControl.connectPeripheral), name: ScopeConnection.notifications.connect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WirelessControl.disconnectPeripheral), name: ScopeConnection.notifications.disconnect, object: nil)
    
    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
        
        if connectStatus == .connected {
            connectPeripheral()
        }
    }

    
    
//    override func isPressed() {
//    
//        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let popover = myStoryboard.instantiateViewController(withIdentifier: "wirelessVC")
//        popover.modalPresentationStyle = .popover
//        let popController = popover.popoverPresentationController
//        popController!.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
//        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
//        popController!.sourceView = self
//        popController!.sourceRect = self.bounds
//        sourceVC.present(popover, animated: true, completion: nil)
//    }
    
    
    func connectPeripheral() {
        ctrlItem.alpha = 1.0
    }
    
    func disconnectPeripheral() {
        ctrlItem.alpha = 0.1
    }
    
    func initCtrl() {
        
        //let wirelessImg = UIImage(named: "wireless")
        let wirelessImg = UIImage(named: "wireless", in: bundle, compatibleWith: self.traitCollection)
        ctrlItem.image = wirelessImg?.withRenderingMode(.alwaysTemplate)
        ctrlItem.frame.size = CGSize(width: 44, height: 44)
        ctrlItem.tintColor = self.graphicColor
        ctrlItem.alpha = 0.1
        
        if self.frame.width <= 60 {
            self.title = nil
        }
//        if self.traitCollection.verticalSizeClass == .compact {
//            self.title = nil
//        }
        else {
            self.title = "Connection"
        }
        
        self.item = ctrlItem
//        self.popoverType = ScopeWirelessViewController.self
        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.popover = myStoryboard.instantiateViewController(withIdentifier: "wirelessVC")
        self.popover.modalPresentationStyle = .popover

        
        self.initView()
    }
    
    
//    override func prepareForInterfaceBuilder() {
//        //self.dynamicType.init(coder: NSCoder())
//        bundle = Bundle(for: type(of: self))
//        initCtrl()
//        super.prepareForInterfaceBuilder()
//        
//    }
    
}
