//
//  TopicTitleCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class TopicTitleCell: UITableViewCell {

    let avatarImage = UIImageView()
    let titleLabel = UILabel()
    let typeLabel = UILabel()
    
    
    let leftInsets: CGFloat = 10
    let topInsets: CGFloat = 5
    
    let avatarHeight: CGFloat = 50
    
    func configureCell(group: GroupProfile, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        let getCacheImage = GetCacheImage(url: group.photo100, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 25
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
        self.addSubview(avatarImage)
        

        titleLabel.text = group.name
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 16)!
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.3
        
        titleLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 10, width: bounds.width - 3 * leftInsets - avatarHeight, height: 20)
        self.addSubview(titleLabel)
        

        if group.type == "group" {
            if group.isClosed == 0 {
                typeLabel.text = "Открытая группа"
            } else if group.isClosed == 1 {
                typeLabel.text = "Закрытая группа"
            } else {
                typeLabel.text = "Частная группа"
            }
        } else if group.type == "page" {
            typeLabel.text = "Публичная страница"
        } else {
            typeLabel.text = "Мероприятие"
        }
        
        typeLabel.font = UIFont(name: "Verdana", size: 12)!
        typeLabel.isEnabled = false
        
        typeLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 30, width: bounds.width - 3 * leftInsets - avatarHeight, height: 15)
        self.addSubview(typeLabel)
    }
}
