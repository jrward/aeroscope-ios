//
//  VertControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/16/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class VertControl : ScopeUIControl {
    
    let vertPopoverVC = VertPopoverVC()
    var ctrlItem = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder, title: "Vertical", item: ctrlItem, popoverType: VertPopoverVC.self)
        super.init(coder: aDecoder)
        
    }
    

    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    func initCtrl() {
        ctrlItem.text = scope.settings.getVert()
        ctrlItem.font = UIFont(name: "Helvetica Neue", size: 18)!
        ctrlItem.textColor = self.textColor//Scope.globalTintColor
        ctrlItem.sizeToFit()
        ctrlItem.frame.size.width = 60
        ctrlItem.textAlignment = .center
        self.title = "Vertical"
        self.item = ctrlItem
        
        self.popover = vertPopoverVC
        self.initView()
        
         NotificationCenter.default.addObserver(self, selector: #selector(VertControl.updateVert) , name: ScopeSettings.notifications.vert, object: nil)
    }
    
    override func prepareForInterfaceBuilder() {
        initCtrl()
        super.prepareForInterfaceBuilder()
        
    }
    
    func updateVert() {
        ctrlItem.text = scope.settings.getVert()
        //ctrlItem.sizeToFit()
    }
    
}

class VertPopoverVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var vertScroll : UITableView!
    var acDC : UISegmentedControl!
    let scope = Scope.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        acDC = UISegmentedControl(frame: CGRectMake(0,0,200,70))
//        acDC.setTitle("DC", forSegmentAtIndex: 0)
//        acDC.setTitle("AC", forSegmentAtIndex: 1)
//        acDC.insertSegmentWithTitle("DC", atIndex: 0, animated: false)
//        acDC.insertSegmentWithTitle("DC", atIndex: 1, animated: <#T##Bool#>)
        
        acDC = UISegmentedControl(items: ["DC", "AC"])
        acDC.addTarget(self, action: #selector(acDCPressed), for: .valueChanged);
        
        vertScroll = UITableView(frame: CGRect(x: 0,y: 0,width: 200,height: 500))
        
        vertScroll.delegate = self
        vertScroll.dataSource = self
        
        vertScroll.separatorStyle = .none
        vertScroll.register(UITableViewCell.self, forCellReuseIdentifier: "cell_vert")
        vertScroll.backgroundColor = UIColor.clear
        vertScroll.allowsSelection = true
        //vertScroll.backgroundColor = UIApplication.sharedApplication().keyWindow?.tintColor.colorWithAlphaComponent(0.2)
//        vertScroll.backgroundColor = UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0)
//        self.view.layer.borderWidth = 1.0
//        self.view.layer.borderColor = self.view.tintColor.CGColor
        //vertScroll.color

        vertScroll.sizeToFit()
        
        
        //vertScroll.sizeThatFits(CGSize(width: 200,height: 390))
        
        self.view.addSubview(acDC)
        self.view.addSubview(vertScroll)
        
        acDC.translatesAutoresizingMaskIntoConstraints = false
        vertScroll.translatesAutoresizingMaskIntoConstraints = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        
        NSLayoutConstraint(item: acDC, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1.0, constant: 8).isActive = true
        
        NSLayoutConstraint(item: acDC, attribute:  .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: acDC, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant:50).isActive = true
        
        NSLayoutConstraint(item: acDC, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 180).isActive = true
        //NSLayoutAttribute.NotAnAttribute
        NSLayoutConstraint(item: vertScroll, attribute:  .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200).isActive = true
        
//        NSLayoutConstraint(item: vertScroll, attribute:  .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 500).active = true
        
        NSLayoutConstraint(item: vertScroll, attribute:  .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: vertScroll, attribute:  .top, relatedBy: .equal, toItem: acDC, attribute: .bottom, multiplier: 1.0, constant: 8).isActive = true
        
        NSLayoutConstraint(item: vertScroll, attribute:  .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: vertScroll, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: vertScroll, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self.view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200).isActive = true
        
        self.preferredContentSize = CGSize(width: vertScroll.bounds.size.width, height: vertScroll.bounds.size.height + acDC.bounds.size.height + 50.0)
        

        
        
//         NSLayoutConstraint(item: vertScroll, attribute:  .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0).active = true

        
        
    }
    
    override func viewWillLayoutSubviews() {
        vertScroll.reloadData()
        vertScroll.frame =  CGRect(origin: vertScroll.frame.origin, size: vertScroll.intrinsicContentSize)

           }
    
    override func viewDidLayoutSubviews() {
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let myIndex = IndexPath(row: scope.settings.getVertSettings().index(of: scope.settings.getVert())!, section: 0)
        
        vertScroll.selectRow(at: myIndex, animated: false, scrollPosition: UITableViewScrollPosition.middle)

        self.tableView(vertScroll, didSelectRowAt: myIndex)
        
        if scope.settings.getACDC() == .dc {
            acDC.selectedSegmentIndex = 0
        }
        else {
            acDC.selectedSegmentIndex = 1
        }
    }
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scope.settings.getVertSettings().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scope.settings.setVert(scope.settings.getVertSettings()[(indexPath as NSIndexPath).row])
        
        let mycell = tableView.cellForRow(at: indexPath)!
        mycell.textLabel!.textColor = UIColor.white
        mycell.backgroundColor = UIColor.clear
    
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let mycell = tableView.cellForRow(at: indexPath)!
        mycell.textLabel!.textColor = self.view.tintColor
        mycell.backgroundColor = UIColor.clear
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let mycell = tableView.dequeueReusableCell(withIdentifier: "cell_vert", for: indexPath) as UITableViewCell
        
        mycell.textLabel!.text = scope.settings.getVertSettings()[(indexPath as NSIndexPath).row]
        if mycell.isSelected {
            mycell.textLabel!.textColor = UIColor.white
        }
        else {
            mycell.textLabel!.textColor = self.view.tintColor
        }
        mycell.backgroundColor = UIColor.clear
        mycell.selectedBackgroundView = UIView()
        mycell.selectedBackgroundView?.backgroundColor = self.view.tintColor
        
        return mycell
    }
    
    func acDCPressed() {
        if acDC.selectedSegmentIndex == 0 {
            scope.settings.setACDC(.dc)
        }
        else if acDC.selectedSegmentIndex == 1 {
            scope.settings.setACDC(.ac)
        }
    }
}
