//
//  GroupProfileView.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupProfileView: UIView {

    var delegate: UIViewController!
    
    var statusSeparator1 = UIView()
    var statusSeparator2 = UIView()
    var statusSeparator3 = UIView()
    var statusSeparator4 = UIView()
    var membersLabel = UILabel()
    var statusLabel = UILabel()
    var isMemberButton = UIButton()
    var messageButton = UIButton()
    var groupMessagesButton = UIButton()
    var activityLabel = UILabel()
    var siteGroupLabel = UILabel()
    var typeGroupLabel = UILabel()
    var coverImageView = UIImageView()
    var avatarImageView = UIImageView()
    var groupNameLabel = UILabel()
    var newRecordButton = UIButton()
    var postponedWallButton = UIButton()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var coverHeight: CGFloat = UIScreen.main.bounds.width * 200.0 / 795.0
    let avatarImageHeight: CGFloat = 100.0
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    let verticalSpacingInsets: CGFloat = 5.0
    let statusSeparatorHeight: CGFloat = 5.0
    let memberButtonLeftInsets: CGFloat = 70.0
    let memberButtonHeight: CGFloat = 25.0
    
    let groupNameLabelFont = UIFont(name: "Verdana-Bold", size: 16)!
    let typeGroupLabelFont = UIFont(name: "Verdana", size: 13)!
    let siteGroupLabelFont = UIFont(name: "Verdana", size: 11)!
    let statusLabelFont = UIFont(name: "Verdana", size: 14)!
    let activityLabelFont = UIFont(name: "Verdana", size: 13)!
    let memberButtonFont = UIFont(name: "Verdana-Bold", size: 12)!
    let membersLabelFont = UIFont(name: "Verdana", size: 13)!
    
    func setGroupCover(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        if profile.isCover == 1 {
            
            
            coverHeight = UIScreen.main.bounds.width * CGFloat(profile.coverHeight) / CGFloat(profile.coverWidth)
            
            let getCacheImage = GetCacheImage(url: profile.coverUrl, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    self.coverImageView.image = getCacheImage.outputImage
                }
            }
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation {
                self.coverImageView.layer.borderColor = UIColor.black.cgColor
                self.coverImageView.layer.borderWidth = 1.0
                self.coverImageView.contentMode = .scaleAspectFit
                self.coverImageView.clipsToBounds = true
            }
        } else {
            coverHeight = 0.0
        }
        
        coverImageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: coverHeight)
        
        self.addSubview(coverImageView)
        
        return topY + coverHeight
    }
    
    func setNewRecordButton(profile: GroupProfile, postponed: Int, topY: CGFloat) -> CGFloat {
        var topY = topY
        
        if profile.type == "group" && profile.canPost == 1 {
            newRecordButton.setTitle("Создать новую запись", for: .normal)
            newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
            newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
            newRecordButton.setTitleColor(UIColor.black, for: .selected)
            newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            
            newRecordButton.setImage(UIImage(named: "add-record"), for: .normal)
            newRecordButton.imageView?.tintColor = newRecordButton.tintColor
            newRecordButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 2, right: 0)
            
            newRecordButton.contentMode = .center
            
            newRecordButton.frame = CGRect(x: 30, y: topY, width: UIScreen.main.bounds.width - 60, height: 30)
            
            self.addSubview(newRecordButton)
            
            topY += 30
            
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: 5)
            separator.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            self.addSubview(separator)
            
            topY += 5
        } else if profile.type == "page" {
            newRecordButton.setTitle("Предложить новость", for: .normal)
            newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
            newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
            newRecordButton.setTitleColor(UIColor.black, for: .selected)
            newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            
            newRecordButton.setImage(UIImage(named: "add-record"), for: .normal)
            newRecordButton.imageView?.tintColor = newRecordButton.tintColor
            newRecordButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 2, right: 0)
            
            newRecordButton.contentMode = .center
            
            newRecordButton.frame = CGRect(x: 30, y: topY, width: UIScreen.main.bounds.width - 60, height: 30)
            
            self.addSubview(newRecordButton)
            
            topY += 30
            
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: 5)
            separator.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            self.addSubview(separator)
            
            topY += 5
        }
        
        if postponed > 0 {
            postponedWallButton.setTitle("Отложенные записи (\(postponed))", for: .normal)
            postponedWallButton.setTitleColor(postponedWallButton.tintColor, for: .normal)
            postponedWallButton.setTitleColor(UIColor.black, for: .highlighted)
            postponedWallButton.setTitleColor(UIColor.black, for: .selected)
            postponedWallButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            
            postponedWallButton.setImage(UIImage(named: "postponed"), for: .normal)
            postponedWallButton.imageView?.tintColor = postponedWallButton.tintColor
            postponedWallButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 2, right: 0)
            
            postponedWallButton.contentMode = .center
            
            postponedWallButton.frame = CGRect(x: 30, y: topY, width: UIScreen.main.bounds.width - 60, height: 30)
            
            self.addSubview(postponedWallButton)
            
            topY += 30
            
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: 5)
            separator.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            self.addSubview(separator)
            
            topY += 5
        }
        
        return topY
    }
    
    func setAvatarImageView(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        let leftAvatarInsets: CGFloat = UIScreen.main.bounds.width - avatarImageHeight - avatarImageHeight / 5.0
        
        var topAvatarInsets: CGFloat = topY - avatarImageHeight / 3.0
        if profile.isCover == 0 {
            topAvatarInsets = topY + 10
        }
        
        let getCacheImage = GetCacheImage(url: profile.photo200, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                self.avatarImageView.image = getCacheImage.outputImage
            }
        }
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation {
            self.avatarImageView.layer.borderColor = UIColor.white.cgColor
            self.avatarImageView.layer.borderWidth = 3.0
            self.avatarImageView.layer.cornerRadius = 49
            self.avatarImageView.contentMode = .scaleAspectFit
            self.avatarImageView.clipsToBounds = true
        }
        
        avatarImageView.frame = CGRect(x: leftAvatarInsets, y: topAvatarInsets, width: avatarImageHeight, height: avatarImageHeight)
        self.addSubview(avatarImageView)
        
        return topY
    }
    
    func getLabelSize(_ text: String, _ font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - avatarImageHeight - avatarImageHeight / 4.0 - 2 * leftInsets
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func setGroupNameLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        groupNameLabel.text = profile.name
        groupNameLabel.font = groupNameLabelFont
        groupNameLabel.numberOfLines = 2
        groupNameLabel.adjustsFontSizeToFitWidth = true
        groupNameLabel.minimumScaleFactor = 0.6
        
        let groupNameLabelSize = getLabelSize(profile.name, groupNameLabelFont)
        
        var width = groupNameLabelSize.width
        var height = groupNameLabelSize.height
        
        let maxWidth = avatarImageView.frame.minX - 2 * leftInsets
        
        if width < maxWidth {
            width = maxWidth
        }
        if height > 40 {
            height = 40.0
        }
        
        var groupNameLabelTop: CGFloat = topY + topInsets
        if profile.isCover == 0 {
            groupNameLabelTop = topY + topInsets + 20
            if height >= 25 {
                groupNameLabelTop = topY + topInsets + 10
            }
        }
        groupNameLabel.frame = CGRect(x: leftInsets, y: groupNameLabelTop, width: width, height: height)
        
        groupNameLabel.textAlignment = .center
        
        self.addSubview(groupNameLabel)
        
        return height + groupNameLabelTop
    }
    
    func setTypeAndSiteLabels(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        var type = ""
        if profile.deactivated != "" {
            if profile.deactivated == "banned" {
                type = "Сообщество заблокировано"
            }
            if profile.deactivated == "deleted" {
                type = "Сообщество удалено"
            }
        } else {
            if profile.type == "group" {
                if profile.isClosed == 0 {
                    type = "Открытая группа"
                } else {
                    type = "Закрытая группа"
                }
            }
            if profile.type == "page" {
                type = "Публичная страница"
            }
            if profile.type == "event" {
                type = "Мероприятие"
            }
        }
        
        typeGroupLabel.text = type
        typeGroupLabel.font = typeGroupLabelFont
        typeGroupLabel.textAlignment = .center
        typeGroupLabel.isEnabled = false
        
        typeGroupLabel.frame = CGRect(x: leftInsets, y: topY, width: avatarImageView.frame.minX - 2 * leftInsets, height: 20)
        
        var site = "https://vk.com/\(profile.screenName)"
        if profile.site != "" {
            site = profile.site
        }
        
        siteGroupLabel.text = site
        siteGroupLabel.prepareTextForPublish2(self.delegate)
        siteGroupLabel.font = siteGroupLabelFont
        //siteGroupLabel.textColor = UIColor(displayP3Red: 124/255, green: 172/255, blue: 238/255, alpha: 1)
        siteGroupLabel.textAlignment = .center
        siteGroupLabel.adjustsFontSizeToFitWidth = true
        siteGroupLabel.numberOfLines = 1
        siteGroupLabel.minimumScaleFactor = 0.75
        
        siteGroupLabel.frame = CGRect(x: leftInsets, y: topY + 20, width: avatarImageView.frame.minX - 2 * leftInsets, height: 20)
        
        self.addSubview(typeGroupLabel)
        self.addSubview(siteGroupLabel)
        
        return topY + 40
    }
    
    func getStatusLabelSize(_ text: String, _ font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func setStatusLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        var str = ""
        if profile.status != "" {
            str = profile.status.prepareTextForPublic()
        } else if profile.description != "" {
            str = profile.description.prepareTextForPublic()
        }
        
        statusLabel.text = str
        statusLabel.font = statusLabelFont
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let statusLabelSize = getStatusLabelSize(str, statusLabelFont)
        
        var width = statusLabelSize.width
        if width < maxWidth {
            width = maxWidth
        }
        var height = statusLabelSize.height
        if height < 30 {
            height = 30
        }
        if str == "" {
            height = 0.0
        }
        
        statusSeparator1.frame = CGRect(x: 0, y: topY + verticalSpacingInsets, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        statusSeparator1.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        statusSeparator1.isHidden = false
        
        statusLabel.frame = CGRect(x: leftInsets, y: topY + statusSeparatorHeight + verticalSpacingInsets, width: width, height: height)
        statusLabel.isHidden = false
        
        if profile.type == "event" {
            activityLabel.text = "Дата и время события: \(profile.activity)"
        } else {
            activityLabel.text = "Тематика: \(profile.activity)"
        }
        activityLabel.font = activityLabelFont
        activityLabel.textAlignment = .center
        activityLabel.frame = CGRect(x: leftInsets, y: topY + verticalSpacingInsets + statusSeparatorHeight + height, width: maxWidth, height: 16)
        activityLabel.isHidden = false
        activityLabel.isEnabled = false
        
        var title = "Вы администратор"
        if profile.levelAdmin == 1 {
            title = "Вы модератор"
        } else if profile.levelAdmin == 2 {
            title = "Вы редактор"
        }
        var titleColor = UIColor.black
        var backColor = UIColor.lightGray
        
        if profile.isAdmin == 0 {
            if profile.isMember == 1 {
                title = "Вы подписаны"
                if profile.type == "group" {
                    title = "Вы участник"
                }
                titleColor = UIColor.black
                backColor = UIColor.lightGray
            } else {
                title = "Подписаться"
                if profile.type == "group" {
                    title = "Подать заявку"
                    if profile.isClosed == 0 {
                        title = "Присоединиться"
                    }
                }
                backColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                titleColor = UIColor.white
            }
        }
        
        isMemberButton.setTitle(title, for: .normal)
        isMemberButton.titleLabel?.font = memberButtonFont
        isMemberButton.setTitleColor(titleColor, for: .normal)
        isMemberButton.backgroundColor = backColor
        isMemberButton.titleLabel?.textAlignment = NSTextAlignment.center
        isMemberButton.layer.borderColor = UIColor.black.cgColor
        isMemberButton.layer.borderWidth = 0.6
        isMemberButton.layer.cornerRadius = memberButtonHeight/3
        isMemberButton.clipsToBounds = true
        isMemberButton.isEnabled = true
        isMemberButton.isHidden = false
        isMemberButton.frame = CGRect(x: memberButtonLeftInsets, y: topY + verticalSpacingInsets + statusSeparatorHeight + height + activityLabel.frame.height + 2 * verticalSpacingInsets, width: UIScreen.main.bounds.width - 2 * memberButtonLeftInsets, height: memberButtonHeight)
        
        statusSeparator2.frame = CGRect(x: 0, y: topY + statusSeparatorHeight + verticalSpacingInsets + height + activityLabel.frame.height + 2 * verticalSpacingInsets + isMemberButton.frame.height + 2 * verticalSpacingInsets, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        statusSeparator2.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        statusSeparator2.isHidden = false
        
        self.addSubview(statusLabel)
        self.addSubview(statusSeparator1)
        self.addSubview(statusSeparator2)
        self.addSubview(activityLabel)
        self.addSubview(isMemberButton)
        
        var topNew = topY + 5 * verticalSpacingInsets + 2 * statusSeparatorHeight + height + activityLabel.frame.height + memberButtonHeight
        
        if profile.canMessage == 1 {
            messageButton.setTitle("Написать сообщение", for: .normal)
            messageButton.titleLabel?.font = memberButtonFont
            messageButton.setTitleColor(UIColor.white, for: .normal)
            messageButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            messageButton.titleLabel?.textAlignment = NSTextAlignment.center
            messageButton.layer.borderColor = UIColor.black.cgColor
            messageButton.layer.borderWidth = 0.6
            messageButton.layer.cornerRadius = memberButtonHeight/3
            messageButton.clipsToBounds = true
            messageButton.isEnabled = true
            messageButton.isHidden = false
            messageButton.frame = CGRect(x: memberButtonLeftInsets, y: topNew, width: UIScreen.main.bounds.width - 2 * memberButtonLeftInsets, height: memberButtonHeight)
            self.addSubview(messageButton)
            
            topNew += memberButtonHeight + 2 * verticalSpacingInsets
            
            statusSeparator2.frame = CGRect(x: 0, y: topNew, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        }
        
        if profile.isAdmin == 1 && profile.canMessage == 1{
            topNew += verticalSpacingInsets
            
            groupMessagesButton.setTitle("Сообщения сообщества", for: .normal)
            groupMessagesButton.titleLabel?.font = memberButtonFont
            groupMessagesButton.setTitleColor(UIColor.white, for: .normal)
            groupMessagesButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            groupMessagesButton.titleLabel?.textAlignment = NSTextAlignment.center
            groupMessagesButton.layer.borderColor = UIColor.black.cgColor
            groupMessagesButton.layer.borderWidth = 0.6
            groupMessagesButton.layer.cornerRadius = memberButtonHeight/3
            groupMessagesButton.clipsToBounds = true
            groupMessagesButton.isEnabled = true
            groupMessagesButton.isHidden = false
            groupMessagesButton.frame = CGRect(x: memberButtonLeftInsets, y: topNew, width: UIScreen.main.bounds.width - 2 * memberButtonLeftInsets, height: memberButtonHeight)
            self.addSubview(groupMessagesButton)
            
            topNew += memberButtonHeight + 2 * verticalSpacingInsets
            
            statusSeparator2.frame = CGRect(x: 0, y: topNew, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        }
        
        return topNew
    }
    
    func updateMemberButton(profile: GroupProfile) {
        var title = "Вы администратор"
        var titleColor = UIColor.black
        var backColor = UIColor.lightGray
        
        if profile.isAdmin == 0 {
            if profile.isMember == 1 {
                title = "Вы подписаны"
                if profile.type == "group" {
                    title = "Вы участник"
                }
                titleColor = UIColor.black
                backColor = UIColor.lightGray
            } else {
                title = "Подписаться"
                if profile.type == "group" {
                    title = "Подать заявку"
                    if profile.isClosed == 0 {
                        title = "Присоединиться"
                    }
                }
                backColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                titleColor = UIColor.white
            }
        }
        
        isMemberButton.setTitle(title, for: .normal)
        isMemberButton.titleLabel?.font = memberButtonFont
        isMemberButton.setTitleColor(titleColor, for: .normal)
        isMemberButton.backgroundColor = backColor
        isMemberButton.titleLabel?.textAlignment = NSTextAlignment.center
        isMemberButton.layer.borderColor = UIColor.black.cgColor
        isMemberButton.layer.borderWidth = 0.6
        isMemberButton.layer.cornerRadius = 10
        isMemberButton.clipsToBounds = true
        isMemberButton.isEnabled = true
    }
    
    func updateMembersLabel(profile: GroupProfile) {
        membersLabel.text = profile.membersCounter.subscribersAdder()
        if profile.type == "group" {
            membersLabel.text = profile.membersCounter.membersAdder()
        }
    }
        
    func setMembersLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        membersLabel.text = profile.membersCounter.subscribersAdder()
        if profile.type == "group" {
            membersLabel.text = profile.membersCounter.membersAdder()
        }
        membersLabel.font = membersLabelFont
        
        membersLabel.textColor = membersLabel.tintColor //UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        membersLabel.textAlignment = .center
        membersLabel.isEnabled = true
        membersLabel.isHidden = false
        membersLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 30)
        
        self.addSubview(membersLabel)
        
        statusSeparator3.frame = CGRect(x: 0, y: topY + membersLabel.frame.height, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        statusSeparator3.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        self.addSubview(statusSeparator3)
        
        return topY + membersLabel.frame.height + statusSeparatorHeight
    }
    
    func addSeparator4(_ topY: CGFloat) {
        statusSeparator4.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        statusSeparator4.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        self.addSubview(statusSeparator4)
    }
    
    func configureCell(profile: GroupProfile) -> CGFloat {
        
        var topY: CGFloat = 0.0
        
        topY = setGroupCover(profile, topY)
        topY = setAvatarImageView(profile, topY)
        topY = setGroupNameLabel(profile, topY)
        topY = setTypeAndSiteLabels(profile, topY)
        
        
        if topY < avatarImageView.frame.maxY {
            topY = avatarImageView.frame.maxY
        }
        
        topY = setStatusLabel(profile, topY)
        topY = setMembersLabel(profile, topY)
        
        return topY
    }
}
