//
//  FavePhotoCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class FavePhotoCell: UITableViewCell {

    var photoImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func configureCell(photo: Photos, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        for subview in subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        var url = photo.xxbigPhotoURL
        if url == "" {
            url = photo.xbigPhotoURL
        }
        if url == "" {
            url = photo.bigPhotoURL
        }
        if url == "" {
            url = photo.photoURL
        }
        
        photoImage = UIImageView()
        photoImage.tag = 100
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .newsFeedImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photoImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.photoImage.layer.borderColor = UIColor.black.cgColor
            self.photoImage.layer.borderWidth = 0
            self.photoImage.layer.cornerRadius = 0
            self.photoImage.contentMode = .scaleAspectFit
            self.photoImage.clipsToBounds = true
        }
        
        photoImage.frame = CGRect(x: 5, y: 5, width: bounds.size.width - 10, height: bounds.size.height - 10)
        
        self.addSubview(photoImage)
    }
}
