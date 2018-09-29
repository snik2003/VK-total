//
//  NotificationCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {


    var not: Notifications!
    var indexPath: IndexPath!
    var notLabel: UILabel!
    var avatarTapRecognizer1 = UITapGestureRecognizer()
    var avatarTapRecognizer2 = UITapGestureRecognizer()
    var delegate: NotificationCellProtocol!
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 5.0
    
    let topAvatarInsets: CGFloat = 10.0
    let avatarSize: CGFloat = 60.0
    let smallImageSize: CGFloat = 30.0
    
    let notFont = UIFont(name: "Verdana", size: 14.0)!
    let colorFont = UIFont(name: "Verdana", size: 13.0)! // bold
    let dateFont = UIFont(name: "Verdana", size: 11.0)!
    let parentFont = UIFont(name: "Verdana", size: 12.0)! // bold
    let feedbackFont = UIFont(name: "Verdana-Italic", size: 13.0)!
    let leaveFont = UIFont(name: "Verdana", size: 12.0)! // bold
    
    let linkColor = UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1)
    let parentColor = UIColor.brown
    let feedbackColor = UIColor.purple
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 4 * leftInsets - avatarSize
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func configureCell(not: Notifications, profiles: [WallProfiles], groups: [WallGroups], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView, viewController: NotificationsController) {
        
        self.not = not
        self.indexPath = indexPath
        
        let subviews = self.subviews
        for subview in subviews {
            if subview is UIImageView || subview is UILabel || subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        notLabel = UILabel()
        notLabel.font = notFont
        notLabel.numberOfLines = 0
        notLabel.contentMode = .top
        notLabel.textAlignment = .left
        notLabel.lineBreakMode = .byCharWrapping
        
        let avatarImage = UIImageView()
        let smallImage = UIImageView()
        
        var url = ""
        var name = ""
        var userName = ""
        var userSex = -1
        var smallName = "error"
        
        let nameRecord = getRecordName(not: not)
        let parentComment = getParentCommentText(not: not)
        let comment = getFeedbackCommentText(not: not, indexPath: indexPath)
        let photoText = getPhotoText(not: not)
        
        if not.feedback[indexPath.row].fromID > 0 {
            let profile = profiles.filter({ $0.uid == not.feedback[indexPath.row].fromID })
            
            if profile.count > 0 {
                url = profile[0].photoURL
                userSex = profile[0].sex
                userName = "\(profile[0].firstName) \(profile[0].lastName)"
            }
        } else {
            let group = groups.filter({ $0.gid == abs(not.feedback[indexPath.row].fromID) })
            
            if group.count > 0 {
                url = group[0].photoURL
                userName = group[0].name
            }
        }
        
        if not.type == "group_invite" {
            let profile = profiles.filter({ $0.uid == not.feedback[indexPath.row].fromID })
            
            if profile.count > 0 {
                url = profile[0].photoURL
                smallName = "not_invite"
                var typeGroup = "в группу"
                if not.feedback[indexPath.row].type == "page" {
                    typeGroup = "в сообщество"
                } else if not.feedback[indexPath.row].type == "event" {
                    typeGroup = "на мероприятие"
                }
                
                if profile[0].sex == 1 {
                    name = "\(profile[0].firstName) \(profile[0].lastName) пригласила вас \(typeGroup) «\(not.feedback[indexPath.row].text)»"
                } else {
                    name = "\(profile[0].firstName) \(profile[0].lastName) пригласил вас \(typeGroup) «\(not.feedback[indexPath.row].text)»"
                }
                
                setColorText(fullString: name, avatarString: "\(profile[0].firstName) \(profile[0].lastName)", postString: "\(typeGroup) «\(not.feedback[indexPath.row].text)»", parent: "", feedback: "")
            }
        }
        
        if not.type == "follow" {
            
            smallName = "not_plus"
            if userSex == -1 {
                name = "Сообщество \(userName) подало заявку в друзья"
            } else if userSex == 1 {
                name = "\(userName) подала заявку в друзья"
            } else {
                name = "\(userName) подал заявку в друзья"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "", parent: "", feedback: "")
        }
        
        if not.type == "friend_accepted" {
            smallName = "not_plus"
            if userSex == 1 {
                name = "\(userName) приняла вашу заявку в друзья"
            } else {
                name = "\(userName) принял вашу заявку в друзья"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "", parent: "", feedback: "")
        }
        
        if not.type == "mention" {
            smallName = "not_mention"
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в записи \(nameRecord)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в записи \(nameRecord)на своей стене"
            } else {
                name = "\(userName) упоминул вас в записи \(nameRecord)на своей стене"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "записи", parent: "\(nameRecord)", feedback: "")
        }
        
        if not.type == "mention_comments" {
            smallName = "not_mention"
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в своем комментарии \(comment)"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в своем комментарии \(comment)"
            } else {
                name = "\(userName) упоминул вас в своем комментарии \(comment)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "комментарии", parent: "\(comment)", feedback: "")
        }
        
        if not.type == "wall" {
            smallName = "not_wall"
            if userSex == 1 {
                name = "\(userName) опубликовала запись \(nameRecord)на вашей стене"
            } else {
                name = "\(userName) опубликовал запись \(nameRecord)на вашей стене"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "запись", parent: nameRecord, feedback: "")
        }
        
        if not.type == "comment_post" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей записи \(nameRecord)"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей записи \(nameRecord)"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей записи \(nameRecord)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "записи", parent: nameRecord, feedback: comment)
        }
        
        if not.type == "comment_photo" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей фотографии"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей фотографии"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей фотографии"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "фотографии", parent: "", feedback: comment)
        }
        
        if not.type == "comment_video" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей видеозаписи \(photoText)"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей видеозаписи \(photoText)"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей видеозаписи \(photoText)"
            }
            setColorText(fullString: name, avatarString: "\(userName)", postString: "видеозаписи", parent: "\(photoText)", feedback: comment)
        }
        
        if not.type == "reply_comment" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к записи"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к записи"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к записи"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "записи", parent: parentComment, feedback: comment)
        }
        
        if not.type == "reply_comment_photo" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к фотографии"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к фотографии"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к фотографии"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "фотографии", parent: parentComment, feedback: comment)
        }
        
        if not.type == "reply_comment_video" {
            smallName = "not_comment"
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            }
            
             setColorText(fullString: name, avatarString: "\(userName)", postString: "видеозаписи", parent: parentComment, feedback: comment)
        }
        
        if not.type == "like_post" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила вашу запись \(nameRecord)"
            } else {
                name = "\(userName) оценил вашу запись \(nameRecord)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "запись", parent: nameRecord, feedback: "")
        }
        
        if not.type == "like_comment" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к записи"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к записи"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "записи", parent: "\(parentComment)", feedback: "")
        }
        
        if not.type == "like_photo" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила вашу фотографию \(photoText)"
            } else {
                name = "\(userName) оценил вашу фотографию \(photoText)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "фотографию", parent: "\(photoText)", feedback: "")
        }
        
        if not.type == "like_video" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила вашу видеозапись \(photoText)"
            } else {
                name = "\(userName) оценил вашу видеозапись \(photoText)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "видеозапись", parent: " \(photoText)", feedback: "")
        }
        
        if not.type == "like_comment_photo" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к фотографии"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к фотографии"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "фотографии", parent: "\(parentComment)", feedback: "")
        }
        
        if not.type == "like_comment_video" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к видеозаписи"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к видеозаписи"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "видеозаписи", parent: "\(parentComment)", feedback: "")
        }
        
        if not.type == "like_comment_topic" {
            smallName = "not_like"
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) в обсуждении"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) в обсуждении"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "обсуждении", parent: "\(parentComment)", feedback: "")
        }
        
        if not.type == "copy_post" {
            smallName = "not_repost"
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей записью \(nameRecord)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей записью \(nameRecord)на своей стене"
            } else {
                name = "\(userName) поделился вашей записью \(nameRecord)на своей стене"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "записью", parent: nameRecord, feedback: "")
        }
        
        if not.type == "copy_photo" {
            smallName = "not_repost"
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей фотографией \(photoText)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей фотографией \(photoText)на своей стене"
            } else {
                name = "\(userName) поделился вашей фотографией \(photoText)на своей стене"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "фотографией", parent: "\(photoText)", feedback: "")
        }
        
        if not.type == "copy_video" {
            smallName = "not_repost"
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей видеозаписью \(photoText)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей видеозаписью \(photoText)на своей стене"
            } else {
                name = "\(userName) поделился вашей видеозаписью \(photoText)на своей стене"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "видеозаписью", parent: "\(photoText)", feedback: "")
        }
        
        if not.type == "mention_comment_photo" {
            smallName = "not_mention"
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в комментарии \(comment) к фотографии \(photoText)"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в комментарии \(comment) к фотографии \(photoText)"
            } else {
                name = "\(userName) упоминул вас в комментарии \(comment) к фотографии \(photoText)"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "комментарии", parent: "\(photoText)", feedback: comment)
        }
        
        if not.type == "mention_comment_video" {
            smallName = "not_mention"
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в комментарии \(comment) к видеозаписи"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в комментарии \(comment) к видеозаписи"
            } else {
                name = "\(userName) упоминул вас в комментарии \(comment) к видеозаписи"
            }
            
            setColorText(fullString: name, avatarString: "\(userName)", postString: "комментарии", parent: "", feedback: comment)
        }
        
        
        notLabel.text = name
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            avatarImage.layer.cornerRadius = 29
            avatarImage.clipsToBounds = true
            smallImage.image = UIImage(named: smallName)
            smallImage.layer.cornerRadius = 15
            smallImage.layer.borderColor = UIColor.white.cgColor
            smallImage.layer.borderWidth = 3.0
            smallImage.clipsToBounds = true
        }
        
        avatarImage.frame = CGRect(x: leftInsets, y: topAvatarInsets, width: avatarSize, height: avatarSize)
        
        smallImage.frame = CGRect(x: 2 * leftInsets + avatarSize - smallImageSize, y: topAvatarInsets + avatarSize - smallImageSize, width: smallImageSize, height: smallImageSize)
        
        let notLabelSize = getTextSize(text: name + "еще немного", font: notFont)
        
        notLabel.frame = CGRect(x: 3 * leftInsets + avatarSize, y: 2 * topInsets, width: notLabelSize.width, height: notLabelSize.height)
        
        if not.type == "group_invite" {
            let leaveButton = UIButton()
            leaveButton.setTitle("Принять/Отклонить", for: .normal)
            leaveButton.titleLabel?.font = leaveFont
            
            leaveButton.setTitleColor(UIColor.white, for: .normal)
            leaveButton.setTitleColor(UIColor.red, for: .selected)
            
            leaveButton.layer.borderColor = UIColor.black.cgColor
            leaveButton.layer.borderWidth = 0.5
            leaveButton.layer.cornerRadius = 10
            leaveButton.clipsToBounds = true
            leaveButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            leaveButton.isEnabled = true
            
            var leaveButtonY: CGFloat = 2 * topInsets +  notLabelSize.height
            if leaveButtonY + 24 + topInsets < 2 * topAvatarInsets + avatarSize {
                leaveButtonY = 2 * topAvatarInsets + avatarSize - 24 - topInsets
            }
            
            leaveButton.frame = CGRect(x: bounds.width - 170 - 10, y: leaveButtonY + 2, width: 170, height: 22)
            
            leaveButton.addTarget(self, action: #selector(self.leaveButtonClick(sender:)), for: .touchUpInside)
            
            self.addSubview(leaveButton)
        } else {
            let dateLabel = UILabel()
            dateLabel.font = dateFont
            dateLabel.numberOfLines = 1
            dateLabel.isEnabled = false
            dateLabel.text = not.date.toStringLastTime()
            dateLabel.contentMode = .center
            dateLabel.textAlignment = .right
            
            var dateLabelY: CGFloat = 2 * topInsets +  notLabelSize.height
            if dateLabelY + 24 + topInsets < 2 * topAvatarInsets + avatarSize {
                dateLabelY = 2 * topAvatarInsets + avatarSize - 24 - topInsets
            }
            
            dateLabel.frame = CGRect(x: 3 * leftInsets + avatarSize, y: dateLabelY, width: bounds.width - 4 * leftInsets - avatarSize, height: 24)
            
            self.addSubview(dateLabel)
        }
        
        avatarTapRecognizer1.addTarget(self, action: #selector(tapAvatar(sender:)))
        avatarTapRecognizer1.numberOfTapsRequired = 1
        avatarTapRecognizer2.addTarget(self, action: #selector(tapAvatar(sender:)))
        avatarTapRecognizer2.numberOfTapsRequired = 1
        
        avatarImage.addGestureRecognizer(avatarTapRecognizer1)
        avatarImage.isUserInteractionEnabled = true
        smallImage.addGestureRecognizer(avatarTapRecognizer2)
        smallImage.isUserInteractionEnabled = true
        
        self.addSubview(avatarImage)
        self.addSubview(smallImage)
        self.addSubview(notLabel)
    }
    
    func getRowHeight(not: Notifications, profiles: [WallProfiles], groups: [WallGroups], indexPath: IndexPath) -> CGFloat {
        
        let height1 = 2 * topAvatarInsets + avatarSize
        var name = ""
        var userName = ""
        var userSex = -1
        
        let nameRecord = getRecordName(not: not)
        let parentComment = getParentCommentText(not: not)
        let comment = getFeedbackCommentText(not: not, indexPath: indexPath)
        let photoText = getPhotoText(not: not)
        
        if not.feedback[indexPath.row].fromID > 0 {
            let profile = profiles.filter({ $0.uid == not.feedback[indexPath.row].fromID })
            
            if profile.count > 0 {
                userSex = profile[0].sex
                userName = "\(profile[0].firstName) \(profile[0].lastName)"
            }
        } else {
            let group = groups.filter({ $0.gid == abs(not.feedback[indexPath.row].fromID) })
            
            if group.count > 0 {
                userName = group[0].name
            }
        }
        
        if not.type == "group_invite" {
            let profile = profiles.filter({ $0.uid == not.feedback[indexPath.row].fromID })
            
            if profile.count > 0 {
                var typeGroup = "в группу"
                if not.feedback[indexPath.row].type == "page" {
                    typeGroup = "в сообщество"
                } else if not.feedback[indexPath.row].type == "event" {
                    typeGroup = "на мероприятие"
                }
                
                if profile[0].sex == 1 {
                    name = "\(profile[0].firstName) \(profile[0].lastName) пригласила вас \(typeGroup) «\(not.feedback[indexPath.row].text)»"
                } else {
                    name = "\(profile[0].firstName) \(profile[0].lastName) пригласил вас \(typeGroup) «\(not.feedback[indexPath.row].text)»"
                }
            }
        }
        
        if not.type == "follow" {
            if userSex == -1 {
                name = "Сообщество \(userName) подало заявку в друзья"
            } else if userSex == 1 {
                name = "\(userName) подала заявку в друзья"
            } else {
                name = "\(userName) подал заявку в друзья"
            }
        }
        
        if not.type == "friend_accepted" {
            if userSex == 1 {
                name = "\(userName) приняла вашу заявку в друзья"
            } else {
                name = "\(userName) принял вашу заявку в друзья"
            }
        }
        
        if not.type == "mention" {
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в записи \(nameRecord)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в записи \(nameRecord)на своей стене"
            } else {
                name = "\(userName) упоминул вас в записи \(nameRecord)на своей стене"
            }
        }
        
        if not.type == "mention_comments" {
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в своем комментарии \(comment)"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в своем комментарии \(comment)"
            } else {
                name = "\(userName) упоминул вас в своем комментарии \(comment)"
            }
        }
        
        if not.type == "wall" {
            if userSex == 1 {
                name = "\(userName) опубликовала запись \(nameRecord)на вашей стене"
            } else {
                name = "\(userName) опубликовал запись \(nameRecord)на вашей стене"
            }
        }
        
        if not.type == "comment_post" {
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей записи \(nameRecord)"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей записи \(nameRecord)"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей записи \(nameRecord)"
            }
        }
        
        if not.type == "comment_photo" {
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей фотографии"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей фотографии"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей фотографии"
            }
        }
        
        if not.type == "comment_video" {
            if userSex == -1 {
                name = "Сообщество \(userName) оставило комментарий \(comment) к вашей видеозаписи \(photoText)"
            } else if userSex == 1 {
                name = "\(userName) оставила комментарий \(comment) к вашей видеозаписи \(photoText)"
            } else {
                name = "\(userName) оставил комментарий \(comment) к вашей видеозаписи \(photoText)"
            }
        }
        
        if not.type == "reply_comment" {
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к записи"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к записи"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к записи"
            }
        }
        
        if not.type == "reply_comment_photo" {
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к фотографии"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к фотографии"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к фотографии"
            }
        }
        
        if not.type == "reply_comment_video" {
            if userSex == -1 {
                name = "Сообщество \(userName) ответило \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            } else if userSex == 1 {
                name = "\(userName) ответила \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            } else {
                name = "\(userName) ответил \(comment) на ваш комментарий \(parentComment) к видеозаписи"
            }
        }
        
        if not.type == "like_post" {
            if userSex == 1 {
                name = "\(userName) оценила вашу запись \(nameRecord)"
            } else {
                name = "\(userName) оценил вашу запись \(nameRecord)"
            }
        }
        
        if not.type == "like_comment" {
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к записи"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к записи"
            }
        }
        
        if not.type == "like_photo" {
            if userSex == 1 {
                name = "\(userName) оценила вашу фотографию \(photoText)"
            } else {
                name = "\(userName) оценил вашу фотографию \(photoText)"
            }
        }
        
        if not.type == "like_video" {
            if userSex == 1 {
                name = "\(userName) оценила вашу видеозапись \(photoText)"
            } else {
                name = "\(userName) оценил вашу видеозапись \(photoText)"
            }
        }
        
        if not.type == "like_comment_photo" {
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к фотографии"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к фотографии"
            }
        }
        
        if not.type == "like_comment_video" {
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) к видеозаписи"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) к видеозаписи"
            }
        }
        
        if not.type == "like_comment_topic" {
            if userSex == 1 {
                name = "\(userName) оценила ваш комментарий \(parentComment) в обсуждении"
            } else {
                name = "\(userName) оценил ваш комментарий \(parentComment) в обсуждении"
            }
        }
        
        if not.type == "copy_post" {
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей записью \(nameRecord)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей записью \(nameRecord)на своей стене"
            } else {
                name = "\(userName) поделился вашей записью \(nameRecord)на своей стене"
            }
        }
        
        if not.type == "copy_photo" {
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей фотографией \(photoText)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей фотографией \(photoText)на своей стене"
            } else {
                name = "\(userName) поделился вашей фотографией \(photoText)на своей стене"
            }
        }
        
        if not.type == "copy_video" {
            if userSex == -1 {
                name = "Сообщество \(userName) поделилось вашей видеозаписью \(photoText)на своей стене"
            } else if userSex == 1 {
                name = "\(userName) поделилась вашей видеозаписью \(photoText)на своей стене"
            } else {
                name = "\(userName) поделился вашей видеозаписью \(photoText)на своей стене"
            }
        }
        
        if not.type == "mention_comment_photo" {
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в комментарии \(comment) к фотографии \(photoText)"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в комментарии \(comment) к фотографии \(photoText)"
            } else {
                name = "\(userName) упоминул вас в комментарии \(comment) к фотографии \(photoText)"
            }
        }
        
        if not.type == "mention_comment_video" {
            if userSex == -1 {
                name = "Сообщество \(userName) упоминуло вас в комментарии \(comment) к видеозаписи"
            } else if userSex == 1 {
                name = "\(userName) упоминула вас в комментарии \(comment) к видеозаписи"
            } else {
                name = "\(userName) упоминул вас в комментарии \(comment) к видеозаписи"
            }
        }
        
        if name == "" {
            return 0
        }
        
        let notLabelSize = getTextSize(text: name + "еще немного", font: notFont)
        let height2 = 3 * topInsets + notLabelSize.height + 24
        
        if height1 > height2 {
            return height1
        }
        
        return height2
    }
    
    func setColorText(fullString: String, avatarString: String, postString: String, parent: String, feedback: String) {
        
        let rangeOfPostString = (fullString as NSString).range(of: postString)
        let rangeOfParentString = (fullString as NSString).range(of: parent)
        let rangeOfFeedbackString = (fullString as NSString).range(of: feedback)
        
        let attributedString = NSMutableAttributedString(string: fullString)
        
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: linkColor, NSAttributedString.Key.font: colorFont], range: rangeOfPostString)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: parentColor, NSAttributedString.Key.font: parentFont], range: rangeOfParentString)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: feedbackColor, NSAttributedString.Key.font: feedbackFont], range: rangeOfFeedbackString)
        
        let tap = UITapGestureRecognizer()
        tap.add {
            if let not = self.not, let indexPath = self.indexPath {
                
                if not.type == "follow" || not.type == "friend_accepted" {
                    self.delegate.openProfileController(id: not.feedback[indexPath.row].fromID, name: "")
                    
                } else if not.type == "comment_video" || not.type == "reply_comment_video" || not.type == "like_video" || not.type == "like_comment_video" || not.type == "copy_video" || not.type == "mention_comment_video" {
                    //print("tap video")
                    
                    if not.type == "reply_comment_video" || not.type == "like_comment_video" {
                        self.delegate.openVideoController(ownerID: "\(not.parent[0].ownerID)", vid: "\(not.parent[0].typeID)", accessKey: "", title: "Видеозапись")
                    } else {
                        self.delegate.openVideoController(ownerID: "\(not.parent[0].ownerID)", vid: "\(not.parent[0].id)", accessKey: "", title: "Видеозапись")
                    }
                    
                } else if not.type == "comment_photo" || not.type == "reply_comment_photo" || not.type == "like_photo" || not.type == "like_comment_photo" || not.type == "copy_photo" || not.type == "mention_comment_photo" {
                    
                    //print("tap photo")
                    self.delegate.openPhoto(not: not)
                    
                } else if not.type == "like_comment_topic" {
                    
                    self.delegate.openTopicController(groupID: "\(abs(not.parent[0].ownerID))", topicID: "\(not.parent[0].typeID)", title: "", delegate: self.delegate as! UIViewController)
                    
                } else if not.type == "group_invite" {
                    
                    // print("tap group invite")
                    
                    var name = not.feedback[indexPath.row].text
                    if name.length > 20 {
                        name = "\((name).prefix(20))..."
                    } else {
                        name = "Сообщество"
                    }
                    
                    self.delegate.openProfileController(id: -1 * not.feedback[indexPath.row].id, name: name)
                } else if not.type == "mention" || not.type == "wall" || not.type == "wall_publish" {
                        self.delegate.openWallRecord(ownerID: not.feedback[indexPath.row].toID, postID: not.feedback[indexPath.row].id, accessKey: "", type: "post")
                } else if not.type == "like_comment" || not.type == "reply_comment"{
                        self.delegate.openWallRecord(ownerID: not.parent[0].fromID, postID: not.parent[0].typeID, accessKey: "", type: "post")
                        
                } else {
                    self.delegate.openWallRecord(ownerID: not.parent[0].toID, postID: not.parent[0].id, accessKey: "", type: "post")
                }
            }
        }
        tap.numberOfTapsRequired = 1
        
        notLabel.attributedText = attributedString
        notLabel.addGestureRecognizer(tap)
        notLabel.isUserInteractionEnabled = true
    }
    
    @objc func tapAvatar(sender: UITapGestureRecognizer) {
        self.delegate.openProfileController(id: not.feedback[indexPath.row].fromID, name: "")
    }
    
    @objc func leaveButtonClick(sender: UIButton) {
        
        (self.delegate as! NotificationsController).leaveGroupInvite(sender: sender)
    }
    
    func getParentCommentText(not: Notifications) -> String {
        
        var str = ""
        if not.parent[0].text != "" {
            str = "\"\(not.parent[0].text.prepareTextForPublic())\""
        }
        
        return str
    }
    
    func getFeedbackCommentText(not: Notifications, indexPath: IndexPath) -> String {
        
        var str = ""
        if not.feedback[indexPath.row].text != "" {
            str = "\"\(not.feedback[indexPath.row].text.prepareTextForPublic())\""
        }
        
        return str
    }
    
    func getPhotoText(not: Notifications) -> String {
        
        var str = ""
        if not.parent[0].text != "" {
            str = "\"\(not.parent[0].text.prepareTextForPublic())\" "
        }
        
        return str
    }
    
    func getRecordName(not: Notifications) -> String {
        var str = not.parent[0].text.prepareTextForPublic()
        if not.parent[0].text == "" {
            str = "\(not.parent[0].repostText.prepareTextForPublic())"
        }
        var str1 = str.components(separatedBy: [".", "!", "?", "\n"])
        var nameRecord = ""
        if str1[0] != "" {
            nameRecord = "\"\(str1[0])...\" "
        } else {
            if not.parent[0].attach.count > 0 {
                str = not.parent[0].attach[0].text.prepareTextForPublic()
                if not.parent[0].attach[0].text == "" {
                    if not.parent[0].repostAttach.count > 0 {
                        str = not.parent[0].repostAttach[0].text.prepareTextForPublic()
                    }
                }
            } else {
                if not.parent[0].repostAttach.count > 0 {
                    str = not.parent[0].repostAttach[0].text.prepareTextForPublic()
                }
            }
            str1 = str.components(separatedBy: [".", "!", "?", "\n"])
            if str1[0] != "" {
                nameRecord = "\"\(str1[0])...\" "
            }
        }
        
        return nameRecord
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
