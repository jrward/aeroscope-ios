//
//  TriggerControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/17/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

protocol CtrlItemDelegate {
    func setImage(_ image: UIImage)
}


@IBDesignable
class TriggerControl : ScopeUIControl, CtrlItemDelegate {
    
    let triggerPopoverVC = TriggerPopoverVC()
    var ctrlItem = UIImageView()
    var bundle : Bundle!

    
    let posTrigImg = UIImage(named: "pos_edge_trigger")
    let negTrigImg = UIImage(named: "neg_edge_trigger")
    let anyTrigImg = UIImage(named: "any_edge_trigger")
    
    //var triggerControlVC : UIViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bundle = Bundle(for: type(of: self))

    }

    required init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder, title: "Trigger", item: ctrlItem, popoverType: TriggerPopoverVC.self)
        super.init(coder: aDecoder)
        
        bundle = Bundle(for: type(of: self))
        //triggerControlVC = TriggerControlVC(view: self)
        
    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    func setImage(_ image: UIImage) {
        ctrlItem.image = image.withRenderingMode(.alwaysTemplate)
    }
    
    func initCtrl() {
        let img = UIImage(named: "pos_edge_trigger", in: bundle, compatibleWith: self.traitCollection)
        ctrlItem.image = img?.withRenderingMode(.alwaysTemplate)
        ctrlItem.sizeToFit()
        ctrlItem.tintColor = self.graphicColor
        ctrlItem.isHighlighted = false
        //ctrlItem.i
        self.title = "Trigger"
        self.item = ctrlItem
        self.popover = triggerPopoverVC

        self.initView()
    }
    
    override func isPressed() {
        super.isPressed()
        let trigPopover = self.popover as! TriggerPopoverVC
        trigPopover.delegate = self

    }
    
    
    override func prepareForInterfaceBuilder() {
        bundle = Bundle(for: type(of: self))
        initCtrl()
        super.prepareForInterfaceBuilder()
    }
}


class TriggerPopoverVC : UIViewController {
    
    let scope = Scope.sharedInstance
    var lpTrigBtn : UIButton!
    var autoTrigBtn : UIButton!
    
    var delegate : CtrlItemDelegate?
    
    var trigCtrlRadio : UISegmentedControl!
    
    struct TriggerIndex {
        static var pos = 0
        static var neg = 1
        static var any = 2
    }
    
    //let posTrigImg = UIImage(named: <#T##String#>, in: <#T##Bundle?#>, compatibleWith: <#T##UITraitCollection?#>)
    let posTrigImg = UIImage(named: "pos_edge_trigger")
    let negTrigImg = UIImage(named: "neg_edge_trigger")
    let anyTrigImg = UIImage(named: "any_edge_trigger")
    let lpImg = UIImage(named: "nr_trigger")
    let autoImg = UIImage(named: "auto_trigger")


    
//    var autoTrigButton: UIButton! {
//        didSet {
//            autoTrigSelected = true
//            //autoTrigButton.tintColor = UIColor.blueColor()
//            autoTrigButton.backgroundColor = nil
//            scope.settings.trigCtrl.autoTrig.value = true
//        }
//    }
//    
//    var lpTrigButton: UIButton! {
//        didSet {
//            lpTrigSelected = false
//            //lpTrigButton.tintColor = UIColor.blueColor()
//            lpTrigButton.backgroundColor = nil
//            scope.settings.trigCtrl.lowPassTrig.value = false
//        }
//    }
//    
//
//    var lpTrigSelected = false {
//        didSet {
//            if (lpTrigSelected) {
//                let image = UIImage(named: "lp_trigger_sel")
//                image!.imageWithRenderingMode(.AlwaysTemplate)
//                lpTrigButton.setImage(image, forState: .Normal)
//                scope.settings.trigCtrl.lowPassTrig.value = true
//            }
//                
//            else {
//                let image = UIImage(named: "lp_trigger")
//                image!.imageWithRenderingMode(.AlwaysTemplate)
//                lpTrigButton.setImage(image, forState: .Normal)
//                scope.settings.trigCtrl.lowPassTrig.value = false
//            }
//        }
//    }
//
//    func lpTrigTouched(sender: UIButton) {
//        lpTrigSelected = !lpTrigSelected
//    }
//    
//    
//    var autoTrigSelected = true {
//        didSet {
//            if (autoTrigSelected) {
//                let image = UIImage(named: "auto_trigger_sel")
//                image!.imageWithRenderingMode(.AlwaysTemplate)
//                autoTrigButton.setImage(image, forState: .Normal)
//                scope.settings.trigCtrl.autoTrig.value = true
//            }
//                
//            else {
//                let image = UIImage(named: "auto_trigger")
//                image!.imageWithRenderingMode(.AlwaysTemplate)
//                autoTrigButton.setImage(image, forState: .Normal)
//                scope.settings.trigCtrl.autoTrig.value = false
//            }
//        }
//    }
//    
//
//    
//     func autoTrigTouched(sender: UIButton) {
//        autoTrigSelected = !autoTrigSelected
//    }

    
    
