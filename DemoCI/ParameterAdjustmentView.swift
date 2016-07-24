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
}