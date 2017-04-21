//
//  OffsetControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/16/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class OffsetControl : ScopeUIControl {
    
    var ctrlItem = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOffset) , name: ScopeSettings.notifications.offset, object: nil)
    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    
    
    func initCtrl() {
        
       
        let offsetVolts = Translator.toVoltsFrom(
            offset: scope.settings.getOffset(),
            conv: scope.settings.getVertMeta().offsetConv,
            voltConv: scope.settings.getVertMeta().voltsPerBit)
        ctrlItem.text = Translator.toStringFrom(voltage: offsetVolts)
        ctrlItem.font = UIFont(name: "Helvetica Neue", size: 18)!
        ctrlItem.sizeToFit()
        ctrlItem.frame.size.width = self.frame.size.width
        ctrlItem.textAlignment = .center
        ctrlItem.textColor = self.textColor //Scope.globalTintColor
        self.title = "Offset"
        self.item = ctrlItem
        
        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)

        self.popover = myStoryboard.instantiateViewController(withIdentifier: "offsetVC")
        self.popover.modalPresentationStyle = .popover

        self.initView()

    }
    
    func updateOffset() {
        let offsetVolts = Translator.toVoltsFrom(
            offset: scope.settings.getOffset(),
            conv: scope.settings.getVertMeta().offsetConv,
            voltConv: scope.settings.getVertMeta().voltsPerBit)
        ctrlItem.text = Translator.toStringFrom(voltage: offsetVolts)
    }
    
//    override func prepareForInterfaceBuilder() {
//        initCtrl()
//        super.prepareForInterfaceBuilder()
//    }
    
}
