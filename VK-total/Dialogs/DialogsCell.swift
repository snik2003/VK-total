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
    var messView = UIView()
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 5.0
    
    let userAvatarSize: CGFloat = 65.0
    let fromAvatarSize: CGFloat = 30.0
    
    let nameFont = UIFont(name: "Verdana", size: 14)!
    let messFont = UIFont(name: "Verdana", size: 11)!
    let dateFont = UIFont(name: "Verdana", size: 10)!
    
    func configureCell(mess: Message, conversation: Conversation?, users: [DialogsUsers], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = .clear
        
        for subview in self.subviews {
            if subview.tag == 100 { subview.removeFromSuperview() }
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
                if user[0].inLove {
                    name = "\(user[0].firstName) \(user[0].lastName) 💞"
                }
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
        
        if let conversation = conversation, conversation.important {
            let favoriteImage = UIImageView()
            favoriteImage.tag = 100
            favoriteImage.image = UIImage(named: "favorite")
            favoriteImage.contentMode = .scaleAspectFill
            let leftX = leftInsets + userAvatarSize - 20
            let topY = topInsets + userAvatarSize - 20
            favoriteImage.frame = CGRect(x: leftX, y: topY, width: 20, height: 20)
            self.addSubview(favoriteImage)
        }
        
        nameLabel.tag = 100
        nameLabel.text = name
        nameLabel.textColor = vkSingleton.shared.labelColor
        
        if online == 1 {
            if onlineMobile == 1 {
                let fullString = "\(name) "
                nameLabel.setOnlineMobileStatus(text: "\(fullString)", platform: platform)
            } else {
                let fullString = "\(name) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                if #available(iOS 13.0, *) {
                    attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.link], range: rangeOfColoredString)
                } else {
                    attributedString.setAttributes([NSAttributedString.Key.foregroundColor: nameLabel.tintColor], range: rangeOfColoredString)
                }
                
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
        dateLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
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
        } else {
            print("users count = 0")
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
        
        messView.frame = CGRect(x: 2.5 * leftInsets + userAvatarSize + fromAvatarSize, y: topInsets + 35, width: UIScreen.main.bounds.width - userAvatarSize - fromAvatarSize - 3 * leftInsets, height: fromAvatarSize)
        
        messLabel.frame = CGRect(x: leftInsets/2, y: 0, width: messView.bounds.width - leftInsets, height: messView.bounds.height)
        messView.addSubview(messLabel)
        
        self.addSubview(messView)
        
        messView.backgroundColor = .clear
        messView.layer.borderWidth = 0
        if mess.out == 0 {
            if mess.readState == 0 {
                self.backgroundColor = vkSingleton.shared.unreadColor
            }
        } else {
            if mess.readState == 0 {
                messView.backgroundColor = vkSingleton.shared.unreadColor
                messView.configureMessageView(out: 0, radius: 6, border: 0.2)
            }
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
            
            if !mess.body.isEmpty {
                messLabel.text = mess.body.replacingOccurrences(of: "\n", with: " ").prepareTextForPublic()
                
                messLabel.numberOfLines = 2
                messLabel.textColor = vkSingleton.shared.secondaryLabelColor
            } else if let attach = mess.attach.first, !attach.type.isEmpty {
                if attach.type == "photo" {
                    messLabel.text = "[Фотография]"
                } else if attach.type == "video" {
                    messLabel.text = "[Видеозапись]"
                } else if attach.type == "sticker" {
                    messLabel.text = "[Стикер]"
                } else if attach.type == "wall" {
                    messLabel.text = "[Запись на стене]"
                } else if attach.type == "gift" {
                    messLabel.text = "[Подарок]"
                } else if attach.type == "link" {
                    messLabel.text = "[Ссылка]"
                } else if attach.type == "doc" {
                    if let doc = attach.docs.first {
                        if doc.type == 3 {
                            messLabel.text = "[GIF]"
                        } else if doc.type == 4 {
                            messLabel.text = "[Граффити]"
                        } else if doc.type == 5 {
                            messLabel.text = "[Голосовое сообщение]"
                        } else if doc.type == 6 {
                            messLabel.text = "[Видеозапись]"
                        } else {
                            messLabel.text = "[Документ]"
                        }
                    } else {
                        messLabel.text = "[Документ]"
                    }
                } else {
                    messLabel.text = "[Вложение]"
                }
                messLabel.numberOfLines = 1
                messLabel.textColor = messLabel.tintColor
            } else if mess.typeAttach.count == 0 && mess.fwdMessage.count > 0 {
                if mess.fwdMessage.count == 1 {
                    messLabel.text = "[Пересланное сообщение]"
                } else {
                    messLabel.text = "[Пересланные сообщения]"
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
                    } else {
                        messLabel.text = mess.action
                    }
                } else {
                    if mess.action == "chat_create" {
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
                    } else {
                        messLabel.text = mess.action
                    }
                }
                
                messLabel.numberOfLines = 2
                messLabel.textColor = vkSingleton.shared.secondaryLabelColor
            } else {
                messLabel.text = mess.body
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
