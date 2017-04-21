//
//  ScopeBatteryView.swift
//  AeroscopeLite
//
//  Created by Jonathan Ward on 12/2/16.
//  Copyright © 2016 Jonathan Ward. All rights reserved.
//

import Foundation
import UIKit

protocol ScopeBatteryViewDataSource : class {
    func battStateForBatteryView() -> ScopeBattery.BattState
    func chargeStateForBatteryView() -> Bool
}

@IBDesignable
class ScopeBatteryView : UIView {
    
    let battImage = UIImageView()
    let battDead = UIImageView()
    let battFullCharge = UIImageView()
    let battCharging = UIImageView()
    
    var bundle : Bundle!

    
    weak var dataSource : ScopeBatteryViewDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }
    
    required init?(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
        initLayers()
    }
    
    func initLayers() {
        bundle = Bundle(for: type(of: self))

        self.addSubview(battImage)
        self.addSubview(battDead)
        self.addSubview(battFullCharge)
        self.addSubview(battCharging)
        
        self.bringSubview(toFront: battCharging)
        self.isOpaque = false
        self.backgroundColor = UIColor.clear

    }
    
    override func layoutSubviews() {
        battImage.frame = self.bounds
        battDead.frame = self.bounds
        battFullCharge.frame = self.bounds
        battCharging.frame = self.bounds
        
        battImage.contentMode = .scaleToFill
        battImage.tintColor = UIColor.gray
        
        battDead.contentMode = .scaleToFill
        battFullCharge.contentMode = .scaleToFill
        battCharging.contentMode = .scaleToFill
        
        updateBattState()
        
       // chargeLayer.image = UIImage(named: "batt_charging")
      //  chargeLayer.contentMode = .scaleToFill
        
    }
    
        
    func updateBattState() {
        if let battState = dataSource?.battStateForBatteryView(),
            let chargeState = dataSource?.chargeStateForBatteryView() {
            
            switch battState {
                case .fullyCharged:
                    battImage.image = UIImage(named: "batt_empty")?.withRenderingMode(.alwaysTemplate)
                    battDead.image = nil
                    battFullCharge.image = UIImage(named: "batt_fullcharge")
                case .full:
                    battImage.image = UIImage(named: "batt_full")?.withRenderingMode(.alwaysTemplate)
                    battDead.image = nil
                    battFullCharge.image = nil
                case .mid:
                    battImage.image = UIImage(named: "batt_mid")?.withRenderingMode(.alwaysTemplate)
                    battDead.image = nil
                    battFullCharge.image = nil
                case .low:
                    battImage.image = UIImage(named: "batt_low")?.withRenderingMode(.alwaysTemplate)
                    battDead.image = nil
                    battFullCharge.image = nil
                case .dead:
                    battImage.image = UIImage(named: "batt_empty")?.withRenderingMode(.alwaysTemplate)
                    battDead.image = UIImage(named: "batt_dead")
                    battFullCharge.image = nil
            case .unknown:
                    battImage.image = nil
                    battDead.image = nil
                    battFullCharge.image = nil
            }
            
            if chargeState == true {
                battCharging.image = UIImage(named: "batt_charging")
            }
                
            else {
                battCharging.image = nil
            }

        }
        
        else {
            battImage.image = UIImage(named: "batt_mid", in: bundle,
                compatibleWith: self.traitCollection)?.withRenderingMode(.alwaysTemplate)
        }
        
    }
    
    override func prepareForInterfaceBuilder() {
        bundle = Bundle(for: type(of: self))

        initLayers()
        layoutSubviews()
        super.prepareForInterfaceBuilder()
    }
    
    
}
