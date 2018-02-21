//
//  ScopeFrameView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/16/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit
import Accelerate



protocol ScopeFrameViewDataSource : class {
    func dataForScopeFrameView() -> frameData?
    func positionForGndSymbol() -> CGFloat?
    func positionForTrigSymbol() -> CGFloat?
    func positionForTrigXPos() -> CGFloat?
    func dataForTrigXLabel() -> String?
    func dataForGndLabel() -> String?
    func highlightSamples() -> Bool?
}

class TraceWriter : NSObject, CALayerDelegate {

    weak var dataSource : ScopeFrameViewDataSource?     //data source delegate
    var borderSize : CGFloat = 1
    var bounds: CGRect = CGRect()

    init(borderSize: CGFloat, bounds: CGRect, dataSource: ScopeFrameViewDataSource?) {
        self.borderSize = borderSize
        self.bounds = bounds
        self.dataSource = dataSource
    }
    
    override init() {
        
    }
    
    func display(_ layer: CALayer)  {
        if let tracelayer = layer as? CAShapeLayer {
            tracelayer.path = drawTrace().cgPath
        }
    }
    
    func drawTrace() -> UIBezierPath{
        let x_size = bounds.size.width
        let y_size = bounds.size.height
        let trace = UIBezierPath()
        let frameData = dataSource?.dataForScopeFrameView()
        let highlight = dataSource?.highlightSamples() ?? false
        var frame : Samples = frameData?.frame ?? Samples()
        let frameSize : CGFloat = CGFloat(frameData?.frameSize ?? 500)
        let frameXOffset : CGFloat = CGFloat(frameData?.xPos ?? 0)
        let subTrig : CGFloat = CGFloat(frameData?.subTrig ?? 0)
        
        let xstep : CGFloat
        if frameSize < 2 {
            xstep = (x_size - 2*borderSize)
        }
            
        else {
            xstep = (x_size - 2*borderSize) / (frameSize - 1)
        }
        
        let subTrigOffset = xstep * subTrig
        
        let scale : CGFloat = CGFloat((y_size - 2*borderSize)/255)
        
        if !frame.data.isEmpty {
            trace.move(to: CGPoint(x: borderSize + (frameXOffset * xstep) + subTrigOffset, y: (y_size - borderSize) - CGFloat(frame.data[0].value) * scale))
            if frameSize < 2 {
                trace.addLine(to: CGPoint(x: borderSize + (frameXOffset * xstep) + xstep + subTrigOffset, y: (y_size - borderSize) - CGFloat(frame.data[0].value) * scale))
            }
            else {
                
                for i in 1 ..< frame.data.count {
                    trace.addLine(to: CGPoint(x: borderSize + (frameXOffset * xstep) + (CGFloat(i) * xstep) + subTrigOffset, y: (y_size - borderSize) - CGFloat(frame.data[i].value) * scale))
                    if frame.data[i].isValid && highlight {
                        trace.addArc(withCenter: CGPoint(x: borderSize + (frameXOffset * xstep) + (CGFloat(i) * xstep) + subTrigOffset, y: (y_size - borderSize) - CGFloat(frame.data[i].value) * scale), radius: 1.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
                    }
                }
            }
        }
        
        return trace
    }
}


@IBDesignable
class ScopeFrameView: UIView{
    
    var interp_en = true

    @IBInspectable
    var gridColor : UIColor = UIColor.orange {didSet { updateColors()}}
    @IBInspectable
    var borderColor : UIColor = UIColor.red { didSet { updateColors() }}
    @IBInspectable
    var bgColor : UIColor = UIColor.black {didSet { updateColors()}}
    @IBInspectable
    var traceColor : UIColor = UIColor.green {didSet { updateColors()}}
    @IBInspectable
    var gndColor : UIColor = UIColor.green {didSet { updateColors() }}
    @IBInspectable
    var caretColor: UIColor = UIColor.gray {didSet { updateColors() }}
    
