//
//  UIScopeControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/13/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit


//@IBDesignable
class ScopeUIControl : UIControl, UIPopoverPresentationControllerDelegate {
     
    var title : String?
    var font : UIFont = UIFont(name: "Helvetica Neue", size: 14)!
    var item : UIView?
    
    let textColor = Scope.globalTintColor//UIColor.white//UIColor.lightGray//UIColor.white
    let graphicColor = Scope.globalTintColor//UIColor.lightGray//UIColor.white Scope.globalTintColor

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

        let width = bounds.size.width
        let height = bounds.size.height
        
        self.tintColor = Scope.globalTintColor
        self.addControlItem()
        item?.tintAdjustmentMode = .normal
        self.addTarget(self, action: #selector(ScopeUIControl.isPressed), for: .touchUpInside)
        
    }



    override var isHighlighted: Bool {
        didSet {
            //alpha = highlighted ? 0.6 : 1.0
            if isHighlighted { self.alpha = 0.6 }
                
            else {
                UIView.animate(withDuration: 0.25, animations: { _ in
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
    
    func isPressed() {
        let popController = popover.popoverPresentationController
        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
        popController!.delegate = self
        popController!.sourceView = self
        popController!.sourceRect = self.bounds
        //popController!.backgroundColor = UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0)
        popController!.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
//        popController!.presentedView()?.layer.borderColor = UIColor.blackColor().CGColor
//        popController!.presentedView()?.layer.borderWidth = 1.0
        sourceVC.present(popover, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {

        return UIModalPresentationStyle.none
    }
    
    
//    override func prepareForInterfaceBuilder() {
//        //initView()
//        super.prepareForInterfaceBuilder()
//        
//    }
    
    override func layoutSubviews() {
        initView()

        let width = bounds.size.width
        let height = bounds.size.height
        
        self.layer.cornerRadius = 5;
        //self.layer.masksToBounds = true;
        self.clipsToBounds = true
        
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 1.0;
        self.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
        
        if title != nil  {
            
            let titleFont = font
            let titleRect = CGRect(x: 0,y: 2, width: width, height: height/4)
            let titleTxt = UILabel(frame: titleRect)
            titleTxt.text = title
            titleTxt.font = titleFont
            titleTxt.textColor = textColor//self.tintColor
            titleTxt.textAlignment = NSTextAlignment.center
            self.addSubview(titleTxt)

        }
        
        self.addControlItem()
        self.addTarget(self, action: #selector(ScopeUIControl.isPressed), for: .touchUpInside)
    }
    

    

}
