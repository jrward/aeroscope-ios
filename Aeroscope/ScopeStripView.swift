//
//  ScopeStripView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/17/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit

protocol ScopeStripViewDataSource : class {
    //0.0 - 100.0
    func frameWidthForScopeStripView() -> CGFloat?
    //0.0 - 100.0
    func framePositionForScopeStripView() -> CGFloat?
    func triggerPositionForScopeStripView() -> CGFloat?
    func tracePositionForScopeStripView() -> CGFloat?
    func traceWidthForScopeStripView() -> CGFloat?
    func traceScaleForScopeStripView() -> CGFloat?
    func traceDataForScopeStripView() -> [UInt8]?

}




@IBDesignable
class ScopeStripView: UIView {

    @IBInspectable
    var fgColor : UIColor = UIColor.gray { didSet { setNeedsDisplay() } }
    @IBInspectable
    var bgColor : UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var traceColor : UIColor = UIColor.green { didSet { setNeedsDisplay() } }
    @IBInspectable
    var triggerColor : UIColor = UIColor.red { didSet { setNeedsDisplay() }}

    
    var track_width : CGFloat {
        return bounds.size.width
    }
    var track_height : CGFloat {
        //return bounds.size.height * 0.30
        return bounds.size.height * 0.80
    }
   
    var slider_height : CGFloat {
        //return bounds.size.height * 0.80
        return bounds.size.height * 0.90
    }
    
    let triggerWidth : CGFloat = 26.0
    let triggerHeight : CGFloat = 20.0
    let touchSize : CGFloat = 44.0
    
    var mycenter : CGPoint {
        return convert(center, from: superview)
    }
    
    var topLeft : CGPoint {
        return convert(CGPoint(x: 0, y: 0), from:superview)
    }
    
    let traceLayer = CAShapeLayer()
    let sliderLayer = CAShapeLayer()
    let triggerLayer = CAShapeLayer()
    
    weak var dataSource : ScopeStripViewDataSource?     //data source delegate
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayers()
    }
    
    func initLayers() {
        self.layer.addSublayer(sliderLayer)
        sliderLayer.actions = ["position": NSNull()]
        
        self.layer.addSublayer(triggerLayer)
        triggerLayer.actions = ["position":NSNull()]
        
        self.layer.addSublayer(traceLayer)
        
        self.backgroundColor = UIColor.clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.clipsToBounds = true

    }

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
//        self.clipsToBounds = true
//        self.layer.cornerRadius = 5;
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = self.tintColor.CGColor

