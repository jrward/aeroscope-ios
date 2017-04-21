//
//  RunStopeControl.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 3/30/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RunStopControl : UIControl {
    

    let scope = Scope.sharedInstance
    //let runStopSingle = Scope.sharedInstance.settings.runStopSingle
    let runStop = UIControl()
    let single = UIControl()
    
    let activeLabel = UILabel()
    let inactiveLabel = UILabel()
    let singleLabel = UILabel()
    
    let separatorView = UIView()
    
    let separatorLayer = CAShapeLayer()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        initView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        initView()
    }
    

    
//    
//    override func draw(_ rect: CGRect) {
//        let width = bounds.size.width
//        let height = bounds.size.height
//        
//        separatorLayer.path = separator.cgPath
//        separator.move(to: CGPoint(x: 0, y: height/2))
//        separator.addLine(to: CGPoint(x: width, y: height/2))
//        separator.addLine(to: CGPoint(x: width, y: 0))
//        separator.addLine(to: CGPoint(x: 0,y: 0))
//        separator.close()
//        //separator.moveToPoint(CGPointMake(0, 2/3 * height))
//        //separator.addLineToPoint(CGPointMake(width, 2/3 * height))
//        
//        let separatorColor = Scope.globalTintColor
//        separatorColor.set()
//        separator.lineWidth = 1.0
//        separator.stroke()
//        //separator.fill()
//        //separatorLayer.strokeColor = self.tintColor.CGColor
//    }
    
    override func layoutSubviews() {
        let width = bounds.size.width
        let height = bounds.size.height
        
        initView()
        
        activeLabel.text = "Stop"
        activeLabel.font = UIFont(name: "Helvetica Neue", size: 20)
        activeLabel.textColor = UIColor.white
        //runLabel.textColor = self.tintColor
        activeLabel.frame = CGRect(x: 0, y: 8, width: width, height: height/4)
//        activeLabel.frame = CGRectInset(runStop.bounds, 0, -20)
//        activeLabel.frame.offsetInPlace(dx: 0, dy: -10)
        activeLabel.textAlignment = .center
        //runLabel.alpha = 0.4
        
        inactiveLabel.text = "Run"
        inactiveLabel.font = UIFont(name: "Helvetica Neue", size: 14)
        inactiveLabel.textColor = UIColor.white
        //stopLabel.textColor = self.tintColor
        inactiveLabel.frame = CGRect(x: 0, y: height/4 - 2, width: width, height: height/4)
        //inactiveLabel.frame = CGRectInset(runStop.bounds, 0, -20)
        //inactiveLabel.frame.offsetInPlace(dx: 0, dy: 10)
        inactiveLabel.textAlignment = .center
        inactiveLabel.alpha = 0.5
        
        singleLabel.text = "Single"
        singleLabel.textColor = Scope.globalTintColor//self.tintColor
        singleLabel.frame = CGRect(x: 0, y: height/2, width: width, height: height/2)
        singleLabel.textAlignment = .center
        
        runStop.frame = CGRect(x: 0,y: 0, width: width, height: height/2)
        runStop.backgroundColor = self.tintColor
        //runStop.tintAdjustmentMode = .normal

        
        single.frame = CGRect(x: 0, y: height/2, width: width, height: height/2)
        single.tintAdjustmentMode = .normal
        
        //separatorView.backgroundColor = UIColor.white
        
        separatorLayer.path = drawSeparator().cgPath
        separatorLayer.fillColor = nil
        separatorLayer.lineWidth = 1.0
        separatorLayer.strokeColor = Scope.globalTintColor.cgColor

        runStopSingleChanged()
    }
    
