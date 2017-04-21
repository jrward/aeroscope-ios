//
//  HamburgerControl.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 3/5/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

//@IBDesignable
class HamburgerControl : ScopeUIControl {
    
    var ctrlItem = UIImageView()
    var bundle : Bundle!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bundle = Bundle(for: type(of: self))

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        bundle = Bundle(for: type(of: self))
    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    

    func initCtrl() {
        let hamburgerImg = UIImage(named: "hamburger", in: bundle, compatibleWith: self.traitCollection)

        ctrlItem.image = hamburgerImg?.withRenderingMode(.alwaysTemplate)
        ctrlItem.frame.size = CGSize(width: 44, height: 44)
        ctrlItem.tintColor = Scope.globalTintColor
        ctrlItem.alpha = 1.0
        
        self.title = nil
    
        self.item = ctrlItem
        
        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.popover = myStoryboard.instantiateViewController(withIdentifier: "hamburgerVC")
        popover.modalPresentationStyle = .popover



        self.initView()
        

    }
    
//    override func isPressed() {
//        
//        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let popover = myStoryboard.instantiateViewController(withIdentifier: "hamburgerVC")
//        debugPrint("Printing for the sake of initializing view of VC: \(popover.view)")
//        popover.modalPresentationStyle = .popover
//        let popController = popover.popoverPresentationController
//        popController!.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
//        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
//        popController!.sourceView = self
//        popController!.sourceRect = self.bounds
//        
//        self.sourceVC.present(popover, animated: true, completion: nil)
//    }
    
    
//    override func prepareForInterfaceBuilder() {
//        bundle = Bundle(for: type(of: self))
//        initCtrl()
//        super.prepareForInterfaceBuilder()
//    }
    
}

//class HamburgerPopoverVC : UIViewController {
//    
//    override func viewDidLoad() {
//        self.preferredContentSize = CGSize(width: 300, height: 500)
//        
//    }
//    
//}
