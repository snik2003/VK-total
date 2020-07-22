//
//  Record2Cell.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import FLAnimatedImage
import WebKit

class Record2Cell: UITableViewCell {
    
    var delegate: UIViewController!
    
    var viewsButton = UIButton()
    var repostsButton = UIButton()
    var commentsButton = UIButton()
    var likesButton = UIButton()
    
    var infoAvatar1 = UIImageView()
    var infoAvatar2 = UIImageView()
    var infoAvatar3 = UIImageView()
    var infoLikesLabel = UILabel()
    
    var musicTitle10 = UILabel()
    var musicTitle9 = UILabel()
    var musicTitle8 = UILabel()
    var musicTitle7 = UILabel()
    var musicTitle6 = UILabel()
    var musicTitle5 = UILabel()
    var musicTitle4 = UILabel()
    var musicTitle3 = UILabel()
    var musicTitle2 = UILabel()
    var musicTitle1 = UILabel()
    
    var musicArtist10 = UILabel()
    var musicArtist9 = UILabel()
    var musicArtist8 = UILabel()
    var musicArtist7 = UILabel()
    var musicArtist6 = UILabel()
    var musicArtist5 = UILabel()
    var musicArtist4 = UILabel()
    var musicArtist3 = UILabel()
    var musicArtist2 = UILabel()
    var musicArtist1 = UILabel()
    
    var musicImage10 = UIImageView()
    var musicImage9 = UIImageView()
    var musicImage8 = UIImageView()
    var musicImage7 = UIImageView()
    var musicImage6 = UIImageView()
    var musicImage5 = UIImageView()
    var musicImage4 = UIImageView()
    var musicImage3 = UIImageView()
    var musicImage2 = UIImageView()
    var musicImage1 = UIImageView()
    
    var linkImage = UIImageView()
    var linkLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    var imageView10 = UIImageView()
    var imageView9 = UIImageView()
    var imageView8 = UIImageView()
    var imageView7 = UIImageView()
    var imageView6 = UIImageView()
    var imageView5 = UIImageView()
    var imageView4 = UIImageView()
    var imageView3 = UIImageView()
    var imageView2 = UIImageView()
    var imageView1 = UIImageView()
    
    var repostDateLabel = UILabel()
    var repostNameLabel = UILabel()
    var signerLabel = UILabel()
    var repostAvatarImageView = UIImageView()
    
    let postTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let repostTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    var avatarImageView = UIImageView()
    
    var nameLabel = UILabel()
    var datePostLabel = UILabel()
    var onlyFriendsLabel = UILabel()
    
    var answerLabels: [UILabel] = []
    var rateLabels: [UILabel] = []
    var totalLabel = UILabel()
    
    var poll: Poll!
    var videos: [Videos] = []
    
    var webView: WKWebView!
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var position: CGPoint = CGPoint.zero
    
    
    let avatarImageSize: CGFloat = 60.0
    let repostAvatarImageSize: CGFloat = 44.0
    
    let textFont: UIFont = UIFont(name: "Verdana", size: 15.0)!
    let linkFont: UIFont = UIFont(name: "Verdana", size: 11.0)!
    
    let audioImageSize: CGFloat = 30.0
    let linkImageSize: CGFloat = 100.0
    let topLinkInsets: CGFloat = 5.0
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    let topNameLabelInsets: CGFloat = 20.0
    let nameLabelHeight: CGFloat = 21.0
    
    var dateLabelHeight: CGFloat = 18.0
    
    let verticalSpacingElements: CGFloat = 5.0
    
    let infoPanelHeight: CGFloat = 30.0
    let infoAvatarHeight: CGFloat = 28.0
    let infoAvatarTrailing: CGFloat = -5.0
    
    let likesButtonWight: CGFloat = 80.0
    let likesButtonHeight: CGFloat = 40.0
    
    let signerLabelHeight: CGFloat = 22.0
    let signerFont = UIFont.boldSystemFont(ofSize: 15)
    
