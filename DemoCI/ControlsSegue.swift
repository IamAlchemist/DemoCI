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
            currentControlsViewContorller.willMove(toParentViewController: nil)
            currentControlsViewContorller.removeFromParentViewController()
            currentControlsViewContorller.view.removeFromSuperview()
        }
        
        source.addChildViewController(destination)
        hostView!.addSubview(destination.view)
        destination.view.frame = hostView!.bounds
        destination.didMove(toParentViewController: source)
    }
    
}