//        UIColor(red: 65/255, green: 0/255, blue: 0/255, alpha: 1.0).set()
//
//        drawTouchTarget(10.0).fill()
//        drawTouchTarget(50.0).fill()
//        drawTouchTarget(90.0).fill()
        
        let position = CGFloat(dataSource?.framePositionForScopeStripView() ?? 50.0)
        let width = CGFloat(dataSource?.frameWidthForScopeStripView() ?? (100.0 * 500.0/4096.0))
        
        let pen = UIBezierPath()
        
        pen.move(to: CGPoint(x: mycenter.x-(track_width/2), y: mycenter.y-(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x+(track_width/2), y: mycenter.y-(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x+(track_width/2), y: mycenter.y+(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x-(track_width/2), y: mycenter.y+(track_height/2)))
        pen.close()
        pen.lineWidth = lineWidth
        bgColor.set()
        pen.stroke()
        pen.fill()
        

        

        
        
        UIColor(red: 65/255, green: 0/255, blue: 0/255, alpha: 1.0).set()
        drawTrigger(10.0).fill()
        drawTrigger(50.0).fill()
        drawTrigger(90.0).fill()
        //let ghostColor = UIColor(red: 65/255, green: 0, blue: 0, alpha: 1.0) //triggerColor.colorWithAlphaComponent(0.2)
        //ghostColor.set()
        //traceColor.set()
//        triggerColor.colorWithAlphaComponent(0.5).set()
//        drawTouchTarget(10.0).fill()
//        drawTouchTarget(50.0).fill()
//        drawTouchTarget(90.0).fill()

        
        //fgColor.set()
       // drawSlider(width: width, position: position).stroke()
        
        sliderLayer.path = drawSlider(width: width, position: 0.0).cgPath
        sliderLayer.strokeColor = fgColor.cgColor
        sliderLayer.lineWidth = lineWidth
        sliderLayer.fillColor = nil

        updateSlider()
        
        triggerLayer.path = drawTrigger(50.0).cgPath
        triggerLayer.fillColor = triggerColor.cgColor
        
        updateTrigger()
        
        traceLayer.strokeColor = traceColor.cgColor
        traceLayer.lineWidth = lineWidth
        traceLayer.fillColor = nil
        
    }
    
    func drawLiveTrace() -> UIBezierPath {
        let mypath = UIBezierPath()
        
        let pen = UIBezierPath()
        
        pen.move(to: CGPoint(x: mycenter.x-(track_width/2), y: mycenter.y-(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x+(track_width/2), y: mycenter.y-(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x+(track_width/2), y: mycenter.y+(track_height/2)))
        pen.addLine(to: CGPoint(x: mycenter.x-(track_width/2), y: mycenter.y+(track_height/2)))
        pen.close()
        pen.lineWidth = lineWidth
        bgColor.set()
        pen.stroke()
        pen.fill()
        
        pen.removeAllPoints()
        pen.move(to: CGPoint(x: mycenter.x-(track_width/2), y: bounds.size.height/2))
        //for (var index=Int(mycenter.x-(track_width/2)); index < Int(track_width); index += 1) {
        //        for index in Int(mycenter.x-(track_width/2))  ..<  Int(track_width){
        //            pen.addLineToPoint(CGPoint(x: CGFloat(index), y: CGFloat(5*sin(Double(index/5)))+(bounds.size.height/2) ) )
        //        }
        
        for index in 0 ..< Int(bounds.width) {
            pen.addLine(to: CGPoint(x: Double(index), y: -5*sin(Double(index)/6.0) + Double(bounds.size.height/2) ))
        }
        traceColor.set()
        pen.stroke()
        
        return mypath
    }
    
    func drawFullTrace() -> UIBezierPath {
        let mypath = UIBezierPath()
        
        return mypath
    }
    
    func drawTrace(scale: CGFloat, width: CGFloat, position: CGFloat) -> UIBezierPath {
        let relativeWidth = width/100.0 * track_width
        let relativePos = position/100.0 * track_width
        let mypath = UIBezierPath()
        
        //22 cycles in full frame width with
        
        mypath.move(to: CGPoint(x: relativePos, y: mycenter.y))
        //for (var index=Int(mycenter.x-(track_width/2)); index < Int(track_width); index += 1) {
        //        for index in Int(mycenter.x-(track_width/2))  ..<  Int(track_width){
        //            pen.addLineToPoint(CGPoint(x: CGFloat(index), y: CGFloat(5*sin(Double(index/5)))+(bounds.size.height/2) ) )
        //        }
        
        for index in 0 ..< Int(relativeWidth * scale) {
            let nextX = relativePos + (CGFloat(index)/CGFloat(scale))
            let nextY = -5*sin(CGFloat(index)/4.0) + CGFloat(mycenter.y)
            mypath.addLine(to: CGPoint(x:nextX, y: nextY))
        }
        
        return mypath
    }
    
    func drawSlider(width: CGFloat, position: CGFloat) -> UIBezierPath {
        
        let relativeWidth = width/100.0 * track_width
        let relativePos = position/100.0 * track_width
        let mypath = UIBezierPath()
//        mypath.move(to: CGPoint(x: mycenter.x  - (relativeWidth/2), y: mycenter.y + (slider_height/2)))
//        mypath.addLine(to: CGPoint(x:mycenter.x  + (relativeWidth/2), y: mycenter.y + (slider_height/2)))
//        mypath.addLine(to: CGPoint(x:mycenter.x  + (relativeWidth/2), y: mycenter.y - (slider_height/2)))
//        mypath.addLine(to: CGPoint(x:mycenter.x  - (relativeWidth/2), y: mycenter.y - (slider_height/2)))
        
        mypath.move(to: CGPoint(x: relativePos, y: mycenter.y + (slider_height/2)))
        mypath.addLine(to: CGPoint(x: relativePos  + (relativeWidth), y: mycenter.y + (slider_height/2)))
        mypath.addLine(to: CGPoint(x: relativePos  + (relativeWidth), y: mycenter.y - (slider_height/2)))
        mypath.addLine(to: CGPoint(x: relativePos,  y: mycenter.y - (slider_height/2)))
        mypath.close()
        mypath.move(to: CGPoint(x: relativePos + (relativeWidth/2), y: mycenter.y + (slider_height/2)))
        mypath.addLine(to: CGPoint(x: relativePos + (relativeWidth/2), y: mycenter.y + (slider_height/4)))
        mypath.move(to: CGPoint(x: relativePos + (relativeWidth/2), y: mycenter.y - (slider_height/2)))
        mypath.addLine(to: CGPoint(x: relativePos + (relativeWidth/2), y: mycenter.y - (slider_height/4)))
        
        return mypath
    }

    func drawTrigger(_ position: CGFloat) -> UIBezierPath {
        let myPath = UIBezierPath()
        let center = position / 100 * bounds.size.width
        myPath.move( to: CGPoint(x: center - (triggerWidth/2), y: 0.0))
        myPath.addLine( to: CGPoint(x: center + (triggerWidth/2), y: 0.0))
        myPath.addLine( to: CGPoint(x: center, y: triggerHeight))
        myPath.close()
        return myPath
    }
    
    func drawTouchTarget(_ position: CGFloat) -> UIBezierPath {
        let myPath = UIBezierPath()
        let center = CGPoint(x:position / 100 * bounds.size.width, y: bounds.size.height/2)
        myPath.addArc(withCenter: center, radius: touchSize/2, startAngle: 0, endAngle: 360.0, clockwise: true)

        return myPath
    }
    
    func updateTrigger() {
        let triggerXPos = dataSource?.triggerPositionForScopeStripView() ?? 50.0
        triggerLayer.position = CGPoint(x: CGFloat((triggerXPos-50.0)/100.0) * track_width, y: 0.0)
    }
    
    func updateSliderWidth() {
        let relPos = dataSource?.framePositionForScopeStripView() ?? 50.0
        let width = (dataSource?.frameWidthForScopeStripView())
        if width == nil {
            sliderLayer.path = nil
        }
        else {
            sliderLayer.path = drawSlider(width: width!, position: 0.0).cgPath
            updateSlider()
    //        sliderLayer.strokeColor = fgColor.cgColor
    //        sliderLayer.lineWidth = lineWidth
    //        sliderLayer.fillColor = nil
        }
    }
    
    func updateSlider() {
        let relPos = dataSource?.framePositionForScopeStripView() ?? 50.0
        let width = (dataSource?.frameWidthForScopeStripView() ?? 20.0) // 100.0 * track_width
        
//        let emptySpace = track_width - width
//        print("track width: \(track_width)   width: \(width)")
//        
//        let translatedPosition = emptySpace * relPos/100.0 + width/2 - track_width/2
//        
//        print("translated position: \(translatedPosition)")
//    
        
        //sliderLayer.position = CGPoint(x: CGFloat((position-50.0)/100.0) * track_width, y: 0.0)
        sliderLayer.position = CGPoint(x: (relPos/100.0) * track_width, y: 0.0)
        //sliderLayer.needsDisplay()
    }
    
    func clearTrace() {
        traceLayer.path = nil
    }
    
    func updateTrace() {
        let scale : CGFloat = dataSource?.traceScaleForScopeStripView() ?? 1.0
        let width = dataSource?.traceWidthForScopeStripView()
        let position = dataSource?.tracePositionForScopeStripView() ?? 50.0
        traceLayer.strokeColor = traceColor.cgColor
        if width == nil {
            traceLayer.path = nil
        }
        else {
            traceLayer.path = drawTrace(scale: scale, width: width!, position: position).cgPath
        }
    
    }
    
    func updateTraceFullframe() {
        let scale : CGFloat = dataSource?.traceScaleForScopeStripView() ?? 1.0
        let width = dataSource?.traceWidthForScopeStripView() ?? 20.0
        let position = dataSource?.tracePositionForScopeStripView() ?? 50.0
        traceLayer.strokeColor = traceColor.cgColor
        traceLayer.path = drawTrace(scale: scale, width: width, position: position).cgPath
    }

}
