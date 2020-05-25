//
//  VideoCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit

class VideoCell: UITableViewCell {
    
    var record: Videos!
    var viewsButton = UIButton()
    var repostsButton = UIButton()
    var commentsButton = UIButton()
    var likesButton = UIButton()
    
    var infoAvatar1 = UIImageView()
    var infoAvatar2 = UIImageView()
    var infoAvatar3 = UIImageView()
    var infoLikesLabel = UILabel()
    
    var viewsLabel = UILabel()
    var durationLabel = UILabel()
    
    var webView = WKWebView()
    
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    var avatarImageView = UIImageView()
    
    var nameLabel = UILabel()
    var datePostLabel = UILabel()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var position: CGPoint = CGPoint.zero
    
    
    let avatarImageSize: CGFloat = 60.0
    
    let titleFont: UIFont = UIFont(name: "Verdana", size: 14.0)!
    let descriptionFont: UIFont = UIFont(name: "Verdana", size: 12.0)!
    let viewsFont: UIFont = UIFont(name: "Verdana", size: 12.0)!
    let durationFont: UIFont = UIFont(name: "Verdana", size: 13.0)!
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    let topNameLabelInsets: CGFloat = 20.0
    let nameLabelHeight: CGFloat = 21.0
    let dateLabelHeight: CGFloat = 18.0
    let viewsLabelHeight: CGFloat = 20.0
    
    let verticalSpacingElements: CGFloat = 5.0
    
    let infoPanelHeight: CGFloat = 30.0
    let infoAvatarHeight: CGFloat = 28.0
    let infoAvatarTrailing: CGFloat = -5.0
    
