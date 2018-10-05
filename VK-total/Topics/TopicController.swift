//
//  TopicController.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON
import DCCommentView
import Popover

class TopicController: UIViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate {

    var groupID = ""
    var topicID = ""
    
    var group: [GroupProfile] = []
    
    var offset = 0
    var count = 30
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    var topics: [Topic] = []
    var topicProfiles: [WallProfiles] = []
    
    var comments: [Comments] = []
    var profiles: [CommentsProfiles] = []
    var groups: [CommentsGroups] = []
    var total = 0

    var tableView: UITableView!
    var commentView: DCCommentView!
    
    var delegate: UIViewController!
    
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
            
            self.createTableView()
        }
        
        getTopicComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTableView() {
        tableView = UITableView()
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        commentView.tabHeight = self.tabHeight
        
        if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(self.groupID)!) {
            setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        } else {
            setCommentFromGroupID(id: 0, controller: self)
        }
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.tintColor = vkSingleton.shared.mainColor
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TopicTitleCell.self, forCellReuseIdentifier: "groupCell")
        tableView.register(TopicCell.self, forCellReuseIdentifier: "topicCell")
        tableView.register(CommentCell2.self, forCellReuseIdentifier: "commentCell")
        
        tableView.separatorStyle = .none
        //self.view.addSubview(tableView)
    }
    
    @objc func tapFromGroupButton(sender: UIButton) {
        sender.buttonTouched(controller: self)
        
        self.commentView.endEditing(true)
        self.actionFromGroupButton(fromView: commentView.fromGroupButton)
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
                        self.createTopicComment(text: "", attachments: "", stickerID: product[index], guid: "\(Date().timeIntervalSince1970)", controller: self)
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
        self.openNewCommentController(ownerID: "-\(groupID)", message: commentView.textView.text!, type: "new_topic_comment", title: "Новый комментарий", replyID: 0, replyName: "", comment: nil, controller: self)
    }
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        createTopicComment(text: text!, attachments: "", stickerID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
    }
    
    func getTopicComments() {
        let opq = OperationQueue()
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView)
        }
        
        let url = "/method/board.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_id": "\(topicID)",
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "sort": "desc",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseComments = ParseComments2()
        parseComments.addDependency(getServerDataOperation)
        opq.addOperation(parseComments)
        
        let url2 = "/method/board.getTopics"
        let parameters2 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_ids": "\(topicID)",
            "extended": "1",
            "preview": "1",
            "preview_length": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        let parseTopics = ParseTopics()
        parseTopics.addDependency(getServerDataOperation2)
        opq.addOperation(parseTopics)
        
        let url3 = "/method/groups.getById"
        let parameters3 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        opq.addOperation(getServerDataOperation3)
        
        // парсим объект
        let parseGroupProfile = ParseGroupProfile()
        parseGroupProfile.addDependency(getServerDataOperation3)
        opq.addOperation(parseGroupProfile)
        
        let reloadController = ReloadTopicController(controller: self)
        reloadController.addDependency(parseComments)
        reloadController.addDependency(parseTopics)
        reloadController.addDependency(parseGroupProfile)
        OperationQueue.main.addOperation(reloadController)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return group.count
        }
        if section == 1 {
            return topics.count
        }
        if section == 2 {
            return comments.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 60
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! TopicCell
            
            return cell.getRowHeight(topic: topics[0])
        case 2:
            if indexPath.row == 0 {
                if comments.count == total {
                    return 0
                }
                return 40
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell2
            
                let index = comments.count - indexPath.row
                let height = cell.getRowHeight(comment: comments[index])
                return height
            }
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! TopicTitleCell
            
            cell.configureCell(group: group[0], indexPath: indexPath, cell: cell, tableView: tableView)
            cell.selectionStyle = .none
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
            
            let topic = topics[0]
            
            cell.configureCell(topic: topic, group: group, profiles: topicProfiles, indexPath: indexPath, cell: cell, tableView: tableView)
            cell.selectionStyle = .none
            
            return cell
        case 2:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell2
                
                if comments.count < total {
                    var count = self.count
                    if count > total - comments.count {
                        count = total - comments.count
                    }
                    cell.configureCountCell(count: count, total: total - comments.count)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell2
                
                
                let comment = comments[comments.count - indexPath.row]
                
                cell.delegate = self
                cell.configureCell(comment: comment, profiles: profiles, groups: groups, indexPath: indexPath, cell: cell, tableView: tableView)
                
                let tapSelect = UITapGestureRecognizer(target: self, action: #selector(selectComment(sender:)))
                cell.isUserInteractionEnabled = true
                cell.addGestureRecognizer(tapSelect)
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(likeComment(sender:)))
                cell.likesButton.addGestureRecognizer(longPress)
                
                let tapAvatarImage = UITapGestureRecognizer()
                tapAvatarImage.add {
                    self.openProfileController(id: comment.fromID, name: "")
                }
                cell.avatarImage.isUserInteractionEnabled = true
                cell.avatarImage.addGestureRecognizer(tapAvatarImage)
                
                cell.selectionStyle = .none
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let gid = Int("-\(groupID)") {
                self.openProfileController(id: gid, name: "")
            }
        case 1:
            break
        case 2:
            if indexPath.row > 0 {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
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
                        
                        if action == "show_music_\(index)" {
                            
                            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                            alertController.addAction(cancelAction)
                            
                            let action1 = UIAlertAction(title: "Открыть песню в iTunes", style: .default) { action in
                                
                                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                                self.getITunesInfo(searchString: "\(comment.attach[index].title) \(comment.attach[index].artist)", searchType: "song")
                            }
                            alertController.addAction(action1)
                            
                            let action3 = UIAlertAction(title: "Открыть исполнителя в iTunes", style: .default) { action in
                                
                                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                                self.getITunesInfo(searchString: "\(comment.attach[index].artist)", searchType: "artist")
                            }
                            alertController.addAction(action3)
                            
                            let action2 = UIAlertAction(title: "Скопировать название", style: .default) { action in
                                
                                let link = "\(comment.attach[index].artist). \(comment.attach[index].title)"
                                UIPasteboard.general.string = link
                                if let string = UIPasteboard.general.string {
                                    self.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
                                }
                            }
                            alertController.addAction(action2)
                            
                            self.present(alertController, animated: true)
                        }
                    }
                    
                    if action == "comment" {
                        
                    }
                }
            }
        default:
            break
        }
    }
    
    @objc func selectComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                    let comment = comments[comments.count - indexPath.row]
                    
                    var title = ""
                    if "\(comment.fromID)" == vkSingleton.shared.userID {
                        title = "\(comment.date.toStringLastTime()) Вы написали:"
                    } else {
                        if comment.fromID > 0 {
                            let user = profiles.filter({ $0.uid == comment.fromID })
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
                    }
                    
                    if comment.canLike == 1 && comment.userLikes == 0 {
                        let action2 = UIAlertAction(title: "Мне нравится", style: .default) { action in
                            
                            self.likeTopicComment(indexPath: indexPath)
                        }
                        alertController.addAction(action2)
                    }
                    
                    if comment.userLikes == 1 {
                        let action3 = UIAlertAction(title: "Отменить «Мне нравится»", style: .destructive) { action in
                            
                            self.likeTopicComment(indexPath: indexPath)
                        }
                        alertController.addAction(action3)
                    }
                    
                    if comment.countLikes > 0 {
                        let action4 = UIAlertAction(title: "Список «Кому нравится»", style: .default) { action in
                            
                            let url = "/method/likes.getList"
                            let parameters = [
                                "access_token": vkSingleton.shared.accessToken,
                                "type": "topic_comment",
                                "owner_id": "-\(self.groupID)",
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
                            
                            self.openNewCommentController(ownerID: self.groupID, message: comment.text, type: "edit_topic_comment", title: "Редактирование", replyID: 0, replyName: "", comment: comment, controller: self)
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
                                self.deleteTopicComment(commentID: "\(comment.id)", controller: self)
                                
                            }
                            alertView.addButton("Отмена, я передумал") {
                                
                            }
                            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить данный комментарий? Это действие необратимо.")
                        }
                        alertController.addAction(action5)
                    }
                    
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    @objc func likeComment(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                likeTopicComment(indexPath: indexPath)
            }
        }
    }
    
    func likeTopicComment(indexPath: IndexPath) {
        let index = comments.count - indexPath.row
        let comment = comments[index]
        
        if comment.userLikes == 0 {
            let url = "/method/likes.add"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": "topic_comment",
                "owner_id": "-\(groupID)",
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
                    self.comments[index].countLikes += 1
                    self.comments[index].userLikes = 1
                    self.comments[index].canLike = 0
                    OperationQueue.main.addOperation {
                        self.playSoundEffect(vkSingleton.shared.likeSound)
                        if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                            cell.setLikesButton(comment: self.comments[index])
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
                "type": "topic_comment",
                "owner_id": "-\(groupID)",
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
                    self.comments[index].countLikes -= 1
                    self.comments[index].userLikes = 0
                    self.comments[index].canLike = 1
                    OperationQueue.main.addOperation {
                        self.playSoundEffect(vkSingleton.shared.unlikeSound)
                        if let cell = self.tableView.cellForRow(at: indexPath) as? CommentCell2 {
                            cell.setLikesButton(comment: self.comments[index])
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                }
            }
            
            OperationQueue().addOperation(request)
        }
    }
    
    @objc func loadMoreComments() {
        
        let url = "/method/board.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_id": "\(topicID)",
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "sort": "desc",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        
        let parseComments = ParseComments2()
        parseComments.addDependency(getServerDataOperation)
        parseComments.completionBlock = {
            self.offset += self.count
            self.total = parseComments.count
            for comment in parseComments.comments {
                self.comments.append(comment)
            }
            for profile in parseComments.profiles {
                self.profiles.append(profile)
            }
            for group in parseComments.groups {
                self.groups.append(group)
            }
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 2), at: .bottom, animated: true)
                }
            }
        }
        OperationQueue().addOperation(parseComments)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        if topics.count > 0 {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action5 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/topic-\(self.groupID)_\(self.topicID)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на обсуждение:" , msg: "\(string)")
                }
            }
            alertController.addAction(action5)
            
            let action6 = UIAlertAction(title: "Добавить ссылку в «Избранное»", style: .default) { action in
                
                let link = "https://vk.com/topic-\(self.groupID)_\(self.topicID)"
                self.addLinkToFave(link: link, text: "Обсуждение в сообществе «\(self.group[0].name)»:\nтема «\(self.topics[0].title)»")
            }
            alertController.addAction(action6)
            
            if topics[0].isClosed == 0 {
                let action1 = UIAlertAction(title: "Закрыть тему для комментирования", style: .destructive) { action in
                    
                    self.closeTopic(controller: self)
                }
                alertController.addAction(action1)
            } else {
                let action1 = UIAlertAction(title: "Открыть тему для комментирования", style: .default) { action in
                    
                    self.openTopic(controller: self)
                }
                alertController.addAction(action1)
            }
            
            if topics[0].isFixed == 1 {
                let action2 = UIAlertAction(title: "Открепить тему в списке обсуждений", style: .destructive) { action in
                    
                    self.unfixTopic(controller: self)
                }
                alertController.addAction(action2)
            } else {
                let action2 = UIAlertAction(title: "Закрепить тему в списке обсуждений", style: .default) { action in
                    
                    self.fixTopic(controller: self)
                }
                alertController.addAction(action2)
            }
            
            let action3 = UIAlertAction(title: "Изменить заголовок темы обсуждения", style: .default) { action in
                
                self.changeTitleTopic(oldTitle: self.topics[0].title)
            }
            alertController.addAction(action3)
            
            let action4 = UIAlertAction(title: "Удалить тему из списка обсуждений", style: .destructive) { action in
                
                self.deleteATopic()
            }
            alertController.addAction(action4)
            
            present(alertController, animated: true)
        }
    }
    
    func changeTitleTopic(oldTitle: String) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = oldTitle
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            self.editTopic(newTitle: textView.text!, controller: self)
        }
        
        alert.addButton("Отмена", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
        }
        
        alert.showInfo("", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func deleteATopic() {
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
            self.deleteTopic(controller: self)
        }
        
        alertView.addButton("Отмена, я передумал") {
            
        }
        alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить данное обсуждение? Это действие необратимо.")
    }
}
