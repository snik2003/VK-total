//
//  FaveUsersCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class FaveUsersCell: UITableViewCell {

    
    var nameLabel: UILabel!
    var avatarImage: UIImageView!
    
    func configureCell(user: NewsProfiles, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
     
        for subview in subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        nameLabel = UILabel()
        nameLabel.tag = 100
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.font = UIFont(name: "Verdana", size: 14)!
        nameLabel.frame = CGRect(x: 60, y: 15, width: bounds.size.width - 100, height: 20)
        self.addSubview(nameLabel)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        avatarImage = UIImageView()
        avatarImage.tag = 100
        avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
        
        let getCacheImage = GetCacheImage(url: user.photoURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 19
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        self.addSubview(avatarImage)
    }
}
