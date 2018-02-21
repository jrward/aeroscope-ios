//
//  HorizControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/16/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class HorizControl : ScopeUIControl {
    
    let horizPopoverVC = HorizPopoverVC()
    var ctrlItem = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //super.init(coder: aDecoder, title: "Horizontal", item: ctrlItem, popoverType: HorizPopoverVC.self)
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HorizControl.updateHoriz), name: ScopeSettings.notifications.horiz, object: nil)

    }
    
    override func layoutSubviews() {
        initCtrl()
        super.layoutSubviews()
    }
    
    func initCtrl() {
        ctrlItem.text = scope.settings.getHoriz()
        ctrlItem.font = UIFont(name: "Helvetica Neue", size: 18)!
        ctrlItem.sizeToFit()
        ctrlItem.frame.size.width = 60
        ctrlItem.textAlignment = .center
        ctrlItem.textColor = self.textColor
        self.title = "Horizontal"
        self.item = ctrlItem
        self.popover = horizPopoverVC
//        self.popover.preferredContentSize = CGSize(width: 200, height: 600)

        self.initView()
    }
    
    override func prepareForInterfaceBuilder() {
        initCtrl()
        super.prepareForInterfaceBuilder()
    }
    
    
    @objc func updateHoriz() {
        ctrlItem.text = scope.settings.getHoriz()

    }
}

class HorizPopoverVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var horizScroll : UITableView!
    let scope = Scope.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        horizScroll = UITableView(frame: CGRect(x: 0,y: 0,width: 200,height: 600))
        
        horizScroll.delegate = self
        horizScroll.dataSource = self
        
        horizScroll.register(UITableViewCell.self, forCellReuseIdentifier: "cell_horiz")
        horizScroll.backgroundColor = UIColor.clear
        horizScroll.allowsSelection = true
        horizScroll.separatorStyle = .none
        
//        let myIndex = NSIndexPath(forRow: scope.settings.horizMapping.settings.indexOf(scope.settings.horiz.value)!, inSection: 0)
//        horizScroll.selectRowAtIndexPath(myIndex, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        horizScroll.showsVerticalScrollIndicator = true

        self.horizScroll.reloadData()

        horizScroll.sizeToFit()
        self.preferredContentSize = horizScroll.bounds.size
        //self.preferredContentSize = horizScroll.intrinsicContentSize
            //horizScroll.sizeThatFits(CGSizeMake(200,600))
        
        self.view.addSubview(horizScroll)
        
        
        Timer.scheduledTimer(timeInterval: 0.1, target: horizScroll, selector: #selector(UIScrollView.flashScrollIndicators), userInfo: nil, repeats: false)
        
    }
    
    override func viewWillLayoutSubviews() {
        horizScroll.reloadData()
        horizScroll.frame = self.view.frame
    }
    
    override func viewDidLayoutSubviews() {
   
      

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //let myIndex = NSIndexPath(forRow: scope.settings.horizMapping.settings.indexOf(scope.settings.horiz.value)!, inSection: 0)
        

        let myIndex = IndexPath(row: scope.settings.getHorizSettings().index(of: scope.settings.getHoriz())!, section: 0)
        
        horizScroll.selectRow(at: myIndex, animated: false, scrollPosition: UITableViewScrollPosition.middle)
        
        self.tableView(horizScroll, didSelectRowAt: myIndex)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(scope.settings.getHorizSettings().count)
        
        return scope.settings.getHorizSettings().count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scope.settings.setHoriz(scope.settings.getHorizSettings()[(indexPath as NSIndexPath).row])
        let mycell = tableView.cellForRow(at: indexPath)!
        mycell.textLabel!.textColor = ScopeTheme.manager.activeTheme.textSelected
        mycell.backgroundColor = UIColor.clear
        
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let mycell = tableView.cellForRow(at: indexPath)
        mycell?.textLabel!.textColor = ScopeTheme.manager.activeTheme.text
        mycell?.backgroundColor = UIColor.clear
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mycell = tableView.dequeueReusableCell(withIdentifier: "cell_horiz", for: indexPath) as UITableViewCell
        
        mycell.textLabel!.text = scope.settings.getHorizSettings()[(indexPath as NSIndexPath).row]
        
        if mycell.isSelected {
            mycell.textLabel!.textColor = ScopeTheme.manager.activeTheme.textSelected
        }
        else {
            mycell.textLabel!.textColor = ScopeTheme.manager.activeTheme.text
        }
        mycell.backgroundColor = UIColor.clear
        mycell.selectedBackgroundView = UIView()
        mycell.selectedBackgroundView?.backgroundColor = ScopeTheme.manager.activeTheme.selected
        
        return mycell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let mycell = tableView.cellForRow(at: indexPath)
//
//        return mycell?.intrinsicContentSize.height ?? 0.0
//    }
    

    
}