    let xDiv = 10
    let yDiv = 8
    let subDiv = 5
    let graticleLength : CGFloat = 8
    var x_size : CGFloat!
    var y_size : CGFloat!
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    let borderSize : CGFloat = 1
    
    let traceLayer = CAShapeLayer()
    let traceWriter = TraceWriter()
    
    let gndLayer = CAShapeLayer()
    let trigLayer = CAShapeLayer()
    let trigXPosLayer = CAShapeLayer()
    
    let gndArrowLayer = CAShapeLayer()
    
    weak var dataSource : ScopeFrameViewDataSource?     //data source delegate
    
    let leftTrig = ArrowLabelView(frame: CGRect(x: 8,y: 4,width: 140,height: 14),text: "Trig: 1.00 us", loc: .left, dir: .left, color: UIColor.red)
    
    let rightTrig = ArrowLabelView(frame: CGRect(x: 0,y: 4,width: 140,height: 14),text: "Trig: 1.00 us", loc: .right, dir: .right, color: UIColor.red)
    
    let upGnd = ArrowLabelView(frame: CGRect(x: 4,y: 24,width: 140,height: 14),text: "Gnd: 1.99 mV", loc: .left, dir: .up, color: UIColor.green)
    
    let downGnd = ArrowLabelView(frame: CGRect(x: 4,y: 16,width: 140,height: 14),text: "Gnd: 1.99 mV", loc: .left, dir: .down, color: UIColor.green)
    
    func updateColors() {
        setNeedsDisplay()
        traceLayer.strokeColor = traceColor.cgColor
        gndLayer.strokeColor = gndColor.cgColor
        trigLayer.fillColor = self.caretColor.cgColor
        trigXPosLayer.fillColor = self.caretColor.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLayers()
    }
    
    func initLayers() {
        self.layer.addSublayer(traceLayer)
        self.layer.addSublayer(gndLayer)
        self.layer.addSublayer(trigLayer)
        self.layer.addSublayer(trigXPosLayer)
        self.addSubview(leftTrig)
        self.addSubview(rightTrig)
        self.addSubview(upGnd)
        self.addSubview(downGnd)

    }
    
    override func layoutSubviews() {
        x_size = bounds.size.width
        y_size = bounds.size.height
        
        traceLayer.strokeColor = traceColor.cgColor
        traceLayer.lineJoin = kCALineJoinRound
        traceLayer.lineWidth = 3.0
        traceLayer.fillColor = nil
        traceLayer.actions = ["position":NSNull()]
        traceLayer.delegate = traceWriter
        traceWriter.dataSource = dataSource
        traceWriter.bounds = bounds
        traceLayer.path = traceWriter.drawTrace().cgPath
        
        gndLayer.path = drawGnd().cgPath
        gndLayer.lineWidth = 1.0
        gndLayer.fillColor = nil
        gndLayer.strokeColor = gndColor.cgColor
        gndLayer.actions = ["position":NSNull()]
        
        trigLayer.path = drawTrig().cgPath
        trigLayer.fillColor = self.caretColor.cgColor
        trigLayer.actions = ["position":NSNull()]
        
        trigXPosLayer.path = drawTrigXPos().cgPath
        trigXPosLayer.fillColor = self.caretColor.cgColor
        trigXPosLayer.actions = ["position":NSNull()]
        
        rightTrig.frame.origin.x = self.frame.size.width - rightTrig.frame.size.width - 20
        downGnd.frame.origin.y = self.frame.size.height - downGnd.frame.size.height - 12

        updateTrig()
        updateGnd()
        updateTrigXPos()

    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let frame = drawFrame()
        let grid = drawGrid()
        let graticle = drawGraticle()
        bgColor.set()
        frame.fill()
        
        gridColor.set()
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = self.borderColor.cgColor
        grid.stroke()
        graticle.stroke()
        leftTrig.color = caretColor
        rightTrig.color = caretColor
        upGnd.color = gndColor
        downGnd.color = gndColor

    }
    

