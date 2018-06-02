//
//  GroupProfileCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 12.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupProfileCell: UITableViewCell {

    @IBOutlet weak var statusSeparator1: UIView! {
        didSet {
            statusSeparator1.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var statusSeparator2: UIView! {
        didSet {
            statusSeparator1.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var membersLabel: UILabel! {
        didSet {
            membersLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var isMemberButton: UIButton! {
        didSet {
            isMemberButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var activityLabel: UILabel! {
        didSet {
            activityLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var siteGroupLabel: UILabel! {
        didSet {
            siteGroupLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var typeGroupLabel: UILabel! {
        didSet {
            typeGroupLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var coverImageView: UIImageView! {
        didSet {
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var groupNameLabel: UILabel! {
        didSet {
            groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
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
    
    func setGroupCover(_ profile: GroupProfile, _ indexPath: IndexPath, _ cell: UITableViewCell, _ tableView: UITableView, _ topY: CGFloat) -> CGFloat {
        
        if profile.isCover == 1 {
            
            coverHeight = UIScreen.main.bounds.width * CGFloat(profile.coverHeight) / CGFloat(profile.coverWidth)
            
            let getCacheImage = GetCacheImage(url: profile.coverUrl, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: coverImageView, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
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
        
        return topY + coverHeight
    }
    
    func setAvatarImageView(_ profile: GroupProfile, _ indexPath: IndexPath, _ cell: UITableViewCell, _ tableView: UITableView, _ topY: CGFloat) -> CGFloat {
        
        let leftAvatarInsets: CGFloat = UIScreen.main.bounds.width - avatarImageHeight - avatarImageHeight / 4.0
        
        var topAvatarInsets: CGFloat = topY - avatarImageHeight / 2.0
        if profile.isCover == 0 {
            topAvatarInsets = topY + 10
        }
        
        let getCacheImage = GetCacheImage(url: profile.photo200, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImageView, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImageView.layer.borderColor = UIColor.white.cgColor
            self.avatarImageView.layer.borderWidth = 3.0
            self.avatarImageView.layer.cornerRadius = 49
            self.avatarImageView.contentMode = .scaleAspectFit
            self.avatarImageView.clipsToBounds = true
        }
        
        avatarImageView.frame = CGRect(x: leftAvatarInsets, y: topAvatarInsets, width: avatarImageHeight, height: avatarImageHeight)
        return topY
    }
    
    func getLabelSize(_ text: String, _ font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - avatarImageHeight - avatarImageHeight / 4.0 - 2 * leftInsets
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
    
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func setGroupNameLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        groupNameLabel.text = profile.name
        let groupNameLabelSize = getLabelSize(groupNameLabel.text!, groupNameLabel.font)
        
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
        groupNameLabel.isHidden = false
        
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
        typeGroupLabel.isHidden = false
        
        typeGroupLabel.frame = CGRect(x: leftInsets, y: topY, width: avatarImageView.frame.minX - 2 * leftInsets, height: 20)
        
        var site = "https://vk.com/\(profile.screenName)"
        if profile.site != "" {
            site = profile.site
        }
        
        siteGroupLabel.text = site
        siteGroupLabel.isHidden = false
        
        siteGroupLabel.frame = CGRect(x: leftInsets, y: topY + 20, width: avatarImageView.frame.minX - 2 * leftInsets, height: 20)
        
        return topY + 40
    }
    
    func getStatusLabelSize(_ text: String, _ font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func setStatusLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        var str = ""
        if profile.status != "" {
            str = profile.status.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        } else if profile.description != "" {
            str = profile.description.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        }
        statusLabel.text = str
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let statusLabelSize = getStatusLabelSize(statusLabel.text!, statusLabel.font)
        
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
        statusSeparator1.isHidden = false
        
        statusLabel.frame = CGRect(x: leftInsets, y: topY + statusSeparatorHeight + verticalSpacingInsets, width: width, height: height)
        statusLabel.isHidden = false
        
        activityLabel.text = "Тематика: \(profile.activity)"
        activityLabel.textAlignment = .center
        activityLabel.frame = CGRect(x: leftInsets, y: topY + verticalSpacingInsets + statusSeparatorHeight + height, width: maxWidth, height: 16)
        activityLabel.isHidden = false
        
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
        isMemberButton.setTitleColor(titleColor, for: .normal)
        isMemberButton.backgroundColor = backColor
        isMemberButton.titleLabel?.textAlignment = NSTextAlignment.center
        isMemberButton.layer.borderColor = UIColor.black.cgColor
        isMemberButton.layer.borderWidth = 0.6
        isMemberButton.layer.cornerRadius = 10
        isMemberButton.clipsToBounds = true
        isMemberButton.isEnabled = true
        isMemberButton.isHidden = false
        isMemberButton.frame = CGRect(x: memberButtonLeftInsets, y: topY + verticalSpacingInsets + statusSeparatorHeight + height + activityLabel.frame.height + verticalSpacingInsets, width: UIScreen.main.bounds.width - 2 * memberButtonLeftInsets, height: memberButtonHeight)
        
        statusSeparator2.frame = CGRect(x: 0, y: topY + statusSeparatorHeight + verticalSpacingInsets + height + activityLabel.frame.height + verticalSpacingInsets + isMemberButton.frame.height + 2 * verticalSpacingInsets, width: UIScreen.main.bounds.width, height: statusSeparatorHeight)
        statusSeparator2.isHidden = false
        
        let topNew = topY + 4 * verticalSpacingInsets + 2 * statusSeparatorHeight + height + activityLabel.frame.height + memberButtonHeight
        
        return topNew
    }
    
    func setMembersLabel(_ profile: GroupProfile, _ topY: CGFloat) -> CGFloat {
        
        membersLabel.text = profile.membersCounter.subscribersAdder()
        if profile.type == "group" {
            membersLabel.text = profile.membersCounter.membersAdder()
        }
        membersLabel.isHidden = false
        membersLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 30)
        
        return topY + membersLabel.frame.height
    }
    
    func configureCell(profile: GroupProfile, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        var topY: CGFloat = 0.0
        
        topY = setGroupCover(profile, indexPath, cell, tableView, topY)
        topY = setAvatarImageView(profile, indexPath, cell, tableView, topY)
        topY = setGroupNameLabel(profile, topY)
        topY = setTypeAndSiteLabels(profile, topY)

        
        if topY < avatarImageView.frame.maxY {
            topY = avatarImageView.frame.maxY
        }
        
        topY = setStatusLabel(profile, topY)
        topY = setMembersLabel(profile, topY)
    }
    
    func getRowHeight(profile: GroupProfile) -> CGFloat {
    
        var height: CGFloat = 0.0
        
        if profile.isCover == 1 {
            let cover = UIScreen.main.bounds.width * CGFloat(profile.coverHeight) / CGFloat(profile.coverWidth)
            
            height += cover
        }
        
        var topAvatarInsets: CGFloat = 10
        if profile.isCover == 1 {
            topAvatarInsets = height - avatarImageHeight / 2.0
        }
        
        var nameLabelHeight = getLabelSize(profile.name, groupNameLabel.font).height
        if nameLabelHeight > 40 {
            nameLabelHeight = 40.0
        }
        
        var groupNameLabelTop = topInsets
        if profile.isCover == 0 {
            groupNameLabelTop = topInsets + 20
            if nameLabelHeight >= 25 {
                groupNameLabelTop = topInsets + 10
            }
        }
        
        
        height += groupNameLabelTop + nameLabelHeight + 40
        
        
        if height < topAvatarInsets + avatarImageHeight {
            height = topAvatarInsets + avatarImageHeight
        }
        
        var str = ""
        if profile.status != "" {
            str = profile.status.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        } else if profile.description != "" {
            str = profile.description.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        }
        var statusLabelHeight = getStatusLabelSize(str, statusLabel.font).height
        if statusLabelHeight < 30 {
            statusLabelHeight = 30
        }
        if str == "" {
            statusLabelHeight = 0.0
        }
        
        height += 4 * verticalSpacingInsets + 2 * statusSeparatorHeight + statusLabelHeight + 16 + memberButtonHeight + 30
        
        return height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
