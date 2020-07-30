//
//  WallRecordCell2.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SwiftMessages
import SwiftyJSON
import WebKit

class WallRecordCell2: UITableViewCell {
    
    var delegate: UIViewController!
    
    var repostsButton = UIButton()
    var commentsButton = UIButton()
    var likesButton = UIButton()
    var viewsButton = UIButton()
    
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
    var repostAvatarImageView = UIImageView()
    var readMoreButton = UIButton()
    
    let postTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let repostTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    var signerLabel = UILabel()
    
    var avatarImageView = UIImageView()
    
    var nameLabel = UILabel()
    var datePostLabel = UILabel()
    var onlyFriendsLabel = UILabel()
    
    var repostReadMoreButton = UIButton()
    
    var drawCell = true
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var position: CGPoint = CGPoint.zero
    
    var readMoreButtonTapped = false
    var readMoreButtonTapped2 = false
    
    let avatarImageSize: CGFloat = 60.0
    let repostAvatarImageSize: CGFloat = 44.0
    
    let textFont: UIFont = UIFont(name: "Verdana", size: 15.0)!
    let linkFont: UIFont = UIFont(name: "Verdana", size: 12.0)!
    
    let audioImageSize: CGFloat = 30.0
    let linkImageSize: CGFloat = 100.0
    let topLinkInsets: CGFloat = 5.0
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    let topNameLabelInsets: CGFloat = 20.0
    let nameLabelHeight: CGFloat = 21.0
    
    var dateLabelHeight: CGFloat = 18.0
    
    let verticalSpacingElements: CGFloat = 5.0
    
    let readMoreLevel: CGFloat = 190.0
    
    let likesButtonWidth: CGFloat = 80.0
    let repotsButtonWidth: CGFloat = 70.0
    let likesButtonHeight: CGFloat = 40.0
    
    let signerLabelHeight: CGFloat = 22.0
    let signerFont = UIFont.boldSystemFont(ofSize: 15)
    
    let qLabelFont = UIFont(name: "Verdana-Bold", size: 13)!
    let aLabelFont = UIFont(name: "Verdana", size: 12)!
    
    var answerLabels: [UILabel] = []
    var rateLabels: [UILabel] = []
    var votersLabels: [UILabel] = []
    var totalLabel = UILabel()
    var voteButton = UIButton()
    
    var poll: Poll!
    
