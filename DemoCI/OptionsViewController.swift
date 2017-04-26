//
//  OptionsViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/12/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController, CameraControlsViewControllerProtocol {
    @IBOutlet weak var bracketedCaptureSwitch: UISwitch!
    
    var cameraController: CameraController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cameraController = cameraController {
            bracketedCaptureSwitch.isOn = cameraController.enableBracketedCapture
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        cameraController?.enableBracketedCapture = sender.isOn
    }
}
