//
//  CommentCell2.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SwiftyJSON

class CommentCell2: UITableViewCell {

    var delegate: UIViewController!
    var comment: Comments!
    var users: [CommentsProfiles]!
    var groups: [CommentsGroups]!
    
    var position: CGPoint = CGPoint.zero
    
    var avatarImage = UIImageView()
    var nameLabel = UILabel()
    var dateLabel = UILabel()
    var commentLabel = UILabel()
    var likesButton = UIButton()
    var images: [UIImageView] = []
    var countButton = UIButton()
    var artists: [UILabel] = []
    var titles: [UILabel] = []
    
    let avatarHeight: CGFloat = 40.0
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    let vertInsets: CGFloat = 5.0
    let separatorHeight: CGFloat = 0.5
    let likesButtonWidth: CGFloat = 60
    let likesButtonHeight: CGFloat = 25
    let stickerHeight: CGFloat = 100
    
    let audioImageSize: CGFloat = 30.0
    let linkImageSize: CGFloat = 100.0
    let topLinkInsets: CGFloat = 5.0
    
    let nameFont = UIFont(name: "Verdana-Bold", size: 14)!
    let dateFont = UIFont(name: "Verdana", size: 10)!
    let commFont = UIFont(name: "Verdana", size: 12)!
    let likeFont = UIFont(name: "Verdana-Bold", size: 12)!
    
    func configureCountCell(count: Int, total: Int) {
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        countButton.tag = 100
        countButton.setTitle("Показать еще \(count) из \(total) комментариев", for: .normal)
        countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
        countButton.contentMode = .center
        countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
        countButton.titleLabel?.adjustsFontSizeToFitWidth = true
        countButton.titleLabel?.minimumScaleFactor = 0.5
        countButton.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.addSubview(countButton)
    }
    
    func configureCell(comment: Comments, profiles: [CommentsProfiles], groups: [CommentsGroups], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.comment = comment
        self.users = profiles
        self.groups = groups
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        configureAvatar(comment: comment, profiles: profiles, groups: groups, indexPath: indexPath, cell: cell, tableView: tableView)
        
        var topY = topInsets + 22
        topY = configureCommentLabel(comment: comment, topY: topY)
        topY = configureAttachment(comment: comment, topY: topY, indexPath: indexPath, cell: cell, tableView: tableView)
        configureDateLabel(comment: comment, profiles: profiles, groups: groups, tableView: tableView, topY: topY)
        topY = configureLikesButton(comment: comment, topY: topY)
        //topY = setSeparator(topY: topY)
    }
    
    func setSeparator(topY: CGFloat) -> CGFloat {
        
        let separator = UILabel()
        separator.tag = 100
        separator.backgroundColor = UIColor.lightGray
        separator.frame = CGRect(x: avatarHeight + 2 * leftInsets, y: topY + topInsets, width: UIScreen.main.bounds.width - avatarHeight - 3 * leftInsets, height: separatorHeight)
        self.addSubview(separator)
        
        return topY + topInsets + separatorHeight
    }
    
