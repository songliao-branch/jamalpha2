//
//  FretCell.swift
//  horizontalCollectionView
//
//  Created by Jun Zhou on 9/3/15.
//  Copyright (c) 2015 Jun Zhou. All rights reserved.
//

import Foundation
import UIKit

// represents all 4,5 6th strings on a certain fret in the horizontalCollectionView
class FretCell: UICollectionViewCell {
    
    var fretNumberLabel: UILabel!
    var imageView: UIImageView! //background image
    
    var trueWidth: CGFloat = CGFloat()
    var trueHeight: CGFloat = CGFloat()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height * 11 / 12))
        imageView.image = UIImage(named: "3-string")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
        
        fretNumberLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height * 1 / 12))
        fretNumberLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        fretNumberLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        fretNumberLabel.textAlignment = NSTextAlignment.Center
        contentView.addSubview(fretNumberLabel)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}