    let qLabelFont = UIFont(name: "Verdana-Bold", size: 13)!
    let aLabelFont = UIFont(name: "Verdana", size: 12)!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
    }
    
    func configureCell(record: Record, profiles: [RecordProfiles], groups: [RecordGroups], likes: [Likes], indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell, viewController: UIViewController) -> CGFloat {
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
            if subview is UIImageView || subview is UILabel || subview is UIButton || subview is WKWebView {
                subview.removeFromSuperview()
            }
        }
        
        answerLabels.removeAll(keepingCapacity: false)
        rateLabels.removeAll(keepingCapacity: false)
        
        var url = ""
        var name = ""
        
        if record.fromID > 0 {
            let users = profiles.filter( { $0.uid == record.fromID } )
            if users.count > 0 {
                url = users[0].photoURL
                name = "\(users[0].firstName) \(users[0].lastName)"
                if record.isPinned == 1 {
                    name = "📌 \(users[0].firstName) \(users[0].lastName)"
                }
                if record.postType == "postpone" {
                    name = "⏱ \(users[0].firstName) \(users[0].lastName)"
                }
            }
        } else {
            let groups = groups.filter( { $0.gid == abs(record.fromID) } )
            if groups.count > 0 {
                url = groups[0].photoURL
                name = groups[0].name
                if record.isPinned == 1 {
                    name = "📌 \(groups[0].name)"
                }
                if record.postType == "postpone" {
                    name = "⏱ \(groups[0].name)"
                }
            }
        }
        
        avatarImageView.image = UIImage(named: "no-photo")
        var getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        var setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImageView, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImageView.layer.cornerRadius = 29
            self.avatarImageView.clipsToBounds = true
        }
        
        nameLabel.textColor = vkSingleton.shared.labelColor
        repostNameLabel.textColor = vkSingleton.shared.labelColor
        datePostLabel.textColor = vkSingleton.shared.secondaryLabelColor
        repostDateLabel.textColor = vkSingleton.shared.secondaryLabelColor
        postTextLabel.textColor = vkSingleton.shared.labelColor
        repostTextLabel.textColor = vkSingleton.shared.labelColor
        infoLikesLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
    
        if record.friendsOnly == 1 {
            onlyFriendsLabel.text = "Только для друзей"
            onlyFriendsLabel.numberOfLines = 1
            onlyFriendsLabel.textAlignment = .right
            onlyFriendsLabel.font = UIFont(name: "Verdana", size: 12)!
            onlyFriendsLabel.textColor = UIColor.systemRed
            onlyFriendsLabel.isEnabled = true
            onlyFriendsLabel.frame = CGRect(x: 2 * leftInsets + avatarImageSize, y: 5, width: self.bounds.width - 3 * leftInsets - avatarImageSize, height: 15)
            self.addSubview(onlyFriendsLabel)
        }
        
        datePostLabel.text = record.date.toStringLastTime()
        if record.postSource != "" {
            datePostLabel.setSourceOfRecord(text: " \(datePostLabel.text!)", source: record.postSource, delegate: viewController)
        }
        dateLabelHeight = 18
        datePostLabel.numberOfLines = 1
        datePostLabel.contentMode = .center
        datePostLabel.font = UIFont(name: "Verdana", size: 12)!
        datePostLabel.isEnabled = false
        
        postTextLabel.text = record.text
        postTextLabel.font = textFont
        postTextLabel.numberOfLines = 0
        postTextLabel.lineBreakMode = .byWordWrapping
        postTextLabel.prepareTextForPublish2(viewController)
        
        repostTextLabel.text = ""
        repostTextLabel.font = textFont
        repostTextLabel.numberOfLines = 0
        
        if record.repostOwnerID != 0 {
            if record.repostOwnerID > 0 {
                let users = profiles.filter( { $0.uid == record.repostOwnerID } )
                if users.count > 0 {
                    url = users[0].photoURL
                    name = "\(users[0].firstName) \(users[0].lastName)"
                }
            } else {
                let groups = groups.filter( { $0.gid == abs(record.repostOwnerID) } )
                if groups.count > 0 {
                    url = groups[0].photoURL
                    name = groups[0].name
                }
            }
            
            repostAvatarImageView.image = UIImage(named: "no-photo")
            getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: repostAvatarImageView, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.repostAvatarImageView.layer.cornerRadius = 21
                self.repostAvatarImageView.clipsToBounds = true
            }
            
            repostNameLabel.text = name
            repostDateLabel.text = record.repostDate.toStringLastTime()
            repostNameLabel.adjustsFontSizeToFitWidth = true
            repostNameLabel.minimumScaleFactor = 0.5
            
            repostNameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
            repostDateLabel.font = UIFont(name: "Verdana", size: 12)!
            repostDateLabel.isEnabled = false
            
            repostTextLabel.text = record.repostText
            repostTextLabel.lineBreakMode = .byWordWrapping
            repostTextLabel.prepareTextForPublish2(viewController)
            
            repostAvatarImageView.isHidden = false
            repostNameLabel.isHidden = false
            repostDateLabel.isHidden = false
            repostTextLabel.isHidden = false
        } else {
            repostAvatarImageView.isHidden = true
            repostNameLabel.isHidden = true
            repostDateLabel.isHidden = true
            repostTextLabel.isHidden = true
        }
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        textLabelFrame()
        repostAvatarImageViewFrame()
        repostNameLabelFrame()
        repostDateLabelFrame()
        repostTextLabelFrame()
        
        
        var topY: CGFloat = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + 2 * verticalSpacingElements
        
        if record.repostOwnerID != 0 {
            topY = topY + repostAvatarImageSize + verticalSpacingElements + repostTextLabel.frame.height + 1 + 2 * verticalSpacingElements
        }
        
        var photos: [Photos] = []
        let maxWidth = UIScreen.main.bounds.width - 20
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                let photo = Photos(json: JSON.null)
                photo.width = record.photoWidth[index]
                photo.height = record.photoHeight[index]
                photo.text = record.photoText[index]
                photo.xxbigPhotoURL = record.photoURL[index]
                photo.xbigPhotoURL = record.photoURL[index]
                photo.bigPhotoURL = record.photoURL[index]
                photo.smallPhotoURL = record.photoURL[index]
                photo.pid = "\(record.photoID[index])"
                photo.uid = "\(record.photoOwnerID[index])"
                photo.ownerID = "\(record.photoOwnerID[index])"
                photo.createdTime = record.date
                photos.append(photo)
            }
        }
        
        let aView = AttachmentsView()
        aView.backgroundColor = .clear
        aView.tag = 100
        aView.delegate = self.delegate
        aView.photos = photos
        let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: false)
        aView.frame = CGRect(x: 10, y: topY, width: maxWidth, height: aHeight)
        self.addSubview(aView)
        
        topY += aHeight
        
        topY = setImageView(0, topY, record, cell, indexPath, imageView1, tableView)
        topY = setImageView(1, topY, record, cell, indexPath, imageView2, tableView)
        topY = setImageView(2, topY, record, cell, indexPath, imageView3, tableView)
        topY = setImageView(3, topY, record, cell, indexPath, imageView4, tableView)
        topY = setImageView(4, topY, record, cell, indexPath, imageView5, tableView)
        topY = setImageView(5, topY, record, cell, indexPath, imageView6, tableView)
        topY = setImageView(6, topY, record, cell, indexPath, imageView7, tableView)
        topY = setImageView(7, topY, record, cell, indexPath, imageView8, tableView)
        topY = setImageView(8, topY, record, cell, indexPath, imageView9, tableView)
        topY = setImageView(9, topY, record, cell, indexPath, imageView10, tableView)
        
        for index in 0...9 {
            if record.mediaType[index] == "link" {
                topY = setLinkLabel(index, topY, record, cell, indexPath, linkImage, linkLabel, tableView, viewController)
            }
        }
        
        topY = setAudioLabel(0, topY, record, cell, indexPath, musicImage1, musicTitle1, musicArtist1, tableView)
        topY = setAudioLabel(1, topY, record, cell, indexPath, musicImage2, musicTitle2, musicArtist2, tableView)
        topY = setAudioLabel(2, topY, record, cell, indexPath, musicImage3, musicTitle3, musicArtist3, tableView)
        topY = setAudioLabel(3, topY, record, cell, indexPath, musicImage4, musicTitle4, musicArtist4, tableView)
        topY = setAudioLabel(4, topY, record, cell, indexPath, musicImage5, musicTitle5, musicArtist5, tableView)
        topY = setAudioLabel(5, topY, record, cell, indexPath, musicImage6, musicTitle6, musicArtist6, tableView)
        topY = setAudioLabel(6, topY, record, cell, indexPath, musicImage7, musicTitle7, musicArtist7, tableView)
        topY = setAudioLabel(7, topY, record, cell, indexPath, musicImage8, musicTitle8, musicArtist8, tableView)
        topY = setAudioLabel(8, topY, record, cell, indexPath, musicImage9, musicTitle9, musicArtist9, tableView)
        topY = setAudioLabel(9, topY, record, cell, indexPath, musicImage10, musicTitle10, musicArtist10, tableView)
        
        for index in 0...9 {
            if record.mediaType[index] == "poll" {
                if let poll = record.poll {
                    self.poll = poll
                    topY = configurePoll(poll, topY: topY)
                }
            }
        }
        
        if record.signerID != 0 {
            let users = profiles.filter({ $0.uid == record.signerID })
            if users.count > 0 {
                signerLabel.text = "\(users[0].firstName) \(users[0].lastName)"
                signerLabel.font = signerFont
                signerLabel.textAlignment = .right
                signerLabel.contentMode = .top
                signerLabel.textColor = signerLabel.tintColor
                signerLabel.frame = CGRect(x: leftInsets, y: topY, width: self.bounds.width - 2 * leftInsets, height: signerLabelHeight)
                self.addSubview(signerLabel)
                topY += signerLabelHeight
            }
        }
        
        if record.postType != "postpone" {
            configureInfoPanel(record, likes, topY, indexPath, cell, tableView)
            topY = topY + infoPanelHeight
        
            let titleColor = vkSingleton.shared.secondaryLabelColor
            let tintColor = vkSingleton.shared.secondaryLabelColor
            
            likesButton.frame = CGRect(x: leftInsets/2, y: topY, width: likesButtonWight, height: likesButtonHeight)
            likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            likesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            
            
            setLikesButton(record: record)
            
            self.addSubview(likesButton)
            
            repostsButton.frame = CGRect(x: likesButton.frame.maxX + 10, y: topY, width: likesButtonWight, height: likesButtonHeight)
            repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            
            repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.normal)
            repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.selected)
            repostsButton.setImage(UIImage(named: "repost3"), for: .normal)
            repostsButton.imageView?.tintColor = tintColor
            repostsButton.setTitleColor(titleColor, for: .normal)
            if record.userPeposted == 1 {
                repostsButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
                repostsButton.imageView?.tintColor = vkSingleton.shared.likeColor
            }
            
            self.addSubview(repostsButton)
            
            
            viewsButton.frame = CGRect(x: bounds.size.width - likesButtonWight - leftInsets/2, y: topY, width: likesButtonWight, height: likesButtonHeight)
            viewsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            viewsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            
            viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.normal)
            viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.selected)
            viewsButton.setImage(UIImage(named: "views"), for: .normal)
            viewsButton.imageView?.tintColor = tintColor
            viewsButton.setTitleColor(titleColor, for: .normal)
            viewsButton.isUserInteractionEnabled = false
            
            self.addSubview(viewsButton)
            
            if record.canComment == 1 || record.countComments > 0 {
                commentsButton.frame = CGRect(x: viewsButton.frame.minX - likesButtonWight, y: topY, width: likesButtonWight, height: likesButtonHeight)
                commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
                commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
                commentsButton.setImage(UIImage(named: "message2"), for: .normal)
                
                commentsButton.setTitleColor(commentsButton.tintColor.withAlphaComponent(0.8), for: .normal)
                commentsButton.imageView?.tintColor = commentsButton.tintColor.withAlphaComponent(0.8)
                
                commentsButton.setTitle("\(record.countComments)", for: .normal)
                commentsButton.setTitle("\(record.countComments)", for: .selected)
                
                commentsButton.isUserInteractionEnabled = false
                self.addSubview(commentsButton)
            }
            
            topY = topY + likesButtonHeight
        }
        
        return topY
    }
    
    func configurePoll(_ poll: Poll, topY: CGFloat) -> CGFloat {
        
        let view = UIView()
        view.tag = 100
        var viewY: CGFloat = 5
        
        let qLabel = UILabel()
        qLabel.font = qLabelFont
        qLabel.text = "Опрос: \(poll.question)"
        qLabel.textAlignment = .center
        qLabel.backgroundColor = vkSingleton.shared.mainColor
        qLabel.textColor = UIColor.white
        qLabel.numberOfLines = 0
        
        let qLabelSize = getPollLabelSize(text: "Опрос: \(poll.question)", font: qLabelFont)
        qLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets, height: qLabelSize.height + 5)
        view.addSubview(qLabel)
        
        if poll.anonymous == 1 {
            let anonLabel = UILabel()
            anonLabel.text = "Анонимный опрос"
            anonLabel.textAlignment = .right
            anonLabel.isEnabled = false
            anonLabel.font = UIFont(name: "Verdana", size: 10)!
            anonLabel.frame = CGRect(x: 2 * leftInsets, y: viewY + qLabelSize.height + 5, width: bounds.width - 4 * leftInsets, height: 15)
            view.addSubview(anonLabel)
        }
        viewY += qLabelSize.height + 25
        
        
        for index in 0...poll.answers.count-1 {
            let aLabel = UILabel()
            aLabel.font = aLabelFont
            aLabel.text = "\(index+1). \(poll.answers[index].text)"
            aLabel.textColor = .white
            aLabel.numberOfLines = 0
            aLabel.tag = index
            
            let aLabelSize = getPollLabelSize(text: "\(index+1). \(poll.answers[index].text)", font: aLabelFont)
            aLabel.frame = CGRect(x: 5, y: viewY, width: aLabelSize.width, height: aLabelSize.height + 5)
            view.addSubview(aLabel)
            
            viewY += aLabelSize.height
            
            let rLabel = UILabel()
            rLabel.text = ""
            rLabel.textAlignment = .right
            rLabel.textColor = UIColor.clear
            rLabel.font = UIFont(name: "Verdana-Bold", size: 10)!
            rLabel.frame = CGRect(x: 5, y: viewY+5, width: aLabelSize.width, height: 15)
            view.addSubview(rLabel)
            rateLabels.append(rLabel)
            
            
            viewY += 25
            answerLabels.append(aLabel)
        }
        
        totalLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        totalLabel.textAlignment = .right
        totalLabel.textColor = vkSingleton.shared.mainColor
        totalLabel.isEnabled = true
        totalLabel.numberOfLines = 1
        
        totalLabel.frame = CGRect(x: 2 * leftInsets, y: viewY, width: bounds.width - 4 * leftInsets, height: 20)
        view.addSubview(totalLabel)
        viewY += 20
        
        view.frame = CGRect(x: 5, y: topY, width: bounds.width - 10, height: viewY)
        view.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        view.layer.borderWidth = 1.0
        self.addSubview(view)
        
        updatePoll()
        
        return topY + viewY + verticalSpacingElements
    }
    
    func updatePoll() {
        if answerLabels.count > 0 {
            for index in 0...answerLabels.count-1 {
                if self.poll.answerID != 0 {
                    answerLabels[index].backgroundColor = vkSingleton.shared.mainColor.withAlphaComponent(0.4)
                    
                    if self.poll.answerID == self.poll.answers[index].id {
                        answerLabels[index].backgroundColor = UIColor.purple.withAlphaComponent(0.75)
                        answerLabels[index].textColor = .white
                        answerLabels[index].isEnabled = true
                    } else {
                        answerLabels[index].textColor = .white
                    }
                } else {
                    answerLabels[index].backgroundColor = vkSingleton.shared.mainColor
                    answerLabels[index].textColor = .white
                }
            }
        }
        
        if rateLabels.count > 0 {
            for index in 0...rateLabels.count-1 {
                rateLabels[index].text = "\(self.poll.answers[index].votes.rateAdder()) (\(self.poll.answers[index].rate) %)"
                
                if self.poll.answerID != 0 {
                    rateLabels[index].textColor = vkSingleton.shared.secondaryLabelColor
                } else {
                    rateLabels[index].textColor = UIColor.clear
                }
            }
        }
        
        totalLabel.text = "Всего проголосовало: \(self.poll.votes)"
    }
    
    func configureInfoPanel(_ record: Record, _ likes: [Likes], _ topY: CGFloat, _ indexPath: IndexPath, _ cell: UITableViewCell, _ tableView: UITableView) {
        
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
    
    func setLikesButton(record: Record) {
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
    
    func setImageView(_ index: Int, _ topY: CGFloat, _ record: Record, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ tableView: UITableView) -> CGFloat {
        
        var imageHeight: CGFloat = 0.0
        var imageWidth: CGFloat = 0.0
        var topNew = topY
        
        let subviews = imageView.subviews
        for subview in subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
            if subview is UILabel {
                subview.removeFromSuperview()
            }
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        imageView.frame = CGRect(x: 5.0, y: topY, width: imageWidth, height: 0.0)
        imageView.backgroundColor = vkSingleton.shared.backColor
        imageView.image = nil
        
        self.addSubview(imageView)
        
        if record.mediaType[index] == "doc" {
            if record.photoWidth[index] != 0 {
                imageWidth = UIScreen.main.bounds.width - 20.0
                imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
            }
            
            if imageHeight > 4 {
                imageView.frame = CGRect(x: 10.0, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    imageView.clipsToBounds = true
                }
                
                if record.photoText[index] == "gif" {
                    let loadingView = UIView()
                    loadingView.tag = 1000
                    loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    loadingView.center = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
                    loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    loadingView.clipsToBounds = true
                    loadingView.layer.cornerRadius = 6
                    imageView.addSubview(loadingView)
                    
                    let activityIndicator = UIActivityIndicatorView()
                    activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    activityIndicator.style = .white
                    activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                    activityIndicator.startAnimating()
                    loadingView.addSubview(activityIndicator)
                    
                    let gifSizeLabel = UILabel()
                    gifSizeLabel.text = "GIF: \(record.size[index].getFileSizeToString())"
                    gifSizeLabel.numberOfLines = 1
                    gifSizeLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                    gifSizeLabel.textAlignment = .center
                    gifSizeLabel.contentMode = .center
                    gifSizeLabel.textColor = .white
                    gifSizeLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    gifSizeLabel.layer.cornerRadius = 4
                    gifSizeLabel.clipsToBounds = true
                    let gifSizeWidth = gifSizeLabel.getTextWidth(maxWidth: 200)
                    gifSizeLabel.frame = CGRect(x: imageWidth - 10 - gifSizeWidth, y: imageHeight - 4 - 10 - 20, width: gifSizeWidth, height: 20)
                    imageView.addSubview(gifSizeLabel)
                    
                    if record.videoURL[index] != "" && record.size[index] < 150_000_000 {
                        queue.addOperation {
                            let url = URL(string: record.videoURL[index])
                            if let data = try? Data(contentsOf: url!) {
                                let setAnimatedImageToRow = SetAnimatedImageToRow.init(data: data, imageView: imageView, cell: cell, indexPath: indexPath, tableView: tableView)
                                OperationQueue.main.addOperation(setAnimatedImageToRow)
                                OperationQueue.main.addOperation {
                                    imageView.bringSubviewToFront(gifSizeLabel)
                                    activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                }
                            }
                        }
                    }
                }
                topNew = topY + imageHeight + 4.0
                
                self.addSubview(imageView)
            }
        }
        
        if record.mediaType[index] == "video" {
            if record.photoURL[index] != "" {
                if record.photoWidth[index] > record.photoHeight[index] && record.photoWidth[index] > 0 {
                    imageWidth = UIScreen.main.bounds.width - 20.0
                    imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                } else if record.photoWidth[index] <= record.photoHeight[index] && record.photoHeight[index] > 0 {
                    imageHeight = UIScreen.main.bounds.width - 20.0
                    imageWidth = UIScreen.main.bounds.width - 20.0
                } else {
                    imageWidth = UIScreen.main.bounds.width - 20.0
                    imageHeight = imageWidth * 240.0 / 320.0
                }
            }
            
            if imageHeight > 0 {
                imageView.frame = CGRect(x: 10 + (UIScreen.main.bounds.width - 20.0 - imageWidth) / 2, y: topY + 2.0, width: imageWidth, height: imageHeight)
                
                imageView.image = UIImage(named: "no-video")
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 4.0
                
                let loadingView = UIView()
                loadingView.tag = 1000
                loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                loadingView.center = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
                loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                loadingView.clipsToBounds = true
                loadingView.layer.cornerRadius = 6
                imageView.addSubview(loadingView)
                
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                activityIndicator.style = .white
                activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                activityIndicator.startAnimating()
                loadingView.addSubview(activityIndicator)
                
                let viewsLabel = UILabel()
                viewsLabel.text = "Просмотров: \(record.videoViews[index])"
                viewsLabel.numberOfLines = 1
                viewsLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                viewsLabel.textAlignment = .left
                let viewsLabelWidth = viewsLabel.getTextWidth(maxWidth: 300)
                viewsLabel.frame = CGRect(x: 15, y: topY + imageHeight, width: viewsLabelWidth, height: 20)
                self.addSubview(viewsLabel)
                
                let durationLabel = UILabel()
                if record.size[index] == 0 {
                    durationLabel.text = "LIVE"
                } else {
                    durationLabel.text = record.size[index].getVideoDurationToString()
                }
                durationLabel.numberOfLines = 1
                durationLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                durationLabel.textAlignment = .right
                let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
                durationLabel.frame = CGRect(x: UIScreen.main.bounds.width - 20 - durationLabelWidth + 5, y: topY + imageHeight, width: durationLabelWidth, height: 20)
                self.addSubview(durationLabel)
                
                if record.size[index] == 0 {
                    durationLabel.textColor = .red
                    durationLabel.alpha = 1.0
                } else {
                    durationLabel.textColor = vkSingleton.shared.secondaryLabelColor
                    durationLabel.alpha = 1.0
                }
                
                viewsLabel.textColor = vkSingleton.shared.secondaryLabelColor
                viewsLabel.alpha = 1.0
                
                let titleLabel = UILabel()
                titleLabel.text = record.photoText[index]
                titleLabel.textAlignment = .center
                titleLabel.font = UIFont(name: "Verdana", size: 12.0)!
                titleLabel.numberOfLines = 2
                titleLabel.textColor = titleLabel.tintColor
                let titleLabelHeight = fmin(titleLabel.getTextSize(maxWidth: UIScreen.main.bounds.width - 20).height, 30)
                titleLabel.frame = CGRect(x: 15, y: topY + imageHeight + 20, width: UIScreen.main.bounds.width - 20 - 15, height: titleLabelHeight)
                self.addSubview(titleLabel)
                
                let videoTap = UITapGestureRecognizer()
                videoTap.add {
                    self.delegate.openVideoController(ownerID: "\(record.photoOwnerID[index])", vid: "\(record.photoID[index])", accessKey: record.photoAccessKey[index], title: "Видеозапись", scrollToComment: false)
                }
                titleLabel.isUserInteractionEnabled = true
                titleLabel.addGestureRecognizer(videoTap)
                
                if let video = videos.filter({ $0.id == record.photoID[index] && $0.ownerID == record.photoOwnerID[index] }).first {
                    
                    let configuration = WKWebViewConfiguration()
                    configuration.allowsInlineMediaPlayback = true
                    configuration.mediaTypesRequiringUserActionForPlayback = []
                    let frame = CGRect(x: 10, y: topY + 2.0, width: imageWidth, height: imageHeight)
                    
                    webView = WKWebView(frame: frame, configuration: configuration)
                    webView.navigationDelegate = self
                    webView.backgroundColor = vkSingleton.shared.backColor
                    webView.layer.backgroundColor = vkSingleton.shared.backColor.cgColor
                    webView.layer.cornerRadius = 4
                    webView.clipsToBounds = true
                    webView.isHidden = true
                    webView.isOpaque = false
                    self.addSubview(webView)
                    
                    if video.platform.contains("YouTube"), let str = video.player.components(separatedBy: "?").first, let newURL = URL(string: str) {
                        webView.loadHTMLString(embedVideoHtmlYoutube(videoID: newURL.lastPathComponent, autoplay: 1, playsinline: 1, muted: true), baseURL: nil)
                    } else if let url = URL(string: "\(video.player)&enablejsapi=1&&playsinline=0&autoplay=0") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                        webView.load(request)
                    }
                } else {
                    let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        activityIndicator.stopAnimating()
                        loadingView.removeFromSuperview()
                    }
                    
                    let videoImage = UIImageView()
                    videoImage.image = UIImage(named: "video")
                    imageView.addSubview(videoImage)
                    videoImage.frame = CGRect(x: imageWidth / 2 - 30, y: (imageHeight) / 2 - 30, width: 60, height: 60)
                    
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(videoTap)
                }
                
                topNew = topY + imageHeight + 30.0 + titleLabelHeight
            }
        }
        
        return topNew
    }
    
    func setLinkLabel(_ index: Int, _ topY: CGFloat, _ record: Record, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ linkLabel: UILabel, _ tableView: UITableView, _ viewController: UIViewController) -> CGFloat {
        
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        linkLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
        
        if record.photoURL[index] != "" {
            if record.photoWidth[index] > record.photoHeight[index] {
                imageWidth = linkImageSize
                imageHeight = linkImageSize * CGFloat(240) / CGFloat(320)
                
                if imageHeight < linkImageSize * 0.75 {
                    imageHeight = linkImageSize * 0.75
                }
            } else if record.photoWidth[index] < record.photoHeight[index] {
                imageWidth = linkImageSize * CGFloat(240) / CGFloat(320)
                imageHeight = linkImageSize
            } else {
                imageWidth = linkImageSize
                imageHeight = linkImageSize
            }
            
            let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    imageView.image = getCacheImage.outputImage
                }
            }
            queue.addOperation(getCacheImage)
        } else if record.linkURL[index].containsIgnoringCase(find: "itunes.apple.com") {
            imageWidth = linkImageSize * 0.7
            imageHeight = linkImageSize * 0.7
            imageView.image = UIImage(named: "itunes")
        } else {
            imageWidth = linkImageSize * 0.8
            imageHeight = linkImageSize * 0.8
            imageView.image = UIImage(named: "url")
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = linkLabel.tintColor.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.clipsToBounds = true
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: imageWidth, height: imageHeight)
        
        self.addSubview(imageView)
        
        var linkText = record.linkURL[index]
        if record.linkText[index] != "" {
            linkText = "\(record.linkText[index])\n\(record.linkURL[index])"
            if record.linkText[index].length > 100 {
                linkText = "\(record.linkText[index].prefix(100))...\n\(record.linkURL[index])"
            }
        }
        
        linkLabel.text = linkText
        linkLabel.font = linkFont
        linkLabel.adjustsFontSizeToFitWidth = true
        linkLabel.minimumScaleFactor = 0.5
        linkLabel.contentMode = .center
        linkLabel.textAlignment = .center
        linkLabel.sizeToFit()
        linkLabel.numberOfLines = 0
        linkLabel.clipsToBounds = true
        linkLabel.layer.borderColor = linkLabel.tintColor.cgColor
        linkLabel.layer.borderWidth = 0.5
        linkLabel.lineBreakMode = .byWordWrapping
        linkLabel.prepareTextForPublish2(viewController)
        
        linkLabel.frame = CGRect(x: imageWidth + 2 * leftInsets, y: topY + topLinkInsets, width: self.bounds.width - imageWidth - 3 * leftInsets, height: imageHeight)
        
        self.addSubview(linkLabel)
        
        return topY + 2 * topLinkInsets + imageHeight
    }
    
    func setAudioLabel(_ index: Int, _ topY: CGFloat, _ record: Record, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ audioLabel: UILabel, _ audioNameLabel: UILabel, _ tableView: UITableView) -> CGFloat {
        
        var topNew = topY
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: 0.0)
        audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
        audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4 + audioNameLabel.frame.height, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
        
        imageView.image = UIImage(named: "music")
        audioNameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        audioLabel.font = UIFont(name: "Verdana", size: 13)!
        
        if record.mediaType[index] == "audio" {
            if record.audioTitle[index] != "" {
                imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: audioImageSize)
                
                audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                audioNameLabel.text = record.audioArtist[index]
                audioNameLabel.textColor = vkSingleton.shared.labelColor
                
                audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 20, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                audioLabel.text = record.audioTitle[index]
                audioLabel.textColor = audioLabel.tintColor
                
                imageView.isHidden = false
                audioNameLabel.isHidden = false
                audioLabel.isHidden = false
                
                topNew = topY + 2 * topLinkInsets + audioImageSize
            }
        }
        
        self.addSubview(imageView)
        self.addSubview(audioNameLabel)
        self.addSubview(audioLabel)
        
        return topNew
    }
    
    func avatarImageViewFrame() {
        let avatarImageOrigin = CGPoint(x: leftInsets, y: topInsets)
        
        avatarImageView.frame = CGRect(origin: avatarImageOrigin, size: CGSize(width: avatarImageSize, height: avatarImageSize))
        
        self.addSubview(avatarImageView)
    }
    
    func repostAvatarImageViewFrame() {
        let repostAvatarImageY = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + verticalSpacingElements
        
        let repostAvatarImageOrigin = CGPoint(x: leftInsets, y: repostAvatarImageY)
        
        var height = repostAvatarImageSize
        if repostAvatarImageView.isHidden == true {
            height = 0.0
        }
        repostAvatarImageView.frame = CGRect(origin: repostAvatarImageOrigin, size: CGSize(width: repostAvatarImageSize, height: height))
        
        self.addSubview(repostAvatarImageView)
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
    
    func repostNameLabelFrame() {
        
        let repostNameLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + verticalSpacingElements + 6)
        
        let repostNameLabelWidth = bounds.size.width - repostNameLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostNameLabel.isHidden == true {
            height = 0.0
        }
        
        repostNameLabel.frame = CGRect(origin: repostNameLabelOrigin, size: CGSize(width: repostNameLabelWidth, height: height))
        
        self.addSubview(repostNameLabel)
    }
    
    func repostDateLabelFrame() {
        
        let repostDateLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + verticalSpacingElements + 6 + repostNameLabel.frame.height + 1)
        
        let repostDateLabelWidth = bounds.size.width - repostDateLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostDateLabel.isHidden == true {
            height = 0.0
        }
        
        repostDateLabel.frame = CGRect(origin: repostDateLabelOrigin, size: CGSize(width: repostDateLabelWidth, height: height))
        
        self.addSubview(repostDateLabel)
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getPollLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func textLabelFrame() {
        let textLabelSize = getTextSize(text: postTextLabel.text!, font: textFont)
        
        postTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements, width: textLabelSize.width, height: textLabelSize.height)
        
        self.addSubview(postTextLabel)
    }
    
    func getRepostTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func repostTextLabelFrame() {
        let repostTextLabelSize = getRepostTextSize(text: repostTextLabel.text!, font: textFont)
        
        repostTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements, width: repostTextLabelSize.width, height: repostTextLabelSize.height)
        
        self.addSubview(repostTextLabel)
    }
    
    func getRowHeight(record: Record) -> CGFloat {
        
        let text = record.text.prepareTextForPublic()
        var textHeight = getTextSize(text: text, font: textFont).height
        
        if text == "" {
            textHeight = 5.0
        }
        
        var height: CGFloat = topInsets + avatarImageSize + verticalSpacingElements + textHeight + 2 * verticalSpacingElements
        
        if record.repostOwnerID != 0 {
            let text2 = record.repostText.prepareTextForPublic()
            var textHeight2 = getRepostTextSize(text: text2, font: textFont).height
            
            if text2 == "" {
                textHeight2 = 5.0
            }
            
            height += repostAvatarImageSize + verticalSpacingElements + textHeight2 + 1 + 2 * verticalSpacingElements
        }
        
        var photos: [Photos] = []
        let maxWidth = UIScreen.main.bounds.width - 20
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                let photo = Photos(json: JSON.null)
                photo.width = record.photoWidth[index]
                photo.height = record.photoHeight[index]
                photo.text = record.photoText[index]
                photo.xxbigPhotoURL = record.photoURL[index]
                photo.xbigPhotoURL = record.photoURL[index]
                photo.bigPhotoURL = record.photoURL[index]
                photo.smallPhotoURL = record.photoURL[index]
                photo.pid = "\(record.photoID[index])"
                photo.ownerID = "\(record.photoOwnerID[index])"
                photo.createdTime = record.date
                photos.append(photo)
            }
        }
        
        let aView = AttachmentsView()
        aView.photos = photos
        let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: true)
        height += aHeight
        
        var imageWidth = [CGFloat] (repeating: 0, count: 10)
        var imageHeight = [CGFloat] (repeating: 0, count: 10)
        for index in 0...9 {
            if record.mediaType[index] == "doc" {
                if record.photoWidth[index] != 0 {
                    imageWidth[index] = UIScreen.main.bounds.width - 20
                    imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 4.0
                    }
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    if record.photoWidth[index] > record.photoHeight[index] && record.photoWidth[index] > 0 {
                        imageWidth[index] = UIScreen.main.bounds.width - 20.0
                        imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    } else if record.photoWidth[index] <= record.photoHeight[index] && record.photoHeight[index] > 0 {
                        imageHeight[index] = UIScreen.main.bounds.width - 20.0
                        imageWidth[index] = imageHeight[index] * CGFloat(record.photoWidth[index]) / CGFloat(record.photoHeight[index])
                    } else {
                        imageWidth[index] = UIScreen.main.bounds.width - 20
                        imageHeight[index] = imageWidth[index] * 240.0 / 320.0
                    }
                    
                    if imageHeight[index] > 0 {
                        let titleLabel = UILabel()
                        titleLabel.text = record.photoText[index]
                        titleLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                        let titleLabelHeight = fmin(titleLabel.getTextSize(maxWidth: UIScreen.main.bounds.width - 20 - 15).height, 30)
                        
                        height += imageHeight[index] + 20.0 + titleLabelHeight
                    }
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "link" {
                var imageHeight = linkImageSize
                if record.photoURL[index] != "" {
                    if record.photoWidth[index] > record.photoHeight[index] {
                        imageHeight = linkImageSize * CGFloat(240) / CGFloat(320)
                    }
                } else {
                    imageHeight = linkImageSize * 0.8
                }
                
                height += 2 * topLinkInsets + imageHeight
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "audio" {
                if record.audioTitle[index] != "" {
                    height = height + 2 * topLinkInsets + audioImageSize
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "poll" {
                if let poll = record.poll {
                    let qLabelSize = getPollLabelSize(text: "Опрос: \(poll.question)", font: qLabelFont)
                    var viewY: CGFloat = 5 + qLabelSize.height + 25
                    
                    for ind in 0...poll.answers.count-1 {
                        let aLabelSize = getPollLabelSize(text: "\(ind+1). \(poll.answers[ind].text)", font: aLabelFont)
                        viewY += aLabelSize.height + 25
                    }
                    
                    viewY += 20
                    height += viewY + verticalSpacingElements
                }
            }
        }
        
        if record.signerID != 0 {
            height += signerLabelHeight
        }
        
        if record.postType != "postpone" {
            height = height + infoPanelHeight + likesButtonHeight
        }
        
        height = height + topInsets
        
        return height
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            position = touch.location(in: self)
        }
    }
    
    func getActionOnClickPosition(touch: CGPoint, record: Record) -> String {
        
        var res = "show_record"
        
        if touch.y >= avatarImageView.frame.minY && touch.y < avatarImageView.frame.maxX {
            res = "show_owner"
        }
        
        if record.repostOwnerID != 0 {
            if touch.y >= repostAvatarImageView.frame.minY && touch.y < repostAvatarImageView.frame.maxY {
                res = "show_repost_owner"
            }
            
            if touch.y >= repostTextLabel.frame.minY && touch.y < repostTextLabel.frame.maxY {
                res = "show_repost_record"
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                if index == 0 && touch.y >= imageView1.frame.minY && touch.y < imageView1.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 1 && touch.y >= imageView2.frame.minY && touch.y < imageView2.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 2 && touch.y >= imageView3.frame.minY && touch.y < imageView3.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 3 && touch.y >= imageView4.frame.minY && touch.y < imageView4.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 4 && touch.y >= imageView5.frame.minY && touch.y < imageView5.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 5 && touch.y >= imageView6.frame.minY && touch.y < imageView6.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 6 && touch.y >= imageView7.frame.minY && touch.y < imageView7.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 7 && touch.y >= imageView8.frame.minY && touch.y < imageView8.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 8 && touch.y >= imageView9.frame.minY && touch.y < imageView9.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 9 && touch.y >= imageView10.frame.minY && touch.y < imageView10.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    if index == 0 && touch.y >= imageView1.frame.minY && touch.y < imageView1.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 1 && touch.y >= imageView2.frame.minY && touch.y < imageView2.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 2 && touch.y >= imageView3.frame.minY && touch.y < imageView3.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 3 && touch.y >= imageView4.frame.minY && touch.y < imageView4.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 4 && touch.y >= imageView5.frame.minY && touch.y < imageView5.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 5 && touch.y >= imageView6.frame.minY && touch.y < imageView6.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 6 && touch.y >= imageView7.frame.minY && touch.y < imageView7.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 7 && touch.y >= imageView8.frame.minY && touch.y < imageView8.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 8 && touch.y >= imageView9.frame.minY && touch.y < imageView9.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 9 && touch.y >= imageView10.frame.minY && touch.y < imageView10.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                }
            }
            
            if record.mediaType[index] == "doc" && record.photoText[index] == "gif" {
                if record.videoURL[index] != "" {
                    if index == 0 && touch.y >= imageView1.frame.minY && touch.y < imageView1.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 1 && touch.y >= imageView2.frame.minY && touch.y < imageView2.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 2 && touch.y >= imageView3.frame.minY && touch.y < imageView3.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 3 && touch.y >= imageView4.frame.minY && touch.y < imageView4.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 4 && touch.y >= imageView5.frame.minY && touch.y < imageView5.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 5 && touch.y >= imageView6.frame.minY && touch.y < imageView6.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 6 && touch.y >= imageView7.frame.minY && touch.y < imageView7.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 7 && touch.y >= imageView8.frame.minY && touch.y < imageView8.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 8 && touch.y >= imageView9.frame.minY && touch.y < imageView9.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                    if index == 9 && touch.y >= imageView10.frame.minY && touch.y < imageView10.frame.maxY {
                        res = "show_gif_\(index)"
                        
                    }
                }
            }
            
            if record.mediaType[index] == "audio" {
                if record.audioTitle[index] != "" {
                    if index == 0 && touch.y >= musicArtist1.frame.minY && touch.y < musicTitle1.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 1 && touch.y >= musicArtist2.frame.minY && touch.y < musicTitle2.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 2 && touch.y >= musicArtist3.frame.minY && touch.y < musicTitle3.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 3 && touch.y >= musicArtist4.frame.minY && touch.y < musicTitle4.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 4 && touch.y >= musicArtist5.frame.minY && touch.y < musicTitle5.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 5 && touch.y >= musicArtist6.frame.minY && touch.y < musicTitle6.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 6 && touch.y >= musicArtist7.frame.minY && touch.y < musicTitle7.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 7 && touch.y >= musicArtist8.frame.minY && touch.y < musicTitle8.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 8 && touch.y >= musicArtist9.frame.minY && touch.y < musicTitle9.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 9 && touch.y >= musicArtist10.frame.minY && touch.y < musicTitle10.frame.maxY {
                        res = "show_music_\(index)"
                    }
                }
            }
        }
        
        if record.signerID != 0 {
            if touch.y >= signerLabel.frame.minY && touch.y < signerLabel.frame.maxY {
                res = "show_signer_profile"
            }
        }
        
        if record.countLikes > 0 && touch.y >= infoLikesLabel.frame.minY && touch.y < infoLikesLabel.frame.maxY {
            res = "show_info_likes"
        }
        
        return res
    }
}

extension Int {
    func getFileSizeToString() -> String {
        var res = "\(self)"
        
        if self >= 1_000_000 {
            let size = self / 1_000_000
            res = "\(size)Mb"
        } else if self >= 1_000 {
            let size = self / 1_000
            res = "\(size)Kb"
        } else {
            res = "\(self)b"
        }
        
        return res
    }
    
    func getVideoDurationToString() -> String {
        var res = "00:00"
        
        let dur = self
        let hour = dur / 3600
        let min = (dur % 3600) / 60
        let sec = dur % 60
        
        if hour > 0 {
            res = String(format: "%d:%02d:%02d", hour, min, sec)
        } else {
            res = String(format: "%02d:%02d", min, sec)
        }
        
        return res
    }
}

extension Record2Cell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
    }
}

extension UIImage {
    
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
