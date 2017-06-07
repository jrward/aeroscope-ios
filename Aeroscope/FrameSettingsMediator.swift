//
//  FrameSettingsMediator.swift
//  Aeroscope
//
//  Created by Jonathan Ward on 5/17/17.
//  Copyright © 2017 Jonathan Ward. All rights reserved.
//

import Foundation

//protocol FrameMediatorDelegate : class {
//    func zoomX(_: Float)
//    func zoomY(_: Float)
//    func panX(_: Float)
//    func panY(_: Float)
//}

// Takes in two settings and 
//class FrameSettingsMediator : FrameSettingsDelegate {
//    
//    var frameSettings : ScopeSettings!
//    var scopeSettings : ScopeSettings!
//    weak var mediatorDelegate : FrameMediatorDelegate?
//    
//    init(frameSettings: ScopeSettings, scopeSettings: ScopeSettings)
//    {
//        self.frameSettings = frameSettings
//        self.scopeSettings = scopeSettings
//        
//    }
//    
//    init() {
//        
//    }
//    
//    func calcZoomY() -> Float {
//        let zoom : Double = frameSettings.vert.mappedSetting().toReal /
//            scopeSettings.vert.mappedSetting().toReal
//        return Float(zoom)
//    }
//    
//    func calcZoomX() -> Float {
//        let zoom : Double = frameSettings.horiz.mappedSetting().toReal /
//            scopeSettings.horiz.mappedSetting().toReal
//        return Float(zoom)
//    }
//    
//    func mediateSettings() {
//        
//    }
//    
//    
//    func didChangeVert() {
//        let zoom = calcZoomY()
//        mediatorDelegate?.zoomY(zoom)
//    }
//    
//    func didChangeHoriz() {
//        let zoom = calcZoomX()
//        mediatorDelegate?.zoomX(zoom)
//    }
//    
//    func didChangeOffset() {
//        mediatorDelegate?.
//    }
//    
//    func didChangeWindowPos() {
//        //Unused at this time
//    }
//    
//}
