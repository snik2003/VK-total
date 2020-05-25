//
//  FavePagesCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 13/05/2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import UIKit

class FavePagesCell: UITableViewCell {

    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    var avatarImage: UIImageView!
    
    let nameFont = UIFont(name: "Verdana", size: 13)!
    let descFont = UIFont(name: "Verdana", size: 10)!
    
    func configureCell(group: FavePages, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
     
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        nameLabel = UILabel()
        nameLabel.tag = 100
        nameLabel.text = "\(group.name)"
        nameLabel.font = nameFont
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.frame = CGRect(x: 60, y: 5, width: bounds.size.width - 100, height: 40)
        self.addSubview(nameLabel)
        
        if group.description != "" || group.deactivated != "" {
            nameLabel.layer.frame = CGRect(x: 60, y: 5, width: bounds.size.width - 100, height: 25)
            
            descriptionLabel = UILabel()
            descriptionLabel.tag = 100
            descriptionLabel.text = "\(group.description)"
            if group.deactivated != "" { descriptionLabel.text = "Сообщество заблокировано" }
            descriptionLabel.font = descFont
            descriptionLabel.numberOfLines = 1
            descriptionLabel.alpha = 0.6
            descriptionLabel.adjustsFontSizeToFitWidth = true
            descriptionLabel.minimumScaleFactor = 0.5
            descriptionLabel.frame = CGRect(x: 60, y: 26, width: bounds.size.width - 100, height: 15)
            self.addSubview(descriptionLabel)
        }
        
        if #available(iOS 13.0, *) {
            nameLabel.textColor = .label
            descriptionLabel.textColor = .secondaryLabel
        }
        
        avatarImage = UIImageView()
        avatarImage.tag = 100
        avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
        
        let getCacheImage = GetCacheImage(url: group.photoURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 20
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        self.addSubview(avatarImage)
    }
}
