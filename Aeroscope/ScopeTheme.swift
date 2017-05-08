//
//  ScopeTheme.swift
//  Aeroscope
//
//  Created by Jonathan Ward on 4/24/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit
import Themeable

// Define the theme and its properties to be used throughout your app
struct ScopeTheme: Theme {
    
    let identifier: String
    let text : UIColor
    let textAccent: UIColor
    let textSelected : UIColor
    let textMeas: UIColor
    let tint: UIColor
    let tintAccent: UIColor
    let border: UIColor
    let fill: UIColor
    let selected: UIColor
    let grid: UIColor
    let bgGrid: UIColor
    let caretColor: UIColor
    let scopeBorder: UIColor
    let trace: UIColor
    let traceAccent: UIColor
    let stripBorder: UIColor
    let bgPrimary: UIColor
    let bgSecondary: UIColor
    let bgApp: UIColor
    let accentPrimary: UIColor
    let accentSecondary: UIColor
    let batt: UIColor
    let bgBatt: UIColor
    
    static let day = ScopeTheme(
        identifier: "com.Aeroscope.Themeable.day",
        text: UIColor.black,
        textAccent: UIColor.black,
        textSelected: UIColor.white,
        textMeas: UIColor.darkGray,
        tint: UIColor.black,
        tintAccent: UIColor.white,
        border: UIColor.black,
        fill: UIColor.clear,
        selected: UIColor.black,
        grid: UIColor.black,
        bgGrid: UIColor.white,
        caretColor: UIColor.black,
        scopeBorder: UIColor.black,
        trace: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        traceAccent: UIColor(red: 204/255, green: 0.0, blue: 0.0, alpha: 1.0),
        stripBorder: UIColor.black,
        bgPrimary: UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0),
        bgSecondary: UIColor.clear,
        bgApp: UIColor.white,
        accentPrimary: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        accentSecondary: UIColor.lightGray,
        batt: UIColor.black,
        bgBatt: UIColor.clear
    )
    
    static let dark = ScopeTheme(
        identifier: "com.Aeroscope.Themeable.dark",
        text: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        textAccent: UIColor.white,
        textSelected: UIColor.white,
        textMeas: UIColor.gray,
        tint: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        tintAccent: UIColor.white,
        border: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        fill: UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0),
        selected: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        grid: UIColor(red: 204/255, green: 0.0, blue: 0.0, alpha: 1.0),
        bgGrid: UIColor.black,
        caretColor: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        scopeBorder: UIColor(red: 204/255, green: 0.0, blue: 0.0, alpha: 1.0),
        trace: UIColor(red: 149/255, green: 224/255, blue: 0.0, alpha: 1.0),
        traceAccent: UIColor(red: 131/255, green: 197/255, blue: 0.0, alpha: 1.0),
        stripBorder: UIColor.clear,
        bgPrimary: UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0),
        bgSecondary: UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0),
        bgApp: UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0),
        accentPrimary: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        accentSecondary: UIColor.gray,
        batt: UIColor.gray,
        bgBatt: UIColor.clear
    )
    
    
    static let darklight = ScopeTheme(
        identifier: "com.Aeroscope.Themeable.darklight",
        text: UIColor.white,
        textAccent: UIColor.white,
        textSelected: UIColor.white,
        textMeas: UIColor.gray,
        tint: UIColor.white,
        tintAccent: UIColor.black,
        border: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        fill: UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0),
        selected: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        grid: UIColor(red: 204/255, green: 0.0, blue: 0.0, alpha: 1.0),
        bgGrid: UIColor.black,
        caretColor: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        scopeBorder: UIColor(red: 204/255, green: 0.0, blue: 0.0, alpha: 1.0),
        trace: UIColor(red: 149/255, green: 224/255, blue: 0.0, alpha: 1.0),
        traceAccent: UIColor(red: 131/255, green: 197/255, blue: 0.0, alpha: 1.0),
        stripBorder: UIColor.clear,
        bgPrimary: UIColor(red: 60/255, green: 0/255, blue: 0/255, alpha: 1.0),
        bgSecondary: UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0),
        bgApp: UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0),
        accentPrimary: UIColor(red: 240/255, green: 0.0, blue: 0.0, alpha: 1.0),
        accentSecondary: UIColor.gray,
        batt: UIColor.lightGray,
        bgBatt: UIColor.clear

    )
//    rgb(76, 175, 80)
//    4caf50
//    8bc34a
//    cddc39
//    4caf50

    //9e9e9e
    //oldred: UIColor(red: 255/255, green: 25/255, blue: 25/255, alpha: 1.0)
    
//    /#E53935
    static let bright = ScopeTheme(
        identifier: "com.Aeroscope.Themeable.bright",
        text: UIColor.white,
        textAccent: UIColor.white,
        textSelected: UIColor.white,
        textMeas: UIColor.white,
        tint: UIColor.white,
        tintAccent: UIColor.black,
        border: UIColor.clear,
        fill: UIColor(red: 0xF4/0xFF, green: 0x43/0xFF, blue: 36/0xFF, alpha: 1.0),
        selected:  UIColor(red: 0x4C/0xFF, green: 0xAF/0xFF, blue: 0x50/0xFF, alpha: 1.0),
        grid: UIColor.gray,
        bgGrid: UIColor.black,
        caretColor: UIColor.white,
        scopeBorder: UIColor(red: 0xF4/0xFF, green: 0x43/0xFF, blue: 36/0xFF, alpha: 1.0),
        trace: UIColor(red: 0xCD/0xFF, green: 0xDC/0xFF, blue: 0x39/0xFF, alpha: 1.0),
        traceAccent:UIColor(red: 0x8B/0xFF, green: 0xC3/0xFF, blue: 0x4A/0xFF, alpha: 1.0),
        stripBorder: UIColor.clear,
        bgPrimary: UIColor(red: 0xB7/0xFF, green: 0x1C/0xFF, blue: 0x1C/0xFF, alpha: 1.0),
        bgSecondary:  UIColor(red: 0xF4/0xFF, green: 0x43/0xFF, blue: 36/0xFF, alpha: 1.0),
        bgApp: UIColor(red: 28/255, green: 31/255, blue: 36/255, alpha: 1.0),
        accentPrimary: UIColor(red: 0xF4/0xFF, green: 0x43/0xFF, blue: 36/0xFF, alpha: 1.0),
        accentSecondary: UIColor.gray,
        batt: UIColor.white,
        bgBatt: UIColor.black

    )
    
    
    // Expose the available theme variants
    static let variants: [ScopeTheme] = [ .dark, .darklight, .bright, .day ]
    
    // Expose the shared theme manager
    static let manager = ThemeManager<ScopeTheme>(default: .darklight)
    
}
