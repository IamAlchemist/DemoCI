//
//  ExposureViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/12/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit
import CoreMedia

class ExposureViewController : UIViewController, CameraControlsViewControllerProtocol {
    @IBOutlet weak var autoExposureSwitch: UISwitch!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var isoSlider: UISlider!
    @IBOutlet weak var biasSlider: UISlider!
    
    var cameraController: CameraController? {
        willSet {
            if let cameraController = cameraController {
                cameraController.unregisterObserver(self, property: CameraControlObservableSettingExposureTargetOffset)
                cameraController.unregisterObserver(self, property: CameraControlObservableSettingExposureDuration)
                cameraController.unregisterObserver(self, property: CameraControlObservableSettingISO)
            }
        }
        didSet {
            if let cameraController = cameraController {
                cameraController.registerObserver(self, property: CameraControlObservableSettingExposureTargetOffset)
                cameraController.registerObserver(self, property: CameraControlObservableSettingExposureDuration)
                cameraController.registerObserver(self, property: CameraControlObservableSettingISO)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isViewLoaded && cameraController != nil {
            if let autoExposure = cameraController?.isContinuousAutoFocusEnabled() {
                autoExposureSwitch.isOn = autoExposure
                updateSliders()
            }
            
            if let currentDuration = cameraController?.currentExposureDuration() {
                speedSlider.value = currentDuration
            }
            
            if let currentISO = cameraController?.currentISO() {
                isoSlider.value = currentISO
            }
            
            if let currentBias = cameraController?.currentExposureTargetOffset() {
                biasSlider.value = currentBias
            }
        }
    }
    
    @IBAction func autoExposureChanged(_ sender: UISwitch) {
        if sender.isOn {
            cameraController?.enableContinuousAutoExposure()
        }
        else {
            cameraController?.setCustomExposureWithDuration(speedSlider.value)
        }
        
        updateSliders()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        switch sender {
        case biasSlider:
            cameraController?.setExposureTargetBias(sender.value)
        case speedSlider:
            cameraController?.setCustomExposureWithDuration(sender.value)
        case isoSlider:
            cameraController?.setCustomExposureWithISO(sender.value)
        default:
            break
        }
    }
}

private extension ExposureViewController {
    func updateSliders() {
        for slider in [speedSlider, isoSlider] as [UISlider] {
            slider.isEnabled = !autoExposureSwitch.isOn
        }
    }
}

extension ExposureViewController : CameraSettingValueObserver {
    func cameraSetting(_ setting: String, valueChanged value: AnyObject) {
        if setting == CameraControlObservableSettingExposureDuration {
            if let durationValue = value as? NSValue {
                let duration = CMTimeGetSeconds(durationValue.timeValue)
                speedSlider.value = Float(duration)
            }
        }
        else if setting == CameraControlObservableSettingISO {
            if let iso = value as? Float {
                print("iso value : \(iso)")
                isoSlider.value = Float(iso)
            }
        }
    }
}