//    override var isHighlighted: Bool {
//        didSet {
//            //alpha = highlighted ? 0.6 : 1.0
//            if isHighlighted { self.alpha = 0.6 }
//                
//            else {
//                UIView.animate(withDuration: 0.25, animations: { _ in
//                    self.alpha = 1.0 }) 
//            }
//        }
//    }
    
    func drawSeparator() -> UIBezierPath {
        let separator = UIBezierPath()
        let width = bounds.size.width
        let height = bounds.size.height
        
        separator.move(to: CGPoint(x: 0, y: height/2))
        separator.addLine(to: CGPoint(x: width, y: height/2))
        separator.addLine(to: CGPoint(x: width, y: 0))
        separator.addLine(to: CGPoint(x: 0,y: 0))
        
        return separator
//        separator.close()
        
        //separator.moveToPoint(CGPointMake(0, 2/3 * height))
        //separator.addLineToPoint(CGPointMake(width, 2/3 * height))
        
        
//        let separatorColor = Scope.globalTintColor
//        separatorColor.set()
//        separator.lineWidth = 1.0
//        separator.stroke()
    }
    
    func initView() {
        self.addSubview(single)
        self.addSubview(runStop)
        self.addSubview(singleLabel)
        self.addSubview(inactiveLabel)
        self.addSubview(activeLabel)
        self.addSubview(separatorView)
        
        self.tintColor = Scope.globalTintColor
        self.layer.cornerRadius = 5;
        //self.layer.masksToBounds = true;
        self.clipsToBounds = true
        
        self.layer.borderColor = self.tintColor.cgColor//scope.globalTintColor.CGColor //self.tintColor.CGColor
        self.layer.borderWidth = 1.0;
        self.backgroundColor = UIColor.clear
        
        

        separatorView.layer.addSublayer(separatorLayer)
        //self.bringSubview(toFront: separatorView)
        


        
        NotificationCenter.default.addObserver(self, selector: #selector(runStopSingleChanged), name: ScopeCmd.notifications.runState, object: nil)

        //self.addTarget(self, action: #selector(self.isPressed), forControlEvents: .TouchUpInside)
        single.addTarget(self, action: #selector(singleIsPressed), for: .touchUpInside)
        runStop.addTarget(self, action: #selector(runStopIsPressed), for: .touchUpInside)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initView()
    }
    
//    override func tintColorDidChange() {
//        self.runStop.backgroundColor = self.tintColor
//        
//    }

    
    func runStopSingleChanged() {
        switch scope.settings.getRunState() {
        case .run:
            setRun()
        case .stop:
            setStop()
        case .single:
            setSingle()
        }
    }
    
    func setRun() {
        setRunCtrl()
        clearSingle()
    }
    
    func setRunCtrl() {
        runStop.backgroundColor = Scope.globalTintColor//self.tintColor
        activeLabel.text = "Run"
        activeLabel.tintColor = UIColor.white
        inactiveLabel.text = "Stop"
        inactiveLabel.tintColor = UIColor.white
    }
    
    func setStop() {
        runStop.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)//Scope.globalTintColor//self.tintColor
        activeLabel.text = "Stop"
        activeLabel.tintColor = Scope.globalTintColor//UIColor.white
        inactiveLabel.text = "Run"
        inactiveLabel.tintColor = UIColor.white
        clearSingle()
    }
    
    func setSingle() {
        setRunCtrl()
        single.backgroundColor = Scope.globalTintColor //self.tintColor
        singleLabel.textColor = UIColor.white
        singleLabel.alpha = 1.0
    }
    
    func clearSingle() {
        single.backgroundColor = UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0)
        //self.tintColor.colorWithAlphaComponent(0.2)
        singleLabel.textColor = Scope.globalTintColor //self.tintColor
    }
    
    
    func runStopIsPressed() {
        print("RunStop")
        if scope.settings.getRunState() == .run || scope.settings.getRunState() == .single {
            scope.settings.setRunState(.stop)
        }
        
        else if scope.settings.getRunState() == .stop {
            scope.settings.setRunState(.run)
        }
        
        activeLabel.alpha = 0.6
        
        UIView.animate(withDuration: 0.25, animations: { _ in
            self.activeLabel.alpha = 1.0
        }) 
    }
    
    func singleIsPressed() {
        print("Single")
        scope.settings.setRunState(.single)
        
//        singleLabel.alpha = 0.6
//        UIView.animateWithDuration(0.25) { _ in
//            self.singleLabel.alpha = 1.0
//        }
    }
    
}

class RunStopSingleVC : UIViewController {
    
    
    
}
