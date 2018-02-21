//
//  MeasurementControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/22/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MeasureControl : ScopeUIControl {
    
    var ctrlItem = UILabel()
    var bundle : Bundle!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bundle = Bundle(for: type(of: self))

    }
    
    required init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder, title: "Measure", item: ctrlItem, popoverType: MeasurePopoverVC.self)
        super.init(coder: aDecoder)
        bundle = Bundle(for: type(of: self))

        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMeas), name: ScopeMeasurementCenter.notifications.listChanged, object: nil)
//        initCtrl()
        
        }
 
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    func initCtrl() {
        ctrlItem.text = "None"
        ctrlItem.font = UIFont(name: "Helvetica Neue", size: 18)!
        ctrlItem.sizeToFit()
        ctrlItem.frame.size.width = 60
        ctrlItem.textAlignment = .center
        ctrlItem.textColor = self.textColor //Scope.globalTintColor
        self.title = "Measure"
        self.item = ctrlItem
//        self.popoverType = MeasurePopoverVC.self
        
        let myStoryboard = UIStoryboard(name: "Main", bundle: bundle)
        self.popover = myStoryboard.instantiateViewController(withIdentifier: "measVC")
        self.popover.modalPresentationStyle = .popover


        self.initView()
        

    }
    
//    override func isPressed() {
//        
//        let myStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let popover = myStoryboard.instantiateViewController(withIdentifier: "measVC")
//        popover.modalPresentationStyle = .popover
//        let popController = popover.popoverPresentationController
//        popController!.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
//        popController!.permittedArrowDirections = UIPopoverArrowDirection.any
//        popController!.sourceView = self
//        popController!.sourceRect = self.bounds
//        sourceVC.present(popover, animated: true, completion: nil)
//    }
    
    @objc func updateMeas() {
        if scope.measure.measList.isEmpty {
            ctrlItem.text = "None"
        }
        
        else {
            ctrlItem.text = "Auto"
        }
        
        //ctrlItem.sizeToFit()
    }
    
    override func prepareForInterfaceBuilder() {
        bundle = Bundle(for: type(of: self))
        initCtrl()
        super.prepareForInterfaceBuilder()
    }
//    
}

//class MeasurePopoverVC : UIViewController {
//    
//    override func viewDidLoad() {
//        self.preferredContentSize = CGSize(width: 300, height: 500)
//        
//    }

//}
