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
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.barStyle = .default
        tabBarController?.tabBar.barStyle = .default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
            let controller = segue.destination as? FilterDetailViewController, segue.identifier == "showDetail"
        {
            controller.filterName = filters[indexPath.item].filterName
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


extension FilterListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterProperties: (filterName: String, filterDisplayName: String) = filters[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemFilterCell", for: indexPath)
        cell.textLabel?.text = filterProperties.filterDisplayName
        
        return cell
    }
}