    var webView: WKWebView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        readMoreButtonFrame()
    }
    
    
    func configureCell(record: Wall, profiles: [WallProfiles], groups: [WallGroups], videos: [Videos], indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell, viewController: UIViewController) -> CGFloat {
        
        var topY: CGFloat = 0
        
        if drawCell {
            self.backgroundColor = vkSingleton.shared.backColor
            
            for subview in self.subviews {
                if subview.tag == 100 {
                    subview.removeFromSuperview()
                }
                if subview is UIImageView || subview is UILabel || subview is UIButton {
                    subview.removeFromSuperview()
                }
                
                if let webView = subview as? WKWebView {
                    webView.removeFromSuperview()
                }
            }
            
            answerLabels.removeAll(keepingCapacity: false)
            rateLabels.removeAll(keepingCapacity: false)
            
            signerLabel.text = ""
            postTextLabel.text = ""
            repostTextLabel.text = ""
        
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
            
            nameLabel.text = name
            nameLabel.textColor = vkSingleton.shared.labelColor
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            
            if record.friendsOnly == 1 {
                onlyFriendsLabel.text = "Только для друзей"
                onlyFriendsLabel.numberOfLines = 1
                onlyFriendsLabel.textAlignment = .right
                onlyFriendsLabel.font = UIFont(name: "Verdana", size: 12)!
                onlyFriendsLabel.textColor = .systemRed
                onlyFriendsLabel.isEnabled = true
                onlyFriendsLabel.frame = CGRect(x: 2 * leftInsets + avatarImageSize, y: 5, width: self.bounds.width - 3 * leftInsets - avatarImageSize, height: 15)
                if drawCell { self.addSubview(onlyFriendsLabel) }
            }
        
        
            datePostLabel.text = record.date.toStringLastTime()
            if record.postSource != "" {
                datePostLabel.setSourceOfRecord(text: " \(datePostLabel.text!)", source: record.postSource, delegate: viewController)
            }
            dateLabelHeight = 18
            datePostLabel.numberOfLines = 1
            datePostLabel.contentMode = .center
            datePostLabel.font = UIFont(name: "Verdana", size: 12)!
            datePostLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            let avatarTap = UITapGestureRecognizer()
            avatarTap.add {
                self.delegate.openProfileController(id: record.fromID, name: name)
            }
            
            let nameTap = UITapGestureRecognizer()
            nameTap.add {
                self.delegate.openProfileController(id: record.fromID, name: name)
            }
            
            let dateTap = UITapGestureRecognizer()
            dateTap.add {
                self.delegate.openProfileController(id: record.fromID, name: name)
            }
            
            avatarImageView.isUserInteractionEnabled = true
            nameLabel.isUserInteractionEnabled = true
            datePostLabel.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(avatarTap)
            nameLabel.addGestureRecognizer(nameTap)
            datePostLabel.addGestureRecognizer(dateTap)
            
            let postTextTap = UITapGestureRecognizer()
            postTextTap.add {
                self.delegate.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: false)
            }
            
            let repostTextTap = UITapGestureRecognizer()
            repostTextTap.add {
                self.delegate.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: false)
            }
            
            postTextLabel.isUserInteractionEnabled = true
            repostTextLabel.isUserInteractionEnabled = true
            postTextLabel.addGestureRecognizer(postTextTap)
            repostTextLabel.addGestureRecognizer(repostTextTap)
            
            readMoreButton.isHidden = true
            repostReadMoreButton.isHidden = true
            
            readMoreButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            readMoreButton.setTitle("Читать полностью", for: .normal)
            readMoreButton.setTitleColor(UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1), for: .normal)
            
            readMoreButton.contentMode = .left
            readMoreButton.contentHorizontalAlignment = .left
            
            repostReadMoreButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            repostReadMoreButton.setTitle("Читать полностью", for: .normal)
            repostReadMoreButton.setTitleColor(UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1) /*UIColor.init(red: 127/255, green: 187/255, blue: 249/255, alpha: 1)*/, for: .normal)
            repostReadMoreButton.contentMode = .left
            repostReadMoreButton.contentHorizontalAlignment = .left
        
        
            if record.readMore1 == 0 {
                readMoreButtonTapped = true
            }
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
                
                repostNameLabel.textColor = vkSingleton.shared.labelColor
                repostDateLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                repostNameLabel.text = name
                repostDateLabel.text = record.repostDate.toStringLastTime()
                repostNameLabel.adjustsFontSizeToFitWidth = true
                repostNameLabel.minimumScaleFactor = 0.5
                
                repostNameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
                repostDateLabel.font = UIFont(name: "Verdana", size: 12)!
                
                if record.readMore2 == 0 {
                    readMoreButtonTapped2 = true
                }
                repostTextLabel.text = record.repostText
                repostTextLabel.lineBreakMode = .byWordWrapping
                repostTextLabel.prepareTextForPublish2(viewController)
                
                repostAvatarImageView.isHidden = false
                repostNameLabel.isHidden = false
                repostDateLabel.isHidden = false
                repostTextLabel.isHidden = false
                
                let avatarRepostTap = UITapGestureRecognizer()
                avatarRepostTap.add {
                    self.delegate.openProfileController(id: record.repostOwnerID, name: name)
                }
                
                let nameRepostTap = UITapGestureRecognizer()
                nameRepostTap.add {
                    self.delegate.openProfileController(id: record.repostOwnerID, name: name)
                }
                
                let dateRepostTap = UITapGestureRecognizer()
                dateRepostTap.add {
                    self.delegate.openProfileController(id: record.repostOwnerID, name: name)
                }
                
                repostAvatarImageView.isUserInteractionEnabled = true
                repostNameLabel.isUserInteractionEnabled = true
                repostDateLabel.isUserInteractionEnabled = true
                repostAvatarImageView.addGestureRecognizer(avatarRepostTap)
                repostNameLabel.addGestureRecognizer(nameRepostTap)
                repostDateLabel.addGestureRecognizer(dateRepostTap)
            } else {
                repostAvatarImageView.isHidden = true
                repostNameLabel.isHidden = true
                repostDateLabel.isHidden = true
                repostTextLabel.isHidden = true
                repostReadMoreButton.isHidden = true
            }
        
            avatarImageViewFrame()
            nameLabelFrame()
            datePostLabelFrame()
            textLabelFrame(readmore: record.readMore1)
            readMoreButtonFrame()
            repostAvatarImageViewFrame()
            repostNameLabelFrame()
            repostDateLabelFrame()
            repostTextLabelFrame(readmore: record.readMore2)
            repostReadMoreButtonFrame()
            
            
            topY = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + 1 + 2 * verticalSpacingElements
            
            if record.repostOwnerID != 0 {
                topY = topY + repostAvatarImageSize + verticalSpacingElements + repostTextLabel.frame.height + repostReadMoreButton.frame.height + 1 + 2 * verticalSpacingElements
            }
        } else {
            postTextLabel.text = record.text
            postTextLabel.font = textFont
            postTextLabel.numberOfLines = 0
            postTextLabel.lineBreakMode = .byWordWrapping
            postTextLabel.prepareTextForPublish2(viewController)
            
            let textLabelSize = getTextSize(text: postTextLabel.text!, font: textFont, readmore: record.readMore1)
            
            var readMoreButtonHeight: CGFloat = 20.0
            if readMoreButton.isHidden == true {
                readMoreButtonHeight = 0
            }
            
            topY = topInsets + avatarImageSize + 3 * verticalSpacingElements + textLabelSize.height + readMoreButtonHeight + 1
            
            if record.repostOwnerID != 0 {
                repostTextLabel.text = record.repostText
                repostTextLabel.font = textFont
                repostTextLabel.numberOfLines = 0
                repostTextLabel.lineBreakMode = .byWordWrapping
                repostTextLabel.prepareTextForPublish2(viewController)
                
                let repostTextLabelSize = getRepostTextSize(text: repostTextLabel.text!, font: textFont, readmore: record.readMore2)
                
                var repostReadMoreButtonHeight: CGFloat = 20.0
                if repostReadMoreButton.isHidden == true {
                    repostReadMoreButtonHeight = 0
                }
                
                topY = topY + repostAvatarImageSize + 3 * verticalSpacingElements + repostTextLabelSize.height + repostReadMoreButtonHeight + 1
            }
        }
        
        var photos: [Photos] = []
        let maxWidth = UIScreen.main.bounds.width - 20 + 2.5
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
        aView.photos = photos
        
        if drawCell {
            aView.backgroundColor = .clear
            aView.tag = 100
            aView.delegate = self.delegate
            
            let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: false)
            aView.frame = CGRect(x: 10, y: topY, width: maxWidth, height: aHeight)
            self.addSubview(aView)
            
            topY += aHeight
        } else {
            aView.tag = 100
            aView.photos = photos
            let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: true)
            
            topY += aHeight
        }
        
        topY = setImageView(0, topY, record, videos, cell, indexPath, imageView1, tableView)
        topY = setImageView(1, topY, record, videos, cell, indexPath, imageView2, tableView)
        topY = setImageView(2, topY, record, videos, cell, indexPath, imageView3, tableView)
        topY = setImageView(3, topY, record, videos, cell, indexPath, imageView4, tableView)
        topY = setImageView(4, topY, record, videos, cell, indexPath, imageView5, tableView)
        topY = setImageView(5, topY, record, videos, cell, indexPath, imageView6, tableView)
        topY = setImageView(6, topY, record, videos, cell, indexPath, imageView7, tableView)
        topY = setImageView(7, topY, record, videos, cell, indexPath, imageView8, tableView)
        topY = setImageView(8, topY, record, videos, cell, indexPath, imageView9, tableView)
        topY = setImageView(9, topY, record, videos, cell, indexPath, imageView10, tableView)
        
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
                if drawCell {
                    signerLabel.text = "\(users[0].firstName) \(users[0].lastName)"
                    signerLabel.font = signerFont
                    signerLabel.textAlignment = .right
                    signerLabel.contentMode = .top
                    signerLabel.textColor = signerLabel.tintColor
                    signerLabel.frame = CGRect(x: leftInsets, y: topY, width: self.bounds.width - 2 * leftInsets, height: signerLabelHeight)
                    if drawCell { self.addSubview(signerLabel) }
                    
                    let signerTap = UITapGestureRecognizer()
                    signerTap.add {
                        self.delegate.openProfileController(id: record.signerID, name: "")
                    }
                    signerLabel.isUserInteractionEnabled = true
                    signerLabel.addGestureRecognizer(signerTap)
                }
                
                topY += signerLabelHeight
            }
        }
        
        if record.postType != "postpone" && record.filter == "" {
            if drawCell {
                let view = UIView()
                view.tag = 100
                view.backgroundColor = .clear
                view.frame = CGRect(x: 2, y: topY + 2, width: bounds.width - 4, height: likesButtonHeight - 4)
                self.addSubview(view)
                
                let likeTap = UITapGestureRecognizer()
                likeTap.add {
                    self.delegate.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: false)
                }
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(likeTap)
                
                likesButton.frame = CGRect(x: leftInsets/2 - 2, y: 0, width: likesButtonWidth, height: likesButtonHeight - 4)
                likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
                likesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
                
                setLikesButton(record: record)
                
                view.addSubview(likesButton)
                
                let titleColor = vkSingleton.shared.secondaryLabelColor
                let tintColor = vkSingleton.shared.secondaryLabelColor
                
                repostsButton.frame = CGRect(x: likesButton.frame.maxX, y: 0, width: repotsButtonWidth, height: likesButtonHeight - 4)
                repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
                repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
                
                repostsButton.setTitle("\(record.countReposts)", for: .normal)
                repostsButton.setTitle("\(record.countReposts)", for: .selected)
                repostsButton.setImage(UIImage(named: "repost3"), for: .normal)
                repostsButton.imageView?.tintColor = tintColor
                repostsButton.setTitleColor(titleColor, for: .normal)
                if record.userPeposted == 1 {
                    repostsButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
                    repostsButton.imageView?.tintColor = vkSingleton.shared.likeColor
                }
                
                view.addSubview(repostsButton)
                
                viewsButton.frame = CGRect(x: bounds.width - likesButtonWidth - leftInsets/2 + 2, y: 0, width: likesButtonWidth, height: likesButtonHeight - 4)
                viewsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
                viewsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
                
                viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.normal)
                viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.selected)
                viewsButton.setImage(UIImage(named: "views"), for: .normal)
                viewsButton.setTitleColor(titleColor, for: .normal)
                viewsButton.imageView?.tintColor = tintColor
                viewsButton.isUserInteractionEnabled = false
                
                view.addSubview(viewsButton)
                
                if record.canComment == 1 || record.countComments > 0 {
                    commentsButton.frame = CGRect(x: viewsButton.frame.minX - repotsButtonWidth, y: 0, width: repotsButtonWidth, height: likesButtonHeight - 4)
                    commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
                    commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
                    commentsButton.setImage(UIImage(named: "message2"), for: .normal)
                    commentsButton.setTitle("\(record.countComments)", for: .normal)
                    commentsButton.setTitle("\(record.countComments)", for: .selected)
                    
                    commentsButton.setTitleColor(commentsButton.tintColor.withAlphaComponent(0.8), for: .normal)
                    commentsButton.imageView?.tintColor = commentsButton.tintColor.withAlphaComponent(0.8) //UIColor(red: 124/255, green: 172/255, blue: 238/255, alpha: 1)
                    
                    view.addSubview(commentsButton)
                }
            }
            
            return topY + likesButtonHeight
        }
        
        return topY + topInsets
    }
    
    func configurePoll(_ poll: Poll, topY: CGFloat) -> CGFloat {
        
        var viewY: CGFloat = 5
        
        if drawCell {
            let view = UIView()
            view.tag = 100
            
            let textColor = vkSingleton.shared.secondaryLabelColor
            
            if !poll.photo.isEmpty {
                let qLabel = PollQuestionLabel()
                qLabel.font = qLabelFont
                qLabel.text = poll.question
                qLabel.textAlignment = .center
                qLabel.backgroundColor = vkSingleton.shared.mainColor
                qLabel.textColor = UIColor.white
                qLabel.numberOfLines = 0
                
                let qLabelSize = getPollQuestionLabelSize(text: poll.question, font: qLabelFont)
                qLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets - 10, height: qLabelSize.height + 5)
                view.addSubview(qLabel)
                
                let qImage = UIImageView()
                qImage.frame = CGRect(x: 6, y: (qLabelSize.height - 44) / 2, width: 48, height: 48)
                qLabel.addSubview(qImage)
                
                let getCacheImage = GetCacheImage(url: poll.photo, lifeTime: .newsFeedImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        qImage.image = getCacheImage.outputImage
                        qImage.contentMode = .scaleAspectFill
                        qImage.layer.borderWidth = 1
                        qImage.layer.borderColor = UIColor.white.cgColor
                        qImage.clipsToBounds = true
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                
                viewY += qLabelSize.height + 5
            } else {
                let qLabel = UILabel()
                qLabel.font = qLabelFont
                qLabel.text = poll.question
                qLabel.textAlignment = .center
                qLabel.backgroundColor = vkSingleton.shared.mainColor
                qLabel.textColor = UIColor.white
                qLabel.numberOfLines = 0
                
                let qLabelSize = getPollLabelSize(text: poll.question, font: qLabelFont)
                qLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets - 10, height: qLabelSize.height + 5)
                view.addSubview(qLabel)
                viewY += qLabelSize.height + 5
            }
            
            if poll.anonymous == 1 {
                let anonLabel = UILabel()
                anonLabel.text = "Анонимный опрос"
                anonLabel.textColor = textColor
                anonLabel.textAlignment = .left
                anonLabel.font = UIFont(name: "Verdana", size: 11)!
                anonLabel.frame = CGRect(x: leftInsets, y: viewY, width: (bounds.width - 2 * leftInsets) / 2 - leftInsets, height: 15)
                view.addSubview(anonLabel)
            }
            
            if poll.canVote && poll.endDate > 0 {
                let dateLabel = UILabel()
                dateLabel.font = UIFont(name: "Verdana", size: 11)!
                dateLabel.textColor = textColor
                dateLabel.textAlignment = .right
                dateLabel.numberOfLines = 1
                dateLabel.adjustsFontSizeToFitWidth = true
                dateLabel.minimumScaleFactor = 0.7
                dateLabel.text = "Опрос до \(poll.endDate.toStringPollEndDate())"
                dateLabel.frame = CGRect(x: (bounds.width - 2 * leftInsets) / 2, y: viewY, width: (bounds.width - 2 * leftInsets) / 2 - leftInsets, height: 15)
                view.addSubview(dateLabel)
            }

            viewY += 15
            
            if !poll.canVote && !poll.disableUnvote {
                let closedLabel = UILabel()
                closedLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
                closedLabel.text = "Опрос завершен"
                closedLabel.textAlignment = .center
                closedLabel.textColor = vkSingleton.shared.labelColor
                closedLabel.isEnabled = true
                closedLabel.numberOfLines = 1
                closedLabel.frame = CGRect(x: leftInsets, y: viewY, width: bounds.width - 4 * leftInsets, height: 40)
                view.addSubview(closedLabel)
                
                viewY += 40
            } else if poll.disableUnvote && poll.answerIDs.count > 0 {
                let closedLabel = UILabel()
                closedLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
                closedLabel.text = "Вы уже проголосовали"
                closedLabel.textAlignment = .center
                closedLabel.textColor = vkSingleton.shared.labelColor
                closedLabel.isEnabled = true
                closedLabel.numberOfLines = 1
                closedLabel.frame = CGRect(x: leftInsets, y: viewY, width: bounds.width - 4 * leftInsets, height: 40)
                view.addSubview(closedLabel)
                
                viewY += 40
            } else {
                let multiLabel = UILabel()
                multiLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
                multiLabel.textAlignment = .center
                multiLabel.textColor = vkSingleton.shared.labelColor
                multiLabel.numberOfLines = 2
                multiLabel.text = "Выберите один вариант ответа:"
                if poll.multiple { multiLabel.text = "Выберите один или несколько вариантов ответа:" }
                multiLabel.frame = CGRect(x: leftInsets, y: viewY, width: bounds.width - 4 * leftInsets, height: 40)
                view.addSubview(multiLabel)
                
                viewY += 40
            }
            
            for index in 0...poll.answers.count-1 {
                let aLabel = PollAnswerLabel()
                aLabel.font = aLabelFont
                aLabel.text = poll.answers[index].text
                aLabel.backgroundColor = vkSingleton.shared.mainColor
                aLabel.isEnabled = true
                aLabel.isUserInteractionEnabled = true
                aLabel.textColor = .white
                aLabel.numberOfLines = 0
                aLabel.tag = index
                
                let aLabelSize = getPollAnswerLabelSize(text: "\(index+1). \(poll.answers[index].text)", font: aLabelFont)
                aLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets - 10, height: aLabelSize.height + 10)
                view.addSubview(aLabel)
                
                viewY += aLabelSize.height + 10
                
                let rLabel = UILabel()
                rLabel.text = ""
                rLabel.textAlignment = .right
                
                rLabel.textColor = UIColor.clear
                rLabel.font = UIFont(name: "Verdana", size: 11)!
                rLabel.frame = CGRect(x: (bounds.width - 2 * leftInsets - 10) / 2, y: viewY, width: (bounds.width - 2 * leftInsets - 10) / 2, height: 15)
                rLabel.adjustsFontSizeToFitWidth = true
                rLabel.minimumScaleFactor = 0.5
                view.addSubview(rLabel)
                rateLabels.append(rLabel)
                
                if poll.anonymous == 0 {
                    let vLabel = UILabel()
                    vLabel.text = "Кто проголосовал?"
                    vLabel.textAlignment = .left
                    vLabel.textColor = UIColor.systemBlue
                    vLabel.isHidden = true
                    vLabel.font = UIFont(name: "Verdana", size: 11)!
                    vLabel.frame = CGRect(x: 10, y: viewY, width: (bounds.width - 2 * leftInsets - 10) / 2 - 10, height: 15)
                    vLabel.adjustsFontSizeToFitWidth = true
                    vLabel.minimumScaleFactor = 0.5
                    view.addSubview(vLabel)
                    
                    let votersTap = UITapGestureRecognizer()
                    vLabel.isUserInteractionEnabled = true
                    vLabel.addGestureRecognizer(votersTap)
                    votersTap.add {
                        self.delegate.getPollVoters(poll: poll, index: index)
                    }
                    
                    votersLabels.append(vLabel)
                }
                
                
                viewY += 25
                answerLabels.append(aLabel)
            }
            
            totalLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
            totalLabel.textAlignment = .right
            totalLabel.textColor = vkSingleton.shared.mainColor
            totalLabel.isEnabled = true
            totalLabel.adjustsFontSizeToFitWidth = true
            totalLabel.minimumScaleFactor = 0.5
            totalLabel.numberOfLines = 1
            
            totalLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets - 10, height: 20)
            view.addSubview(totalLabel)
            viewY += 20
            
            if poll.multiple && poll.canVote {
                voteButton.setTitleColor(.white, for: .normal)
                voteButton.backgroundColor = vkSingleton.shared.separatorColor
                voteButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
                voteButton.setTitle("Проголосовать", for: .normal)
                voteButton.frame = CGRect(x: 5, y: viewY + 10, width: bounds.width - 2 * leftInsets - 10, height: 25)
                voteButton.contentHorizontalAlignment = .center
                voteButton.addTarget(self, action: #selector(self.pollMultipleVote), for: .touchUpInside)
                voteButton.layer.cornerRadius = 2
                voteButton.clipsToBounds = true
                voteButton.isEnabled = false
                view.addSubview(voteButton)
                viewY += 40
            }
            
            view.frame = CGRect(x: leftInsets, y: topY + 5, width: bounds.width - 2 * leftInsets, height: viewY)
            view.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            view.layer.borderWidth = 1.0
            self.addSubview(view)
            
            updatePoll()
        } else {
            let qLabelSize = getPollLabelSize(text: "Опрос: \(poll.question)", font: qLabelFont)
            viewY += qLabelSize.height + 60
            
            for index in 0...poll.answers.count-1 {
                let aLabelSize = getPollAnswerLabelSize(text: poll.answers[index].text, font: aLabelFont)
                viewY += aLabelSize.height + 35
            }
            
            viewY += 20
            if poll.multiple && poll.canVote { viewY += 40 }
        }
        
        return topY + 5 + viewY + verticalSpacingElements
    }
    
    func updatePoll() {
        if answerLabels.count > 0 {
            var selectedAnswers = 0
            
            for index in 0...answerLabels.count-1 {
                let label = answerLabels[index]
                
                if poll.answerIDs.contains(poll.answers[index].id) {
                    label.textColor = .systemRed
                    let bounds = label.bounds
                    
                    let voteImage = UIImageView()
                    voteImage.image = UIImage(named: "checkmark")
                    voteImage.tintColor = .systemRed
                    voteImage.frame = CGRect(x: bounds.width - 30, y: bounds.minY + (bounds.height - 15)/2, width: 15, height: 15)
                    label.addSubview(voteImage)
                } else {
                    label.textColor = .white
                    for subview in label.subviews {
                        if subview is UIImageView { subview.removeFromSuperview() }
                    }
                }
                
                if poll.answers[index].isSelect {
                    selectedAnswers += 1
                    label.backgroundColor = UIColor.purple
                } else {
                    label.backgroundColor = vkSingleton.shared.mainColor
                }
            }
            
            if selectedAnswers == 0 {
                voteButton.isEnabled = false
                voteButton.backgroundColor = vkSingleton.shared.separatorColor
            } else {
                voteButton.isEnabled = true
                voteButton.backgroundColor = vkSingleton.shared.mainColor
            }
        }
        
        if rateLabels.count > 0 {
            for index in 0...rateLabels.count-1 {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                if let rate = formatter.string(from: NSNumber(value: poll.answers[index].rate)) {
                    rateLabels[index].text = "\(rate) % (\(poll.answers[index].votes.rateAdder()))"
                }
                rateLabels[index].textColor = .clear
                
                if !poll.canVote || poll.answerIDs.count > 0 {
                    rateLabels[index].textColor = vkSingleton.shared.secondaryLabelColor
                }
                
                if votersLabels.count > 0 {
                    votersLabels[index].isHidden = true
                    
                    if !poll.canVote || poll.answerIDs.count > 0 {
                        votersLabels[index].isHidden = poll.answers[index].votes == 0
                    }
                }
            }
        }
        
        totalLabel.text = "Всего проголосовало: \(self.poll.votes)"
    }
    
    @objc func pollMultipleVote() {
        
        if let poll = self.poll {
            
            var variants = ""
            var answerIDs = ""
            var selectedAnswers = 0
            
            if poll.answers.count > 0 {
                for index in 0...poll.answers.count - 1 {
                    if poll.answers[index].isSelect {
                        selectedAnswers += 1
                        variants = "\(variants)«\(poll.answers[index].text)»"
                        answerIDs = "\(answerIDs)\(poll.answers[index].id)"
                        
                        if index < poll.answers.count - 1 {
                            variants = "\(variants)\n"
                            answerIDs = "\(answerIDs),"
                        }
                    }
                }
                
                var message: String? = "Вы выбрали следующий вариант:"
                if selectedAnswers > 1 { message = "Вы выбрали следующие варианты:" }
                
                message = "\(message!) \n\(variants)"
                var title: String? = nil
                if poll.disableUnvote { title = "Внимание!\nОтменить голосование по этому опросу\n будет впоследствии невозможно\n\n"}
                else { title = message; message = nil }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                    for answer in poll.answers {
                        answer.isSelect = false
                        self.updatePoll()
                    }
                }
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Проголосовать", style: .default) { action in
                    let url = "/method/polls.addVote"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(poll.ownerID)",
                        "poll_id": "\(poll.id)",
                        "answer_ids": answerIDs,
                        "v": "5.85"
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            OperationQueue.main.addOperation {
                                poll.answerIDs = []
                                poll.votes += 1
                                for answer in poll.answers {
                                    if answer.isSelect {
                                        answer.votes += 1
                                        poll.answerIDs.append(answer.id)
                                        answer.isSelect = false
                                    }
                                }
                                        
                                for answer in poll.answers {
                                    answer.rate = Double(answer.votes) / Double(poll.votes) * 100
                                }
                                
                                self.updatePoll()
                            }
                        } else {
                            error.showErrorMessage(controller: self.delegate)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
                
                delegate.present(alertController, animated: true)
            }
        }
    }
    
    func setLikesButton(record: Wall) {
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
    
    func setImageView(_ index: Int, _ topY: CGFloat, _ record: Wall, _ videos: [Videos], _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ tableView: UITableView) -> CGFloat {
        
        var imageHeight: CGFloat = 0.0
        var imageWidth: CGFloat = 0.0
        var topNew = topY
        
        if drawCell {
            let subviews = imageView.subviews
            for subview in subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
                if subview is WKWebView {
                    subview.removeFromSuperview()
                }
                if subview.tag == 1000 {
                    subview.removeFromSuperview()
                }
            }
            
            imageView.layer.borderWidth = 0.0
            imageView.layer.cornerRadius = 0.0
            imageView.contentMode = .scaleAspectFill
            
            imageView.frame = CGRect(x: 5.0, y: topY, width: imageWidth, height: 0.0)
            imageView.backgroundColor = vkSingleton.shared.backColor
            imageView.isOpaque = false
            imageView.image = nil
            
            self.addSubview(imageView)
        }
        
        if record.mediaType[index] == "doc" {
            if record.photoWidth[index] != 0 && record.photoHeight[index] != 0 {
                let width = CGFloat(record.photoWidth[index])
                let height = CGFloat(record.photoHeight[index])
                
                if width > height {
                    imageWidth = UIScreen.main.bounds.width - 20.0
                    imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                } else {
                    imageHeight = UIScreen.main.bounds.width - 20.0
                    imageWidth = imageHeight * CGFloat(record.photoWidth[index]) / CGFloat(record.photoHeight[index])
                }
            }
            
            if imageHeight > 4 {
                
                if drawCell {
                    imageView.frame = CGRect(x: 10, y: topY + 2, width: imageWidth, height: imageHeight - 4)
                    if imageWidth < UIScreen.main.bounds.width - 20 {
                        imageView.frame = CGRect(x: 10 + (UIScreen.main.bounds.width - 20 - imageWidth) / 2, y: topY + 2, width: imageWidth, height: imageHeight - 4)
                    }
                    
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
                        if drawCell { imageView.addSubview(loadingView) }
                        
                        let activityIndicator = UIActivityIndicatorView()
                        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                        activityIndicator.style = .white
                        activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                        if drawCell { loadingView.addSubview(activityIndicator) }
                        activityIndicator.startAnimating()
                        
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
                        if drawCell { imageView.addSubview(gifSizeLabel) }
                        
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
                                        
                                        let gifTap = UITapGestureRecognizer()
                                        gifTap.add {
                                            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                            
                                            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                                            alertController.addAction(cancelAction)
                                            
                                            let action1 = UIAlertAction(title: "Сохранить GIF на устройство", style: .default) { action in
                                                
                                                if let url = URL(string: record.videoURL[index]) {
                                                    
                                                    OperationQueue().addOperation {
                                                        OperationQueue.main.addOperation {
                                                            ViewControllerUtils().showActivityIndicator(uiView: self.delegate.view)
                                                        }
                                                        
                                                        self.delegate.saveGifToDevice(url: url)
                                                    }
                                                }
                                            }
                                            alertController.addAction(action1)
                                            
                                            self.delegate.present(alertController, animated: true)
                                        }
                                        imageView.isUserInteractionEnabled = true
                                        imageView.addGestureRecognizer(gifTap)
                                    }
                                }
                            }
                        }
                    }
                    
                    self.addSubview(imageView)
                }
                
                topNew = topY + imageHeight + 4.0
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
                let titleLabel = UILabel()
                titleLabel.text = record.photoText[index]
                titleLabel.textAlignment = .center
                titleLabel.font = UIFont(name: "Verdana", size: 12.0)!
                titleLabel.numberOfLines = 2
                titleLabel.textColor = titleLabel.tintColor
                let titleLabelHeight = fmin(titleLabel.getTextSize(maxWidth: UIScreen.main.bounds.width - 20).height, 30)
                
                if drawCell {
                    imageView.frame = CGRect(x: 10 + (UIScreen.main.bounds.width - 20.0 - imageWidth) / 2, y: topY + 2, width: imageWidth, height: imageHeight)
                    
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
                    if drawCell { imageView.addSubview(loadingView) }
                    
                    let activityIndicator = UIActivityIndicatorView()
                    activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    activityIndicator.style = .white
                    activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                    if drawCell { loadingView.addSubview(activityIndicator) }
                    activityIndicator.startAnimating()
                    
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
                            webView.loadHTMLString(embedVideoHtmlYoutube(videoID: newURL.lastPathComponent, autoplay: 0, playsinline: 1, muted: true), baseURL: nil)
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
                        
                        self.addSubview(imageView)
                    }
                }
                
                topNew = topY + imageHeight + 30.0 + titleLabelHeight
            }
        }
        
        return topNew
    }
    
    func setLinkLabel(_ index: Int, _ topY: CGFloat, _ record: Wall, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ linkLabel: UILabel, _ tableView: UITableView, _ viewController: UIViewController) -> CGFloat {
        
        
        
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
            
            if drawCell {
                imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                linkLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        imageView.image = getCacheImage.outputImage
                    }
                }
                queue.addOperation(getCacheImage)
            }
        } else if record.linkURL[index].containsIgnoringCase(find: "itunes.apple.com") {
            imageWidth = linkImageSize * 0.7
            imageHeight = linkImageSize * 0.7
            imageView.image = UIImage(named: "itunes")
        } else {
            imageWidth = linkImageSize * 0.8
            imageHeight = linkImageSize * 0.8
            imageView.image = UIImage(named: "url")
        }
        
        if drawCell {
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderColor = linkLabel.tintColor.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.clipsToBounds = true
            
            imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: imageWidth, height: imageHeight)
            
            if drawCell { self.addSubview(imageView) }
            
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
            
            linkLabel.frame = CGRect(x: imageWidth + 2 * leftInsets, y: topY + topLinkInsets, width: self.bounds.width - imageWidth - 3 * leftInsets, height: imageHeight)
            
            linkLabel.lineBreakMode = .byWordWrapping
            linkLabel.prepareTextForPublish2(viewController)
            self.addSubview(linkLabel)
        }
        
        return topY + 2 * topLinkInsets + imageHeight
    }
    
    func setAudioLabel(_ index: Int, _ topY: CGFloat, _ record: Wall, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ audioLabel: UILabel, _ audioNameLabel: UILabel, _ tableView: UITableView) -> CGFloat {
        
        var topNew: CGFloat = 0
        
        if record.mediaType[index] == "audio" {
            if record.audioTitle[index] != "" {
                if drawCell {
                    let view = UIView()
                    view.tag = 100
                    view.backgroundColor = .clear
                    
                    imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: 0.0)
                    audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
                    audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4 + audioNameLabel.frame.height, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
                    
                    imageView.image = UIImage(named: "music")
                    audioNameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
                    audioLabel.font = UIFont(name: "Verdana", size: 13)!
                    
                    imageView.frame = CGRect(x: leftInsets, y: topLinkInsets, width: audioImageSize, height: audioImageSize)
                    
                    audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                    audioNameLabel.text = record.audioArtist[index]
                    audioNameLabel.textColor = vkSingleton.shared.labelColor
                    
                    audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: 20, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                    audioLabel.text = record.audioTitle[index]
                    audioLabel.textColor = audioLabel.tintColor
                    
                    imageView.isHidden = false
                    audioNameLabel.isHidden = false
                    audioLabel.isHidden = false
                    
                    view.addSubview(imageView)
                    view.addSubview(audioNameLabel)
                    view.addSubview(audioLabel)
                
                    let audioTap = UITapGestureRecognizer()
                    audioTap.add {
                        self.delegate.getITunesInfo2(artist: record.audioArtist[index], title: record.audioTitle[index])
                    }
                    view.isUserInteractionEnabled = true
                    view.addGestureRecognizer(audioTap)
                    
                    view.frame = CGRect(x: 0, y: topY, width: bounds.size.width, height: 2 * topLinkInsets + audioImageSize)
                    self.addSubview(view)
                }
                
                topNew = 2 * topLinkInsets + audioImageSize
            }
        }
        
        return topY + topNew
    }
    
    func avatarImageViewFrame() {
        let avatarImageOrigin = CGPoint(x: leftInsets, y: topInsets)
        
        avatarImageView.frame = CGRect(origin: avatarImageOrigin, size: CGSize(width: avatarImageSize, height: avatarImageSize))
        
        if drawCell { self.addSubview(avatarImageView) }
    }
    
    func repostAvatarImageViewFrame() {
        let repostAvatarImageY = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements
        
        let repostAvatarImageOrigin = CGPoint(x: leftInsets, y: repostAvatarImageY)
        
        var height = repostAvatarImageSize
        if repostAvatarImageView.isHidden == true {
            height = 0.0
        }
        
        repostAvatarImageView.frame = CGRect(origin: repostAvatarImageOrigin, size: CGSize(width: repostAvatarImageSize, height: height))
        
        if drawCell { self.addSubview(repostAvatarImageView) }
    }
    
    func nameLabelFrame() {
        
        let nameLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets)
        
        let nameLabelWidth = bounds.size.width - nameLabelOrigin.x - leftInsets
        
        nameLabel.frame = CGRect(origin: nameLabelOrigin, size: CGSize(width: nameLabelWidth, height: nameLabelHeight))
    
        if drawCell { self.addSubview(nameLabel) }
    }
    
    
    func datePostLabelFrame() {
        
        let dateLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets + nameLabelHeight + 1)
        
        let dateLabelWidth = bounds.size.width - dateLabelOrigin.x - leftInsets
        
        datePostLabel.frame = CGRect(origin: dateLabelOrigin, size: CGSize(width: dateLabelWidth, height: dateLabelHeight))
        
        if drawCell { self.addSubview(datePostLabel) }
    }
    
    func repostNameLabelFrame() {
        
        let repostNameLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + 6)
        
        let repostNameLabelWidth = bounds.size.width - repostNameLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostNameLabel.isHidden == true {
            height = 0.0
        }
        
        repostNameLabel.frame = CGRect(origin: repostNameLabelOrigin, size: CGSize(width: repostNameLabelWidth, height: height))
        
        if drawCell { self.addSubview(repostNameLabel) }
    }
    
    func repostDateLabelFrame() {
        
        let repostDateLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + 6 + repostNameLabel.frame.height + 1)
        
        let repostDateLabelWidth = bounds.size.width - repostDateLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostDateLabel.isHidden == true {
            height = 0.0
        }
        
        repostDateLabel.frame = CGRect(origin: repostDateLabelOrigin, size: CGSize(width: repostDateLabelWidth, height: height))
        
        if drawCell { self.addSubview(repostDateLabel) }
    }
    
    func getTextSize(text: String, font: UIFont, readmore: Int) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if readmore == 1 {
            if rect.size.height > readMoreLevel {
                height = Double(readMoreLevel)
                readMoreButton.isHidden = false
            } else {
                readMoreButton.isHidden = true
            }
        } else {
            readMoreButton.isHidden = true
        }
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getPollLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets - 10
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getPollQuestionLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets - 10
        let textBlock = CGSize(width: maxWidth - 65, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = max(Double(rect.size.height), 60)
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getPollAnswerLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets - 10
        let textBlock = CGSize(width: maxWidth - 60, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: [.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = max(Double(rect.size.height),15)
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func textLabelFrame(readmore: Int) {
        let textLabelSize = getTextSize(text: postTextLabel.text!, font: textFont, readmore: readmore)
        
        postTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements, width: textLabelSize.width, height: textLabelSize.height)
        
        if drawCell { self.addSubview(postTextLabel) }
    }
    
    func getRepostTextSize(text: String, font: UIFont, readmore: Int) -> CGSize {
        let maxWidth = bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if readmore == 1 {
            if rect.size.height > readMoreLevel {
                height = Double(readMoreLevel)
                repostReadMoreButton.isHidden = false
            } else {
                repostReadMoreButton.isHidden = true
            }
        } else {
            repostReadMoreButton.isHidden = true
        }
        
        if text == "" {
            height = 5.0
        }
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func repostTextLabelFrame(readmore: Int) {
        let repostTextLabelSize = getRepostTextSize(text: repostTextLabel.text!, font: textFont, readmore: readmore)
        
        repostTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements, width: repostTextLabelSize.width, height: repostTextLabelSize.height)
        
        if drawCell { self.addSubview(repostTextLabel) }
    }
    
    func readMoreButtonFrame() {
        
        let readMoreButtonOrigin = CGPoint(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + 1)
        
        let readMoreButtonWidth = bounds.size.width - 2 * leftInsets
        var readMoreButtonHeight: CGFloat = 20.0
        if readMoreButton.isHidden == true {
            readMoreButtonHeight = 0
        }
        
        readMoreButton.frame = CGRect(origin: readMoreButtonOrigin, size: CGSize(width: readMoreButtonWidth, height: readMoreButtonHeight))
        
        if drawCell { self.addSubview(readMoreButton) }
    }
    
    func repostReadMoreButtonFrame() {
        
        let repostReadMoreButtonOrigin = CGPoint(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements + repostTextLabel.frame.height)
        
        let repostReadMoreButtonWidth = bounds.size.width - 2 * leftInsets
        var repostReadMoreButtonHeight: CGFloat = 20.0
        if repostReadMoreButton.isHidden == true {
            repostReadMoreButtonHeight = 0
        }
        
        repostReadMoreButton.frame = CGRect(origin: repostReadMoreButtonOrigin, size: CGSize(width: repostReadMoreButtonWidth, height: repostReadMoreButtonHeight))
        
        if drawCell { self.addSubview(repostReadMoreButton) }
    }
}

extension WallRecordCell2: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.isHidden = false
    }
}

extension WKWebView {
    class func removeCache() {
        guard #available(iOS 9.0, *) else {return}

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("WKWebsiteDataStore record deleted:", record)
            }
        }
    }
}