    func drawGrid() -> UIBezierPath {

        let grid = UIBezierPath()
        
        for index in 1..<xDiv {
            grid.move(to: CGPoint(x: borderSize + CGFloat(index) * (x_size - 2*borderSize)/CGFloat(xDiv)  , y: borderSize ))
            grid.addLine(to: CGPoint(x: borderSize + CGFloat(index) * (x_size - 2*borderSize)/CGFloat(xDiv)  , y: (y_size - borderSize) ))
        }
        
        for index in 1..<yDiv {
            grid.move(to: CGPoint(x: borderSize , y: CGFloat(index) * (y_size - borderSize)/CGFloat(yDiv) ))
            grid.addLine(to: CGPoint(x: x_size - borderSize  , y: CGFloat(index) * (y_size - borderSize)/CGFloat(yDiv) ))
        }
        grid.lineWidth = 1
        grid.setLineDash([3.0,3.0], count: 2, phase: 0)
        
        return grid
        
    }
    
    func drawGraticle() -> UIBezierPath {
        let graticle = UIBezierPath()
        let centerY = bounds.size.height/2
        let centerX = bounds.size.width/2
        let gWidth =  x_size - 2*borderSize
        let gHeight =  y_size - 2*borderSize
        
        graticle.move(to: CGPoint(x: borderSize, y: centerY))
        graticle.addLine(to: CGPoint(x: x_size - 2*borderSize, y: centerY))
        graticle.move(to: CGPoint(x: centerX, y: borderSize))
        graticle.addLine(to: CGPoint(x: centerX, y: y_size - 2*borderSize))
        
        for i in 0 ..< xDiv  {
            for j in 1 ..< subDiv {
                let xDivision =  CGFloat(i) * gWidth / CGFloat(xDiv)
                let xSubDivision = CGFloat(j) * gWidth / CGFloat(xDiv) / CGFloat(subDiv)
                graticle.move(to: CGPoint(x: borderSize + xDivision + xSubDivision, y: centerY - (graticleLength/2)))
                graticle.addLine(to: CGPoint(x: borderSize + xDivision + xSubDivision, y:  centerY + (graticleLength/2)))
            }
        }
        
        for i in 0 ..< yDiv  {
            for j in 1 ..< subDiv {
                let yDivision =  CGFloat(i) * gHeight / CGFloat(yDiv)
                let ySubDivision = CGFloat(j) * gHeight / CGFloat(yDiv) / CGFloat(subDiv)
                
                graticle.move(to: CGPoint(x: centerX - (graticleLength/2) , y: borderSize + yDivision + ySubDivision))
                
                graticle.addLine(to: CGPoint(x: centerX + (graticleLength/2), y: borderSize + yDivision + ySubDivision ))
            }
        }
        
        graticle.lineWidth = 1

        return graticle
    }
    
    func drawFrame() -> UIBezierPath {
        let frame = UIBezierPath()

        frame.move(to: CGPoint(x: 0 , y: 0 ))
        frame.addLine(to: CGPoint(x: x_size , y: 0))
        frame.addLine(to: CGPoint(x: x_size, y: y_size ))
        frame.addLine(to: CGPoint(x: 0, y: y_size ))
        frame.close()
        frame.lineWidth = 0.0
        
        return frame
    }
    
    func updateTrace() {
        traceLayer.setNeedsDisplay()
        
    }

    func drawGnd() -> UIBezierPath {
        let gndSymbol = UIBezierPath()
        let centerY = bounds.size.height/2
        gndSymbol.move(to: CGPoint(x: 3, y: centerY))
        gndSymbol.addLine(to: CGPoint(x: 7, y: centerY))
        gndSymbol.addLine(to: CGPoint(x: 7, y: centerY + 7))
        
        gndSymbol.move(to: CGPoint(x: 3, y: centerY + 7))
        gndSymbol.addLine(to: CGPoint(x: 11, y: centerY + 7))
        
        gndSymbol.move(to: CGPoint(x: 5, y: centerY + 10))
        gndSymbol.addLine(to: CGPoint(x: 9, y: centerY + 10))
        
        gndSymbol.move(to: CGPoint(x: 7, y: centerY + 12))
        gndSymbol.addLine(to: CGPoint(x: 7, y: centerY + 14))
        
        return gndSymbol
    }
    