    func configureAttachment(comment: Comments, topY: CGFloat, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) -> CGFloat {
        
        var topY = topY
        images.removeAll(keepingCapacity: false)
        
        if comment.attach.count > 0 {
            for index in 0...comment.attach.count-1 {
                if comment.attach[index].type == "photo" {
                
                    let photoImage = UIImageView()
                    photoImage.tag = 100
                    let width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                    let height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                    
                    let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToCommentRow(imageView: photoImage)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photoImage.clipsToBounds = true
                    }
                    
                    photoImage.frame = CGRect(x: 3 * leftInsets + avatarHeight, y: topY + vertInsets, width: width, height: height)
                    self.addSubview(photoImage)
                    topY = topY + height + vertInsets
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        let photoViewController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                        
                        var newIndex = 0
                        for ind in 0...comment.attach.count-1 {
                            if comment.attach[ind].type == "photo" {
                                let photos = Photos(json: JSON.null)
                                photos.uid = "\(comment.attach[ind].ownerID)"
                                photos.pid = "\(comment.attach[ind].id)"
                                photos.xxbigPhotoURL = comment.attach[ind].photoURL
                                photos.xbigPhotoURL = comment.attach[ind].photoURL
                                photos.bigPhotoURL = comment.attach[ind].photoURL
                                photos.photoURL = comment.attach[ind].photoURL
                                photos.width = comment.attach[ind].photoWidth
                                photos.height = comment.attach[ind].photoHeight
                                photos.photoAccessKey = comment.attach[index].accessKey
                                photoViewController.photos.append(photos)
                                if ind == index {
                                    photoViewController.numPhoto = newIndex
                                }
                                newIndex += 1
                            }
                        }
                        
                        photoViewController.delegate = self.delegate
                        
                        self.delegate.navigationController?.pushViewController(photoViewController, animated: true)
                    }
                    photoImage.isUserInteractionEnabled = true
                    photoImage.addGestureRecognizer(tap)
                    
                    images.append(photoImage)
                }
             
                if comment.attach[index].type == "video" {
                    let photoImage = UIImageView()
                    photoImage.tag = 100
                    
                    let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToCommentRow(imageView: photoImage)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photoImage.layer.borderColor = UIColor.black.cgColor
                        photoImage.layer.borderWidth = 1.0
                        photoImage.layer.cornerRadius = 5.0
                        photoImage.clipsToBounds = true
                    }
                    
                    let photoX = 3 * leftInsets + avatarHeight
                    var width: CGFloat = 0.0
                    var height: CGFloat = 0.0
                    if CGFloat(comment.attach[index].photoWidth) < UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight {
                        
                        width = CGFloat(comment.attach[index].photoWidth)
                        height = CGFloat(comment.attach[index].photoHeight)
                    } else {
                        width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                        
                        height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                    }
                    
                    photoImage.frame = CGRect(x: photoX, y: topY + vertInsets, width: width, height: height)
                    
                    let videoImage = UIImageView()
                    videoImage.image = UIImage(named: "video")
                    photoImage.addSubview(videoImage)
                    videoImage.frame = CGRect(x: width / 2 - 30, y: height / 2 - 30, width: 60, height: 60)
                    
                    let durationLabel = UILabel()
                    durationLabel.text = comment.attach[index].size.getVideoDurationToString()
                    durationLabel.numberOfLines = 1
                    durationLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                    durationLabel.textAlignment = .center
                    durationLabel.contentMode = .center
                    durationLabel.textColor = UIColor.black
                    durationLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    durationLabel.layer.cornerRadius = 10
                    durationLabel.clipsToBounds = true
                    if let length = durationLabel.text?.length, length > 5 {
                        durationLabel.frame = CGRect(x: width - 10 - 90, y: height - 4 - 10 - 20, width: 90, height: 20)
                    } else {
                        durationLabel.frame = CGRect(x: width - 10 - 60, y: height - 4 - 10 - 20, width: 60, height: 20)
                    }
                    photoImage.addSubview(durationLabel)
                    
                    self.addSubview(photoImage)
                    
                    topY = topY + height + vertInsets
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        self.delegate.openVideoController(ownerID: "\(comment.attach[index].ownerID)", vid: "\(comment.attach[index].id)", accessKey: comment.attach[index].accessKey, title: "Видеозапись")
                    }
                    photoImage.isUserInteractionEnabled = true
                    photoImage.addGestureRecognizer(tap)
                    
