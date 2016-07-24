//
//  PhotoFilterCollectionViewCell.swift
//  DemoCI
//
//  Created by wizard lee on 7/23/16.
//  Copyright © 2016 cc.kauhaus. All rights reserved.
//

import UIKit

let kCellWidth: CGFloat = 66
let kLabelHeight: CGFloat = 20

class PhotoFilterCollectionViewCell: UICollectionViewCell {
    lazy var filterNameLabel: UILabel = {
        return UILabel(frame: CGRect(x: 0, y:kCellWidth, width: kCellWidth, height: kLabelHeight))
    }()

    var filteredImageView: FilteredImageView = {
        return FilteredImageView(frame: CGRect(x: 0, y: 0, width: kCellWidth, height: kCellWidth))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(kCellWidth, kCellWidth + kLabelHeight)
    }
    
    func addSubviews() {
        filteredImageView.layer.borderColor = tintColor.CGColor
        contentView.addSubview(filteredImageView)
        
        filterNameLabel.textAlignment = .Center
        filterNameLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        filterNameLabel.highlightedTextColor = tintColor
        filterNameLabel.font = UIFont.systemFontOfSize(12)
        
        contentView.addSubview(filterNameLabel)
    }
    
    override var selected: Bool {
        didSet {
            filteredImageView.layer.borderWidth = selected ? 2 : 0
        }
    }
}
