//
//  VideoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import WebKit
import DCCommentView
import SCLAlertView
import Popover

class VideoController: InnerViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, DCCommentViewDelegate {

    var scrollToComment = false
    var vid = ""
    var ownerID = ""
    var offset = 0
    var count = 30
    var totalComments = 0
    var accessKey = ""
    
    var delegate: UIViewController?
    
    var video = [Videos]()
    var users = [NewsProfiles]()
    var groups = [NewsGroups]()
    
    var likes = [Likes]()
    var reposts = [Likes]()
    
    var comments = [Comments]()
    var commentsProfiles = [CommentsProfiles]()
    var commentsGroups = [CommentsGroups]()
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    var attachments = ""
    
    var navHeight: CGFloat {
           if #available(iOS 13.0, *) {
               return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           } else {
               return UIApplication.shared.statusBarFrame.size.height +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           }
       }
    var tabHeight: CGFloat = 49
    var firstAppear = true
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var rowHeightCache: [IndexPath: CGFloat] = [:]
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = vkSingleton.shared.backColor
        tableView.sectionIndexBackgroundColor = vkSingleton.shared.backColor
        tableView.sectionIndexTrackingBackgroundColor = vkSingleton.shared.backColor
        tableView.separatorColor = vkSingleton.shared.separatorColor
        self.view.backgroundColor = vkSingleton.shared.backColor
        
        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .done, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
            
            configureTableView()
            tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
            
            ViewControllerUtils().showActivityIndicator(uiView: view)
            getVideo()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func getVideo() {
        let url = "/method/video.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "videos": "\(self.ownerID)_\(self.vid)_\(self.accessKey)",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        queue.addOperation(getServerDataOperation)
        
        let parseVideos = ParseVideos()
        parseVideos.addDependency(getServerDataOperation)
        queue.addOperation(parseVideos)
        
        let url2 = "/method/likes.getList"
        let parameters2: Parameters = [
            "type": "video",
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "item_id": self.vid,
            "filter": "likes",
            "extended": "1",
            "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
            
            "count": "1000",
            "skip_own": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        queue.addOperation(getServerDataOperation2)
        
        let parseLikes = ParseLikes()
        parseLikes.addDependency(getServerDataOperation2)
        queue.addOperation(parseLikes)
        
        let url3 = "/method/video.getComments"
        
        let getServerDataOperation3 = GetServerDataOperation4(url: url3, offset: offset, type: "video", record: Record(json: JSON.null))
        getServerDataOperation3.addDependency(parseVideos)
        queue.addOperation(getServerDataOperation3)
        
        let parseComments = ParseComments()
        parseComments.addDependency(getServerDataOperation3)
        queue.addOperation(parseComments)
        
        let url4 = "/method/likes.getList"
        let parameters4: Parameters = [
            "type": "video",
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "item_id": self.vid,
            "filter": "copies",
            "extended": "1",
            "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
            
            "count": "1000",
            "skip_own": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation4 = GetServerDataOperation(url: url4, parameters: parameters4)
        queue.addOperation(getServerDataOperation4)
        
        let parseReposts = ParseLikes()
        parseReposts.addDependency(getServerDataOperation4)
        queue.addOperation(parseReposts)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadVideoController(controller: self)
        reloadTableController.addDependency(parseVideos)
        reloadTableController.addDependency(parseLikes)
        reloadTableController.addDependency(parseComments)
        reloadTableController.addDependency(parseReposts)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        self.createVideoComment(text: text, attachments: attachments, stickerID: 0, replyID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        commentView.endEditing(true)
        
        let stickersView = StickersView()
        stickersView.delegate = self
        stickersView.configure(width: self.view.bounds.width - 40)
        stickersView.show(fromView: self.commentView.stickerButton)
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        self.openNewCommentController(ownerID: ownerID, message: commentView.textView.text!, type: "new_video_comment", title: "Новый комментарий", replyID: 0, replyName: "", comment: nil, controller: self)
    }
    
    func configureTableView() {
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds, color: vkSingleton.shared.backColor)
        commentView.delegate = self
        commentView.textView.backgroundColor = .clear
        commentView.textView.textColor = vkSingleton.shared.labelColor
        commentView.textView.tintColor = vkSingleton.shared.secondaryLabelColor
        commentView.textView.changeKeyboardAppearanceMode()
        commentView.tintColor = vkSingleton.shared.secondaryLabelColor
        
        commentView.sendImage = UIImage(named: "send")
        
        if (vkSingleton.shared.stickers.count > 0) {
            commentView.stickerImage = UIImage(named: "sticker")
            commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        }
        
        commentView.tabHeight = 0
        
        setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        //setCommentFromGroupID(id: 0, controller: self)
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        tableView.register(VideoCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(CommentCell2.self, forCellReuseIdentifier: "commentCell")
    }
    
    @objc func tapFromGroupButton(sender: UIButton) {
        sender.buttonTouched(controller: self)
        
        self.commentView.endEditing(true)
        self.actionFromGroupButton(fromView: commentView.fromGroupButton)
    }
    
    @objc func loadMoreComments() {
        
        rowHeightCache.removeAll(keepingCapacity: false)
        
        let url = "/method/video.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "video_id": vid,
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "sort": "desc",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        
        let parseComments = ParseComments2()
        parseComments.addDependency(getServerDataOperation)
        parseComments.completionBlock = {
            self.offset += self.count
            self.totalComments = parseComments.count
            for comment in parseComments.comments {
                self.comments.append(comment)
            }
            for profile in parseComments.profiles {
                self.commentsProfiles.append(profile)
            }
            for group in parseComments.groups {
                self.commentsGroups.append(group)
            }
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                }
            }
        }
        OperationQueue().addOperation(parseComments)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if comments.count == 0 {
            return video.count
        } else {
            return video.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < video.count {
            return 1
        } else {
            return comments.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < video.count {
            if let height = rowHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCell
                
                let height = cell.getRowHeight(record: video[indexPath.section])
                rowHeightCache[indexPath] = height
                return height
            }
        } else {
            if indexPath.row == 0 {
                if comments.count == totalComments {
                    return 0
                }
                return 40
            } else {
                if let height = rowHeightCache[indexPath] {
                    return height
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell2
                    
                    let height = cell.getRowHeight(comment: comments[comments.count - indexPath.row])
                    rowHeightCache[indexPath] = height
                    return height
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < self.video.count {
            let video = self.video[indexPath.section]
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
            
            cell.configureCell(record: video, profiles: users, groups: groups, likes: likes, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
            cell.likesButton.addTarget(self, action: #selector(self.likeVideo(sender:)), for: .touchUpInside)
            cell.repostsButton.addTarget(self, action: #selector(self.tapRepostButton), for: .touchUpInside)
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell2
                
                if comments.count < totalComments {
                    var count = self.count
                    if count > totalComments - comments.count {
                        count = totalComments - comments.count
                    }
                    cell.configureCountCell(count: count, total: totalComments - comments.count)
                    cell.countButton.addTarget(self, action: #selector(self.loadMoreComments), for: .touchUpInside)
                    
                    cell.selectionStyle = .none
                } else {
                    for subview in cell.subviews {
                        if subview is UIImageView || subview is UILabel || subview is UIButton {
                            subview.removeFromSuperview()
                        }
                    }
                }
                
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell2
                
                let comment = comments[comments.count - indexPath.row]
                
                cell.delegate = self
                cell.configureCell(comment: comment, profiles: commentsProfiles, groups: commentsGroups, indexPath: indexPath, cell: cell, tableView: tableView)
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(likeVideoComment(sender:)))
                cell.likesButton.addGestureRecognizer(longPress)
                
                if comment.replyComment != 0 {
                    let tapReply = UITapGestureRecognizer(target: self, action: #selector(showReplyComment(sender:)))
                    cell.dateLabel.isUserInteractionEnabled = true
                    cell.dateLabel.addGestureRecognizer(tapReply)
                }
                
                let tapSelect = UITapGestureRecognizer(target: self, action: #selector(selectComment(sender:)))
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(tapSelect)
                
                let tapAvatarImage = UITapGestureRecognizer()
                tapAvatarImage.add {
                    self.openProfileController(id: comment.fromID, name: "")
                }
                cell.avatarImage.isUserInteractionEnabled = true
                cell.avatarImage.addGestureRecognizer(tapAvatarImage)
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section < self.video.count {
            let video = self.video[indexPath.section]
            
            let cell = tableView.cellForRow(at: indexPath) as! VideoCell
            
            let action = cell.getActionOnClickPosition(touch: cell.position)
            
            if action == "show_owner" {
                self.openProfileController(id: video.ownerID, name: "")
            }
            
            if action == "show_info_likes" {
                let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
                
                
                likesController.likes = likes
                likesController.reposts = reposts
                likesController.title = "Оценили"
                self.navigationController?.pushViewController(likesController, animated: true)
            }
            
        } else {
            
            if indexPath.row > 0 {
                let cell = self.tableView.cellForRow(at: indexPath) as! CommentCell2
                let comment = comments[comments.count - indexPath.row]
                
                let action = cell.getActionOnClickPosition(touch: cell.position, comment: comment)
                
                if action == "show_owner" {
                    self.openProfileController(id: comment.fromID, name: "")
                }
                
                for index in 0...9 {
                    if action == "show_photo_\(index)" {
                        self.openWallRecord(ownerID: comment.attach[index].ownerID, postID: comment.attach[index].id, accessKey: comment.attach[index].accessKey, type: "photo", scrollToComment: false)
                    }
                    
                    if action == "show_video_\(index)" {
                        
                        self.openVideoController(ownerID: "\(comment.attach[index].ownerID)", vid: "\(comment.attach[index].id)", accessKey: comment.attach[index].accessKey, title: "Видеозапись", scrollToComment: false)
                    }
                    
                    if action == "save_gif_\(index)" {
                        
                        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                        alertController.addAction(cancelAction)
                        
                        let action1 = UIAlertAction(title: "Сохранить GIF на устройство", style: .default) { action in
                            
                            if let url = URL(string: comment.attach[index].videoURL) {
                                
                                OperationQueue().addOperation {
                                    OperationQueue.main.addOperation {
                                        ViewControllerUtils().showActivityIndicator(uiView: self.view)
                                    }
                                    
                                    self.saveGifToDevice(url: url)
                                }
                            }
                            
                        }
                        alertController.addAction(action1)
                        
                        self.present(alertController, animated: true)
                    }
                }
                
                
                if action == "comment" {
                    
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    @objc func selectComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                    let index = comments.count - indexPath.row
                    let comment = comments[index]
                    
                    var title = ""
                    if "\(comment.fromID)" == vkSingleton.shared.userID {
                        title = "\(comment.date.toStringLastTime()) Вы написали:"
                    } else {
                        if comment.fromID > 0 {
                            let user = commentsProfiles.filter({ $0.uid == comment.fromID })
                            if user.count > 0 {
                                if user[0].sex == 1 {
                                    title = "\(comment.date.toStringLastTime())\n\(user[0].firstName) \(user[0].lastName) написала:"
                                } else {
                                    title = "\(comment.date.toStringLastTime())\n\(user[0].firstName) \(user[0].lastName) написал:"
                                }
                            }
                        } else {
                            title = "\(comment.date.toStringLastTime())\nСообщество написало:"
                        }
                    }
                    
                    var mess = comment.text.prepareTextForPublic().replacingOccurrences(of: "\n", with: " ")
                    if mess.length > 100 {
                        mess = "\(String(mess.prefix(100)))..."
                    }
                    
                    if comment.attach.count == 1 {
                        if mess != "" && comment.attach[0].type != "" {
                            mess = "\(mess)\n"
                        }
                        
                        if comment.attach[0].type == "photo" || comment.attach[0].type == "posted_photo"{
                            mess = "\(mess)[Фотография]"
                        } else if comment.attach[0].type == "video" {
                            mess = "\(mess)[Видеозапись]"
                        } else if comment.attach[0].type == "sticker" {
                            mess = "\(mess)[Стикер]"
                        } else if comment.attach[0].type == "gift" {
                            mess = "\(mess)[Подарок]"
                        } else if comment.attach[0].type == "wall" {
                            mess = "\(mess)[Запись на стене]"
                        } else if comment.attach[0].type == "doc" {
                            mess = "\(mess)[Документ]"
                        } else if comment.attach[0].type == "link" {
                            mess = "\(mess)[Ссылка]"
                        }
                    } else if comment.attach.count > 0 {
                        if mess != ""  {
                            mess = "\(mess)\n"
                        }
                        
                        mess = "\(mess)[\(comment.attach.count.attachAdder())]"
                    }
                    
                    let alertController = UIAlertController(title: title, message: mess, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    if vkSingleton.shared.userID != "\(comment.fromID)" {
                        let action5 = UIAlertAction(title: cell.nameLabel.text!, style: .default) { action in
                            self.openProfileController(id: comment.fromID, name: "")
                            
                        }
                        alertController.addAction(action5)
                        
                        let replyName = comment.getReplyCommentFromID(id: comment.fromID, users: commentsProfiles, groups: commentsGroups)
                        
                        let replyText = comment.getReplyTextFromID(id: comment.fromID, users: commentsProfiles, groups: commentsGroups)
                        
                        let action1 = UIAlertAction(title: "Ответить \(replyName)", style: .default) { action in
                            
                            self.openNewCommentController(ownerID: self.ownerID, message: replyText, type: "new_video_comment", title: "Новый комментарий", replyID: comment.id, replyName: replyName, comment: nil, controller: self)
                        }
                        alertController.addAction(action1)
                    }
                    
                    if comment.canLike == 1 && comment.userLikes == 0 {
                        let action2 = UIAlertAction(title: "Мне нравится", style: .default) { action in
                            
                            self.likeVideoCommentManually(indexPath: indexPath)
                        }
                        alertController.addAction(action2)
                    }
                    
                    if comment.userLikes == 1 {
                        let action3 = UIAlertAction(title: "Отменить «Мне нравится»", style: .destructive) { action in
                            
                            self.likeVideoCommentManually(indexPath: indexPath)
                        }
                        alertController.addAction(action3)
                    }
                    
                    if comment.countLikes > 0 {
                        let action4 = UIAlertAction(title: "Список «Кому нравится»", style: .default) { action in
                            
                            let url = "/method/likes.getList"
                            let parameters = [
                                "access_token": vkSingleton.shared.accessToken,
                                "type": "video_comment",
                                "owner_id": "\(self.ownerID)",
                                "item_id": "\(comment.id)",
                                "extended": "1",
                                "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
                                "count": "1000",
                                "skip_own": "0",
                                "v": vkSingleton.shared.version
                            ]
                            
                            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                            OperationQueue().addOperation(getServerDataOperation)
                            
                            let parseLikes = ParseLikes()
                            parseLikes.addDependency(getServerDataOperation)
                            parseLikes.completionBlock = {
                                OperationQueue.main.addOperation {
                                    let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
                                    
                                    likesController.likes = parseLikes.outputData
                                    likesController.title = "Оценили"
                                    self.navigationController?.pushViewController(likesController, animated: true)
                                }
                            }
                            OperationQueue().addOperation(parseLikes)
                            
                        }
                        alertController.addAction(action4)
                    }
                    
                    if "\(comment.fromID)" == vkSingleton.shared.userID || (comment.fromID < 0 && vkSingleton.shared.adminGroupID.contains(abs(comment.fromID))) {
                        let action7  = UIAlertAction(title: "Редактировать", style: .default) { action in
                            
                            self.openNewCommentController(ownerID: self.ownerID, message: comment.text, type: "edit_video_comment", title: "Редактирование", replyID: 0, replyName: "", comment: comment, controller: self)
                        }
                        alertController.addAction(action7)
                        
                        let action5 = UIAlertAction(title: "Удалить", style: .destructive) { action in
                            
                            var titleColor = UIColor.black
                            var backColor = UIColor.white
                            
                            titleColor = vkSingleton.shared.labelColor
                            backColor = vkSingleton.shared.backColor
                            
                            let appearance = SCLAlertView.SCLAppearance(
                                kTitleTop: 32.0,
                                kWindowWidth: UIScreen.main.bounds.width - 40,
                                kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                                kTextFont: UIFont(name: "Verdana", size: 13)!,
                                kButtonFont: UIFont(name: "Verdana", size: 14)!,
                                showCloseButton: false,
                                showCircularIcon: true,
                                circleBackgroundColor: backColor,
                                contentViewColor: backColor,
                                titleColor: titleColor
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            
                            alertView.addButton("Да, я уверен") {
                                
                                self.deleteVideoComment(commentID: "\(comment.id)", controller: self)
                            }
                            alertView.addButton("Отмена, я передумал") {
                                
                            }
                            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить данный комментарий? Это действие необратимо.")
                        }
                        alertController.addAction(action5)
                    }
                    
                    
                    let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                        
                        self.reportOnObject(ownerID: self.ownerID, itemID: "\(comment.id)", type: "video_comment")
                    }
                    alertController.addAction(action6)
                    
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    @objc func showReplyComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                
                let index = comments.count - indexPath.row
                let comment = comments[index]
                
                let url = "/method/video.getComments"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": ownerID,
                    "video_id": vid,
                    "start_comment_id": "\(comment.replyComment)",
                    "count": "1",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                let parseComments = ParseComments2()
                parseComments.addDependency(getServerDataOperation)
                parseComments.completionBlock = {
                    let reply = parseComments.comments
                    let users = parseComments.profiles
                    let groups = parseComments.groups
                    if reply.count > 0 {
                        var name = ""
                        if reply[0].fromID > 0 {
                            let user = users.filter({ $0.uid == reply[0].fromID })
                            if user.count > 0 {
                                if user[0].sex == 1 {
                                    name = "\(user[0].firstName) \(user[0].lastName) написала"
                                } else {
                                    name = "\(user[0].firstName) \(user[0].lastName) написал"
                                }
                            }
                        } else {
                            let group = groups.filter({ $0.gid == abs(reply[0].fromID) })
                            if group.count > 0 {
                                name = "\(group[0].name) написал"
                            }
                        }
                        
                        var text = reply[0].text.prepareTextForPublic()
                        if reply[0].attach.count > 0 {
                            if reply[0].attach.count == 1 {
                                let aType = reply[0].attach[0].type
                                if aType == "photo" {
                                    if text != "" {
                                        text = "\(text)\n[Фотография]"
                                    } else {
                                        text = "[Фотография]"
                                    }
                                } else if aType == "video" {
                                    if text != "" {
                                        text = "\(text)\n[Видеозапись]"
                                    } else {
                                        text = "[Видеозапись]"
                                    }
                                } else if aType == "sticker" {
                                    if text != "" {
                                        text = "\(text)\n[Стикер]"
                                    } else {
                                        text = "[Стикер]"
                                    }
                                } else if aType == "doc" {
                                    if text != "" {
                                        text = "\(text)\n[Документ]"
                                    } else {
                                        text = "[Документ]"
                                    }
                                } else if aType == "audio" {
                                    if text != "" {
                                        text = "\(text)\n[Аудиозапись]"
                                    } else {
                                        text = "[Аудиозапись]"
                                    }
                                }
                            } else {
                                if text != "" {
                                    text = "\(text)\n[\(reply[0].attach.count.attachAdder())]"
                                } else {
                                    text = "[\(reply[0].attach.count.attachAdder())]"
                                }
                            }
                        }
                        
                        self.showInfoMessage(title: "\(reply[0].date.toStringLastTime())\n\(name):", msg: "\n\(text)\n")
                    } else {
                        
                        self.showErrorMessage(title: "Ошибка", msg: "Увы, комментарий, на который отвечали, уже удален.☹️")
                    }
                }
                OperationQueue().addOperation(parseComments)
            }
        }
    }
    
    @IBAction func likeVideo(sender: AnyObject) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            let index = indexPath.section
            
            if index < self.video.count {
                let video = self.video[index]
                
                if video.userLikes == 0 {
                    
                    let url = "/method/likes.add"
                    var parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": "video",
                        "owner_id": "\(video.ownerID)",
                        "item_id": "\(video.id)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    if self.accessKey != "" {
                        parameters["access_key"] = self.accessKey
                    }
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.video[index].countLikes += 1
                            self.video[index].userLikes = 1
                            OperationQueue.main.addOperation {
                                self.playSoundEffect(vkSingleton.shared.likeSound)
                                if let cell = self.tableView.cellForRow(at: indexPath) as? VideoCell {
                                    cell.setLikesButton(record: self.video[index])
                                }
                            }
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                } else {
                    
                    let url = "/method/likes.delete"
                    var parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": "video",
                        "owner_id": "\(video.ownerID)",
                        "item_id": "\(video.id)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    if self.accessKey != "" {
                        parameters["access_key"] = self.accessKey
                    }
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.video[index].countLikes -= 1
                            self.video[index].userLikes = 0
                            OperationQueue.main.addOperation {
                                self.playSoundEffect(vkSingleton.shared.unlikeSound)
                                if let cell = self.tableView.cellForRow(at: indexPath) as? VideoCell {
                                    cell.setLikesButton(record: self.video[index])
                                }
                            }
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
            }
        }
    }
    
    @objc func likeVideoComment(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                let index = indexPath.section
                
                if index == self.video.count {
                    let comment = self.comments[comments.count - indexPath.row]
                    
                    if comment.userLikes == 0 {
                        
                        let url = "/method/likes.add"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "type": "video_comment",
                            "owner_id": "\(self.ownerID)",
                            "item_id": "\(comment.id)",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                self.comments[self.comments.count - indexPath.row].countLikes += 1
                                self.comments[self.comments.count - indexPath.row].userLikes = 1
                                self.comments[self.comments.count - indexPath.row].canLike = 0
                                OperationQueue.main.addOperation {
                                    self.playSoundEffect(vkSingleton.shared.likeSound)
                                    if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                                        cell.setLikesButton(comment: self.comments[self.comments.count - indexPath.row])
                                    }
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    } else {
                        
                        let url = "/method/likes.delete"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "type": "video_comment",
                            "owner_id": "\(self.ownerID)",
                            "item_id": "\(comment.id)",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                self.comments[self.comments.count - indexPath.row].countLikes -= 1
                                self.comments[self.comments.count - indexPath.row].userLikes = 0
                                self.comments[self.comments.count - indexPath.row].canLike = 1
                                OperationQueue.main.addOperation {
                                    self.playSoundEffect(vkSingleton.shared.unlikeSound)
                                    if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                                        cell.setLikesButton(comment: self.comments[self.comments.count - indexPath.row])
                                    }
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                }
            }
        }
    }
    
    func likeVideoCommentManually(indexPath: IndexPath) {
        let index = indexPath.section
            
        if index == self.video.count {
            let comment = self.comments[comments.count - indexPath.row]
            
            if comment.userLikes == 0 {
                
                let url = "/method/likes.add"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "video_comment",
                    "owner_id": "\(self.ownerID)",
                    "item_id": "\(comment.id)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.comments[self.comments.count - indexPath.row].countLikes += 1
                        self.comments[self.comments.count - indexPath.row].userLikes = 1
                        self.comments[self.comments.count - indexPath.row].canLike = 0
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                                cell.setLikesButton(comment: self.comments[self.comments.count - indexPath.row])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                OperationQueue().addOperation(request)
            } else {
                
                let url = "/method/likes.delete"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "video_comment",
                    "owner_id": "\(self.ownerID)",
                    "item_id": "\(comment.id)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.comments[self.comments.count - indexPath.row].countLikes -= 1
                        self.comments[self.comments.count - indexPath.row].userLikes = 0
                        self.comments[self.comments.count - indexPath.row].canLike = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                                cell.setLikesButton(comment: self.comments[self.comments.count - indexPath.row])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                OperationQueue().addOperation(request)
            }
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if let video = self.video.first {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if video.canAdd == 1 {
                let action1 = UIAlertAction(title: "Добавить в «Мои видеозаписи»", style: .default) { action in
                    
                    let url = "/method/video.add"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "target_id": vkSingleton.shared.userID,
                        "owner_id": "\(video.ownerID)",
                        "video_id": "\(video.id)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(video.title)» успешно добавлена.\n")
                        } else {
                            var title = "Ошибка #\(error.errorCode)"
                            var msg = "\n\(error.errorMsg)\n"
                            if error.errorCode == 800 {
                                title = "Мои видеозаписи"
                                msg = "\nЭта видеозапись уже добавлена.\n"
                            }
                            if error.errorCode == 204 {
                                title = "Мои видеозаписи"
                                msg = "\nОшибка. Нет доступа.\n"
                            }
                            self.showErrorMessage(title: title, msg: msg)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            }
            
            if video.userLikes == 0 {
                let action3 = UIAlertAction(title: "Мне нравится", style: .default) { action in
                    
                    let url = "/method/likes.add"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": "video",
                        "owner_id": "\(video.ownerID)",
                        "item_id": "\(video.id)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.video[0].countLikes += 1
                            self.video[0].userLikes = 1
                            OperationQueue.main.addOperation {
                                self.playSoundEffect(vkSingleton.shared.likeSound)
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0), IndexPath(row: 5, section: 0)], with: .none)
                                self.tableView.endUpdates()
                            }
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
                alertController.addAction(action3)
            } else {
                let action3 = UIAlertAction(title: "Отменить «Мне нравится»", style: .destructive) { action in
                    
                    let url = "/method/likes.delete"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": "video",
                        "owner_id": "\(video.ownerID)",
                        "item_id": "\(video.id)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.video[0].countLikes -= 1
                            self.video[0].userLikes = 0
                            OperationQueue.main.addOperation {
                                self.playSoundEffect(vkSingleton.shared.unlikeSound)
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0), IndexPath(row: 5, section: 0)], with: .none)
                                self.tableView.endUpdates()
                            }
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
                alertController.addAction(action3)
            }
            
            if (vkSingleton.shared.userID == "\(video.ownerID)") || (video.ownerID < 0 && vkSingleton.shared.adminGroupID.contains(abs(video.ownerID))) {
                let action4 = UIAlertAction(title: "Удалить видеозапись", style: .destructive) { action in
                    
                    var titleColor = UIColor.black
                    var backColor = UIColor.white
                    
                    titleColor = vkSingleton.shared.labelColor
                    backColor = vkSingleton.shared.backColor
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleTop: 32.0,
                        kWindowWidth: UIScreen.main.bounds.width - 40,
                        kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                        kTextFont: UIFont(name: "Verdana", size: 13)!,
                        kButtonFont: UIFont(name: "Verdana", size: 14)!,
                        showCloseButton: false,
                        showCircularIcon: true,
                        circleBackgroundColor: backColor,
                        contentViewColor: backColor,
                        titleColor: titleColor
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    
                    alertView.addButton("Да, я уверен") {
                        ViewControllerUtils().showActivityIndicator(uiView: self.view)
                        self.deleteVideoFromSite(ownerID: video.ownerID, videoID: video.id, delegate: self.delegate)
                    }
                    
                    alertView.addButton("Отмена, я передумал") {}
                    
                    var subtitle = "Вы уверены, что хотите удалить данную видеозапись? Это действие необратимо."
                    if !video.title.isEmpty {
                        subtitle = "Вы уверены, что хотите удалить видеозапись «\(video.title)»? Это действие необратимо."
                    }
                    
                    alertView.showWarning("Подтверждение!", subTitle: subtitle)
                }
                alertController.addAction(action4)
            }
            
            let action4 = UIAlertAction(title: "Удалить из «Мои видеозаписи»", style: .destructive) { action in
                
                let url = "/method/video.delete"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "target_id": vkSingleton.shared.userID,
                    "owner_id": "\(video.ownerID)",
                    "video_id": "\(video.id)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(video.title)» успешно удалена.\n")
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                OperationQueue().addOperation(request)
            }
            alertController.addAction(action4)
            
            let action5 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на видеозапись:" , msg: "\(string)")
                }
            }
            alertController.addAction(action5)
            
            let action6 = UIAlertAction(title: "Добавить ссылку в «Избранное»", style: .default) { action in
                
                let link = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                self.addLinkToFave(link: link, text: "Видеозапись")
            }
            alertController.addAction(action6)
            
            let action8 = UIAlertAction(title: "Открыть видео ВКонтакте", style: .destructive) { action in
                let url = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                self.openBrowserControllerNoCheck(url: url)
            }
            alertController.addAction(action8)
            
            let action2 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                self.reportOnObject(ownerID: self.ownerID, itemID: self.vid, type: "video")
            }
            alertController.addAction(action2)
            
        
            present(alertController, animated: true)
        }
    }
    
    @objc func tapRepostButton() {
        
        if video.count > 0 {
            let record = video[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if record.userReposted == 0 {
                let action1 = UIAlertAction(title: "Опубликовать на своей стене", style: .default) { action in
                    
                    let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
                    
                    newRecordController.ownerID = vkSingleton.shared.userID
                    newRecordController.type = "repost"
                    newRecordController.message = ""
                    newRecordController.title = "Репост видеозаписи"
                    
                    newRecordController.delegate2 = self
                    
                    if let ownerID = Int(self.ownerID), let id = Int(self.vid) {
                        newRecordController.repostOwnerID = ownerID
                        newRecordController.repostItemID = id
                        newRecordController.repostAccessKey = self.accessKey
                        
                        var title = ""
                        if record.title != "" {
                            title = " \"\(record.title)\""
                        }
                        newRecordController.repostTitle = "Репост видеозаписи\(title)"
                        
                        if let image = UIApplication.shared.screenShot {
                            let attachment = "video\(self.ownerID)_\(self.vid)_\(self.accessKey)"
                            
                            newRecordController.attachments = attachment
                            newRecordController.attach.append(attachment)
                            newRecordController.photos.append(image)
                            newRecordController.isLoad.append(false)
                            newRecordController.typeOf.append("video")
                        }
                    }
                    
                    self.navigationController?.pushViewController(newRecordController, animated: true)
                }
                alertController.addAction(action1)
            }

            
            let action3 = UIAlertAction(title: "Переслать ссылку на видео", style: .default){ action in
                
                let attachment = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action3)
            
            let action2 = UIAlertAction(title: "Переслать сообщением", style: .default){ action in
                
                let getCacheImage = GetCacheImage(url: record.photoURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    let image = getCacheImage.outputImage
                    OperationQueue.main.addOperation {
                        let attachment = "video\(self.ownerID)_\(self.vid)_\(self.accessKey)"
                        self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        }
    }
}
