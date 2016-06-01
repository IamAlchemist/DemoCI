//
//  ViewController.swift
//  DemoCI
//
//  Created by Wizard Li on 5/30/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var facesView: UIView!
    
    var cameraController : CameraController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraController = CameraController(delegate: self)
        
        if let previewLayer = cameraController.previewLayer {
            videoPreviewView.layer.addSublayer(previewLayer)
        }
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
    }
}

