//
//  ScalarFilterParameter.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class ScalarFilterParameter {
    var name: String?
    var key: String
    var minimumValue: Float?
    var maximumValue: Float?
    var currentValue: Float
    
    init(key: String, value: Float) {
        self.key = key
        self.currentValue = value
    }
    
    init(name: String, key: String, minimumValue: Float, maximumValue: Float, currentValue: Float) {
        self.name = name
        self.key = key
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.currentValue = currentValue
    }
}
