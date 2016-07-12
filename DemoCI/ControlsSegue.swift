//
//  ControlsSegue.swift
//  DemoCI
//
//  Created by wizard lee on 7/12/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class ControlsSegue: UIStoryboardSegue {
    
    var hostView : UIView?
    var currentViewController : UIViewController?
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        if let currentControlsViewContorller = currentViewController {
            currentControlsViewContorller.willMoveToParentViewController(nil)
            currentControlsViewContorller.removeFromParentViewController()
            currentControlsViewContorller.view.removeFromSuperview()
        }
        
        sourceViewController.addChildViewController(destinationViewController)
        hostView!.addSubview(destinationViewController.view)
        destinationViewController.view.frame = hostView!.bounds
        destinationViewController.didMoveToParentViewController(sourceViewController)
    }
    
}
