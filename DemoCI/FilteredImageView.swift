//
//  FilteredImageView.swift
//  DemoCI
//
//  Created by wizard lee on 7/23/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

class FilteredImageView: GLKView {
    
    var ciContext: CIContext!
    
    var filter: CIFilter! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var inputImage: UIImage! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame, context: EAGLContext(api: .openGLES2))
        clipsToBounds = true
        ciContext = CIContext(eaglContext: context)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        context = EAGLContext(api: .openGLES2)
        ciContext = CIContext(eaglContext: context)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ciContext = ciContext, let inputImage = inputImage, let filter = filter
            else { return }
        
        let inputCIImage = CIImage(image: inputImage)
        
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { return }
        
        clearBackground()
        
        let inputBounds = inputCIImage!.extent
        
        let drawableBounds = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        
        let targetBounds = imageBoundsForContentMode(inputBounds, toRect: drawableBounds)
        
        ciContext.draw(outputImage, in: targetBounds, from: inputBounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    func clearBackground() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func aspectFit(_ fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        }
        
        return fitRect.integral
    }
    
    func aspectFill(_ fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        }
        
        return fitRect.integral
    }
    
    func imageBoundsForContentMode(_ fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFill:
            return aspectFill(fromRect, toRect: toRect)
        case .scaleAspectFit:
            return aspectFit(fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }
}

extension FilteredImageView: ParameterAdjustmentDelegate {
    func parameterValueDidChange(_ param: ScalarFilterParameter) {
        filter.setValue(param.currentValue, forKey: param.key)
        setNeedsDisplay()
    }
}
