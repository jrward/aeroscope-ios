//
//  ScopeSettingsInterface.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 5/15/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation

enum ACDC {
    case ac
    case dc
}


protocol FrameSettingsDelegate : AnyObject {
    func didChangeHoriz(oldValue: horiz_mapping)
    func didChangeVert()
    func didChangeOffset()
    func didChangeWindowPos()
    
}

class ScopeSettingsInterface {
    let cmd : ScopeCmd
    var nextFrameSettings : ScopeSettings
    var settingsTimer = Timer()
    var frame : ScopeFrameInterface?
    
    var frameSettingsDelegate : FrameSettingsDelegate?
    
    func stopAcquisition() {
        settingsTimer.invalidate()
        if let frame = frame {
            if !frame.isPaused() {
                cmd.pause()
                frame.pause()
            }
        }
        settingsTimer = Timer.scheduledTimer(timeInterval: 0.090, target: self, selector: #selector(resumeAcquisition), userInfo: nil, repeats: false)
    }
    
    @objc func resumeAcquisition() {
        frame?.resume()
        updateSettings()
        updateRunState()
    }
    
    init(comms: ScopeComms, appSettings: ScopeAppSettings) {
        nextFrameSettings = ScopeSettings(comms: comms)
        cmd = ScopeCmd(comms: comms, appSettings: appSettings)
    }
    
    func updateSettings() {
        if nextFrameSettings.fpga_settings_updated {
            pushSettings()
        }
    }
    
    func pushSettings() {
        nextFrameSettings.send_fpga_settings()
    }
    
    func updateRunState() {
        cmd.runStopSingle = cmd.runStopSingle
    }
    
    
    func getVertSettings() -> [String] {
        return nextFrameSettings.vert.listSettings()
    }
    
    func getHorizSettings() -> [String] {
        return nextFrameSettings.horiz.listSettings()
    }
    
    func getHoriz() -> String {
        return nextFrameSettings.horiz.value
    }
    
    func getHorizMeta() -> horiz_mapping {
        return nextFrameSettings.horiz.mappedSetting()
    }
    
    static func toTimeFrom(samples: Int, conv: Double) -> Double {
        return Double(samples) * conv
    }
    
    func getSubFrameSize() -> Int {
        return nextFrameSettings.horiz.mappedSetting().subFrameSize
    }
    
    func getVert() -> String {
        return nextFrameSettings.vert.value
    }
    
    func getVertMeta() -> vert_mapping {
        return nextFrameSettings.vert.mappedSetting()
    }
    
    func setVert(_ setting: String) {
        stopAcquisition()
        nextFrameSettings.vert.value = setting
        frameSettingsDelegate?.didChangeVert()

    }
    
    func incrementVert() {
        stopAcquisition()
        nextFrameSettings.vert.increment()
        frameSettingsDelegate?.didChangeVert()

    }
    
    func decrementVert() {
        stopAcquisition()
        nextFrameSettings.vert.decrement()
        frameSettingsDelegate?.didChangeVert()

    }
    
    func incrementHoriz() {
        stopAcquisition()
        let oldValue = nextFrameSettings.horiz.mappedSetting()
        nextFrameSettings.horiz.increment()
        frameSettingsDelegate?.didChangeHoriz(oldValue: oldValue)

    }
    
    func decrementHoriz() {
        stopAcquisition()
        let oldValue = nextFrameSettings.horiz.mappedSetting()
        nextFrameSettings.horiz.decrement()
        frameSettingsDelegate?.didChangeHoriz(oldValue: oldValue)

    }
    
    func setHoriz(_ setting: String) {
        stopAcquisition()
        let oldValue = nextFrameSettings.horiz.mappedSetting()
        nextFrameSettings.horiz.value = setting
        frameSettingsDelegate?.didChangeHoriz(oldValue: oldValue)

    }
    
    func getTrigRange() -> Range<Int> {
        return nextFrameSettings.trigger.range
    }
    
    func getTrigMax() -> Int {
        return nextFrameSettings.trigger.range.upperBound - 1
    }
    
    func getTrig() -> Int {
        return nextFrameSettings.trigger.value
    }
    
    func setTrig(_ value: Int) {
        stopAcquisition()
        nextFrameSettings.trigger.value = value
    }
    
    func getTrigMemPos() -> Int {
        return nextFrameSettings.trigger_x_pos.value
    }
    
    func setTrigMemPos(_ position: Int) {
        stopAcquisition()
        nextFrameSettings.trigger_x_pos.value = position
    }
    
    func getTrigMemPosRange() -> Range<Int> {
        return nextFrameSettings.trigger_x_pos.range
    }
    
    func getTrigMemPosMax() -> Int {
        return nextFrameSettings.trigger_x_pos.range.upperBound - 1
    }
    
    func getWindowPos() -> Int {
        return nextFrameSettings.window_pos.value
    }
    
    func getWindowPosRange() -> Range<Int> {
        return nextFrameSettings.window_pos.range
    }
    
    func getWindowPosMin() -> Int {
        return nextFrameSettings.window_pos.range.lowerBound
    }
    
    
    func getWindowPosMax() -> Int {
        return nextFrameSettings.window_pos.range.upperBound - 1
    }
    
    func setWindowPos(_ position: Int) {
        stopAcquisition()
        if position >= getWindowPosMax() || position <= getWindowPosMin() {
            if nextFrameSettings.window_pos.value < getWindowPosMax() &&
                nextFrameSettings.window_pos.value > getWindowPosMin() {
                ScopeMessage.default.set(message: "Trigger Offset Limit Reached")
            }
        }
        nextFrameSettings.window_pos.value = max(min(position,getWindowPosMax()),getWindowPosMin())
        
        frameSettingsDelegate?.didChangeWindowPos()
    }
    
    func incrementWindowPos(_ delta: Int) {
        setWindowPos(self.getWindowPos() + delta)
    }
    
    func getOffset() -> Int {
        return nextFrameSettings.offset.value
    }
    
    func getOffsetRange() -> Range<Int> {
        return nextFrameSettings.offset.range
    }
    
    func getOffsetMax() -> Int {
        return nextFrameSettings.offset.range.upperBound - 1
    }
    
    func setOffset(_ value: Int) {
        stopAcquisition()
        nextFrameSettings.offset.value = value
        frameSettingsDelegate?.didChangeOffset()
    }
    
    func getRunState() -> RunState {
        return cmd.runStopSingle
    }
    
    func setRunState(_ state: RunState) {
        cmd.runStopSingle = state
        
    }
    
    //TODO: Add copy command to copy frame settings on frame reception
    
    
    func autoTrigEnable() {
        stopAcquisition()

        nextFrameSettings.trigCtrl.autoTrig.value = true
    }
    
    func autoTrigDisable() {
        stopAcquisition()

        nextFrameSettings.trigCtrl.autoTrig.value = false
    }
    
    func getAutoTrig() -> Bool {
        return nextFrameSettings.trigCtrl.autoTrig.value
    }
    
    func lpTrigEnable() {
        stopAcquisition()

        nextFrameSettings.trigCtrl.lowPassTrig.value = true
    }
    
    func lpTrigDisable() {
        stopAcquisition()

        nextFrameSettings.trigCtrl.lowPassTrig.value = false
    }
    
    func getLpTrig() -> Bool {
        return nextFrameSettings.trigCtrl.lowPassTrig.value
    }
    
    func getWriteDepth() -> Int {
        return nextFrameSettings.writeDepth.value
    }
    
    func setWriteDepth(_ depth: Int) {
        nextFrameSettings.writeDepth.value = depth
    }
    
    func getReadDepth() -> Int {
        return nextFrameSettings.readDepth.value
    }
    
    func setReadDepth(_ depth: Int) {
        nextFrameSettings.readDepth.value = depth
    }
    
    func getACDC() -> ACDC {
        if nextFrameSettings.dc_en.value == true {
            return .dc
        }
        else {
            return .ac
        }
    }
    
    func setACDC(_ state: ACDC) {
        stopAcquisition()
        if state == .dc {
            nextFrameSettings.dc_en.value = true
        }
        else {
            nextFrameSettings.dc_en.value = false
        }
    }
    
    func setTrigMode(_ mode: TriggerMode) {
        stopAcquisition()

        switch mode {
            case .pos:  nextFrameSettings.trigCtrl.posSlopeTrig.value = true
                        nextFrameSettings.trigCtrl.negSlopeTrig.value = false
            case .neg:  nextFrameSettings.trigCtrl.posSlopeTrig.value = false
                        nextFrameSettings.trigCtrl.negSlopeTrig.value = true
            case .any:  nextFrameSettings.trigCtrl.posSlopeTrig.value = true
                        nextFrameSettings.trigCtrl.negSlopeTrig.value = true
            default:    nextFrameSettings.trigCtrl.posSlopeTrig.value = true
                        nextFrameSettings.trigCtrl.negSlopeTrig.value = false
        }
    }
    
    func getTrigMode() -> TriggerMode {
        if nextFrameSettings.trigCtrl.posSlopeTrig.value == true {
            if nextFrameSettings.trigCtrl.negSlopeTrig.value == true {
                return .any
            }
            else {
                return .pos
            }
        }
        else if nextFrameSettings.trigCtrl.negSlopeTrig.value == true {
            return .neg
        }
        else {
            return .none
        }
    }
    
}
