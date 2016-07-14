//
//  WhiteBalanceViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/12/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class WhiteBalanceViewController : UIViewController, CameraControlsViewControllerProtocol {
    @IBOutlet weak var autoWhiteSwitch: UISwitch!
    @IBOutlet weak var temperatureSlider: UISlider!
    @IBOutlet weak var tintSlider: UISlider!
    
    var cameraController: CameraController? {
        willSet {
            if let cameraController = cameraController {
                cameraController.unregisterObserver(self, property: CameraControlObservableSettingWBGains)
            }
        }
        didSet {
            if let cameraController = cameraController {
                cameraController.registerObserver(self, property: CameraControlObservableSettingWBGains)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let autoWB = cameraController?.isContinuousAutoWhiteBalanceEnabled() {
            autoWhiteSwitch.on = autoWB
            temperatureSlider.enabled = !autoWB
            tintSlider.enabled = !autoWB
        }
        
        if let currentTemperature = cameraController?.currentTemperature() {
            temperatureSlider.value = currentTemperature
        }
        
        if let currentTint = cameraController?.currentTint() {
            tintSlider.value = currentTint
        }
    }
    
    @IBAction func autoWBChanged(sender: UISwitch) {
        temperatureSlider.enabled = !sender.on
        tintSlider.enabled = !sender.on
        
        if autoWhiteSwitch.on {
            cameraController?.enableContinuousAutoWhiteBalance()
        }
        else {
            cameraController?.setCustomWhiteBalanceWithTint(tintSlider.value)
            cameraController?.setCustomWhiteBalanceWithTemperature(temperatureSlider.value)
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        switch sender {
        case temperatureSlider:
            cameraController?.setCustomWhiteBalanceWithTemperature(sender.value)
        case tintSlider:
            cameraController?.setCustomWhiteBalanceWithTint(sender.value)
        default:
            break
        }
    }
}

extension WhiteBalanceViewController : CameraSettingValueObserver {
    func cameraSetting(setting: String, valueChanged value: AnyObject) {
        if setting == CameraControlObservableSettingWBGains {
            if let wbValues = value as? WhiteBalanceValues {
                temperatureSlider.value = wbValues.temperature
                tintSlider.value = wbValues.tint
            }
        }
    }
}


