//
//  ArrowLabelView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 4/16/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ArrowLabelView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    enum Location {
        case left
        case right
    }
    
    enum Direction {
        case up
        case down
        case left
        case right
    }
    
    let label = UILabel()
    let arrowView = UIView()
    let arrowLayer = CAShapeLayer()
    @IBInspectable
    var color : UIColor! {
        didSet {
            arrowLayer.strokeColor = color.cgColor
            label.textColor = color
        }
    }
    
    var location : Location = .left
    
    var direction : Direction = .up
    @IBInspectable
    var text: String! {
        didSet {
            label.text = text
        }
    }
    

    
    init(frame: CGRect, text: String, loc: Location, dir: Direction, color: UIColor) {
        self.location = loc
        self.direction = dir
        self.color = color
        self.text = text
        super.init(frame: frame)
        label.font = UIFont(name: "Helvetica Neue", size: 14)
        initLayers()

    }
    
    func initLayers() {
        label.text = self.text
        label.sizeToFit()
        label.textColor = color
        self.layer.addSublayer(arrowLayer)
        self.addSubview(arrowView)
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }
    
    override func layoutSubviews() {
        let arrowLoc : CGPoint
        
        switch location {
        
        case .left:
            //self.frame.size = label.frame.insetBy(dx: -20, dy: -2).offsetBy(dx: -20, dy: 0)
            arrowLoc = CGPoint(x: 6, y: self.frame.size.height/2)
            label.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            label.frame.origin.x =  16
            label.textAlignment = .left
        case .right:
            //self.frame = label.frame.insetBy(dx: -20, dy: -2).offsetBy(dx: 20, dy: 0)
            arrowLoc = CGPoint(x: self.frame.size.width - 6, y: self.frame.size.height/2)
            label.center = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
            label.frame.origin.x = self.frame.size.width - label.frame.size.width - 16
            //label.frame.maxX = self.frame.maxX - 14
            label.textAlignment = .right
            
        }
        
        switch direction {
        case .up:
            arrowLayer.path = drawArrow(arrowLoc, angle: 0).cgPath
        case .right:
            arrowLayer.path = drawArrow(arrowLoc, angle: CGFloat.pi/2).cgPath
        case .down:
            arrowLayer.path = drawArrow(arrowLoc, angle: CGFloat.pi).cgPath
        case .left:
            arrowLayer.path = drawArrow(arrowLoc, angle: 3*CGFloat.pi/2).cgPath
        }
        
        //arrowLayer.path = drawArrow(CGPoint(x: x_size/10, y: y_size/8), angle: CGFloat(0)).CGPath
        arrowLayer.fillColor = nil
        arrowLayer.lineCap = kCALineCapRound
        arrowLayer.lineJoin =  kCALineJoinRound
        arrowLayer.lineWidth = 2.0

        arrowLayer.strokeColor = color.cgColor
   
    }

    func drawArrow(_ center: CGPoint, angle: CGFloat) -> UIBezierPath {
        let arrow = UIBezierPath()
        let arrowTip = CGPoint(x: 0, y: -6)
        
        arrow.move(to: arrowTip)
        arrow.addLine(to: CGPoint(x: 0, y: 6))
        arrow.move(to: arrowTip)
        arrow.addArc(withCenter: CGPoint(x: 9, y: arrowTip.y), radius: 9, startAngle: CGFloat.pi, endAngle: 3*CGFloat.pi/4, clockwise: false)
        arrow.move(to: arrowTip)
        arrow.addArc(withCenter: CGPoint(x: -9, y: arrowTip.y), radius: 9, startAngle: 0.0, endAngle: CGFloat.pi/4, clockwise: true)
        arrow.apply(CGAffineTransform(rotationAngle: CGFloat(angle)))
        arrow.apply(CGAffineTransform(translationX: center.x, y: center.y))
        //CGContextRotateCTM(, CGFloat(M_PI))
        return arrow
    }
    
//    func drawArrow(center: CGPoint, angle: CGFloat) -> UIBezierPath {
//        let arrow = UIBezierPath()
//        arrow.moveToPoint(CGPointZero)
//        arrow.addLineToPoint(CGPoint(x: 0, y: 12))
//        arrow.moveToPoint(CGPointZero)
//        arrow.addArcWithCenter(CGPoint(x: 9, y: 0), radius: 9, startAngle: CGFloat(M_PI), endAngle: CGFloat(3*M_PI/4), clockwise: false)
//        arrow.moveToPoint(CGPointZero)
//        arrow.addArcWithCenter(CGPoint(x: -9, y: 0), radius: 9, startAngle: 0.0, endAngle: CGFloat(M_PI/4), clockwise: true)
//        arrow.applyTransform(CGAffineTransformMakeRotation(CGFloat(angle)))
//        arrow.applyTransform(CGAffineTransformMakeTranslation(center.x, center.y))
//        //CGContextRotateCTM(, CGFloat(M_PI))
//        return arrow
//    }
    
}
