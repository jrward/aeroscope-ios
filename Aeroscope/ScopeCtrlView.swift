//
//  ScopeCtrlView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/16/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import UIKit

@IBDesignable
class ScopeCtrlView: UIView {

    
    let color = UIColor.redColor()
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        let x_size = bounds.size.width - 10
        let y_size = bounds.size.height - 10
        let pen = UIBezierPath()
        let mycenter = convertPoint(center, fromView: superview)
        pen.moveToPoint(CGPoint(x: mycenter.x-(x_size/2), y: mycenter.y-(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x+(x_size/2), y: mycenter.y-(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x+(x_size/2), y: mycenter.y+(y_size/2)))
        pen.addLineToPoint(CGPoint(x: mycenter.x-(x_size/2), y: mycenter.y+(y_size/2)))
        pen.closePath()
        pen.lineWidth = 3.0
        color.set()
        
        pen.stroke()
    }


}
