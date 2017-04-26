//
//  FocusViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/12/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class FocusViewController : UIViewController, CameraControlsViewControllerProtocol {
    @IBOutlet weak var autoFocusSwitch: UISwitch!
    @IBOutlet weak var lensPositionSlider: UISlider!
    
    var cameraController: CameraController? {
        willSet {
            if let cameraController = cameraController {
                cameraController.unregisterObserver(self, property: CameraControlObservableSettingLensPosition)
            }
        }
        
        didSet {
            if let cameraController = cameraController {
                cameraController.registerObserver(self, property: CameraControlObservableSettingLensPosition)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isViewLoaded && cameraController != nil {
            if let autoFocus = cameraController?.isContinuousAutoFocusEnabled() {
                autoFocusSwitch.isOn = autoFocus
                lensPositionSlider.isEnabled = !autoFocus
            }
            
            if let currentLensPositon = cameraController?.currentLensPosition() {
                lensPositionSlider.value = currentLensPositon
            }
        }
    }
    
    @IBAction func modeSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            cameraController?.enableContinuousAutoFocus()
        }
        else {
            cameraController?.lockFocusAtLensPosition(CGFloat(lensPositionSlider.value))
        }
        lensPositionSlider.isEnabled = !sender.isOn
    }
    
    @IBAction func lensPositionValueChanged(_ sender: UISlider) {
        cameraController?.lockFocusAtLensPosition(CGFloat(sender.value))
    }
}

extension FocusViewController : CameraSettingValueObserver {
    func cameraSetting(_ setting: String, valueChanged value: AnyObject) {
        if case setting = CameraControlObservableSettingLensPosition {
            if let lenPosition = value as? Float {
                lensPositionSlider.value = lenPosition
            }
        }
    }
}