    let likesButtonWight: CGFloat = 80.0
    let likesButtonHeight: CGFloat = 40.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
    }
    
    func configureCell(record: Videos, profiles: [NewsProfiles], groups: [NewsGroups], likes: [Likes], indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell, viewController: UIViewController) {
        
        self.record = record
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in self.subviews {
            if subview is UIImageView || subview is UILabel || subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        var url = ""
        var name = ""
        
        if record.ownerID > 0 {
            let users = profiles.filter( { $0.uid == record.ownerID } )
            if users.count > 0 {
                url = users[0].photoURL
                name = "\(users[0].firstName) \(users[0].lastName)"
            }
        } else {
            let groups = groups.filter( { $0.gid == abs(record.ownerID) } )
            if groups.count > 0 {
                url = groups[0].photoURL
                name = groups[0].name
            }
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImageView, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImageView.layer.cornerRadius = 30
            self.avatarImageView.clipsToBounds = true
        }
        
        if #available(iOS 13.0, *) {
            nameLabel.textColor = .label
            datePostLabel.textColor = .secondaryLabel
            durationLabel.textColor = .secondaryLabel
            viewsLabel.textColor = .secondaryLabel
            titleLabel.textColor = .label
            descriptionLabel.textColor = .secondaryLabel
            infoLikesLabel.textColor = .secondaryLabel
        }
        
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
        datePostLabel.text = record.date.toStringLastTime()
        datePostLabel.font = UIFont(name: "Verdana", size: 12)!
        datePostLabel.isEnabled = false
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        
        var topY: CGFloat = topInsets + avatarImageSize + verticalSpacingElements
        
        if let url = URL(string: record.player) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        let width = UIScreen.main.bounds.width - 2 * leftInsets
        let height = width * CGFloat(240) / CGFloat(320)
        webView.frame = CGRect(x: leftInsets, y: topY, width: width, height: height)
        webView.backgroundColor = vkSingleton.shared.backColor
        webView.layer.backgroundColor = vkSingleton.shared.backColor.cgColor
        webView.layer.cornerRadius = 4
        webView.clipsToBounds = true
        
        self.addSubview(webView)
        
        topY = topY + height + verticalSpacingElements
        
        viewsLabel.text = "Просмотров: \(record.views.getCounterToString())"
        viewsLabel.font = viewsFont
        viewsLabel.contentMode = .center
        viewsLabel.isEnabled = false
        viewsLabel.numberOfLines = 1
        viewsLabel.frame = CGRect(x: leftInsets, y: topY, width: (UIScreen.main.bounds.width - 2 * leftInsets) / 2, height: viewsLabelHeight)
        
        self.addSubview(viewsLabel)
        
        durationLabel.text = record.duration.getVideoDurationToString()
        durationLabel.font = durationFont
        durationLabel.contentMode = .center
        durationLabel.textAlignment = .right
        durationLabel.isEnabled = false
        durationLabel.numberOfLines = 1
        durationLabel.frame = CGRect(x: UIScreen.main.bounds.width / 2, y: topY, width: (UIScreen.main.bounds.width - 2 * leftInsets) / 2, height: viewsLabelHeight)
        
        self.addSubview(durationLabel)
        
        topY = topY + viewsLabelHeight
        
        titleLabel.text = record.title
        titleLabel.textAlignment = .center
        titleLabel.prepareTextForPublish2(viewController)
        titleLabel.font = titleFont
        titleLabel.numberOfLines = 0
        
        let titleSize = getTextSize(text: titleLabel.text!, font: titleFont)
        titleLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: titleSize.height)
        
        self.addSubview(titleLabel)
        
        topY = topY + titleLabel.frame.height + verticalSpacingElements
            
        descriptionLabel.text = record.description
        descriptionLabel.prepareTextForPublish2(viewController)
        descriptionLabel.font = descriptionFont
        descriptionLabel.numberOfLines = 0
        
        let descSize = getTextSize(text: descriptionLabel.text!, font: descriptionFont)
        descriptionLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: descSize.height)
        
        self.addSubview(descriptionLabel)
        
        topY = topY + descriptionLabel.frame.height + verticalSpacingElements
        
        configureInfoPanel(record, likes, topY, indexPath, cell, tableView)
        topY = topY + infoPanelHeight
        
        var titleColor = UIColor.darkGray
        var tintColor = UIColor.darkGray
        
        if #available(iOS 13.0, *) {
            titleColor = .secondaryLabel
            tintColor = .secondaryLabel
        }
        
        likesButton.frame = CGRect(x: leftInsets, y: topY, width: likesButtonWight, height: likesButtonHeight)
        likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
        likesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        setLikesButton(record: record)
        
        self.addSubview(likesButton)
        
        repostsButton.frame = CGRect(x: UIScreen.main.bounds.width - leftInsets - likesButtonWight, y: topY, width: likesButtonWight, height: likesButtonHeight)
        repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
        repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.normal)
        repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.selected)
        repostsButton.setImage(UIImage(named: "repost3"), for: .normal)
        repostsButton.imageView?.tintColor = tintColor
        repostsButton.setTitleColor(titleColor, for: .normal)
        if record.userReposted == 1 {
            repostsButton.setTitleColor(.systemPurple, for: .normal)
            repostsButton.imageView?.tintColor = .systemPurple
        }
        
        self.addSubview(repostsButton)
        
        commentsButton.frame = CGRect(x: (UIScreen.main.bounds.size.width - likesButtonWight) / 2.0, y: topY, width: likesButtonWight, height: likesButtonHeight)
        commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
        commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        commentsButton.setImage(UIImage(named: "message2"), for: .normal)
        commentsButton.setTitleColor(commentsButton.tintColor, for: .normal)
        commentsButton.imageView?.tintColor = commentsButton.tintColor
         
        commentsButton.setTitle("\(record.countComments)", for: UIControl.State.normal)
        commentsButton.setTitle("\(record.countComments)", for: UIControl.State.selected)
         
        self.addSubview(commentsButton)
    }
    
    func configureInfoPanel(_ record: Videos, _ likes: [Likes], _ topY: CGFloat, _ indexPath: IndexPath, _ cell: UITableViewCell, _ tableView: UITableView) {
        
        var countFriends = 0
        var info = "Понравилось"
        for like in likes {
            if like.uid != vkSingleton.shared.userID {
                if like.friendStatus == 3 {
                    countFriends += 1
                    
                    if countFriends == 1 {
                        let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar1, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        queue.addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        if record.userLikes == 1 {
                            info = "\(info) Вам, \(like.firstNameDat)"
                        } else {
                            info = "\(info) \(like.firstNameDat)"
                        }
                    }
                    if countFriends == 2 {
                        let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar2, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        queue.addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        info = "\(info), \(like.firstNameDat)"
                    }
                    if countFriends == 3 {
                        let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar3, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        queue.addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        info = "\(info), \(like.firstNameDat)"
                    }
                    if countFriends == 3 { break }
                }
            }
        }
        
        if (countFriends > 0) {
            var total = 0
            if record.userLikes == 1 {
                total = record.countLikes - countFriends - 1
            } else {
                total = record.countLikes - countFriends
            }
            if total > 0 {
                if total == 1 {
                    info = "\(info) и еще 1 человеку"
                } else {
                    info = "\(info) и еще \(total) людям"
                }
            }
        } else {
            var count = 0
            if record.userLikes == 1 {
                count = record.countLikes - 1
                if count == 0 {
                    info = "Понравилось только Вам"
                } else if count == 1 {
                    info = "Понравилось Вам и еще 1 человеку"
                } else {
                    info = "Понравилось Вам и еще \(count) людям"
                }
            } else {
                count = record.countLikes
                if count == 1 {
                    info = "Понравилось 1 человеку"
                } else {
                    info = "Понравилось \(count) людям"
                }
            }
            
            if count > 0 {
                countFriends += 1
                if likes.count > 0 {
                    let getCacheImage = GetCacheImage(url: likes[0].maxPhotoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar1, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                }
            }
            if count > 1 {
                countFriends += 1
                if likes.count > 0 {
                    let getCacheImage = GetCacheImage(url: likes[1].maxPhotoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar2, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                }
            }
            if count > 2 {
                countFriends += 1
                if likes.count > 0 {
                    let getCacheImage = GetCacheImage(url: likes[2].maxPhotoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar3, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                }
            }
        }
        
        infoLikesLabel.text = info
        infoLikesLabel.font = UIFont(name: "Verdana", size: 12)!
        infoLikesLabel.numberOfLines = 2
        infoLikesLabel.isEnabled = false
        
        if countFriends == 0 {
            infoLikesLabel.frame = CGRect(x: 10, y: topY, width: UIScreen.main.bounds.width - 20, height: 30)
            
            self.addSubview(infoLikesLabel)
        }
        
        if countFriends == 1 {
            infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoLikesLabel.frame = CGRect(x: infoAvatar1.frame.maxX + 5, y: topY, width: UIScreen.main.bounds.width - 10 - infoAvatar1.frame.maxX - 5, height: 30)
            
            infoAvatar1.layer.cornerRadius = 14
            infoAvatar1.layer.borderColor = UIColor.white.cgColor
            infoAvatar1.layer.borderWidth = 1.5
            infoAvatar1.clipsToBounds = true
            infoAvatar1.contentMode = .scaleAspectFit
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    } else {
                        infoAvatar1.layer.borderColor = UIColor.white.cgColor
                    }
                } else if AppConfig.shared.darkMode {
                    infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                } else {
                    infoAvatar1.layer.borderColor = UIColor.white.cgColor
                }
            }
            
            self.addSubview(infoAvatar1)
            self.addSubview(infoLikesLabel)
        }
        
        if countFriends == 2 {
            infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoAvatar2.frame = CGRect(x: infoAvatar1.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoLikesLabel.frame = CGRect(x: infoAvatar2.frame.maxX + 5, y: topY, width: UIScreen.main.bounds.width - 10 - infoAvatar2.frame.maxX - 5, height: infoPanelHeight)
            
            infoAvatar1.layer.cornerRadius = 14
            infoAvatar1.layer.borderColor = UIColor.white.cgColor
            infoAvatar1.layer.borderWidth = 1.5
            infoAvatar1.clipsToBounds = true
            infoAvatar1.contentMode = .scaleAspectFit
            
            infoAvatar2.layer.cornerRadius = 14
            infoAvatar2.layer.borderColor = UIColor.white.cgColor
            infoAvatar2.layer.borderWidth = 1.5
            infoAvatar2.clipsToBounds = true
            infoAvatar2.contentMode = .scaleAspectFit
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                        infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    } else {
                        infoAvatar1.layer.borderColor = UIColor.white.cgColor
                        infoAvatar2.layer.borderColor = UIColor.white.cgColor
                    }
                } else if AppConfig.shared.darkMode {
                    infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
                } else {
                    infoAvatar1.layer.borderColor = UIColor.white.cgColor
                    infoAvatar2.layer.borderColor = UIColor.white.cgColor
                }
            }
            
            self.addSubview(infoAvatar1)
            self.addSubview(infoAvatar2)
            self.addSubview(infoLikesLabel)
        }
        
        if countFriends > 2 {
            infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoAvatar2.frame = CGRect(x: infoAvatar1.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0 , width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoAvatar3.frame = CGRect(x: infoAvatar2.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0 , width: infoAvatarHeight, height: infoAvatarHeight)
            
            infoLikesLabel.frame = CGRect(x: infoAvatar3.frame.maxX + 5, y: topY, width: UIScreen.main.bounds.width - 10 - infoAvatar3.frame.maxX - 5, height: infoPanelHeight)
            
            infoAvatar1.layer.cornerRadius = 14
            infoAvatar1.layer.borderColor = UIColor.white.cgColor
            infoAvatar1.layer.borderWidth = 1.5
            infoAvatar1.clipsToBounds = true
            infoAvatar1.contentMode = .scaleAspectFit
            
            infoAvatar2.layer.cornerRadius = 14
            infoAvatar2.layer.borderColor = UIColor.white.cgColor
            infoAvatar2.layer.borderWidth = 1.5
            infoAvatar2.clipsToBounds = true
            infoAvatar2.contentMode = .scaleAspectFit
            
            infoAvatar3.layer.cornerRadius = 14
            infoAvatar3.layer.borderColor = UIColor.white.cgColor
            infoAvatar3.layer.borderWidth = 1.5
            infoAvatar3.clipsToBounds = true
            infoAvatar3.contentMode = .scaleAspectFit
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                        infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
                        infoAvatar3.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    } else {
                        infoAvatar1.layer.borderColor = UIColor.white.cgColor
                        infoAvatar2.layer.borderColor = UIColor.white.cgColor
                        infoAvatar3.layer.borderColor = UIColor.white.cgColor
                    }
                } else if AppConfig.shared.darkMode {
                    infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
                    infoAvatar3.layer.borderColor = vkSingleton.shared.backColor.cgColor
                } else {
                    infoAvatar1.layer.borderColor = UIColor.white.cgColor
                    infoAvatar2.layer.borderColor = UIColor.white.cgColor
                    infoAvatar3.layer.borderColor = UIColor.white.cgColor
                }
            }
            
            self.addSubview(infoAvatar1)
            self.addSubview(infoAvatar2)
            self.addSubview(infoAvatar3)
            self.addSubview(infoLikesLabel)
        }
    }
    
    func setLikesButton(record: Videos) {
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.normal)
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.selected)
        
        var titleColor = UIColor.darkGray
        var tintColor = UIColor.darkGray
        
        if #available(iOS 13.0, *) {
            titleColor = .secondaryLabel
            tintColor = .secondaryLabel
        }
        
        if record.userLikes == 1 {
            titleColor = .systemPurple
            tintColor = .systemPurple
        }
        
        likesButton.setTitleColor(titleColor, for: .normal)
        likesButton.tintColor = tintColor
        likesButton.setImage(UIImage(named: "filled-like2"), for: .normal)
    }
    
    func avatarImageViewFrame() {
        let avatarImageOrigin = CGPoint(x: leftInsets, y: topInsets)
        
        avatarImageView.frame = CGRect(origin: avatarImageOrigin, size: CGSize(width: avatarImageSize, height: avatarImageSize))
        
        self.addSubview(avatarImageView)
    }
    
    func nameLabelFrame() {
        
        let nameLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets)
        
        let nameLabelWidth = bounds.size.width - nameLabelOrigin.x - leftInsets
        
        nameLabel.frame = CGRect(origin: nameLabelOrigin, size: CGSize(width: nameLabelWidth, height: nameLabelHeight))
        
        self.addSubview(nameLabel)
    }
    
    
    func datePostLabelFrame() {
        
        let dateLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets + nameLabelHeight + 1)
        
        let dateLabelWidth = bounds.size.width - dateLabelOrigin.x - leftInsets
        
        datePostLabel.frame = CGRect(origin: dateLabelOrigin, size: CGSize(width: dateLabelWidth, height: dateLabelHeight))
        
        self.addSubview(datePostLabel)
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 0.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getRowHeight(record: Videos) -> CGFloat {
        
        var height: CGFloat = 0.0
        
        let widthVideo = UIScreen.main.bounds.width - 2 * leftInsets
        let heightVideo = widthVideo * CGFloat(240) / CGFloat(320)
        
        let titleSize = getTextSize(text: record.title.prepareTextForPublic(), font: titleFont)
        let descSize = getTextSize(text: record.description.prepareTextForPublic(), font: descriptionFont)
        
        height = topInsets + avatarImageSize + verticalSpacingElements + heightVideo + verticalSpacingElements + viewsLabelHeight + titleSize.height + verticalSpacingElements + descSize.height + verticalSpacingElements
        
        height = height + infoPanelHeight + likesButtonHeight + topInsets
        
        return height
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            position = touch.location(in: self)
        }
    }
    
    func getActionOnClickPosition(touch: CGPoint) -> String {
        
        var res = ""
        
        if touch.y >= avatarImageView.frame.minY && touch.y < avatarImageView.frame.maxY {
            res = "show_owner"
        }
        
        if let record = self.record, record.countLikes > 0 {
            if touch.y >= infoLikesLabel.frame.minY && touch.y < infoLikesLabel.frame.maxY {
                res = "show_info_likes"
            }
        }
        
        return res
    }
}
