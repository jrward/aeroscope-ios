//
//  ScopeSettingsTranslator.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 7/11/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class Translator {
    
//    func translateSampleTime(_ samples: Int) -> String {
//        //let normalizedDelay = Double(scope.settings.trigger_x_pos.value - 2048) / 51.2
//        var timeGain : Double = 0
//        let msThresh : Double = 1000000
//        let usThresh : Double = 1000
//        
//        switch scope.settings.getHoriz() {
//        case "25ns": timeGain = 2
//        case "50ns": timeGain = 2
//        case "100ns": timeGain = 2
//        case "200ns": timeGain = 4
//        case "400ns": timeGain = 8
//        case "1us": timeGain = 20
//        case "2us": timeGain = 40
//        case "5us": timeGain = 100
//        case"10us": timeGain = 200
//        case "20us": timeGain = 400
//        case "50us": timeGain = 1000
//        case "100us": timeGain = 2000
//        case "200us": timeGain = 4000
//        case "500us": timeGain = 10000
//        case "1ms": timeGain = 20000
//        case "2ms": timeGain = 40000
//        case "5ms": timeGain = 100000
//        case "10ms": timeGain = 200000
//        case "20ms": timeGain = 400000
//        case "50ms": timeGain = 1000000
//        case "100ms": timeGain = 2000000
//        default : timeGain = 2
//        }
//        
//        let calibrateddTime = Double(samples) * timeGain
//        
//        var stringTime : String
//        
//        if abs(calibrateddTime) > msThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / msThresh)
//            stringTime += " ms"
//        }
//            
//        else if abs(calibrateddTime) > usThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / usThresh)
//            stringTime += " us"
//        }
//            
//        else {
//            stringTime = String(format: "%.0f", calibrateddTime)
//            stringTime += " ns"
//        }
//        
//        return stringTime
//    }
    
    static func toStringFrom(time: Double) -> String {
        var stringTime : String
        let sThresh : Double = 1.0
        let msThresh : Double = 1e-3
        let usThresh : Double = 1e-6
        let nsThresh : Double = 1e-9
        let psThresh : Double = 1e-12
        let fsThresh : Double = 1e-15
        
        if abs(time) > sThresh {
            stringTime = String(format: "%.02f", time / sThresh)
            stringTime += " s"
        }
        
        else if abs(time) > msThresh {
            stringTime = String(format: "%.02f", time / msThresh)
            stringTime += " ms"
        }

        else if abs(time) > usThresh {
            stringTime = String(format: "%.02f", time / usThresh)
            stringTime += " us"
        }

        else if abs(time) > nsThresh {
            stringTime = String(format: "%.00f", time / nsThresh)
            stringTime += " ns"
        }
            
        else if abs(time) > psThresh {
            stringTime = String(format: "%.00f", time / psThresh)
            stringTime += " ps"
        }
            
        else if abs(time) > fsThresh {
            stringTime = String(format: "%.00f", time / fsThresh)
            stringTime += " fs"
        }
        //fallback to default representation
        else {
            stringTime = String(time)
            stringTime += " s"
        }
        
        return stringTime
        

    }
    
    //TODO: Push into ScopeSettingsInterface or ScopeSettings?
    static func toTimeFrom(samples: Int, conv: Double) -> Double {
        return Double(samples) * conv
    }

    static func toStringFrom(voltage: Double?) -> String {
        var voltageString : String
        let vThresh : Double = 1.0
        let mvThresh : Double = 1e-3
        
        if let voltUW = voltage {
            if abs(voltUW) >= vThresh {
                voltageString = String(format: "%.02f", voltUW / vThresh)
                voltageString += " V"
            }
            else {
                voltageString = String(format: "%.0f", voltUW / mvThresh)
                voltageString += " mV"
            }
        }
            
        else {
            voltageString = "???? V"
        }
        
        return voltageString
    }
    
    //TODO: Push into ScopeSettingsInterface or ScopeSettings?
    static func toVoltsFrom(offset: Int, conv: Double, voltConv: Double) -> Double {
        let signedOffset = Double(offset - 32768)
        return (signedOffset / conv) * voltConv
    }
    
    
    
//    var offsetToVolts : Double{
//        get {
//            return (signedOffset / offsetConv) * voltConv
//        }
//    }
    
    

