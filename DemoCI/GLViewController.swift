//
//  GLViewController.swift
//  DemoCI
//
//  Created by Wizard Li on 5/30/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit
import GLKit
import CoreImage
import OpenGLES

class GLViewController : UIViewController {
    var cameraController : CameraController!
    
    fileprivate var glContext : EAGLContext!
    fileprivate var ciContext : CIContext!
    fileprivate var renderBuffer : GLuint = GLuint()
    
    fileprivate var glView : GLKView {
        return view as! GLKView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glContext = EAGLContext(api: .openGLES2)
        
        glView.context = glContext
        
        glView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        
        if let window = glView.window {
            glView.frame = window.bounds
        }
        
        ciContext = CIContext(eaglContext: glContext)
        
        cameraController = CameraController(previewType: .manual, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.startRunning()
    }
}

extension GLViewController : CameraControllerDelegate {
    func cameraController(_ cameraController: CameraController, didDetectFaces faces: Array<(id: Int, frame: CGRect)>) {
    }
    
    func cameraContorller(_ cameraController: CameraController, didOutputImage image: CIImage) {
        if glContext != EAGLContext.current() {
            EAGLContext.setCurrent(glContext)
        }
        
        glView.bindDrawable()
        
        let rect = aspectFillRectForImageExtent(view.bounds.size, extentSize: image.extent.size)
        ciContext.draw(image, in: rect, from: image.extent)
        
        glView.display()
    }
    
    func aspectFillRectForImageExtent(_ boundsSize: CGSize, extentSize: CGSize) -> CGRect {
        let destSize = CGSize(width: boundsSize.width * UIScreen.main.scale, height: boundsSize.height * UIScreen.main.scale)
        let scaleWidth = destSize.width / extentSize.width
        let scaleHeight = destSize.height / extentSize.height
        let maxScale = max(scaleWidth, scaleHeight)
        return CGRect(x: 0, y: 0, width: extentSize.width * maxScale, height: extentSize.height * maxScale)
    }
}
























