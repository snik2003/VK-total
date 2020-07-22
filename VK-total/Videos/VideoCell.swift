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
    
    var webView: WKWebView!
    
    let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    var avatarImageView = UIImageView()
    
    var loadingView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    var nameLabel = UILabel()
    var datePostLabel = UILabel()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var position: CGPoint = CGPoint.zero
    
    var autoplay = 1;
    
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
        
        nameLabel.textColor = vkSingleton.shared.labelColor
        datePostLabel.textColor = vkSingleton.shared.secondaryLabelColor
        durationLabel.textColor = vkSingleton.shared.secondaryLabelColor
        viewsLabel.textColor = vkSingleton.shared.secondaryLabelColor
        titleLabel.textColor = vkSingleton.shared.labelColor
        descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
        infoLikesLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
        datePostLabel.text = record.date.toStringLastTime()
        datePostLabel.font = UIFont(name: "Verdana", size: 12)!
        datePostLabel.isEnabled = false
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        
        var topY: CGFloat = topInsets + avatarImageSize + verticalSpacingElements
        
        var width = UIScreen.main.bounds.width - 2 * leftInsets
        var height = width * CGFloat(240) / CGFloat(320)
        
        if record.width > record.height && record.width > 0 {
            width = UIScreen.main.bounds.width - 2 * leftInsets
            height = width * CGFloat(record.height) / CGFloat(record.width)
        } else if record.width <= record.height && record.height > 0 {
            height = UIScreen.main.bounds.width - 2 * leftInsets
            width = UIScreen.main.bounds.width - 2 * leftInsets
        }
        
        let frame = CGRect(x: leftInsets + (UIScreen.main.bounds.width - 2 * leftInsets - width) / 2 , y: topY, width: width, height: height)
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let imageView = UIImageView(frame: frame)
        imageView.image = UIImage(named: "no-video")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4.0
        self.addSubview(imageView)
        
        loadingView = UIView()
        loadingView.tag = 1000
        loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        loadingView.center = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 6
        imageView.addSubview(loadingView)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        activityIndicator.style = .white
        activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
        
        webView = WKWebView(frame: frame, configuration: configuration)
        webView.navigationDelegate = self
        webView.backgroundColor = vkSingleton.shared.backColor
        webView.layer.backgroundColor = vkSingleton.shared.backColor.cgColor
        webView.layer.cornerRadius = 4
        webView.clipsToBounds = true
        webView.isHidden = true
        webView.isOpaque = false
        self.addSubview(webView)
        
        if record.player.contains("youtube"), let str = record.player.components(separatedBy: "?").first, let newURL = URL(string: str) {
        
            webView.loadHTMLString(embedVideoHtmlYoutube(videoID: newURL.lastPathComponent, autoplay: autoplay, playsinline: 1, muted: false), baseURL: nil)
            autoplay = 0
    
        } else if let url = URL(string: "\(record.player)&enablejsapi=1&&playsinline=0&autoplay=0") {
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
            webView.load(request)
            autoplay = 0
        }
        
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
        let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
        durationLabel.frame = CGRect(x: UIScreen.main.bounds.width - leftInsets - durationLabelWidth, y: topY, width: durationLabelWidth, height: viewsLabelHeight)
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
        
        let titleColor = vkSingleton.shared.secondaryLabelColor
        let tintColor = vkSingleton.shared.secondaryLabelColor
        
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
            repostsButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
            repostsButton.imageView?.tintColor = vkSingleton.shared.likeColor
        }
        
        self.addSubview(repostsButton)
        
        if record.canComment == 1 || record.countComments > 0 {
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
            } else if AppConfig.shared.darkMode {
                infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
            } else {
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
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
            } else if AppConfig.shared.darkMode {
                infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
            } else {
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
                infoAvatar2.layer.borderColor = UIColor.white.cgColor
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
            } else if AppConfig.shared.darkMode {
                infoAvatar1.layer.borderColor = vkSingleton.shared.backColor.cgColor
                infoAvatar2.layer.borderColor = vkSingleton.shared.backColor.cgColor
                infoAvatar3.layer.borderColor = vkSingleton.shared.backColor.cgColor
            } else {
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
                infoAvatar2.layer.borderColor = UIColor.white.cgColor
                infoAvatar3.layer.borderColor = UIColor.white.cgColor
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
        
        var titleColor = vkSingleton.shared.secondaryLabelColor
        var tintColor = vkSingleton.shared.secondaryLabelColor
        
        if record.userLikes == 1 {
            titleColor = vkSingleton.shared.likeColor
            tintColor = vkSingleton.shared.likeColor
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
        
        var widthVideo = UIScreen.main.bounds.width - 2 * leftInsets
        var heightVideo = widthVideo * CGFloat(240) / CGFloat(320)
        
        if record.width > record.height && record.width > 0 {
            widthVideo = UIScreen.main.bounds.width - 2 * leftInsets
            heightVideo = widthVideo * CGFloat(record.height) / CGFloat(record.width)
        } else if record.width <= record.height && record.height > 0 {
            heightVideo = UIScreen.main.bounds.width - 2 * leftInsets
            widthVideo = UIScreen.main.bounds.width - 2 * leftInsets
        }
        
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

extension VideoCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        activityIndicator.stopAnimating()
        loadingView.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
        activityIndicator.stopAnimating()
        loadingView.removeFromSuperview()
    }
}

extension UITableViewCell {
    
    func embedVideoHtml(videoURL: String, autoplay: Int, playsinline: Int, muted: Bool) -> String {
        
        var parameters = ""
        if muted { parameters = "\(parameters) muted" }
        if autoplay == 1 { parameters = "\(parameters) autoplay" }
        if playsinline == 1 { parameters = "\(parameters) playsinline" }
        
        print("<html><body style='margin:0px;padding:0px;'><iframe id='playerId' type='text/html' width='100%' height='100%' src='\(videoURL)&enablejsapi=1&&playsinline=\(playsinline)&autoplay=\(autoplay)' frameborder='0'></body></html>")
        
        if muted {
            return """
            <html><body style='margin:0px;padding:0px;'><iframe id='playerId' type='text/html' width='100%' height='100%' src='\(videoURL)&enablejsapi=1&&playsinline=\(playsinline)&autoplay=\(autoplay)' frameborder='0'></body></html>
            """
        }
        
        return """
        <html><body style='margin:0px;padding:0px;'><iframe id='playerId' type='text/html' width='100%' height='100%' src='\(videoURL)&enablejsapi=1&playsinline=\(playsinline)&autoplay=\(autoplay)' frameborder='0'></body></html>
        """
    }
    
    func embedVideoHtmlYoutube(videoID: String, autoplay: Int, playsinline: Int, muted: Bool) -> String {
        
        var playString = ""
        if autoplay == 1 { playString = "a.target.playVideo();" }
        
        if muted {
            return """
            <html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.mute();\(playString)}</script><iframe id='playerId' type='text/html' width='100%' height='100%' src='http://www.youtube.com/embed/\(videoID)?enablejsapi=1&rel=0&&playsinline=\(playsinline)&autoplay=\(autoplay)&modestbranding=1&autohide=1&html5=1' frameborder='0'></body></html>
            """
        }
        
        return """
        <html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){\(playString)}</script><iframe id='playerId' type='text/html' width='100%' height='100%' src='http://www.youtube.com/embed/\(videoID)?enablejsapi=1&rel=0&&playsinline=\(playsinline)&autoplay=\(autoplay)' frameborder='0'></body></html>
        """
    }
}