    func drawTrig() -> UIBezierPath {
        let trigSymbol = UIBezierPath()
        let centerX = x_size - borderSize
        let centerY = y_size - borderSize
        let center = CGPoint(x: centerX, y: centerY)
        
        trigSymbol.move(to: center)
        trigSymbol.addLine(to: CGPoint(x: centerX, y: centerY - 5))
        trigSymbol.addLine(to: CGPoint(x: centerX - 7, y: centerY))
        trigSymbol.addLine(to: CGPoint(x: centerX, y: centerY + 5))
        trigSymbol.close()
    
        return trigSymbol
    }
    
    func drawTrigXPos() -> UIBezierPath {
        let trigXPos = UIBezierPath()
        let centerX = x_size/2
        let centerY = borderSize
        let center = CGPoint(x: centerX, y: centerY)
        
        trigXPos.move(to: center)
        trigXPos.addLine(to: CGPoint(x: centerX + 5, y: centerY))
        trigXPos.addLine(to: CGPoint(x: centerX, y: centerY + 7))
        trigXPos.addLine(to: CGPoint(x: centerX - 5, y: centerY))
        trigXPos.close()
        
        return trigXPos
    }
    
    enum Direction {
        case up
        case down
        case left
        case right
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
        return arrow
    }
    

    func averageTrace(_ trace : [UInt8]) -> Double {
    
        var traceAvg : Double = 0
        
        for el in trace {
            traceAvg += Double(el)
        }
        traceAvg = traceAvg/Double(trace.count)
        //print("Average Value: \(traceAvg)")
        
        return traceAvg
    }
    
    func updateGnd() {
        let position = dataSource?.positionForGndSymbol() ?? 50.0
        if position < 0 {
            downGnd.isHidden = false
            upGnd.isHidden = true
            gndLayer.isHidden = true
            
            downGnd.text = dataSource?.dataForGndLabel()
        }
        else if position > 100 {
            downGnd.isHidden = true
            upGnd.isHidden = false
            gndLayer.isHidden = true
            
            upGnd.text = dataSource?.dataForGndLabel()
        }
        
        else {
            downGnd.isHidden = true
            upGnd.isHidden = true
            gndLayer.isHidden = false
            let scaledPosition = (50 - position) * (y_size - 2*borderSize)/100.0
            self.gndLayer.position = CGPoint(x: 0, y: scaledPosition)
        }
    }
    
    func updateShowPts() {
        if dataSource?.highlightSamples() ?? false{
            traceLayer.lineWidth = 2.0
        }
        
        else {
            traceLayer.lineWidth = 3.0
        }
        
    }
    
    
    func updateTrig() {
        let position = dataSource?.positionForTrigSymbol() ?? 50.0
        let scaledPosition = position / 100.0 * (y_size - 2*borderSize)
        self.trigLayer.position = CGPoint(x: 0, y: -scaledPosition)
    }
    
    func updateTrigXPos() {
        let position = dataSource?.positionForTrigXPos() ?? 50.0
        
        if position < 0 {
            leftTrig.isHidden = false
            rightTrig.isHidden = true
            trigXPosLayer.isHidden = true
            leftTrig.text = dataSource?.dataForTrigXLabel()
            self.trigXPosLayer.position = CGPoint(x: 0, y: 0)

        }
        
        else if position > 100 {
            leftTrig.isHidden = true
            rightTrig.isHidden = false
            trigXPosLayer.isHidden = true
            rightTrig.text = dataSource?.dataForTrigXLabel()
            self.trigXPosLayer.position = CGPoint(x: x_size, y: 0)

        }
        else {
            let scaledPosition = (position - 50) * (x_size - 2*borderSize)/100.0
            self.trigXPosLayer.position = CGPoint(x: scaledPosition, y: 0)
            leftTrig.isHidden = true
            rightTrig.isHidden = true
            trigXPosLayer.isHidden = false
        }
    }
}