                    images.append(photoImage)
                }
                
                if comment.attach[index].type == "sticker" {
                    let photoImage = UIImageView()
                    photoImage.tag = 100
                    
                    let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToCommentRow(imageView: photoImage)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photoImage.clipsToBounds = true
                    }
                    
                    photoImage.frame = CGRect(x: 3 * leftInsets + avatarHeight, y: topY, width: stickerHeight, height: stickerHeight)
                    self.addSubview(photoImage)
                    topY = topY + stickerHeight
                    
                    images.append(photoImage)
                }
                
                if comment.attach[index].type == "doc" && comment.attach[index].ext == "gif" {
                    
                    let photoImage = UIImageView()
                    photoImage.tag = 100
                    
                    let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToCommentRow(imageView: photoImage)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photoImage.clipsToBounds = true
                    }
                    
                    let photoX = 3 * leftInsets + avatarHeight
                    var width: CGFloat = 0.0
                    var height: CGFloat = 0.0
                    if CGFloat(comment.attach[index].photoWidth) < UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight {
                        
                        width = CGFloat(comment.attach[index].photoWidth)
                        height = CGFloat(comment.attach[index].photoHeight)
                    } else {
                        width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                        
                        height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                    }
                    
                    photoImage.frame = CGRect(x: photoX, y: topY + vertInsets, width: width, height: height)
                    photoImage.isHidden = false
                    
                    let gifImage = UIImageView()
                    gifImage.image = UIImage(named: "gif")
                    gifImage.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    gifImage.layer.cornerRadius = 10
                    gifImage.clipsToBounds = true
                    gifImage.frame = CGRect(x: width / 2 - 30, y: (height) / 2 - 30, width: 60, height: 60)
                    photoImage.addSubview(gifImage)
                    
                    let gifSizeLabel = UILabel()
                    gifSizeLabel.text = "Размер: \(comment.attach[index].size.getFileSizeToString())"
                    gifSizeLabel.numberOfLines = 1
                    gifSizeLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                    gifSizeLabel.textAlignment = .center
                    gifSizeLabel.contentMode = .center
                    gifSizeLabel.textColor = UIColor.black
                    gifSizeLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    gifSizeLabel.layer.cornerRadius = 10
                    gifSizeLabel.clipsToBounds = true
                    gifSizeLabel.frame = CGRect(x: width - 5 - 120, y: height - 5 - 20, width: 120, height: 20)
                    photoImage.addSubview(gifSizeLabel)
                    
                    if comment.attach[index].videoURL != "" && comment.attach[index].size < 50_000_000 {
                        OperationQueue().addOperation {
                            let url = URL(string: comment.attach[index].videoURL)
                            if let data = try? Data(contentsOf: url!) {
                                let setAnimatedImageToRow = SetAnimatedImageToRow.init(data: data, imageView: photoImage, cell: cell, indexPath: indexPath, tableView: tableView)
                                OperationQueue.main.addOperation(setAnimatedImageToRow)
                                OperationQueue.main.addOperation {
                                    photoImage.bringSubviewToFront(gifSizeLabel)
                                    gifImage.removeFromSuperview()
                                }
                            }
                        }
                    }
                    self.addSubview(photoImage)
                    
                    topY = topY + vertInsets + height
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                        alertController.addAction(cancelAction)
                        
                        let action1 = UIAlertAction(title: "Сохранить GIF на устройство", style: .default) { action in
                            
                            if let url = URL(string: comment.attach[index].videoURL) {
                                
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
                    photoImage.isUserInteractionEnabled = true
                    photoImage.addGestureRecognizer(tap)
                    
                    images.append(photoImage)
                }
                
                if comment.attach[index].type == "doc" && comment.attach[index].ext == "png" {
                    
                    let photoImage = UIImageView()
                    photoImage.tag = 100
                    
                    let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToCommentRow(imageView: photoImage)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photoImage.clipsToBounds = true
                    }
                    
                    let photoX = 3 * leftInsets + avatarHeight
                    var width: CGFloat = 0.0
                    var height: CGFloat = 0.0
                    if CGFloat(comment.attach[index].photoWidth) < UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight {
                        
                        width = CGFloat(comment.attach[index].photoWidth)
                        height = CGFloat(comment.attach[index].photoHeight)
                    } else {
                        width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                        
                        height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                    }
                    
                    photoImage.frame = CGRect(x: photoX, y: topY + vertInsets, width: width, height: height)
                    photoImage.isHidden = false
                    
                    self.addSubview(photoImage)
                    
                    topY = topY + vertInsets + height
                    
                    images.append(photoImage)
                }
                
                if comment.attach[index].type == "audio" {
                    
                    let audioImage = UIImageView()
                    let artistLabel = UILabel()
                    let audioLabel = UILabel()
                    
                    audioImage.tag = 100
                    artistLabel.tag = 100
                    audioLabel.tag = 100
                    
                    audioImage.image = UIImage(named: "music")
                    
                    artistLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
                    audioLabel.font = UIFont(name: "Verdana", size: 13)!
                    
                    if comment.attach[index].title != "" {
                        audioImage.frame = CGRect(x: avatarHeight + 2 * leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: audioImageSize)
                        
                        artistLabel.frame = CGRect (x: avatarHeight + 3 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 4 * leftInsets - audioImageSize - avatarHeight, height: 16)
                        artistLabel.text = comment.attach[index].artist
                        
                        audioLabel.frame = CGRect (x: avatarHeight + 3 * leftInsets + audioImageSize, y: topY + 20, width: bounds.size.width - 4 * leftInsets - audioImageSize - avatarHeight, height: 16)
                        audioLabel.text = comment.attach[index].title
                        audioLabel.textColor = audioLabel.tintColor
                    }
                    
                    self.addSubview(audioImage)
                    self.addSubview(audioLabel)
                    self.addSubview(artistLabel)
                    
                    topY += audioImageSize + 2 * topLinkInsets
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        self.tapAudioAttach(comment: comment, index: index)
                    }
                    let tap2 = UITapGestureRecognizer()
                    tap2.add {
                        self.tapAudioAttach(comment: comment, index: index)
                    }
                    let tap3 = UITapGestureRecognizer()
                    tap3.add {
                        self.tapAudioAttach(comment: comment, index: index)
                    }
                    audioImage.isUserInteractionEnabled = true
                    artistLabel.isUserInteractionEnabled = true
                    audioLabel.isUserInteractionEnabled = true
                    
                    audioImage.addGestureRecognizer(tap)
                    artistLabel.addGestureRecognizer(tap2)
                    audioLabel.addGestureRecognizer(tap3)
                    
                    images.append(audioImage)
                }
            }
        }
        
        return topY
    }
    
    func setLikesButton(comment: Comments) {
        likesButton.setTitle("\(comment.countLikes)", for: UIControl.State.normal)
        likesButton.setTitle("\(comment.countLikes)", for: UIControl.State.selected)
        
        if comment.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: UIControl.State.normal)
            likesButton.setTitleColor(UIColor.purple, for: UIControl.State.selected)
            likesButton.setTitleColor(UIColor.purple, for: UIControl.State.disabled)
            likesButton.setImage(UIImage(named: "filled-like_comment")?.tint(tintColor:  UIColor.purple), for: UIControl.State.normal)
            likesButton.setImage(UIImage(named: "filled-like_comment")?.tint(tintColor:  UIColor.purple), for: UIControl.State.selected)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: UIControl.State.normal)
            likesButton.setTitleColor(UIColor.darkGray, for: UIControl.State.selected)
            likesButton.setTitleColor(UIColor.darkGray, for: UIControl.State.disabled)
            likesButton.setImage(UIImage(named: "filled-like_comment")?.tint(tintColor:  UIColor.darkGray), for: UIControl.State.normal)
            likesButton.setImage(UIImage(named: "filled-like_comment")?.tint(tintColor:  UIColor.darkGray), for: UIControl.State.selected)
        }
    }

    func configureLikesButton(comment: Comments, topY: CGFloat) -> CGFloat {
        
        likesButton.tag = 100
        likesButton.titleLabel?.font = likeFont
        likesButton.contentHorizontalAlignment = .right
        likesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        likesButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 10)
        
        setLikesButton(comment: comment)
        
        likesButton.frame = CGRect(x: UIScreen.main.bounds.width - leftInsets - likesButtonWidth, y: topY + vertInsets, width: likesButtonWidth, height: likesButtonHeight)
        self.addSubview(likesButton)
        
        return topY + vertInsets + likesButtonHeight
    }
    
    func getCommentLabelSize(text: String, font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - avatarHeight - 3 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 0.0
        }
        
        let size = CGSize(width: ceil(width), height: ceil(height))
        return size
    }
    
    func configureCommentLabel(comment: Comments, topY: CGFloat) -> CGFloat {
    
        commentLabel.tag = 100
        commentLabel.text = comment.text
        commentLabel.prepareTextForPublish2(self.delegate)
        commentLabel.font = commFont
        commentLabel.textAlignment = .left
        commentLabel.contentMode = .center
        commentLabel.numberOfLines = 0
                
        let size = getCommentLabelSize(text: comment.text.prepareTextForPublic(), font: commFont)
        let pointX = avatarHeight + 2 * leftInsets
        let pointY = topY + vertInsets
            
        commentLabel.frame = CGRect(x: pointX, y: pointY, width: size.width, height: size.height)
        self.addSubview(commentLabel)

        return topY + vertInsets + size.height
    }
    
    func configureDateLabel(comment: Comments, profiles: [CommentsProfiles], groups: [CommentsGroups], tableView: UITableView, topY: CGFloat) {
        
        dateLabel.tag = 100
        
        let text = comment.date.toStringCommentLastTime()
        var replyText = ""
        if comment.replyComment != 0 {
            var sex = 0
            if comment.fromID > 0 {
                let current = profiles.filter({ $0.uid == comment.fromID })
                if current.count > 0 {
                    sex = current[0].sex
                }
            }
            
            if comment.replyUser > 0 {
                let users = profiles.filter({ $0.uid == comment.replyUser })
                if users.count > 0 {
                    if sex == 1 {
                        replyText = "ответила \(users[0].firstNameDat)"
                    } else {
                        replyText = "ответил \(users[0].firstNameDat)"
                    }
                } else {
                    if sex == 1 {
                        replyText = "ответила на комментарий"
                    } else {
                        replyText = "ответил на комментарий"
                    }
                }
            } else if comment.replyUser < 0 {
                let group = groups.filter({ $0.gid == abs(comment.replyUser) })
                if group.count > 0 {
                    if sex == 1 {
                        replyText = "ответила сообществу «\(group[0].name)»"
                    } else {
                        replyText = "ответил сообществу «\(group[0].name)»"
                    }
                } else {
                    if sex == 1 {
                        replyText = "ответила сообществу"
                    } else {
                        replyText = "ответил сообществу"
                    }
                }
            }
        }
        
        dateLabel.text = "\(text)"
        if replyText != "" {
            dateLabel.text = "\(text) \(replyText)"
            let fullString = "\(text) \(replyText)"
            let range = (fullString as NSString).range(of: replyText)
            
            let attributedString = NSMutableAttributedString(string: fullString)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor:  dateLabel.tintColor], range: range)
            dateLabel.attributedText = attributedString
        }
        
        dateLabel.font = dateFont
        dateLabel.textAlignment = .left
        dateLabel.contentMode = .center
        dateLabel.numberOfLines = 2
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.8
        dateLabel.contentMode = .bottom
        dateLabel.isEnabled = false
        
        dateLabel.frame = CGRect(x: avatarHeight + 2 * leftInsets, y: topY + vertInsets, width: UIScreen.main.bounds.width - avatarHeight - 3 * leftInsets - likesButtonWidth, height: 30)
        self.addSubview(dateLabel)
    }
    
    func configureAvatar(comment: Comments, profiles: [CommentsProfiles], groups: [CommentsGroups], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        var url = ""
        var name = ""
        if comment.fromID > 0 {
            let owner = profiles.filter({ $0.uid == comment.fromID })
            if owner.count > 0 {
                url = owner[0].photoURL
                name = "\(owner[0].firstName) \(owner[0].lastName)"
            }
        } else {
            let owner = groups.filter({ $0.gid == abs(comment.fromID) })
            if owner.count > 0 {
                url = owner[0].photoURL
                name = owner[0].name
            }
        }
        
        nameLabel.tag = 100
        nameLabel.text = name
        nameLabel.font = nameFont
        nameLabel.textAlignment = .left
        nameLabel.contentMode = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        nameLabel.frame = CGRect(x: avatarHeight + 2 * leftInsets, y: topInsets, width: UIScreen.main.bounds.width - avatarHeight - 3 * leftInsets, height: 22)
        self.addSubview(nameLabel)
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 19
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        avatarImage.tag = 100
        avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
        self.addSubview(avatarImage)
    }
    
    func getRowHeight(comment: Comments) -> CGFloat {
        
        let avatarTop = topInsets + avatarHeight + topInsets
        var topY = topInsets + 22
        let size = getCommentLabelSize(text: comment.text.prepareTextForPublic(), font: commFont)
        
        topY += vertInsets + size.height + vertInsets + likesButtonHeight + topInsets
        
        if comment.attach.count > 0 {
            for index in 0...comment.attach.count-1 {
                if comment.attach[index].type != "" {
                    if comment.attach[index].type == "photo" {
                        
                        let width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                        let height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                        topY = topY + height + vertInsets
                    }
                    
                    if comment.attach[index].type == "video" {
                        var height: CGFloat = 0
                        if CGFloat(comment.attach[index].photoWidth) < UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight {
                            
                            height = CGFloat(comment.attach[index].photoHeight)
                        } else {
                            let width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                            
                            height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                        }
                        
                        topY = topY + height + vertInsets
                    }
                    
                    if comment.attach[index].type == "sticker" {
                        topY = topY + stickerHeight
                    }
                    
                    if comment.attach[index].type == "doc" {
                        var width: CGFloat = 0.0
                        var height: CGFloat = 0.0
                        if CGFloat(comment.attach[index].photoWidth) < UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight {
                            
                            width = CGFloat(comment.attach[index].photoWidth)
                            height = CGFloat(comment.attach[index].photoHeight)
                        } else {
                            width = UIScreen.main.bounds.width - 5 * leftInsets - avatarHeight
                            
                            height = width * CGFloat(comment.attach[index].photoHeight) / CGFloat(comment.attach[index].photoWidth)
                        }
                        
                        topY = topY + vertInsets + height
                    }
                    
                    if comment.attach[index].type == "audio" {
                        topY = topY + audioImageSize + 2 * topLinkInsets
                    }
                    
                }
            }
        }
        
        if avatarTop > topY {
            return avatarTop
        }
        
        return topY
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            position = touch.location(in: self)
        }
    }
    
    func getActionOnClickPosition(touch: CGPoint, comment: Comments) -> String {
        
        var res = "comment"
        
        if touch.y >= avatarImage.frame.minY && touch.y < avatarImage.frame.maxY && touch.x >= avatarImage.frame.minX && touch.x < avatarImage.frame.maxX {
            
            res = "show_owner"
        }
        
        if touch.y >= nameLabel.frame.minY && touch.y < nameLabel.frame.maxY && touch.x >= nameLabel.frame.minX && touch.x < nameLabel.frame.maxX {
            
            res = "show_owner"
        }
        
        if comment.attach.count > 0 {
            for index in 0...comment.attach.count-1 {
                if comment.attach[index].type == "photo" {
                    if touch.y >= images[index].frame.minY && touch.y < images[index].frame.maxY && touch.x >= images[index].frame.minX && touch.x < images[index].frame.maxX {
                        
                        res = "show_photo_\(index)"
                    }
                }
                
                if comment.attach[index].type == "video" {
                    if touch.y >= images[index].frame.minY && touch.y < images[index].frame.maxY && touch.x >= images[index].frame.minX && touch.x < images[index].frame.maxX {
                        
                        res = "show_video_\(index)"
                    }
                }
                
                if comment.attach[index].type == "doc" && comment.attach[index].ext == "gif" {
                    if touch.y >= images[index].frame.minY && touch.y < images[index].frame.maxY && touch.x >= images[index].frame.minX && touch.x < images[index].frame.maxX {
                        
                        res = "save_gif_\(index)"
                    }
                }
                
                if comment.attach[index].type == "audio" {
                    if touch.y >= images[index].frame.minY - topLinkInsets && touch.y < images[index].frame.maxY + topLinkInsets && touch.x >= images[index].frame.minX {
                        
                        res = "show_music_\(index)"
                    }
                }
            }
        }
        
        return res
    }
    
    func tapAudioAttach(comment: Comments, index: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Открыть песню в ITunes", style: .default) { action in
            
            ViewControllerUtils().showActivityIndicator(uiView: self.delegate.view)
            self.delegate.getITunesInfo(searchString: "\(comment.attach[index].title) \(comment.attach[index].artist)", searchType: "song")
        }
        alertController.addAction(action1)
        
        let action3 = UIAlertAction(title: "Открыть исполнителя в ITunes", style: .default) { action in
            
            ViewControllerUtils().showActivityIndicator(uiView: self.delegate.view)
            self.delegate.getITunesInfo(searchString: "\(comment.attach[index].artist)", searchType: "artist")
        }
        alertController.addAction(action3)
        
        let action2 = UIAlertAction(title: "Скопировать название", style: .default) { action in
            
            let link = "\(comment.attach[index].artist). \(comment.attach[index].title)"
            UIPasteboard.general.string = link
            if let string = UIPasteboard.general.string {
                self.delegate.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
            }
        }
        alertController.addAction(action2)
        
        self.delegate.present(alertController, animated: true)
    }
}
