//
//  DialogsCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class DialogsCell: UITableViewCell {

    var timer = Timer()
    
    var userAvatar = UIImageView()
    var fromAvatar = UIImageView()
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var messLabel = UILabel()
    
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
                url = user[0].photo100
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
            self.userAvatar.layer.cornerRadius = self.userAvatarSize/2
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
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: nameLabel.tintColor /*UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)*/], range: rangeOfColoredString)
                
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
            user = users.filter({ $0.uid == vkSingleton.shared.userID })
        } else {
            user = users.filter({ $0.uid == "\(mess.userID)" })
            if mess.actionID != 0 {
                user = users.filter({ $0.uid == "\(mess.actionID)" })
            }
        }
        
        if user.count > 0 {
            url = user[0].photo100
        }
        
        fromAvatar.image = UIImage(named: "error")
        getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: fromAvatar, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.fromAvatar.layer.cornerRadius = self.fromAvatarSize/2
            self.fromAvatar.clipsToBounds = true
            self.fromAvatar.contentMode = .scaleAspectFill
        }
        
        fromAvatar.tag = 100
        fromAvatar.frame = CGRect(x: 2 * leftInsets + userAvatarSize, y: topInsets + 35, width: fromAvatarSize, height: fromAvatarSize)
        self.addSubview(fromAvatar)
        messLabel.font = messFont
        messLabel.tag = 100
        
        updateMessageLabel(mess: mess, users: users)
        
        messLabel.frame = CGRect(x: 2.5 * leftInsets + userAvatarSize + fromAvatarSize, y: topInsets + 35, width: UIScreen.main.bounds.width - userAvatarSize - fromAvatarSize - 3 * leftInsets, height: fromAvatarSize)
        self.addSubview(messLabel)
        
        if mess.readState == 0 {
            self.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        }
    }
    
    func updateMessageLabel(mess: Message, users: [DialogsUsers]) {
        if mess.body == "??typing??" {
            messLabel.text = "набирает сообщение..."
            
            messLabel.numberOfLines = 1
            messLabel.textColor = messLabel.tintColor
            
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:
                #selector(animateDots), userInfo: nil, repeats: true)
            timer.fire()
        } else {
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
            } else if mess.chatID != 0 {
                var actID = mess.userID
                if mess.actionID != 0 {
                    actID = mess.actionID
                }
                let user = users.filter({ $0.uid == "\(actID)" })
                if user.count > 0 {
                    if mess.action == "chat_kick_user" {
                        if user[0].sex == 1 {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) покинула беседу"
                        } else {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) покинул беседу"
                        }
                    } else if mess.action == "chat_invite_user" {
                        if user[0].sex == 1 {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) присоединилась к беседе"
                        } else {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) присоединился к беседе"
                        }
                    } else if mess.action == "chat_invite_user_by_link" {
                        if user[0].sex == 1 {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) присоединилась к беседе"
                        } else {
                            messLabel.text = "\(user[0].firstName) \(user[0].lastName) присоединился к беседе"
                        }
                    } else if mess.action == "chat_create" {
                        messLabel.text = "Создана беседа с названием «\(mess.actionText)»"
                    } else if mess.action == "chat_title_update" {
                        messLabel.text = "Изменено название беседы на «\(mess.actionText)»"
                    } else if mess.action == "chat_photo_update" {
                        messLabel.text = "Обновлена главная фотография беседы"
                    } else if mess.action == "chat_photo_remove" {
                        messLabel.text = "Удалена главная фотография беседы"
                    } else if mess.action == "chat_pin_message" {
                        messLabel.text = "В беседе закреплено сообщение"
                    } else if mess.action == "chat_unpin_message" {
                        messLabel.text = "В беседе откреплено сообщение"
                    }
                }
                messLabel.numberOfLines = 2
                messLabel.textColor = UIColor.darkGray
            }
        }
    }
    
    @objc func animateDots() {
        switch (messLabel.text!) {
        case "набирает сообщение...":
            messLabel.text = "набирает сообщение   "
        case "набирает сообщение   ":
            messLabel.text = "набирает сообщение.  "
        case "набирает сообщение.  ":
            messLabel.text = "набирает сообщение.. "
        case "набирает сообщение.. ":
            messLabel.text = "набирает сообщение..."
        default:
            messLabel.text = "набирает сообщение   "
        }
    }
}
