//
//  CountersCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class CountersCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let leftInsets: CGFloat = 7.0
    let topInsets: CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionViewFrame()
    }
    
    func collectionViewFrame() {
        
        let origin = CGPoint(x: leftInsets, y: topInsets)
        let size = CGSize(width: bounds.size.width - 2 * leftInsets, height: bounds.size.height - 2 * topInsets)
        
        collectionView.frame = CGRect(origin: origin, size: size)
    }
}
