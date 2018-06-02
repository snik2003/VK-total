//
//  PhotoCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 17.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    let leftInsets: CGFloat = 0.0
    let topInsets: CGFloat = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func configureCell(photo: Photos, indexPath: IndexPath, cell: UICollectionViewCell, collectionView: UICollectionView) {
        
        var url = photo.bigPhotoURL
        if url == "" { url = photo.photoURL }
        if url == "" { url = photo.smallPhotoURL }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
        let setImageToRow = SetImageToRowOfCollectionView(cell: cell, imageView: imageView, indexPath: indexPath, collectionView: collectionView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.imageView.layer.borderColor = UIColor.black.cgColor
            self.imageView.layer.borderWidth = 0.5
        }
        
        imageView.contentMode = .scaleAspectFill
        let width = self.bounds.width
        //let width = CGFloat(photo.width) / CGFloat(photo.height) * collectionView.bounds.height
        
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: collectionView.bounds.height)
    }
}
