//
//  MembersCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class MembersCell: UITableViewCell {

    var nameLabel: UILabel!
    var statusLabel: UILabel!
    var avatarImage: UIImageView!
    
    func configureCell(user: Friends, filter: String, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in self.subviews {
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        nameLabel = UILabel()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.textColor = vkSingleton.shared.labelColor
        
        if user.onlineStatus == 1 && filter == "managers" {
            if user.onlineMobile == 1 {
                let fullString = "\(user.firstName) \(user.lastName) "
                nameLabel.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
            } else {
                let fullString = "\(user.firstName) \(user.lastName) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: nameLabel.tintColor], range: rangeOfColoredString)
                
                nameLabel.attributedText = attributedString
            }
        }
        
        nameLabel.font = UIFont(name: "Verdana", size: 15)!
        nameLabel.frame = CGRect(x: 60, y: 8, width: bounds.size.width - 70, height: 18)
        self.addSubview(nameLabel)
        
        statusLabel = UILabel()
        statusLabel.isUserInteractionEnabled = false
        statusLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
        if filter == "managers" {
            if user.role == "moderator" {
                statusLabel.text = "модератор"
            } else if user.role == "editor" {
                statusLabel.text = "редактор"
            } else if user.role == "creator" {
                statusLabel.text = "создатель сообщества"
            } else {
                statusLabel.text = "администратор"
            }
            statusLabel.textColor = statusLabel.tintColor
        } else {
            if user.deactivated != "" {
                if user.deactivated == "banned" {
                    statusLabel.text = "страница заблокирована"
                }
                if user.deactivated == "deleted" {
                    statusLabel.text = "страница удалена"
                }
            } else {
                if user.onlineStatus == 1 {
                    statusLabel.text = "онлайн"
                    if user.onlineMobile == 1 {
                        statusLabel.text = "онлайн (моб.)"
                    }
                    statusLabel.textColor = statusLabel.tintColor
                } else {
                    if user.sex == 1 {
                        statusLabel.text = "заходила \(user.lastSeen.toStringLastTime())"
                    } else {
                        statusLabel.text = "заходил \(user.lastSeen.toStringLastTime())"
                    }
                }
            }
        }
        
        statusLabel.font = UIFont(name: "Verdana", size: 12)!
        statusLabel.frame = CGRect(x: 60, y: 25, width: bounds.size.width - 70, height: 16)
        self.addSubview(statusLabel)
        
        avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "error")
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
