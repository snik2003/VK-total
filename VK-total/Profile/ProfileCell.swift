//
//  ProfileCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 17.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView! {
        didSet {
            avatarImage.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var onlineStatusLabel: UILabel! {
        didSet {
            onlineStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var ageLabel: UILabel! {
        didSet {
            ageLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var infoButton: UIButton! {
        didSet {
            infoButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    let infoButtonHeight: CGFloat = 22.0
    let rightInfoButton: CGFloat = 20.0
    let bottomInfoButton: CGFloat = 15.0
    let leftInsets: CGFloat = 8.0
    let bottomInsets: CGFloat = 6.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureCell(profile: UserProfileInfo, indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell) {
        
        nameLabel.text = profile.firstName + " " + profile.lastName
        nameLabel.textColor = UIColor.black //UIColor.white
        
        if profile.onlineStatus == 1 {
            onlineStatusLabel.text = "онлайн"
            if profile.onlineMobile == 1 {
                onlineStatusLabel.text = "онлайн (моб.)"
            }
            onlineStatusLabel.textColor = UIColor.blue
        } else {
            onlineStatusLabel.textColor = UIColor.black //UIColor.white
            onlineStatusLabel.text = "заходил " + profile.lastSeen.toStringLastTime()
            if profile.sex == 1 {
                onlineStatusLabel.text = "заходила " + profile.lastSeen.toStringLastTime()
            }
        }
        
        if profile.birthDate != "" {
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "dd.MM.YYYY"
            let date = dateFormatter2.date(from: profile.birthDate)
            let age = date?.age
            
            if age != nil {
                ageLabel.text = "\(age ?? 0) лет"
                
                if profile.homeTown != "" {
                    ageLabel.text = ageLabel.text! + ", \(profile.homeTown)"
                }
            } else {
                ageLabel.text = profile.homeTown
            }
        } else {
            if profile.homeTown != "" {
                ageLabel.text = profile.homeTown
            }
        }
        ageLabel.textColor = UIColor.black //UIColor.white
        
        let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.borderWidth = 1
            self.avatarImage.layer.borderColor = UIColor.black.cgColor
            self.avatarImage.clipsToBounds = true
        }
        
        if profile.deactivated != "" {
            if profile.deactivated == "banned" {
                onlineStatusLabel.text = "заблокирован"
            }
            if profile.deactivated == "deleted" {
                onlineStatusLabel.text = "страница удалена"
            }
            ageLabel.text = ""
        }
        
        infoButton.tintColor = UIColor.black //UIColor.white
        
        if profile.hasPhoto == 0 {
            nameLabel.textColor = UIColor.black
            onlineStatusLabel.textColor = UIColor.black
            ageLabel.textColor = UIColor.black
            infoButton.tintColor = UIColor.black
        }
        
        nameLabel.isHidden = false
        onlineStatusLabel.isHidden = false
        ageLabel.isHidden = false
        infoButton.isHidden = false
        
        avatarImage.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        
        var topY = bounds.size.height - bottomInsets
        if ageLabel.text != "" {
            topY = topY - 15
            ageLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.size.width - 2 * leftInsets, height: 15)
        } else {
            ageLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.size.width - 2 * leftInsets, height: 0)
        }
        
        topY = topY - 15
        onlineStatusLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.size.width - 2 * leftInsets, height: 15)
        
        topY = topY - 21
        nameLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.size.width - 2 * leftInsets, height: 21)
        
        let infoButtonX = bounds.size.width - rightInfoButton - infoButtonHeight
        let infoButtonY = bounds.size.height - bottomInfoButton - infoButtonHeight
        infoButton.frame = CGRect(x: infoButtonX, y: infoButtonY, width: infoButtonHeight, height: infoButtonHeight)
    }
}