//    static func getOffsetGain() -> Float {
//        
////        var translationGain : CGFloat = 1
////        switch scope.settings.get {
////        case "20mV":
////            //amplifiedTranslation =   translationInView
////            translationGain = 0.99659
////        case "50mV":
////            //amplifiedTranslation =   translationInView
////            translationGain = 1.024
////        case "100mV":
////            //amplifiedTranslation =  (4.7 / 2.3) * translationInView
////            //            translationGain = (4.7 / 2.3)
////            translationGain = 2.048 //4.7/2.3
////        case "200mV":
////            //amplifiedTranslation =  (4.7 / 0.9) * translationInView
////            //            translationGain = (4.7 / 0.9)
////            translationGain = 4.096//(4.7 / 1.1)
////        case "500mV":
////            //amplifiedTranslation =  (4.7 / 0.5) * translationInView
////            translationGain = 10.24//(4.7 / 0.5)
////        case "1V":
////            //amplifiedTranslation =  (4.7 / 0.2) * translationInView
////            //translationGain = (4.7 / 0.2)
////            translationGain = 20.48//(4.7 / 0.23)
////        case "2V":
////            //amplifiedTranslation =  (4.7 / 0.1) * translationInView
////            translationGain = 40.96//(4.7 / 0.1)
////        case "5V":
////            //amplifiedTranslation =  (4.7 / 0.046) * translationInView
////            translationGain = 102.4//(4.7 / 0.046)
////        case "10V":
////            //amplifiedTranslation =  (4.7 / 0.023) * translationInView
////            translationGain = 204.8//(4.7 / 0.023)
////            
////        default:
////            //amplifiedTranslation = 0
////            translationGain = 1
////        }
//        
////        return translationGain
//        let offConv = scope.settings.getVertMeta().offsetConv
//        return 1.0//Float(scope.settings.getVertMeta().offsetConv)
//    }
    


    //Move this into model?
