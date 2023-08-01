//
//  ScopeOffsetView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 4/8/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import UIKit
import Foundation


protocol ScopeOffsetViewDataSource : AnyObject {
    //0.0 - 100.0
    func frameHeightForScopeOffsetView(_ sender: ScopeOffsetView) -> CGFloat?
    //0.0 - 100.0
    func offsetForScopeOffsetView(_ sender: ScopeOffsetView) -> CGFloat?
}

@IBDesignable
class ScopeOffsetView: UIView {

    @IBInspectable
    var gridColor : UIColor = UIColor.white { didSet { setNeedsDisplay() } }
    @IBInspectable
    var bgColor : UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    @IBInspectable
    var sliderColor : UIColor = UIColor.gray { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var labelColor = UIColor(red: 240/255, green: 0/255, blue: 0/255, alpha: 1.0) {
        didSet {
            labelFont = UIFont(name: "Helvetica Neue", size: 16)!
            labelAttr  = [NSAttributedString.Key.foregroundColor : labelColor,
                          NSAttributedString.Key.font : labelFont]
            setNeedsDisplay()
        }
    }
    
    weak var dataSource : ScopeOffsetViewDataSource?
    
    let sliderLayer = CAShapeLayer()
    
    
    
    var labelFont : UIFont!
    
    var labelAttr : [NSAttributedString.Key : AnyObject]!
    
    let labelBox = NSString(string: "I|q`")
    
    var width : CGFloat {
        return bounds.size.width
    }
    var height : CGFloat {
        return bounds.size.height
    }
    
    var labelHeight : CGFloat {
        return labelBox.size(withAttributes: labelAttr).height
    }
    
    var scale_height : CGFloat {
        return height //- (2 * labelHeight)
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
        self.layer.addSublayer(sliderLayer)
        self.backgroundColor = nil
        self.isOpaque = false
        sliderLayer.actions = ["position": NSNull()]
        
        labelFont = UIFont(name: "Helvetica Neue", size: 16)!
        labelAttr  = [NSAttributedString.Key.foregroundColor : labelColor,
                      NSAttributedString.Key.font : labelFont]
       // NSTex]
        
    }

    

    override func draw(_ rect: CGRect) {
        self.backgroundColor = nil
        self.isOpaque = false
        let frameHeight = dataSource?.frameHeightForScopeOffsetView(self) ?? (8.0/80.0)
        let pen = UIBezierPath()
        
        pen.move(to: CGPoint(x: 45, y: 0))
        pen.addLine(to: CGPoint(x: width-5, y: 0))
        pen.addLine(to: CGPoint(x: width-5, y: height))
        pen.addLine(to: CGPoint(x: 45, y: height))
        pen.close()

        bgColor.set()
        pen.fill()
        sliderLayer.path = drawSlider(frameHeight: frameHeight, position: 50.0).cgPath
        
        sliderLayer.strokeColor = sliderColor.cgColor
        sliderLayer.lineWidth = lineWidth
        sliderLayer.fillColor = nil
        
        updateSlider()
        
        pen.removeAllPoints()
        
        pen.move(to: CGPoint(x: 40, y: scale_height/10))
        pen.addLine(to: CGPoint(x: width, y: scale_height/10))
        pen.move(to: CGPoint(x: 40, y: 2*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 2*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 3*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 3*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 4*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 4*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 5*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 5*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 6*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 6*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 7*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 7*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 8*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 8*scale_height/10 ))
        pen.move(to: CGPoint(x: 40, y: 9*scale_height/10 ))
        pen.addLine(to: CGPoint(x: width, y: 9*scale_height/10 ))
        
        gridColor.set()
        pen.stroke()
        
        
        let label40 = NSString(string: "40V")
        let label30 = NSString(string: "30V")
        let label20 = NSString(string: "20V")
        let label10 = NSString(string: "10V")
        let label00 = NSString(string: "0V")
        let labelNeg10 = NSString(string: "-10V")
        let labelNeg20 = NSString(string: "-20V")
        let labelNeg30 = NSString(string: "-30V")
        let labelNeg40 = NSString(string: "-40V")

        let textOffset : CGFloat = (labelHeight/2)
        
        label40.draw(at: CGPoint(x: 0, y: scale_height/10 - textOffset), withAttributes: labelAttr)
        label30.draw(at: CGPoint(x: 0, y: 2*scale_height/10 - textOffset), withAttributes: labelAttr)
        label20.draw(at: CGPoint(x: 0, y: 3*scale_height/10 - textOffset), withAttributes: labelAttr)
        label10.draw(at: CGPoint(x: 0, y: 4*scale_height/10 - textOffset), withAttributes: labelAttr)
        label00.draw(at: CGPoint(x: 0, y: 5*scale_height/10 - textOffset), withAttributes: labelAttr)
        labelNeg10.draw(at: CGPoint(x: 0, y: 6*scale_height/10 - textOffset), withAttributes: labelAttr)
        labelNeg20.draw(at: CGPoint(x: 0, y: 7*scale_height/10 - textOffset), withAttributes: labelAttr)
        labelNeg30.draw(at: CGPoint(x: 0, y: 8*scale_height/10 - textOffset), withAttributes: labelAttr)
        labelNeg40.draw(at: CGPoint(x: 0, y: 9*scale_height/10 - textOffset), withAttributes: labelAttr)
        
    }
    
    override func layoutSubviews() {

    }
    
    func drawSlider(frameHeight: CGFloat, position: CGFloat) -> UIBezierPath {
        
        let mypath = UIBezierPath()
        
        print("slider position: \(position)")
        
        let height = frameHeight / 100.0 * bounds.size.height
        let pos = (100.0 - position) / 100.0 * bounds.size.height

        mypath.move(to: CGPoint(x: 45, y: pos - height/2))
        mypath.addLine(to: CGPoint(x: width-5, y: pos - height/2))
        mypath.addLine(to: CGPoint(x: width-5, y: pos + height/2))
        mypath.addLine(to: CGPoint(x: 45, y: pos + height/2))
        mypath.close()
            
        return mypath
    }
    
    func updateSliderHeight() {
        let frameHeight = dataSource?.frameHeightForScopeOffsetView(self) ?? (8.0/80.0)

        sliderLayer.path = drawSlider(frameHeight: frameHeight, position: 50.0).cgPath
        
        sliderLayer.strokeColor = UIColor.lightGray.cgColor
        sliderLayer.lineWidth = lineWidth
        sliderLayer.fillColor = nil
    }
 
    func updateSlider() {
        let position = dataSource?.offsetForScopeOffsetView(self) ?? 50.0
        let positionTranslated = (position - 50.0) / 100.0  * bounds.size.height
        
        sliderLayer.position = CGPoint(x: 0.0, y: positionTranslated)
    }

}
