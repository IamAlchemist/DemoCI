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
        image.draw(at: CGPoint.zero)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        filteredImageView.inputImage = image
        filteredImageView.contentMode = .scaleAspectFit
        filteredImageView.filter = filters[0]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.barStyle = .black
        tabBarController?.tabBar.barStyle = .black
    }
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDescriptiors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoFilterCell", for: indexPath) as! PhotoFilterCollectionViewCell
        
        cell.filteredImageView.contentMode = .scaleAspectFill
        cell.filteredImageView.inputImage = filteredImageView.inputImage
        cell.filteredImageView.filter = filters[indexPath.item]
        cell.filterNameLabel.text = filterDescriptiors[indexPath.item].filterDisplayName
        
        return cell
    }
}

extension PhotoFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filteredImageView.filter = filters[indexPath.item]
    }
}

extension PhotoFilterViewController: UICollectionViewDelegateFlowLayout {
    
}