//    static func offsetToString(offset: Int) -> String {
//        let offset = -10 * ((0.000152588 * Double(offset) - 5.0))
//        
//        var offsetString : String
//        if abs(offset) >= 1.0 {
//            offsetString = String(format: "%.03f", offset)
//            offsetString += " V"
//        }
//        else {
//            offsetString = String(format: "%.0f", offset*1000.0)
//            offsetString += " mV"
//        }
//        
//        print("\(offset)    \(offsetString)")
//        return offsetString
//    }
//
//
//
//    /    func translate
//    func gndLabelOffset() -> String {
//        let offset = -10 * ((0.000152588 * Double(scope.settings.getOffset())) - 5.0)
//        let halfScaleV : Double
//        
//        switch scope.settings.getVert() {
//        case "20mV": halfScaleV = 0.08
//        case "50mV":  halfScaleV = 0.2
//        case "100mV": halfScaleV = 0.4
//        case "200mV": halfScaleV = 0.8
//        case "500mV":  halfScaleV = 2.0
//        case "1V":  halfScaleV = 4.0
//        case "2V": halfScaleV = 8.0
//        case "5V":  halfScaleV = 20.0
//        case "10V": halfScaleV = 40.0
//        default: halfScaleV = 4.0
//        }
//        
//        let gndOffset = abs(offset) - halfScaleV
//        
//        print("offset: \(abs(offset))  halfScaleV: \(halfScaleV)")
//        
//        return scope.settings.translateVoltage(Double(gndOffset))
//    }
//
//
//
//
//    //MARK: Work
//    //translates offset into onscreen units
//    func offsetTranslation() -> CGFloat {
//        var translatedOffset : CGFloat
//        var fullscaleVoltage : Double
//        //        let calTable = scope.settings.offsetCalTable
//        //        let vert = scope.settings.vert.value
//        let offset = -10 * ((0.000152588 * Double(scope.settings.getOffset() /*- calTable[vert]!*/)) - 5.0)
//        switch scope.settings.getVert() {
//        case "20mV": fullscaleVoltage = -0.08
//        case "50mV":  fullscaleVoltage = -0.2
//        case "100mV": fullscaleVoltage = -0.4
//        case "200mV": fullscaleVoltage = -0.8
//        case "500mV":  fullscaleVoltage = -2.0
//        case "1V":  fullscaleVoltage = -4.0
//        case "2V": fullscaleVoltage = -8.0
//        case "5V":  fullscaleVoltage = -20.0
//        case "10V": fullscaleVoltage = -40.0
//        default: fullscaleVoltage = -4.0
//        }
//        
//        print(offset)
//        translatedOffset = CGFloat(offset/fullscaleVoltage) * (-128)
//        
//        return translatedOffset
//        
//    }
//
//    func translateStoppedOffset() -> CGFloat {
//        //this is 10/ (2^16)
//        let offsetDiff = -10 * ((0.000152588 * Double(scope.settings.getOffset() - scope.settings.getStoppedOffset())))
//        var fullscaleVoltage : Double
//        
//        switch scope.settings.getVert() {
//        case "20mV": fullscaleVoltage = 0.08
//        case "50mV":  fullscaleVoltage = 0.2
//        case "100mV": fullscaleVoltage = 0.4
//        case "200mV": fullscaleVoltage = 0.8
//        case "500mV":  fullscaleVoltage = 2.0
//        case "1V":  fullscaleVoltage = 4.0
//        case "2V": fullscaleVoltage = 8.0
//        case "5V":  fullscaleVoltage = 20.0
//        case "10V": fullscaleVoltage = 40.0
//        default: fullscaleVoltage = 4.0
//        }
//        
//        return CGFloat(offsetDiff/fullscaleVoltage) * (255/2)
//    }
//
//    //    func trigDelayLabelTranslated() -> String {
//    //        let normalizedDelay = Double(scope.settings.getTrigMemPos() - 2048) / 51.2
//    //        var delayGain : Double = 0
//    //        let msThresh : Double = 1000000
//    //        let usThresh : Double = 1000
//    //
//    //        switch scope.settings.getHoriz() {
//    //        case "25ns": delayGain = 25
//    //        case "50ns": delayGain = 50
//    //        case "100ns": delayGain = 100
//    //        case "200ns": delayGain = 200
//    //        case "400ns": delayGain = 400
//    //        case "1us": delayGain = 1000
//    //        case "2us": delayGain = 2000
//    //        case "5us": delayGain = 5000
//    //        case"10us": delayGain = 10000
//    //        case "20us": delayGain = 20000
//    //        case "50us": delayGain = 50000
//    //        case "100us": delayGain = 100000
//    //        case "200us": delayGain = 200000
//    //        case "500us": delayGain = 500000
//    //        case "1ms": delayGain = 1000000
//    //        case "2ms": delayGain = 2000000
//    //        case "5ms": delayGain = 5000000
//    //        case "10ms": delayGain = 10000000
//    //        case "20ms": delayGain = 20000000
//    //        case "50ms": delayGain = 50000000
//    //        case "100ms": delayGain = 100000000
//    //        default : delayGain = 100
//    //        }
//    //
//    //        let calibratedDelay = normalizedDelay * delayGain
//    //        var stringDelay : String
//    //
//    //        if abs(calibratedDelay) > msThresh {
//    //            stringDelay = String(format: "%.02f", calibratedDelay / msThresh)
//    //            stringDelay += " ms"
//    //        }
//    //
//    //        else if abs(calibratedDelay) > usThresh {
//    //            stringDelay = String(format: "%.02f", calibratedDelay / usThresh)
//    //            stringDelay += " us"
//    //        }
//    //
//    //        else {
//    //            stringDelay = String(format: "%.0f", calibratedDelay)
//    //            stringDelay += " ns"
//    //        }
//    //
//    //        return stringDelay
//    //    }
//
//    //TODO: There is some fucked up shit here. Look at it!
//
//    func translateSampleTime(_ samples: Int) -> String {
//        //let normalizedDelay = Double(scope.settings.trigger_x_pos.value - 2048) / 51.2
//        var timeGain : Double = 0
//        let msThresh : Double = 1000000
//        let usThresh : Double = 1000
//        
//        switch scope.settings.getHoriz() {
//        case "25ns": timeGain = 2
//        case "50ns": timeGain = 2
//        case "100ns": timeGain = 2
//        case "200ns": timeGain = 4
//        case "400ns": timeGain = 8
//        case "1us": timeGain = 20
//        case "2us": timeGain = 40
//        case "5us": timeGain = 100
//        case"10us": timeGain = 200
//        case "20us": timeGain = 400
//        case "50us": timeGain = 1000
//        case "100us": timeGain = 2000
//        case "200us": timeGain = 4000
//        case "500us": timeGain = 10000
//        case "1ms": timeGain = 20000
//        case "2ms": timeGain = 40000
//        case "5ms": timeGain = 100000
//        case "10ms": timeGain = 200000
//        case "20ms": timeGain = 400000
//        case "50ms": timeGain = 1000000
//        case "100ms": timeGain = 2000000
//        default : timeGain = 2
//        }
//        
//        let calibrateddTime = Double(samples) * timeGain
//        
//        var stringTime : String
//        
//        if abs(calibrateddTime) > msThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / msThresh)
//            stringTime += " ms"
//        }
//            
//        else if abs(calibrateddTime) > usThresh {
//            stringTime = String(format: "%.02f", calibrateddTime / usThresh)
//            stringTime += " us"
//        }
//            
//        else {
//            stringTime = String(format: "%.0f", calibrateddTime)
//            stringTime += " ns"
//        }
//        
//        return stringTime
//    }
//
}


