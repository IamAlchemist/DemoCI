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
    
    private var faceViews = [UIView]()
    
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
        
        
        focusButton.selected = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = cameraController.previewLayer else { return }
        previewLayer.frame = videoPreviewView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraController.startRunning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

extension CameraViewController : CameraControllerDelegate {
    func cameraContorller(cameraController: CameraController, didOutputImage image: CIImage) {
    }
    
    func cameraController(cameraController: CameraController, didDetectFaces faces: Array<(id: Int, frame: CGRect)>) {
        prepareFaceView(faces.count - faceViews.count)
        for (idx, face) in faces.enumerate() {
            faceViews[idx].frame = face.frame
        }
    }
}

private extension CameraViewController {
    func prepareFaceView(diff : Int) {
        if diff > 0 {
            for _ in 0..<diff {
                let faceView = UIView(frame: CGRectZero)
                faceView.backgroundColor = UIColor.clearColor()
                faceView.layer.borderColor = UIColor.yellowColor().CGColor
                faceView.layer.borderWidth = 1.0
                
                facesView.addSubview(faceView)
                faceViews.append(faceView)
            }
        }
        else {
            for _ in 0..<abs(diff) {
                faceViews[0].removeFromSuperview()
                faceViews.removeAtIndex(0)
            }
        }
    }
}

extension CameraViewController : CameraSettingValueObserver {
    func cameraSetting(setting: String, valueChanged value: AnyObject) {
//        switch setting {
//        case CameraControlObservableSettingAdjustingFocus:
//            <#code#>
//        default:
//            <#code#>
//        }
    }
}



