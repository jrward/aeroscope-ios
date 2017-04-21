//
//  ScopeFrameViewController.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/15/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class ScopeFrameViewController: UIViewController, ScopeFrameViewDataSource {
    
    let scope = Scope.sharedInstance
    
    let frame = ScopeFrame(comms: Scope.sharedInstance.comms, frameSize: 512)
    
    var nf = NSNumberFormatter() {
        didSet {
            nf.numberStyle = .DecimalStyle
        }
    }
    
    @IBOutlet weak var triggerSlider: UISlider! {
        didSet {
            triggerSlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2));
            triggerSlider.minimumTrackTintColor = UIColor.grayColor()
            triggerSlider.maximumTrackTintColor = UIColor.grayColor()
            triggerSlider.minimumValue = Float(scope.settings.trigger_range.startIndex)
            triggerSlider.maximumValue = Float(scope.settings.trigger_range.endIndex - 1)
            triggerSlider.value = Float(scope.settings.trigger.value)
            
            let image = UIImage(named: "thumb")
            image!.imageWithRenderingMode(.AlwaysTemplate)

            triggerSlider.setThumbImage(image, forState: .Normal)
            triggerSlider.setThumbImage(image, forState: .Selected)
        }
    }
    
    @IBAction func triggerChanged(sender: UISlider) {
        scope.settings.trigger.value = Int(triggerSlider.value)
        print(scope.settings.trigger.value)
        
    }
    
 
    @IBOutlet weak var scopeFrameView: ScopeFrameView!{
        didSet {
            scopeFrameView.dataSource = self
            let panRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
            scopeFrameView.addGestureRecognizer(panRecognizer)
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinch:")
            scopeFrameView.addGestureRecognizer(pinchRecognizer)

        }
    }
    
    @IBOutlet weak var vertLabel : UILabel! {
        didSet {
            vertLabel.textColor = UIColor.blackColor()
            vertLabel.text = "\(scope.settings.vert.value) per div"
        }
    }
    @IBOutlet weak var horizLabel : UILabel!  {
        didSet {
            horizLabel.textColor = UIColor.blackColor()
            horizLabel.text = "\(scope.settings.horiz.value) per div"
        }
    }
    @IBOutlet weak var offsetLabel : UILabel!  {
        didSet {
            offsetLabel.textColor = UIColor.blackColor()
            offsetLabel.text = "Offset: \(scope.settings.offset.value)"
        }
    }
    @IBOutlet weak var trigDelayLabel : UILabel!  {
        didSet {
            trigDelayLabel.textColor = UIColor.blackColor()
            trigDelayLabel.text = "Trig Delay: \(scope.settings.trigger_x_pos.value)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFrame", name: frame.frameNotification, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVert", name: scope.settings.vertNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHoriz", name: scope.settings.horizNotification, object: nil)
        
        
    }
    
    func updateVert() {
        updateSettingsText()
    }
    
    func updateHoriz() {
        updateSettingsText()
    }
    
    func dataForScopeFrameView() -> [UInt8]? {
        return frame.frame
    }
  
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//                case "Scope Control":
//                    if let vc = segue.destinationViewController as? ScopeCtrlViewController {
//                        
//                }
//                default: break
//            }
    
//        }
//    }

    func pan(gesture: UIPanGestureRecognizer) {
        
        //TODO: let translationInView Build up before setting it to zero
        let translation = gesture.translationInView(scopeFrameView)
        let triggerTranslation : Int = Int( translation.x / scopeFrameView.x_size * 512.0)
        let triggerXMax = scope.settings.trigger_x_pos_range.endIndex - 1
        let triggerXMin = scope.settings.trigger_x_pos_range.startIndex
        scope.settings.trigger_x_pos.value = max(min(scope.settings.trigger_x_pos.value + triggerTranslation, triggerXMax), triggerXMin)
        print(translation.x)
        print(scopeFrameView.x_size)
        print(triggerTranslation)
        print(scope.settings.trigger_x_pos.value)
        //framePosition = min(max((framePosition + frameTranslation),0),100)
        
        
        let offsetTranslation : Int = Int(translation.y / scopeFrameView.y_size * 512.0)
        let offsetMax = scope.settings.offset_range.endIndex - 1
        let offsetMin = scope.settings.offset_range.startIndex
        scope.settings.offset.value = max(min(scope.settings.offset.value + offsetTranslation, offsetMax), offsetMin)
        gesture.setTranslation(CGPointZero, inView: scopeFrameView)
        updateSettingsText()
    
    }
    
    func pinch(gesture: UIPinchGestureRecognizer) {
        struct Static {
            static var changed = false
            static var level = 0 {
                didSet {
                    if level != oldValue {
                        changed = true
                    }
                    else {
                        changed = false
                    }
                }
            }
            static var vert = false
        }
        
        let increment : () -> (Void) = {
            if (Static.changed) {
                if Static.vert {
                    self.scope.settings.vert.increment()
                    self.scope.updateSettings()
                }
                else {
                    self.scope.settings.horiz.increment()
                    self.scope.updateSettings()
                }
            }
        }
        
        let decrement : () -> (Void) = {
            if (Static.changed) {
                if Static.vert {
                    self.scope.settings.vert.decrement()
                    self.scope.updateSettings()
                }
                else {
                    self.scope.settings.horiz.decrement()
                    self.scope.updateSettings()
                }
            }
        }

        
        switch(gesture.state) {
            
            case .Began:
                Static.level = 0
                Static.changed = false
                
                let loc1 = gesture.locationOfTouch(0, inView: scopeFrameView)
                let loc2 = gesture.locationOfTouch(1, inView: scopeFrameView)
                print(loc1)
                print(loc2)
                print(gesture.scale)
                
                if (abs(loc1.x - loc2.x) > abs(loc1.y - loc2.y)) { //pinch x
                    Static.vert = false
                }
                
                else {
                    Static.vert = true
                }
                
                
            case .Changed: fallthrough
            case .Failed: fallthrough
            case .Cancelled: fallthrough
            case .Ended:
                
                
            if gesture.scale < 0.2 {
                Static.level = 3
                increment()
            }
                
            else if gesture.scale < 0.5 {
                Static.level = 2
                increment()
            }
                
            else if gesture.scale < 0.75 {
                Static.level = 1
                increment()
            }
                
            else if gesture.scale > 5.0 {
                Static.level = -3
                decrement()
            }
                
            else if gesture.scale > 3.0 {
                Static.level = -2
                decrement()
            }
                
            else if gesture.scale > 1.5 {
                Static.level = -1
                decrement()
            }        
        
            default: break
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateFrame() {
        scopeFrameView.drawTrace()
    }
    
    func updateSettingsText() {
        vertLabel.text = "\(scope.settings.vert.value) per div"
        horizLabel.text = "\(scope.settings.horiz.value) per div"
        offsetLabel.text = "Offset: \(scope.settings.offset.value)"
        trigDelayLabel.text = "Trig Delay: \(scope.settings.trigger_x_pos.value)"

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
