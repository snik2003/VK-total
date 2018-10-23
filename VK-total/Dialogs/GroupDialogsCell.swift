//
//  GroupDialogsCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupDialogsCell: UITableViewCell {
    
    var timer = Timer()
    
    var groupID = ""
    
    var userAvatar = UIImageView()
    var fromAvatar = UIImageView()
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var messLabel = UILabel()
    var messView = UIView()
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 5.0
    
    let userAvatarSize: CGFloat = 65.0
    let fromAvatarSize: CGFloat = 30.0
    
    let nameFont = UIFont(name: "Verdana", size: 14)!
    let messFont = UIFont(name: "Verdana", size: 11)!
    let dateFont = UIFont(name: "Verdana", size: 10)!
    
    func configureCell(mess: Message, users: [DialogsUsers], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = UIColor.white
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        var url = ""
        var name = ""
        var online = 0
        var onlineMobile = 0
        var platform = 0
        var user = users.filter({ $0.uid == "\(mess.userID)" })
        
        if mess.chatID == 0 {
            if user.count > 0 {
                url = user[0].maxPhotoOrigURL
                name = "\(user[0].firstName) \(user[0].lastName)"
                online = user[0].online
                onlineMobile = user[0].onlineMobile
                platform = user[0].platform
            }
        } else {
            url = mess.photo200
            name = mess.title
        }
        
        if url == ""  {
            url = "https://vk.com/images/community_200.png"
        }
        
        userAvatar.image = UIImage(named: "error")
        var getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        var setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: userAvatar, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.userAvatar.layer.cornerRadius = 32
            self.userAvatar.clipsToBounds = true
            self.userAvatar.contentMode = .scaleAspectFill
        }
        
        
        userAvatar.tag = 100
        userAvatar.frame = CGRect(x: leftInsets, y: topInsets, width: userAvatarSize, height: userAvatarSize)
        self.addSubview(userAvatar)
        
        nameLabel.tag = 100
        nameLabel.text = name
        if online == 1 {
            if onlineMobile == 1 {
                let fullString = "\(name) "
                nameLabel.setOnlineMobileStatus(text: "\(fullString)", platform: platform)
            } else {
                let fullString = "\(name) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: nameLabel.tintColor], range: rangeOfColoredString)
                
                nameLabel.attributedText = attributedString
            }
        }
        nameLabel.font = nameFont
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        nameLabel.frame = CGRect(x: 2 * leftInsets + userAvatarSize, y: topInsets, width: UIScreen.main.bounds.width - userAvatarSize - 3 * leftInsets, height: 18)
        self.addSubview(nameLabel)
        
        dateLabel.tag = 100
        dateLabel.text = mess.date.toStringLastTime()
        dateLabel.font = dateFont
        dateLabel.textColor = UIColor.darkGray
        
        dateLabel.frame = CGRect(x: 2 * leftInsets + userAvatarSize, y: topInsets + 16, width: UIScreen.main.bounds.width - userAvatarSize - 3 * leftInsets, height: 17)
        self.addSubview(dateLabel)
        
        if mess.out == 1 {
            user = users.filter({ $0.uid == "-\(groupID)" })
        } else {
            user = users.filter({ $0.uid == "\(mess.userID)" })
        }
        
        if user.count > 0 {
            url = user[0].maxPhotoOrigURL
        }
        
        fromAvatar.image = UIImage(named: "error")
        getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: fromAvatar, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.fromAvatar.layer.cornerRadius = 14
            self.fromAvatar.clipsToBounds = true
            self.fromAvatar.contentMode = .scaleAspectFill
        }
        
        fromAvatar.tag = 100
        fromAvatar.frame = CGRect(x: 2 * leftInsets + userAvatarSize, y: topInsets + 35, width: fromAvatarSize, height: fromAvatarSize)
        self.addSubview(fromAvatar)
        messLabel.font = messFont
        messLabel.tag = 100
        
        updateMessageLabel(mess: mess, users: users)
        
        messView.frame = CGRect(x: 2.5 * leftInsets + userAvatarSize + fromAvatarSize, y: topInsets + 35, width: UIScreen.main.bounds.width - userAvatarSize - fromAvatarSize - 3 * leftInsets, height: fromAvatarSize)
        
        messLabel.frame = CGRect(x: leftInsets/2, y: 0, width: messView.bounds.width - leftInsets, height: messView.bounds.height)
        messView.addSubview(messLabel)
        
        self.addSubview(messView)
        
        messView.backgroundColor = .clear
        messView.layer.borderWidth = 0
        if mess.out == 0 {
            if mess.readState == 0 {
                self.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
            }
        } else {
            if mess.readState == 0 {
                messView.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
                messView.configureMessageView(out: 0, radius: 6, border: 0.2)
            }
        }
    }
    
    func updateMessageLabel(mess: Message, users: [DialogsUsers]) {
        timer.invalidate()
            
        if mess.body != "" {
            messLabel.text = mess.body.replacingOccurrences(of: "\n", with: " ").prepareTextForPublic()
            
            messLabel.numberOfLines = 2
            messLabel.textColor = UIColor.darkGray
        } else if mess.typeAttach.count > 0 {
            if mess.typeAttach == "photo" {
                messLabel.text = "[Фотография]"
            } else if mess.typeAttach == "video" {
                messLabel.text = "[Видеозапись]"
            } else if mess.typeAttach == "sticker" {
                messLabel.text = "[Стикер]"
            } else if mess.typeAttach == "wall" {
                messLabel.text = "[Запись на стене]"
            } else if mess.typeAttach == "gift" {
                messLabel.text = "[Подарок]"
            } else if mess.typeAttach == "doc" {
                messLabel.text = "[Документ]"
            }
            messLabel.numberOfLines = 1
            messLabel.textColor = messLabel.tintColor
        }
    }
}
