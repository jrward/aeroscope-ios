//
//  Debug.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 5/20/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

enum DebugType {
    case all
    case none
    case frame
    case comms
    case ui
}

let debug = Debug(type: .none)

struct Debug {
    
    var type : DebugType = .none
    
    init(type: DebugType) {
        self.type = type
    }
    
}
