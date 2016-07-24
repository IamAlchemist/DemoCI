//
//  FilterListViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class FilterListViewController: UITableViewController {
    let filters: [(filterName: String, filterDisplayName: String)] = [
        ("CIBloom", "Bloom"),
        ("CIColorControls", "Color Controls"),
        ("CIColorInvert", "Color Invert"),
        ("CIColorPosterize", "Color Posterize"),
        ("CIExposureAdjust", "Exposure Adjust"),
        ("CIGammaAdjust", "Gamma Adjust"),
        ("CIGaussianBlur", "Gaussian Blur"),
        ("CIGloom", "Gloom"),
        ("CIHighlightShadowAdjust", "Highlights and Shadows"),
        ("CIHueAdjust", "Hue Adjust"),
        ("CILanczosScaleTransform", "Lanczos Scale Transform"),
        ("CIMaximumComponent", "Maximum Component"),
        ("CIMinimumComponent", "Minimum Component"),
        ("CISepiaTone", "Sepia Tone"),
        ("CISharpenLuminance", "Sharpen Luminance"),
        ("CIStraightenFilter", "Straighten"),
        ("CIUnsharpMask", "Unsharp Mask"),
        ("CIVibrance", "Vibrance"),
        ("CIVignette", "Vignette")
    ]
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = .Default
        navigationController?.navigationBar.barStyle = .Default
        tabBarController?.tabBar.barStyle = .Default
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = tableView.indexPathForSelectedRow,
            controller = segue.destinationViewController as? FilterDetailViewController
            where segue.identifier == "showDetail"
        {
            controller.filterName = filters[indexPath.item].filterName
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}


extension FilterListViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let filterProperties: (filterName: String, filterDisplayName: String) = filters[indexPath.item]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SystemFilterCell", forIndexPath: indexPath)
        cell.textLabel?.text = filterProperties.filterDisplayName
        
        return cell
    }
}