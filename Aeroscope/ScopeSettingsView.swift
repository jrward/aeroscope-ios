//
//  ScopeSettingsView.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 10/4/15.
//  Copyright © 2015 Jonathan Ward. All rights reserved.
//

import UIKit



class ScopeSettingsView: UIView {

    let settings = Scope.sharedInstance.settings
    
    var myRect : CGRect!
    var myCtx : CGContext!
    
    func drawText(context: CGContextRef, text: NSString, attributes: [String: AnyObject], x: CGFloat, y: CGFloat) -> CGSize {
        let font = attributes[NSFontAttributeName] as! UIFont
        let attributedString = NSAttributedString(string: text as String, attributes: attributes)
        
        let textSize = text.sizeWithAttributes(attributes)
        
        // y: Add font.descender (its a negative value) to align the text at the baseline
        let textPath    = CGPathCreateWithRect(CGRect(x: x, y: y + font.descender, width: ceil(textSize.width), height: ceil(textSize.height)), nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frame       = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedString.length), textPath, nil)
        
        
        
        CTFrameDraw(frame, context)
        
        return textSize
        
    }

    let textAttributes: [String: AnyObject] = [
        NSForegroundColorAttributeName : UIColor.greenColor().CGColor,
        NSFontAttributeName : UIFont.systemFontOfSize(14)
    ]
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        myRect = rect
        myCtx = UIGraphicsGetCurrentContext()
  
        CGContextTranslateCTM(myCtx, 0.0, CGRectGetHeight(myRect))
        CGContextScaleCTM(myCtx, 1.0, -1.0)
        let vertSetting = settings.vert.value
        let horizSetting = settings.horiz.value
        let offsetSetting = settings.offset.value
        let trigDelaySetting = settings.trigger_x_pos.value
        drawText(myCtx!, text: "\(vertSetting) /div", attributes: textAttributes, x: 5, y: 25)
        drawText(myCtx!, text: "\(horizSetting) /div", attributes: textAttributes, x: 5, y: 5)
        drawText(myCtx!, text: "Offset: \(offsetSetting)", attributes: textAttributes, x: 200, y: 25)
        drawText(myCtx!, text: "Trigger Delay: \(trigDelaySetting)", attributes: textAttributes, x: 200, y: 5)
        //updateSettings()
        
    }

    func updateSettings() {
        setNeedsDisplay()
    }

}
