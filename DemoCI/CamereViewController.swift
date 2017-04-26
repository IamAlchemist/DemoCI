//
//  ViewController.swift
//  DemoCI
//
//  Created by Wizard Li on 5/30/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var facesView: UIView!
    
    @IBOutlet weak var focusButton: UIButton!
    @IBOutlet weak var focusIndicator: UIView!
    
    @IBOutlet weak var shutterButton: UIButton!
    
    @IBOutlet weak var exposureButton: UIButton!
    @IBOutlet weak var exposureIndicator: UIView!
    
    @IBOutlet weak var whiteBalanceButton: UIButton!
    @IBOutlet weak var whiteBalanceIndicator: UIView!
    
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var optionsIndicator: UIView!
    
    var cameraController : CameraController!
    
    fileprivate var currentControlsViewController : UIViewController?
    fileprivate var faceViews = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraController = CameraController(delegate: self)
        
        if let previewLayer = cameraController.previewLayer {
            videoPreviewView.layer.addSublayer(previewLayer)
        }
        
        cameraController.registerObserver(self, property: CameraControlObservableSettingAdjustingFocus)
        cameraController.registerObserver(self, property: CameraControlObservableSettingAdjustingWhiteBalance)
        cameraController.registerObserver(self, property: CameraControlObservableSettingAdjustingExposure)
        cameraController.registerObserver(self, property: CameraControlObservableSettingLensPosition)
        cameraController.registerObserver(self, property: CameraControlObservableSettingISO)
        cameraController.registerObserver(self, property: CameraControlObservableSettingExposureDuration)
        cameraController.registerObserver(self, property: CameraControlObservableSettingExposureTargetOffset)
        cameraController.registerObserver(self, property: CameraControlObservableSettingWBGains)
        
        
        focusButton.isSelected = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = cameraController.previewLayer else { return }
        previewLayer.frame = videoPreviewView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraController.startRunning()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controlsSegue = segue as? ControlsSegue {
            controlsSegue.currentViewController = currentControlsViewController
            controlsSegue.hostView = controlsView
            
            currentControlsViewController = controlsSegue.destination
            
            if var currentControlsViewController = currentControlsViewController as? CameraControlsViewControllerProtocol {
                currentControlsViewController.cameraController = cameraController
            }
        }
    }
}

extension CameraViewController : CameraControllerDelegate {
    func cameraContorller(_ cameraController: CameraController, didOutputImage image: CIImage) {
    }
    
    func cameraController(_ cameraController: CameraController, didDetectFaces faces: Array<(id: Int, frame: CGRect)>) {
        prepareFaceView(faces.count - faceViews.count)
        for (idx, face) in faces.enumerated() {
            faceViews[idx].frame = face.frame
        }
    }
}

extension CameraViewController : CameraSettingValueObserver {
    func cameraSetting(_ setting: String, valueChanged value: AnyObject) {
        switch setting {
        case CameraControlObservableSettingAdjustingFocus:
            if let adjusting = value as? Bool {
                focusIndicator.isHidden = !adjusting
            }
            
        case CameraControlObservableSettingAdjustingWhiteBalance:
            if let adjusting = value as? Bool {
                whiteBalanceIndicator.isHidden = !adjusting
            }
            
        case CameraControlObservableSettingAdjustingExposure:
            if let adjusting = value as? Bool {
                exposureIndicator.isHidden = !adjusting
            }
            
        case CameraControlObservableSettingLensPosition,
             CameraControlObservableSettingExposureTargetOffset,
             CameraControlObservableSettingExposureDuration,
             CameraControlObservableSettingISO,
             CameraControlObservableSettingWBGains:
            displayCurrentValues()
            
        default:
            break
        }
    }
}

private extension CameraViewController {
    @IBAction func exit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func prepareFaceView(_ diff : Int) {
        if diff > 0 {
            for _ in 0..<diff {
                let faceView = UIView(frame: CGRect.zero)
                faceView.backgroundColor = UIColor.clear
                faceView.layer.borderColor = UIColor.yellow.cgColor
                faceView.layer.borderWidth = 1.0
                
                facesView.addSubview(faceView)
                faceViews.append(faceView)
            }
        }
        else {
            for _ in 0..<abs(diff) {
                faceViews[0].removeFromSuperview()
                faceViews.remove(at: 0)
            }
        }
    }

    @IBAction func toggoleControls(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            controlsView.isHidden = true
        }
        else {
            controlsView.isHidden = false
            var segueIdentifier : String?
            switch sender {
            case focusButton:
                segueIdentifier = "Embed Focus"
            case exposureButton:
                segueIdentifier = "Embed Exposure"
            case whiteBalanceButton:
                segueIdentifier = "Embed White Balance"
            case optionsButton:
                segueIdentifier = "Embed Options"
            default:break
            }
            
            for button in [focusButton, exposureButton, whiteBalanceButton, optionsButton] {
                button?.isSelected = button == sender
            }
            
            guard let _segueIdentifier = segueIdentifier else { return }
            performSegue(withIdentifier: _segueIdentifier, sender: self)
        }
    }
    
    @IBAction func shutterButtonTapped(_ sender: UIButton) {
        cameraController.captureStillImage { (image, metadata) in
            self.view.layer.contents = image
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    @IBAction func focusOnPointOfInterest(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: sender.view)
            cameraController.lockFocusAtPointOfInterest(point)
        }
        
    }
    
    func displayCurrentValues() {
        var currentValuesTextComponents = [String]()
        
        if let lensPosition = cameraController.currentLensPosition() {
            currentValuesTextComponents.append(String(format: "F: %.2f", lensPosition))
        }
        
        if let offset = cameraController.currentExposureTargetOffset() {
            currentValuesTextComponents.append(String(format: "±: %.2f", offset))
        }
        
        if let speed = cameraController.currentExposureDuration() {
            currentValuesTextComponents.append(String(format: "S: %.4f", speed))
        }
        
        if let iso = cameraController.currentISO() {
            currentValuesTextComponents.append(String(format: "ISO: %.0f", iso))
        }
        
        if let temp = cameraController.currentTemperature() {
            currentValuesTextComponents.append(String(format: "TEMP: %.0f", temp))
        }
        
        if let tint = cameraController.currentTint() {
            currentValuesTextComponents.append(String(format: "TINT: %.0f", tint))
        }
        
        currentValueLabel.text = currentValuesTextComponents.joined(separator: " - ")
    }
}

