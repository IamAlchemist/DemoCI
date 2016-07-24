//
//  FilterDetailViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class FilterDetailViewController: UIViewController {
    var filterName: String!
    var filter: CIFilter!
    var filteredImageView: FilteredImageView!
    var parameterAdjustmentView: ParameterAdjustmentView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = CIFilter(name: filterName)
        
        navigationItem.title = filter.attributes[kCIAttributeFilterDisplayName] as? String
        
        image = UIImage(named: "duckling")
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        image.drawAtPoint(CGPointZero)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        addSubviews()
        
        applyConstrains()
    }
    
    func filterParamterDescriptors() -> [ScalarFilterParameter] {
        let inputNames = (filter.inputKeys as [String]).filter { parameterName -> Bool in
            return parameterName != "inputImage"
        }
        
        let attributes = filter.attributes
        
        return inputNames.map { (inputName) -> ScalarFilterParameter in
            let attribute = attributes[inputName] as! [String: AnyObject]
            
            let displayName = inputName[inputName.startIndex.advancedBy(5)..<inputName.endIndex]
            let minValue = attribute[kCIAttributeSliderMin] as! Float
            let maxValue = attribute[kCIAttributeSliderMax] as! Float
            let defaultValue = attribute[kCIAttributeDefault] as! Float
            
            return ScalarFilterParameter(name: displayName,
                key: inputName,
                minimumValue: minValue,
                maximumValue: maxValue,
                currentValue: defaultValue)
        }
    }
    
    func addSubviews() {
        filteredImageView = FilteredImageView(frame: view.bounds)
        filteredImageView.inputImage = image
        filteredImageView.filter = filter
        filteredImageView.contentMode = .ScaleAspectFit
        filteredImageView.clipsToBounds = true
        filteredImageView.backgroundColor = view.backgroundColor
        filteredImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filteredImageView)
        
        parameterAdjustmentView = ParameterAdjustmentView(frame: view.bounds, parameters: filterParamterDescriptors())
        parameterAdjustmentView.translatesAutoresizingMaskIntoConstraints = false
        parameterAdjustmentView.setAdjustmentDelegate(filteredImageView)
        view.addSubview(parameterAdjustmentView)
    }
    
    func applyConstrains() {
        filteredImageView.snp_makeConstraints { (make) in
            make.width.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.5)
            make.top.equalTo(view)
            make.leading.equalTo(view)
        }
        
        parameterAdjustmentView.snp_makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.5)
            make.leading.equalTo(view)
        }
    }
}
