//
//  SettingsControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/22/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SettingsControl : ScopeUIControl {
    
    var ctrlItem = UIImageView()
    var bundle : Bundle!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bundle = Bundle(for: type(of: self))

    }
    
    required init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder, title: "Settings", item: ctrlItem, popoverType: SettingsPopoverVC.self)
        super.init(coder: aDecoder)
        bundle = Bundle(for: type(of: self))

    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    func initCtrl() {
        let settingsImg = UIImage(named: "settings", in: bundle, compatibleWith: self.traitCollection)
        ctrlItem.image = settingsImg?.withRenderingMode(.alwaysTemplate)
        ctrlItem = UIImageView(image: settingsImg)
        ctrlItem.frame.size = CGSize(width: 44,height: 44)
        ctrlItem.tintColor = self.graphicColor
        self.title = "Settings"
        self.item = ctrlItem


        let myStoryboard = UIStoryboard(name: "Main", bundle: bundle)
        self.popover = myStoryboard.instantiateViewController(withIdentifier: "settingsVC")
        self.popover.modalPresentationStyle = .popover

        
        
        self.initView()
        
    }
    

    
//    override func isPressed() {
//        
//        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let popover = myStoryboard.instantiateViewController(withIdentifier: "settingsVC")
//        popover.modalPresentationStyle = .popover
//        let popController = popover.popoverPresentationController
//        popController!.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
//        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
//        popController!.sourceView = self
//        popController!.sourceRect = self.bounds
//        sourceVC.present(popover, animated: true, completion: nil)
//    }
    
    override func prepareForInterfaceBuilder() {
        bundle = Bundle(for: type(of: self))

        initCtrl()
//        self.addControlItem()
        super.prepareForInterfaceBuilder()
    }
    
}
