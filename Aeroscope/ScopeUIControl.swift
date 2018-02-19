//
//  UIScopeControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/13/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit
import Themeable


//@IBDesignable
class ScopeUIControl : UIControl, UIPopoverPresentationControllerDelegate, Themeable {
     
    var title : String?
    var font : UIFont = UIFont(name: "Helvetica Neue", size: 14)!
    var item : UIView?
    var titleTxt : UILabel?
    
    var textColor = ScopeTheme.manager.activeTheme.text
    var graphicColor = ScopeTheme.manager.activeTheme.text
    
    var popover : UIViewController!
    var sourceVC : UIViewController!
    let scope = Scope.sharedInstance
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (coder aDecoder: NSCoder, title: String, item: UIView) {
        super.init(coder: aDecoder)!
        self.title = title
        self.item = item
    }

    func initView() {
        assert(self.popover != nil, "popover needs to be set by subclass")
        popover.modalPresentationStyle = .popover
        
        self.tintColor = ScopeTheme.manager.activeTheme.tint
        self.addControlItem()
        item?.tintAdjustmentMode = .normal
        self.addTarget(self, action: #selector(ScopeUIControl.isPressed), for: .touchUpInside)
        
    }



    override var isHighlighted: Bool {
        didSet {
            //alpha = highlighted ? 0.6 : 1.0
            if isHighlighted { self.alpha = 0.6 }
                
            else {
                UIView.animate(withDuration: 0.25, animations: { 
                    self.alpha = 1.0 }) 
            }
        }
    }
    
    func addControlItem() {
        let width = bounds.size.width
        let height = bounds.size.height
        
        if self.item != nil {
            //self.item!.frame = imgRect
            self.addSubview(self.item!)
            //item!.sizeToFit()
            item!.center.x = width/2
            
            if self.title != nil {
                item!.center.y = height*0.625
            }
            else {
                item!.center.y = height/2
            }
        }
       
    }
    
    func registerVC(source: UIViewController) {
        self.sourceVC = source
    }
    
    @objc func isPressed() {
        let popController = popover.popoverPresentationController
        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
        popController!.delegate = self
        popController!.sourceView = self
        popController!.sourceRect = self.bounds
        
        //TODO: Define background color in popover VC (so it receives changes)
        popController!.backgroundColor = ScopeTheme.manager.activeTheme.bgPrimary

        sourceVC.present(popover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {

        return UIModalPresentationStyle.none
    }
    
    override func layoutSubviews() {
        initView()

        let width = bounds.size.width
        let height = bounds.size.height
        
        self.layer.cornerRadius = 5;
        //self.layer.masksToBounds = true;
        self.clipsToBounds = true
        
        self.layer.borderColor = ScopeTheme.manager.activeTheme.border.cgColor
        self.layer.borderWidth = 1.0;
        self.backgroundColor = ScopeTheme.manager.activeTheme.fill
        
        if title != nil  {
            
            let titleFont = font
            let titleRect = CGRect(x: 0,y: 2, width: width, height: height/4)
            titleTxt = UILabel(frame: titleRect)
            titleTxt!.text = title
            titleTxt!.font = titleFont
            titleTxt!.textColor = ScopeTheme.manager.activeTheme.text
            titleTxt!.textAlignment = NSTextAlignment.center
            self.addSubview(titleTxt!)

        }
        
        self.addControlItem()
        self.addTarget(self, action: #selector(ScopeUIControl.isPressed), for: .touchUpInside)
        ScopeTheme.manager.register(themeable: self)
    }
    
    
    func apply(theme: ScopeTheme) {
        textColor = theme.text
        graphicColor = theme.text
        if title != nil {
            titleTxt!.textColor = theme.text
        }
        self.layer.borderColor = theme.border.cgColor
        self.backgroundColor = theme.fill
        self.tintColor = theme.tint
        
        if let textItem = item as? UILabel {
            textItem.textColor = theme.text
        }
        if let graphicItem = item as? UIImageView {
            graphicItem.tintColor = theme.text
        }


    }

    

}
