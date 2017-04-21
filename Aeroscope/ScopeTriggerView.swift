//
//  ScopeTriggerView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/17/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit

@IBDesignable
class ScopeTriggerView: UIView {

    let color : UIColor = UIColor.grayColor()

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
       /* 
        let x_size = bounds.size.width - 10
        let y_size = bounds.size.height - 10
        let pen = UIBezierPath()
        let mycenter = convertPoint(center, fromView: superview)
        pen.moveToPoint(CGPoint(x: mycenter.x-(x_size/2), y: mycenter.y-(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x+(x_size/2), y: mycenter.y-(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x+(x_size/2), y: mycenter.y+(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x-(x_size/2), y: mycenter.y+(y_size/2)))
        pen.closePath()
        pen.lineWidth = 1.0
        color.set()
        
        pen.stroke()
*/
        
    }

    /*

    func drawSlider(#width: CGFloat, position: CGFloat) -> UIBezierPath {
        
        let relativeWidth = width/100.0 * track_width
        let mypath = UIBezierPath()
        mypath.moveToPoint(CGPoint(x: mycenter.x  - (relativeWidth/2), y: mycenter.y + (slider_height/2)))
        mypath.addLineToPoint(CGPoint(x:mycenter.x  + (relativeWidth/2), y: mycenter.y + (slider_height/2)))
        mypath.addLineToPoint(CGPoint(x:mycenter.x  + (relativeWidth/2), y: mycenter.y - (slider_height/2)))
        mypath.addLineToPoint(CGPoint(x:mycenter.x  - (relativeWidth/2), y: mycenter.y - (slider_height/2)))
        mypath.closePath()
        
        return mypath
    }

    func updateSlider() {
        let position = dataSource?.positionForScopeStripView(self) ?? 50.0
        sliderLayer.position = CGPoint(x: CGFloat((position-50.0)/100.0) * track_width, y: 0.0)
        //sliderLayer.needsDisplay()
    }
    
    */
}
