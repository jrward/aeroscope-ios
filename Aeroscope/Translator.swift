//
//  ScopeSettingsTranslator.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 7/11/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

class Translator {
    
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
    
}


