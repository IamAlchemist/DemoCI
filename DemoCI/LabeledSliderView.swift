//
//  LabeledSliderView.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit
import SnapKit

class LabeledSliderView: UIView {
    var slider: UISlider!
    var descriptionLabel: UILabel!
    var valueLabel: UILabel!
    var parameter: ScalarFilterParameter!
    var delegate: ParameterAdjustmentDelegate?
    
    init(frame: CGRect, parameter: ScalarFilterParameter) {
        super.init(frame: frame)
        
        self.parameter = parameter
        
        addSubviews()
        
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        slider = UISlider(frame: frame)
        slider.minimumValue = parameter.minimumValue!
        slider.maximumValue = parameter.maximumValue!
        slider.value = parameter.currentValue
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(slider)
        
        slider.addTarget(self, action: #selector(sliderTouchUpInside(_:)), forControlEvents: .TouchUpInside)
        slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), forControlEvents: .ValueChanged)
        
        descriptionLabel = UILabel(frame: frame)
        descriptionLabel.font = UIFont.boldSystemFontOfSize(14)
        descriptionLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        descriptionLabel.text = parameter.name
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(descriptionLabel)
        
        valueLabel = UILabel(frame: frame)
        valueLabel.font = UIFont.systemFontOfSize(14)
        valueLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        valueLabel.textAlignment = .Right
        valueLabel.text = slider.value.description
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(valueLabel)
    }
    
    func applyConstraints() {
        
        slider.snp_makeConstraints { (make) in
            make.height.equalTo(self).multipliedBy(0.5)
            make.width.equalTo(self)
            make.bottom.equalTo(self)
            make.leading.equalTo(self)
        }
        
        descriptionLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.height.equalTo(self).multipliedBy(0.5)
            make.width.equalTo(self)
            make.leading.equalTo(self)
        }
        
        valueLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.height.equalTo(self).multipliedBy(0.5)
            make.width.equalTo(self)
            make.leading.equalTo(self)
        }
    }
    
    func sliderValueDidChange(sender: AnyObject?) {
        valueLabel.text = String(format: "%0.2f", slider.value)
    }
    
    func sliderTouchUpInside(sender: AnyObject?) {
        if delegate != nil {
            delegate!.parameterValueDidChange(ScalarFilterParameter(key: parameter.key, value: slider.value))
        }
    }
}
