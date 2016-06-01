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
    
    private var glContext : EAGLContext!
    private var ciContext : CIContext!
    private var renderBuffer : GLuint = GLuint()
    
    private var glView : GLKView {
        return view as! GLKView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glContext = EAGLContext(API: .OpenGLES2)
        
        glView.context = glContext
        
        glView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        if let window = glView.window {
            glView.frame = window.bounds
        }
        
        ciContext = CIContext(EAGLContext: glContext)
        
        cameraController = CameraController(previewType: .Manual, delegate: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cameraController.startRunning()
    }
}

extension GLViewController : CameraControllerDelegate {
    func cameraController(cameraController: CameraController, didDetectFaces faces: Array<(id: Int, frame: CGRect)>) {
    }
    
    func cameraContorller(cameraController: CameraController, didOutputImage image: CIImage) {
        if glContext != EAGLContext.currentContext() {
            EAGLContext.setCurrentContext(glContext)
        }
        
        glView.bindDrawable()
        
        let rect = aspectFillRectForImageExtent(view.bounds.size, extentSize: image.extent.size)
        ciContext.drawImage(image, inRect: rect, fromRect: image.extent)
        
        glView.display()
    }
    
    func aspectFillRectForImageExtent(boundsSize: CGSize, extentSize: CGSize) -> CGRect {
        let destSize = CGSize(width: boundsSize.width * UIScreen.mainScreen().scale, height: boundsSize.height * UIScreen.mainScreen().scale)
        let scaleWidth = destSize.width / extentSize.width
        let scaleHeight = destSize.height / extentSize.height
        let maxScale = max(scaleWidth, scaleHeight)
        return CGRect(x: 0, y: 0, width: extentSize.width * maxScale, height: extentSize.height * maxScale)
    }
}
