    override func viewDidLoad() {
        self.preferredContentSize = CGSize(width: 300, height: 60)

        
        self.view.tintColor = ScopeTheme.manager.activeTheme.tint
        
        let radioItems = [posTrigImg, negTrigImg, anyTrigImg]
        
        trigCtrlRadio = UISegmentedControl(items: radioItems as [AnyObject])
        //trigCtrlRadio.center.y = 30
        //trigCtrlRadio.frame.origin.x = 10
        trigCtrlRadio.sizeToFit()
        //trigCtrlRadio.bounds.size.height = 44
        

        trigCtrlRadio.addTarget(self, action: #selector(trigCtrlPressed), for: UIControl.Event.valueChanged)
        self.view.addSubview(trigCtrlRadio)
        
        lpTrigBtn = UIButton(type: .system)
        lpTrigBtn.frame = CGRect(x: 10,y: 5,width: 44,height: 44)
        lpTrigBtn.layer.borderWidth = 1.0
        lpTrigBtn.layer.cornerRadius = 5
        lpTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
        lpTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tint
        lpTrigBtn.setImage(lpImg, for: UIControl.State())
        lpTrigBtn.addTarget(self, action: #selector(TriggerPopoverVC.lpBtnPressed), for: UIControl.Event.touchUpInside)

        self.view.addSubview(lpTrigBtn)
        

        
        
        autoTrigBtn = UIButton(type: .system)
        autoTrigBtn.frame = CGRect(x: 10,y: 5,width: 44,height: 44)
        autoTrigBtn.layer.borderWidth = 1.0
        autoTrigBtn.layer.cornerRadius = 5
        autoTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
        autoTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tint
        autoTrigBtn.setImage(autoImg, for: UIControl.State())
        //autoTrigBtn.setImage(autoImg, forState: .Highlighted)
        autoTrigBtn.addTarget(self, action: #selector(TriggerPopoverVC.autoBtnPressed), for: UIControl.Event.touchUpInside)
        self.view.addSubview(autoTrigBtn)

        
        //trigCtrlRadio.translatesAutoresizingMaskIntoConstraints = false
        trigCtrlRadio.translatesAutoresizingMaskIntoConstraints = false
        lpTrigBtn.translatesAutoresizingMaskIntoConstraints = false
        autoTrigBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: trigCtrlRadio, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leadingMargin, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: trigCtrlRadio, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerYWithinMargins, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: trigCtrlRadio, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: 44).isActive = true
        
        NSLayoutConstraint(item: trigCtrlRadio, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true

        let lpSpacingConst = NSLayoutConstraint(item: lpTrigBtn, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: trigCtrlRadio, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 15.0)
        let lpCenterConst = NSLayoutConstraint(item: lpTrigBtn, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: trigCtrlRadio, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)
        let lpHeightConst = NSLayoutConstraint(item: lpTrigBtn, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        let lpWidthConst = NSLayoutConstraint(item: lpTrigBtn, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: 44)
        
        let autoSpacingCont = NSLayoutConstraint(item: autoTrigBtn, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lpTrigBtn, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 15.0)
        let autoCenterConst = NSLayoutConstraint(item: autoTrigBtn, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: trigCtrlRadio, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([lpSpacingConst, lpCenterConst, lpHeightConst, lpWidthConst, autoSpacingCont, autoCenterConst])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if scope.settings.getTrigMode() == .any {
            trigCtrlRadio.selectedSegmentIndex = TriggerIndex.any
        }
        else if scope.settings.getTrigMode() == .neg {
            trigCtrlRadio.selectedSegmentIndex = TriggerIndex.neg
        }
        else {
            trigCtrlRadio.selectedSegmentIndex = TriggerIndex.pos
        }
        
        lpSelected = scope.settings.getLpTrig()
        
        autoSelected = scope.settings.getAutoTrig()
        
        trigCtrlRadio.tintColor = ScopeTheme.manager.activeTheme.tint

    }
    
    @objc func trigCtrlPressed() {
        if trigCtrlRadio.selectedSegmentIndex == TriggerIndex.pos {
            scope.settings.setTrigMode(.pos)
            delegate?.setImage(posTrigImg!)
            
        }
        
        else if trigCtrlRadio.selectedSegmentIndex == TriggerIndex.neg {
            scope.settings.setTrigMode(.neg)
            delegate?.setImage(negTrigImg!)
        }
        
        else if trigCtrlRadio.selectedSegmentIndex == TriggerIndex.any {
            scope.settings.setTrigMode(.any)
//            scope.settings.trigCtrl.posSlopeTrig.value = true
//            scope.settings.trigCtrl.negSlopeTrig.value = true
            delegate?.setImage(anyTrigImg!)
            
            lpSelected = false
        }
        
    }
    
    var lpSelected : Bool = false {
        didSet {
            if (lpSelected) {
                lpTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tintAccent
                lpTrigBtn.backgroundColor = ScopeTheme.manager.activeTheme.tint
                lpTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
                scope.settings.lpTrigEnable()
                
            }
            else {
                lpTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tint
                lpTrigBtn.backgroundColor = ScopeTheme.manager.activeTheme.bgPrimary
                lpTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
                scope.settings.lpTrigDisable()
            }

        }
    }
    @objc func lpBtnPressed() {
        //lpTrigBtn.selected = !lpTrigBtn.selected

        if trigCtrlRadio.selectedSegmentIndex != TriggerIndex.any {
            lpSelected = !lpSelected
        }
        
//        if (lpSelected) {
//            lpTrigBtn.tintColor = UIColor.whiteColor()
//            lpTrigBtn.backgroundColor = self.view.tintColor
//            scope.settings.trigCtrl.lowPassTrig.value = true
//
//        }
//        else {
//            lpTrigBtn.tintColor = self.view.tintColor
//            lpTrigBtn.backgroundColor = self.view.backgroundColor
//            scope.settings.trigCtrl.lowPassTrig.value = false
//        }
    }
    
    var autoSelected : Bool = true {
        didSet {
            if autoSelected {
                autoTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tintAccent
                autoTrigBtn.backgroundColor = ScopeTheme.manager.activeTheme.tint
                autoTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
                scope.settings.autoTrigEnable()
            }
                
            else {
                autoTrigBtn.tintColor = ScopeTheme.manager.activeTheme.tint
                autoTrigBtn.backgroundColor = self.view.backgroundColor
                autoTrigBtn.layer.borderColor = ScopeTheme.manager.activeTheme.tint.cgColor
                scope.settings.autoTrigDisable()
            }

        }
    }
    @objc func autoBtnPressed() {
        autoSelected = !autoSelected
//        if autoSelected {
//            autoTrigBtn.tintColor = UIColor.whiteColor()
//            autoTrigBtn.backgroundColor = self.view.tintColor
//            scope.settings.trigCtrl.autoTrig.value = true
//        }
//        
//        else {
//            autoTrigBtn.tintColor = self.view.tintColor
//            autoTrigBtn.backgroundColor = self.view.backgroundColor
//            scope.settings.trigCtrl.autoTrig.value = false
//        }
    }
}

//extension UIButton {
//    func setHighlighted()
//    {
//        if(highlighted) {
//            self.backgroundColor = UIColor(red: 1, green: 0.643, blue: 0.282, alpha: 1)
//
//        } else {
//            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        }
//        //self.setHighlighted()
//    }
//}

    
