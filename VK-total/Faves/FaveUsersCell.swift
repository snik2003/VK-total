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
    var descriptionLabel: UILabel!
    var avatarImage: UIImageView!

    let nameFont = UIFont(name: "Verdana", size: 13)!
    let descFont = UIFont(name: "Verdana", size: 10)!
    
    func configureCell(user: NewsProfiles, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView, source: String) {
     
        for subview in subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        nameLabel = UILabel()
        nameLabel.tag = 100
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.font = nameFont
        nameLabel.numberOfLines = 1
        nameLabel.frame = CGRect(x: 60, y: 5, width: bounds.size.width - 100, height: 25)
        self.addSubview(nameLabel)
        
        
        descriptionLabel = UILabel()
        descriptionLabel.tag = 100
        descriptionLabel.text = "https://vk.com/\(user.screenName)"
        descriptionLabel.textColor = descriptionLabel.tintColor
        if source == "banned" {
            descriptionLabel.text = "Пользователь"
            if user.uid < 0 { descriptionLabel.text = "Сообщество" }
            descriptionLabel.textColor = .black
            descriptionLabel.alpha = 0.6
        }
        descriptionLabel.font = descFont
        descriptionLabel.numberOfLines = 1
        descriptionLabel.frame = CGRect(x: 60, y: 25, width: bounds.size.width - 100, height: 15)
        self.addSubview(descriptionLabel)
        
        
        avatarImage = UIImageView()
        avatarImage.tag = 100
        avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
        
        let getCacheImage = GetCacheImage(url: user.photoURL, lifeTime: .avatarImage)
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
