//
//  ParameterAdjustmentView.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

let kSliderMarginX: CGFloat = 20
let kSliderMarginY: CGFloat = 8
let kSliderHeight: CGFloat = 48

protocol ParameterAdjustmentDelegate {
    func parameterValueDidChange(param: ScalarFilterParameter)
}

class ParameterAdjustmentView: UIView {
    var parameters: [ScalarFilterParameter]!
    var sliderViews = [LabeledSliderView]()
    
    func setAdjustmentDelegate(delegate: ParameterAdjustmentDelegate) {
        for sliderView in sliderViews {
            sliderView.delegate = delegate
        }
    }
    
    init(frame: CGRect, parameters: [ScalarFilterParameter]) {
        super.init(frame: frame)
        
        self.parameters = parameters
        
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        var yOffset: CGFloat = kSliderMarginY
        
        for param in parameters {
            let frame = CGRect(x: 0, y: yOffset, width: bounds.size.width, height: bounds.size.height)
            
            let sliderView = LabeledSliderView(frame: frame, parameter: param)
            sliderView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(sliderView)
            
            sliderViews.append(sliderView)
            
            sliderView.snp_makeConstraints(closure: { (make) in
                make.leading.equalTo(self)
                make.top.equalTo(self)
                make.width.equalTo(self)
                make.height.equalTo(kSliderHeight)
            })
            
            yOffset += (kSliderHeight + kSliderMarginY)
        }
    }
}