//
//  BorderColor.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 6/11/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func borderUIColor() -> UIColor? {
        return borderColor != nil ? UIColor(cgColor: borderColor!) : nil
    }
    
    func setBorderUIColor(_ color: UIColor) {
        borderColor = color.cgColor
    }
}

@IBDesignable
extension UIButton{
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.cornerRadius = 5
            layer.borderColor = newValue?.cgColor
            layer.borderWidth = 1
        }
    }
}
