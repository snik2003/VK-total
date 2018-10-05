//
//  VideoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import DCCommentView
import SCLAlertView
import Popover

class VideoController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, DCCommentViewDelegate {

    var vid = ""
    var ownerID = ""
    var offset = 0
    var count = 30
    var totalComments = 0
    var accessKey = ""
    
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
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var rowHeightCache: [IndexPath: CGFloat] = [:]
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]

    let product1 = [97, 98, 99, 100, 101, 102, 103, 105, 106, 107, 108, 109, 110,
                    111, 112, 113, 114, 115, 116, 118, 121, 125, 126, 127, 128]
    
    let product2 = [1, 2, 3, 4, 10, 13, 14, 15, 18, 21, 22, 25, 27, 28, 29, 30, 31,
                    35, 36, 37, 39, 40, 45, 46, 48]
    
    let product3 = [49, 50, 51, 54, 57, 59, 61, 63, 65, 66, 67, 68, 71, 72, 73, 74, 75,
                    76, 82, 83, 86, 87, 88, 89, 91]
    
    let product4 = [134, 140, 145, 136, 143, 151, 148, 144, 142, 137, 135, 133, 138,
                    156, 150, 153, 149, 147, 141, 159, 164, 161, 130, 132, 160]
    
    let product5 = [215, 232, 231, 211, 214, 218, 224, 225, 209, 226, 229, 223, 210,
                    220, 217, 227, 212, 216, 219, 228, 337, 338, 221, 213, 222]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            if UIScreen.main.nativeBounds.height == 2436 {
                self.navHeight = 88
                self.tabHeight = 83
            }
            
            self.configureTableView()
            
            self.tableView.register(CommentCell2.self, forCellReuseIdentifier: "commentCell")
            
            self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44)
            
            let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .done, target: self, action: #selector(self.tapBarButtonItem(sender:)))
            self.navigationItem.rightBarButtonItem = barButton
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        self.createVideoComment(text: text, attachments: attachments, stickerID: 0, replyID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
    }
    
    func configureStickerView(sView: UIView, product: [Int], numProd: Int, width: CGFloat) {
        
        for subview in sView.subviews {
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        let bWidth = (width - 20) / 5
        for index in 0...product.count-1 {
            let sButton = UIButton()
            sButton.frame = CGRect(x: 10 + bWidth * CGFloat(index % 5) + 3, y: 10 + bWidth * CGFloat(index / 5) + 3, width: bWidth - 6, height: bWidth - 6)
            
            sButton.tag = product[index]
            let url = "https://vk.com/images/stickers/\(product[index])/256.png"
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    sButton.setImage(getCacheImage.outputImage, for: .normal)
                    sButton.add(for: .touchUpInside) {
                        self.createVideoComment(text: "", attachments: "", stickerID: product[index], replyID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
                        self.popover.dismiss()
                    }
                    sView.addSubview(sButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        
        for index in 1...5 {
            var startX = width / 2 - 50 * 2.5 - 10
            var url = "https://vk.com/images/stickers/105/256.png"
            
            if index == 2 {
                startX = width / 2 - 50 * 1.5 - 5
                url = "https://vk.com/images/stickers/3/256.png"
            }
            
            if index == 3 {
                startX = width / 2 - 25
                url = "https://vk.com/images/stickers/63/256.png"
            }
            
            if index == 4 {
                startX = width / 2 + 25 + 5
                url = "https://vk.com/images/stickers/145/256.png"
            }
            
            if index == 5 {
                startX = width / 2 + 50 * 1.5 + 10
                url = "https://vk.com/images/stickers/231/256.png"
            }
            
            let menuButton = UIButton()
            menuButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            menuButton.frame = CGRect(x: startX, y: width + 10, width: 50, height: 50)
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    let image = getCacheImage.outputImage
                    
                    menuButton.layer.cornerRadius = 10
                    menuButton.layer.borderColor = UIColor.gray.cgColor
                    menuButton.layer.borderWidth = 1
                    
                    if index == numProd {
                        menuButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 0.5)
                        menuButton.layer.cornerRadius = 10
                        menuButton.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
                        menuButton.layer.borderWidth = 1
                    }
                    
                    menuButton.setImage(image, for: .normal)
                    
                    if index == 1 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product1, numProd: index, width: width)
                        }
                    }
                    if index == 2 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product2, numProd: index, width: width)
                        }
                    }
                    if index == 3 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product3, numProd: index, width: width)
                        }
                    }
                    if index == 4 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product4, numProd: index, width: width)
                        }
                    }
                    if index == 5 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product5, numProd: index, width: width)
                        }
                    }
                    sView.addSubview(menuButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        commentView.endEditing(true)
        
        let width = self.view.bounds.width - 20
        let height = width + 70
        let stickerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        configureStickerView(sView: stickerView, product: product1, numProd: 1, width: width)
        
        self.popover = Popover(options: self.popoverOptions)
        self.popover.show(stickerView, fromView: self.commentView.stickerButton)
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        self.openNewCommentController(ownerID: ownerID, message: commentView.textView.text!, type: "new_video_comment", title: "Новый комментарий", replyID: 0, replyName: "", comment: nil, controller: self)
    }
    
    func configureTableView() {
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        commentView.tabHeight = self.tabHeight
        
        if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(self.ownerID)!) {
            setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        } else {
            setCommentFromGroupID(id: 0, controller: self)
        }
        
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.tintColor = vkSingleton.shared.mainColor
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
        viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < self.video.count {
            let video = self.video[indexPath.section]
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
            
            cell.webView.navigationDelegate = self
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
                        self.openWallRecord(ownerID: comment.attach[index].ownerID, postID: comment.attach[index].id, accessKey: comment.attach[index].accessKey, type: "photo")
                    }
                    
                    if action == "show_video_\(index)" {
                        
                        self.openVideoController(ownerID: "\(comment.attach[index].ownerID)", vid: "\(comment.attach[index].id)", accessKey: comment.attach[index].accessKey, title: "Видеозапись")
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
                let cell = self.tableView.cellForRow(at: indexPath) as! CommentCell2
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
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleTop: 32.0,
                            kWindowWidth: UIScreen.main.bounds.width - 40,
                            kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                            kTextFont: UIFont(name: "Verdana", size: 13)!,
                            kButtonFont: UIFont(name: "Verdana", size: 14)!,
                            showCloseButton: false,
                            showCircularIcon: true
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
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
                alertController.addAction(action3)
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
                        let title = "Ошибка #\(error.errorCode)"
                        let msg = "\n\(error.errorMsg)\n"
                        self.showErrorMessage(title: title, msg: msg)
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
