//
//  PhotoFilterViewController.swift
//  DemoCI
//
//  Created by wizard lee on 7/24/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

class PhotoFilterViewController: UIViewController {
    
    @IBOutlet weak var filteredImageView: FilteredImageView!
    @IBOutlet weak var photoFilterCollectionView: UICollectionView!
    
    var filters = [CIFilter]()
    
    let filterDescriptiors: [(filtername: String, filterDisplayName: String)] = [
        ("CIColorControls", "None"),
        ("CIPhotoEffectMono", "Mono"),
        ("CIPhotoEffectTonal", "Tonal"),
        ("CIPhotoEffectNoir", "Noir"),
        ("CIPhotoEffectFade", "Fade"),
        ("CIPhotoEffectChrome", "Chrome"),
        ("CIPhotoEffectProcess", "Process"),
        ("CIPhotoEffectTransfer", "Transfer"),
        ("CIPhotoEffectInstant", "Instant"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for descriptor in filterDescriptiors {
            filters.append(CIFilter(name: descriptor.filtername)!)
        }
        
        var image = UIImage(named: "duckling")!
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        image.drawAtPoint(CGPointZero)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        filteredImageView.inputImage = image
        filteredImageView.contentMode = .ScaleAspectFit
        filteredImageView.filter = filters[0]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        navigationController?.navigationBar.barStyle = .Black
        tabBarController?.tabBar.barStyle = .Black
    }
}

extension PhotoFilterViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDescriptiors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoFilterCell", forIndexPath: indexPath) as! PhotoFilterCollectionViewCell
        
        cell.filteredImageView.contentMode = .ScaleAspectFill
        cell.filteredImageView.inputImage = filteredImageView.inputImage
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterDescriptiors[indexPath.item].filterDisplayName
        
        return cell
    }
}

extension PhotoFilterViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        filteredImageView.filter = filters[indexPath.item]
    }
}

extension PhotoFilterViewController: UICollectionViewDelegateFlowLayout {
    
}