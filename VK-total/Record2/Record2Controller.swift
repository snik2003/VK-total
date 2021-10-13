//
//  Record2Controller.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DCCommentView
import SCLAlertView
import Photos
import Popover
import CMPhotoCropEditor

class Record2Controller: InnerViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate, PECropViewControllerDelegate {
    
    var delegate: UIViewController!
    var scrollToComment = false
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    
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
    
    var ownerID = ""
    var itemID = ""
    var accessKey = ""
    var count = 30
    var totalComments = 0
    var attachments = ""
    
    var type: String = "post"
    var offset: Int = 0
    
    var news = [Record]()
    var newsProfiles = [RecordProfiles]()
    var newsGroups = [RecordGroups]()
    var photo: Photo!
    var videos = [Videos]()
    
    var likes = [Likes]()
    var reposts = [Likes]()
    
    var comments = [Comments]()
    var commentsProfiles = [CommentsProfiles]()
    var commentsGroups = [CommentsGroups]()
    
    var stickers = [Stickers]()
    
    var rowHeightCache: [IndexPath: CGFloat] = [:]
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
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
    
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
            
            self.configureTableView()
            self.tableView.separatorStyle = .none
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            getRecord()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func configureTableView() {
        tableView.backgroundColor = vkSingleton.shared.backColor
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds, color: vkSingleton.shared.backColor)
        commentView.delegate = self
        commentView.textView.backgroundColor = .clear
        commentView.textView.textColor = vkSingleton.shared.labelColor
        commentView.textView.tintColor = vkSingleton.shared.secondaryLabelColor
        commentView.textView.changeKeyboardAppearanceMode()
        commentView.tintColor = vkSingleton.shared.secondaryLabelColor
        
        commentView.sendImage = UIImage(named: "send")
        
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        commentView.tabHeight = 0
        
        setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(Record2Cell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(CommentCell2.self, forCellReuseIdentifier: "commentCell")
    }
    
    @objc func tapFromGroupButton(sender: UIButton) {
        sender.buttonTouched(controller: self)
        
        self.commentView.endEditing(true)
        self.actionFromGroupButton(fromView: commentView.fromGroupButton)
    }
    
    func configureStickerView(sView: UIView, product: [Int], numProd: Int, width: CGFloat) {
        
        sView.backgroundColor = vkSingleton.shared.backColor
        
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
                        self.createRecordComment(text: "", attachments: "", replyID: 0, guid: "\(Date().timeIntervalSince1970)", stickerID: product[index], controller: self)
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
                        menuButton.backgroundColor = vkSingleton.shared.mainColor.withAlphaComponent(0.5)
                        menuButton.layer.cornerRadius = 10
                        menuButton.layer.borderColor = vkSingleton.shared.mainColor.cgColor
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
        
        sender.buttonTouched(controller: self.delegate)
        commentView.endEditing(true)
        
        if vkSingleton.shared.stickers.count <= 2 {
            let width = self.view.bounds.width - 40
            let height = width + 70
            let stickerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            stickerView.backgroundColor = vkSingleton.shared.backColor
            configureStickerView(sView: stickerView, product: product1, numProd: 1, width: width)
            
            self.popover = Popover(options: self.popoverOptions)
            self.popover.show(stickerView, fromView: self.commentView.stickerButton)
        } else {
            let stickersView = StickersView()
            stickersView.delegate = self
            stickersView.configure(width: self.view.bounds.width - 40)
            stickersView.show(fromView: self.commentView.stickerButton)
        }
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        self.openNewCommentController(ownerID: ownerID, message: commentView.textView.text!, type: "new_record_comment", title: "Новый комментарий", replyID: 0, replyName: "", comment: nil, controller: self)
    }
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        self.createRecordComment(text: text, attachments: attachments, replyID: 0, guid: "\(Date().timeIntervalSince1970)", stickerID: 0, controller: self)
    }
    
    @objc func loadMoreComments() {
    
        var url = ""
        var parameters = ["":""]
        
        rowHeightCache.removeAll(keepingCapacity: false)
        
        if type == "post" {
            url = "/method/wall.getComments"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": ownerID,
                "post_id": itemID,
                "need_likes": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "sort": "desc",
                "preview_length": "0",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
                "v": vkSingleton.shared.version
            ]
        } else if type == "photo" {
            url = "/method/photos.getComments"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": ownerID,
                "photo_id": itemID,
                "need_likes": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "sort": "desc",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
                "v": vkSingleton.shared.version
            ]
        }
        
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
    
    func getRecord() {
        
        rowHeightCache.removeAll(keepingCapacity: false)
        
        if type == "post" {
            
            var code = "var a = API.wall.getById({\"posts\":\"\(ownerID)_\(itemID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":\"1\",\"copy_history_depth\":\"1\",\"fields\":\"id,first_name,last_name,photo_max\",\"v\":\"5.85\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"post\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(itemID)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.wall.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"post_id\":\"\(itemID)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var d = API.likes.getList({\"type\":\"post\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(itemID)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) return [a,b,c,d];"
            
            let url = "/method/execute"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                //print("\(json["response"][2])")
            
                let record = json["response"][0]["items"].compactMap { Record(json: $0.1) }
                let recordProfiles = json["response"][0]["profiles"].compactMap { RecordProfiles(json: $0.1) }
                let recordGroups = json["response"][0]["groups"].compactMap { RecordGroups(json: $0.1) }
                
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                
                let comments = json["response"][2]["items"].compactMap { Comments(json: $0.1) }
                let commentsProfiles = json["response"][2]["profiles"].compactMap { CommentsProfiles(json: $0.1) }
                let commentsGroups = json["response"][2]["groups"].compactMap { CommentsGroups(json: $0.1) }
                let commentsCount = json["response"][2]["count"].intValue
                
                let reposts = json["response"][3]["items"].compactMap { Likes(json: $0.1) }
                
                var videoIDs = ""
                for wall in record {
                    for index in 0...9 {
                        if wall.mediaType[index] == "video" {
                            if videoIDs == "" {
                                if wall.photoAccessKey[index] == "" {
                                    videoIDs = "\(wall.photoOwnerID[index])_\(wall.photoID[index])"
                                } else {
                                    videoIDs = "\(wall.photoOwnerID[index])_\(wall.photoID[index])_\(wall.photoAccessKey[index])"
                                }
                            } else {
                                if wall.photoAccessKey[index] == "" {
                                    videoIDs = "\(videoIDs),\(wall.photoOwnerID[index])_\(wall.photoID[index])"
                                } else {
                                    videoIDs = "\(videoIDs),\(wall.photoOwnerID[index])_\(wall.photoID[index])_\(wall.photoAccessKey[index])"
                                }
                            }
                        }
                    }
                }
                
                if videoIDs != "" {
                    let url2 = "/method/video.get"
                    let parameters2 = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": self.ownerID,
                        "videos": videoIDs,
                        "extended": "0",
                        "fields": "id, first_name, last_name, photo_100",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                    getServerDataOperation2.completionBlock = {
                        guard let data = getServerDataOperation2.data else { return }
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        //print(json)
                        
                        self.videos = json["response"]["items"].compactMap({ Videos(json: $0.1) })
                
                        OperationQueue.main.addOperation {
                            self.news = record
                            self.newsGroups = recordGroups
                            self.newsProfiles = recordProfiles
                            
                            self.likes = likes
                            self.reposts = reposts
                            
                            self.totalComments = commentsCount
                            if self.offset == 0 {
                                self.comments = comments
                                self.commentsGroups = commentsGroups
                                self.commentsProfiles = commentsProfiles
                            } else {
                                for comment in comments {
                                    self.comments.append(comment)
                                }
                                for profile in commentsProfiles {
                                    self.commentsProfiles.append(profile)
                                }
                                for group in commentsGroups {
                                    self.commentsGroups.append(group)
                                }
                            }
                            
                            self.title = "Запись"
                            
                            if self.news.count > 0 {
                                if self.news[0].canComment == 0 {
                                    self.tableView.frame = CGRect(x: 0, y: self.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.navHeight - self.tabHeight)
                                    self.tableView.backgroundColor = vkSingleton.shared.backColor
                                    self.view.addSubview(self.tableView)
                                    self.commentView.removeFromSuperview()
                                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                                } else {
                                    self.view.addSubview(self.commentView)
                                }
                            }
                            
                            self.offset += self.count
                            self.tableView.reloadData()
                            self.tableView.separatorStyle = .singleLine
                            ViewControllerUtils().hideActivityIndicator()
                            
                            if self.scrollToComment && self.comments.count > 0 {
                                self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                                self.scrollToComment = false
                            }
                        }
                    }
                    self.queue.addOperation(getServerDataOperation2)
                } else {
                    OperationQueue.main.addOperation {
                        self.news = record
                        self.newsGroups = recordGroups
                        self.newsProfiles = recordProfiles
                        
                        self.likes = likes
                        self.reposts = reposts
                        
                        self.totalComments = commentsCount
                        if self.offset == 0 {
                            self.comments = comments
                            self.commentsGroups = commentsGroups
                            self.commentsProfiles = commentsProfiles
                        } else {
                            for comment in comments {
                                self.comments.append(comment)
                            }
                            for profile in commentsProfiles {
                                self.commentsProfiles.append(profile)
                            }
                            for group in commentsGroups {
                                self.commentsGroups.append(group)
                            }
                        }
                        
                        self.title = "Запись"
                        
                        if self.news.count > 0 {
                            if self.news[0].canComment == 0 {
                                self.tableView.frame = CGRect(x: 0, y: self.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.navHeight - self.tabHeight)
                                self.tableView.backgroundColor = vkSingleton.shared.backColor
                                self.view.addSubview(self.tableView)
                                self.commentView.removeFromSuperview()
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                            } else {
                                self.view.addSubview(self.commentView)
                            }
                        }
                        
                        self.offset += self.count
                        self.tableView.reloadData()
                        self.tableView.separatorStyle = .singleLine
                        ViewControllerUtils().hideActivityIndicator()
                        
                        if self.scrollToComment && self.comments.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                            self.scrollToComment = false
                        }
                    }
                }
            }
            queue.addOperation(getServerDataOperation)
        } else if type == "photo" {
            
            var code = "var a = API.photos.getById({\"photos\":\"\(ownerID)_\(itemID)_\(accessKey)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(itemID)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.photos.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"photo_id\":\"\(itemID)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var d = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(itemID)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            if let ownerID = Int(self.ownerID), ownerID > 0 {
                code = "\(code) var e = API.users.get({\"user_id\":\"\(ownerID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_max\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            } else if let ownerID = Int(self.ownerID), ownerID < 0{
                code = "\(code) var e = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_id\":\"\(abs(ownerID))\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_hidden_from_feed\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            }
            
            code = "\(code) return [a,b,c,d,e];"
            
            let url = "/method/execute"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json["response"][2]["items"])
            
                let photos = json["response"][0].compactMap { Photo(json: $0.1) }
                
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                
                let comments = json["response"][2]["items"].compactMap { Comments(json: $0.1) }
                let commentsProfiles = json["response"][2]["profiles"].compactMap { CommentsProfiles(json: $0.1) }
                let commentsGroups = json["response"][2]["groups"].compactMap { CommentsGroups(json: $0.1) }
                let commentsCount = json["response"][2]["count"].intValue
                
                let reposts = json["response"][3]["items"].compactMap { Likes(json: $0.1) }
                
                if let ownerID = Int(self.ownerID), ownerID > 0 {
                    let profiles = json["response"][4].compactMap { UserProfileInfo(json: $0.1) }
                    
                    for user in profiles {
                        let profile = RecordProfiles(json: JSON.null)
                        profile.uid = Int(user.uid)!
                        profile.firstName = user.firstName
                        profile.lastName = user.lastName
                        profile.photoURL = user.maxPhotoOrigURL
                        self.newsProfiles.append(profile)
                    }
                } else if let ownerID = Int(self.ownerID), ownerID < 0{
                    let profiles = json["response"][4].compactMap { GroupProfile(json: $0.1) }
                    
                    for group in profiles {
                        let groups = RecordGroups(json: JSON.null)
                        groups.gid = group.gid
                        groups.name = group.name
                        groups.photoURL = group.photo200
                        self.newsGroups.append(groups)
                    }
                }
                
                OperationQueue.main.addOperation {
                    if photos.count > 0 {
                        self.news.removeAll(keepingCapacity: false)
                        let photo = photos[0]
                        
                        self.photo = photo
                        let record = Record(json: JSON.null)
                        record.ownerID = Int(photo.ownerID)!
                        record.fromID = Int(photo.ownerID)!
                        record.id = Int(photo.photoID)!
                        
                        record.mediaType[0] = "photo"
                        record.photoURL[0] = photo.xxbigPhotoURL
                        if record.photoURL[0] == "" { record.photoURL[0] = photo.xbigPhotoURL }
                        if record.photoURL[0] == "" { record.photoURL[0] = photo.bigPhotoURL }
                        if record.photoURL[0] == "" { record.photoURL[0] = photo.photoURL }
                        if record.photoURL[0] == "" { record.photoURL[0] = photo.smallPhotoURL }
                        record.photoID[0] = Int(photo.photoID)!
                        record.photoOwnerID[0] = Int(photo.userID)!
                        record.photoWidth[0] = photo.width
                        record.photoHeight[0] = photo.height
                        record.date = photo.createdTime
                        record.text = photo.text
                        record.userLikes = photo.userLikesThisPhoto
                        record.countLikes = photo.likesCount
                        record.countComments = photo.commentsCount
                        record.countReposts = photo.repostsCount
                        record.canComment = photo.canComment
                        record.canRepost = photo.canRepost
                        record.userPeposted = photo.userRepostedThisPhoto
                        
                        self.news.append(record)
                    }
                    
                    self.title = "Фотография"
                    
                    self.likes = likes
                    self.reposts = reposts
                    
                    self.totalComments = commentsCount
                    if self.offset == 0 {
                        self.comments = comments
                        self.commentsGroups = commentsGroups
                        self.commentsProfiles = commentsProfiles
                    } else {
                        for comment in comments {
                            self.comments.append(comment)
                        }
                        for profile in commentsProfiles {
                            self.commentsProfiles.append(profile)
                        }
                        for group in commentsGroups {
                            self.commentsGroups.append(group)
                        }
                    }
                    
                    if self.news.count > 0 {
                        if self.news[0].canComment == 0 {
                            self.tableView.frame = CGRect(x: 0, y: self.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.navHeight - self.tabHeight)
                            self.tableView.backgroundColor = vkSingleton.shared.backColor
                            self.view.addSubview(self.tableView)
                            self.commentView.removeFromSuperview()
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        } else {
                            self.view.addSubview(self.commentView)
                        }
                    }
                    
                    self.offset += self.count
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .singleLine
                    ViewControllerUtils().hideActivityIndicator()

                    if self.scrollToComment && self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                        self.scrollToComment = false
                    }
                }
            }
            queue.addOperation(getServerDataOperation)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if news.count > 0 {
            if comments.count > 0 {
                return 2
            }
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return news.count
        }
        if section == 1 {
            return comments.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let height = rowHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! Record2Cell
                cell.delegate = self
                
                let height = cell.getRowHeight(record: news[indexPath.row])
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! Record2Cell
            cell.delegate = self
            cell.videos = self.videos
            
            rowHeightCache[indexPath] = cell.configureCell(record: news[indexPath.row], profiles: newsProfiles, groups: newsGroups, likes: likes, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
            
            if news[indexPath.row].postType != "postpone" {
                cell.likesButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
                cell.repostsButton.addTarget(self, action: #selector(self.tapRepostButton), for: .touchUpInside)
            }
            
            if cell.poll != nil {
                for aLabel in cell.answerLabels {
                    let tap = UITapGestureRecognizer()
                    tap.addTarget(self, action: #selector(self.pollVote(sender:)))
                    aLabel.addGestureRecognizer(tap)
                    aLabel.isUserInteractionEnabled = true
                }
            }
            
            cell.selectionStyle = .none
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell2
                
                let comment = comments[comments.count - indexPath.row]
                
                cell.delegate = self
                cell.configureCell(comment: comment, profiles: commentsProfiles, groups: commentsGroups, indexPath: indexPath, cell: cell, tableView: tableView)
                
                let tapLike = UILongPressGestureRecognizer(target: self, action: #selector(likeComment(sender:)))
                cell.likesButton.addGestureRecognizer(tapLike)
                
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
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
        
                    if indexPath.section == 0 {
                        let record = news[indexPath.row]
                        let cell = tableView.cellForRow(at: indexPath) as! Record2Cell
                        
                        let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                        
                        if action == "show_repost_record" {
                            self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post", scrollToComment: false)
                        }
                        
                        if action == "show_owner" {
                            self.openProfileController(id: record.fromID, name: "")
                        }
                        
                        if action == "show_repost_owner" {
                            self.openProfileController(id: record.repostOwnerID, name: "")
                        }
                        
                        for index in 0...9 {
                            if action == "show_photo_\(index)" {
                                let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                                
                                var newIndex = 0
                                for ind in 0...9 {
                                    if record.mediaType[ind] == "photo" {
                                        let photos = Photos(json: JSON.null)
                                        photos.uid = "\(record.photoOwnerID[ind])"
                                        photos.ownerID = "\(record.photoOwnerID[ind])"
                                        photos.pid = "\(record.photoID[ind])"
                                        photos.text = record.photoText[ind]
                                        photos.xxbigPhotoURL = record.photoURL[ind]
                                        photos.xbigPhotoURL = record.photoURL[ind]
                                        photos.bigPhotoURL = record.photoURL[ind]
                                        photos.photoURL = record.photoURL[ind]
                                        photos.width = record.photoWidth[ind]
                                        photos.height = record.photoHeight[ind]
                                        photoViewController.photos.append(photos)
                                        if ind == index {
                                            photoViewController.numPhoto = newIndex
                                        }
                                        newIndex += 1
                                        print("photo text = -\(photos.text)-")
                                    }
                                }
                                
                                photoViewController.delegate = self
                                
                                self.navigationController?.pushViewController(photoViewController, animated: true)
                            }
                            
                            
                            if action == "show_video_\(index)" {
                                
                                self.openVideoController(ownerID: "\(record.photoOwnerID[index])", vid: "\(record.photoID[index])", accessKey: record.photoAccessKey[index], title: "Видеозапись", scrollToComment: false)
                            }
                            
                            if action == "show_gif_\(index)" {
                                
                                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                
                                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                                alertController.addAction(cancelAction)
                                
                                let action1 = UIAlertAction(title: "Сохранить GIF на устройство", style: .default) { action in
                                    
                                    if let url = URL(string: record.videoURL[index]) {
                                        
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
                                
                                self.getITunesInfo2(artist: record.audioArtist[index], title: record.audioTitle[index])
                            }
                        }
                        
                        if action == "show_signer_profile" {
                            self.openProfileController(id: record.signerID, name: "")
                        }
                        
                        if action == "show_info_likes" {
                            let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
                            likesController.likes = likes
                            likesController.reposts = reposts
                            likesController.title = "Оценили"
                            self.navigationController?.pushViewController(likesController, animated: true)
                        }
                    }
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
                        } else if comment.attach[0].type == "doc" && comment.attach[0].ext == "gif" {
                            mess = "\(mess)[Фотография]"
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
                    
                    if (vkSingleton.shared.commentFromGroup == 0 && vkSingleton.shared.userID != "\(comment.fromID)") || (vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup != abs(comment.fromID)){
                        
                        let action5 = UIAlertAction(title: cell.nameLabel.text!, style: .default) { action in
                            self.openProfileController(id: comment.fromID, name: "")
                            
                        }
                        alertController.addAction(action5)
                        
                        let replyName = comment.getReplyCommentFromID(id: comment.fromID, users: commentsProfiles, groups: commentsGroups)
                        
                        let replyText = comment.getReplyTextFromID(id: comment.fromID, users: commentsProfiles, groups: commentsGroups)
                        
                        let action1 = UIAlertAction(title: "Ответить \(replyName)", style: .default) { action in
                            
                            self.openNewCommentController(ownerID: self.ownerID, message: replyText, type: "new_record_comment", title: "Новый комментарий", replyID: comment.id, replyName: replyName, comment: nil, controller: self)
                        }
                        alertController.addAction(action1)
                    }
                    
                    if comment.canLike == 1 && comment.userLikes == 0 {
                        let action2 = UIAlertAction(title: "Мне нравится", style: .default) { action in
                            
                            self.likeCommentManually(indexPath: indexPath)
                        }
                        alertController.addAction(action2)
                    }
                    
                    if comment.userLikes == 1 {
                        let action3 = UIAlertAction(title: "Отменить «Мне нравится»", style: .destructive) { action in
                            
                            self.likeCommentManually(indexPath: indexPath)
                        }
                        alertController.addAction(action3)
                    }
                    
                    if comment.countLikes > 0 {
                        let action4 = UIAlertAction(title: "Список «Кому нравится»", style: .default) { action in
                            
                            var likeType = "comment"
                            if self.type == "photo" {
                                likeType = "photo_comment"
                            }
                            
                            let url = "/method/likes.getList"
                            let parameters = [
                                "access_token": vkSingleton.shared.accessToken,
                                "type": likeType,
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
                        
                        if Int(Date().timeIntervalSince1970) - comment.date <= 24 * 60 * 60 {
                            let action7  = UIAlertAction(title: "Редактировать", style: .default) { action in
                                
                                self.openNewCommentController(ownerID: self.ownerID, message: comment.text, type: "edit_record_comment", title: "Редактирование", replyID: 0, replyName: "", comment: comment, controller: self)
                            }
                            alertController.addAction(action7)
                        }
                    }
                    
                    if "\(comment.fromID)" == vkSingleton.shared.userID || self.ownerID == vkSingleton.shared.userID || (comment.fromID < 0 && vkSingleton.shared.adminGroupID.contains(abs(comment.fromID))) {
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
                                
                                self.deleteRecordComment(commentID: "\(comment.id)", type: self.type, controller: self)
                            }
                            alertView.addButton("Отмена, я передумал") {
                                
                            }
                            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить данный комментарий? Это действие необратимо.")
                        }
                        alertController.addAction(action5)
                    }
                    
                    
                    let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                        
                        self.reportOnObject(ownerID: self.ownerID, itemID: "\(comment.id)", type: "\(self.type)_comment")
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
                
                self.commentView.endEditing(true)
                
                var url = "/method/wall.getComments"
                var parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": ownerID,
                    "post_id": itemID,
                    "start_comment_id": "\(comment.replyComment)",
                    "count": "1",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
                    "v": vkSingleton.shared.version
                ]
                
                if self.type == "photo" {
                    url = "/method/photos.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": ownerID,
                        "photo_id": itemID,
                        "start_comment_id": "\(comment.replyComment)",
                        "count": "1",
                        "preview_length": "0",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
                        "v": vkSingleton.shared.version
                    ]
                }
                
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
    
    @objc func likePost(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.row {
            let record = news[index]
            
            if record.userLikes == 0 {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.add"
                
                var parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": self.type,
                    "owner_id": "\(record.ownerID)",
                    "item_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                if self.type == "photo" && self.accessKey != "" {
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
                        self.news[index].countLikes += 1
                        self.news[index].userLikes = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? Record2Cell {
                                cell.setLikesButton(record: self.news[index])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                likeQueue.addOperation(request)
            } else {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.delete"
                
                var parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": self.type,
                    "owner_id": "\(record.ownerID)",
                    "item_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                if self.type == "photo" && self.accessKey != "" {
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
                        self.news[index].countLikes -= 1
                        self.news[index].userLikes = 0
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? Record2Cell {
                                cell.setLikesButton(record: self.news[index])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                likeQueue.addOperation(request)
                
            }
        }
    }
    
    func likeCommentManually(indexPath: IndexPath) {
        let index = comments.count - indexPath.row
        
        let comment = comments[index]
        
        let owner = news[0].ownerID
        var typeLike = "comment"
        if self.type == "photo" {
            typeLike = "photo_comment"
        }
        
        if comment.userLikes == 0 {
            let likeQueue = OperationQueue()
            
            let url = "/method/likes.add"
            
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": typeLike,
                "owner_id": "\(owner)",
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
                    error.showErrorMessage(controller: self)
                }
            }
            
            likeQueue.addOperation(request)
        } else {
            let likeQueue = OperationQueue()
            
            let url = "/method/likes.delete"
            
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": typeLike,
                "owner_id": "\(owner)",
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
                    error.showErrorMessage(controller: self)
                }
            }
            
            likeQueue.addOperation(request)
            
        }
    }
    
    @objc func likeComment(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            
                let index = comments.count - indexPath.row
                let comment = comments[index]
                
                let owner = news[0].ownerID
                var typeLike = "comment"
                if self.type == "photo" {
                    typeLike = "photo_comment"
                }
                
                if comment.userLikes == 0 {
                    let likeQueue = OperationQueue()
                    
                    let url = "/method/likes.add"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": typeLike,
                        "owner_id": "\(owner)",
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
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    likeQueue.addOperation(request)
                } else {
                    let likeQueue = OperationQueue()
                    
                    let url = "/method/likes.delete"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "type": typeLike,
                        "owner_id": "\(owner)",
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
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    likeQueue.addOperation(request)
                    
                }
            }
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if let record = self.news.first {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action4 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                if self.type == "post" {
                    let link = "https://vk.com/wall\(self.ownerID)_\(self.itemID)"
                    UIPasteboard.general.string = link
                    if let string = UIPasteboard.general.string {
                        self.showInfoMessage(title: "Ссылка на пост:" , msg: "\(string)")
                    }
                } else if self.type == "photo" {
                    let link = "https://vk.com/photo\(self.ownerID)_\(self.itemID)"
                    UIPasteboard.general.string = link
                    if let string = UIPasteboard.general.string {
                        self.showInfoMessage(title: "Ссылка на фотографию:" , msg: "\(string)")
                    }
                }
            }
            alertController.addAction(action4)
            
            let action5 = UIAlertAction(title: "Добавить ссылку в «Избранное»", style: .default) { action in
                
                if self.type == "post" {
                    var text = "Запись на стене"
                    if record.text != "" {
                        text = "Запись на стене:\n\(record.text.prepareTextForPublic().prefix(50))"
                    } else if record.repostText != "" {
                        text = "Запись на стене:\n\(record.repostText.prepareTextForPublic().prefix(50))"
                    }
                    
                    let link = "https://vk.com/wall\(self.ownerID)_\(self.itemID)"
                    self.addLinkToFave(link: link, text: text)
                } else if self.type == "photo" {
                    
                    let link = "https://vk.com/photo\(self.ownerID)_\(self.itemID)"
                    self.addLinkToFave(link: link, text: "Фотография")
                }
            }
            alertController.addAction(action5)
            
            if record.canPin == 1 && record.isPinned == 0 {
                let action1 = UIAlertAction(title: "Закрепить на стене", style: .default) { action in
                    
                    let url = "/method/wall.pin"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(record.ownerID)",
                        "post_id": "\(record.id)",
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
                            self.news[0].isPinned = 1
                            self.showSuccessMessage(title: "Запись на стене", msg: "\nЗапись успешно закреплена на стене\n")
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
                alertController.addAction(action1)
            }
            
            if record.canPin == 1 && record.isPinned == 1 {
                let action1 = UIAlertAction(title: "Открепить на стене", style: .destructive) { action in
                    
                    let url = "/method/wall.unpin"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(record.ownerID)",
                        "post_id": "\(record.id)",
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
                            self.news[0].isPinned = 0
                            self.showSuccessMessage(title: "Запись на стене", msg: "\nЗапись успешно откреплена на стене\n")
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                    
                }
                alertController.addAction(action1)
            }
            
            if record.postType == "post" && record.canDelete == 1 {
                if record.canComment == 1 {
                    let action = UIAlertAction(title: "Закрыть комментирование", style: .destructive) { action in
                        
                        self.closeComments()
                    }
                    alertController.addAction(action)
                } else {
                    let action = UIAlertAction(title: "Открыть комментирование", style: .default) { action in
                        
                        self.closeComments()
                    }
                    alertController.addAction(action)
                }
            }
            
            if record.postType == "postpone" && delegate is PostponedWallController {
                let action6 = UIAlertAction(title: "Опубликовать запись", style: .default) { action in
                    
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
                        self.postponedPost(record: record, delegate: self.delegate)
                        
                    }
                    alertView.addButton("Отмена, я передумал") {
                        
                    }
                    alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите опубликовать эту запись сейчас?\n\nТекущее время публикации:\n\(record.date.toStringLastTime()).")
                }
                alertController.addAction(action6)
            }
            
            if record.canEdit == 1 && (delegate is ProfileController2 || delegate is GroupProfileController2 || delegate is PostponedWallController) {
                let action2 = UIAlertAction(title: "Редактировать запись", style: .default) { action in
                    
                    self.openNewRecordController(ownerID: "\(record.ownerID)", type: "edit", message: record.text, title: "Редактирование", controller: self, delegate: self)
                }
                alertController.addAction(action2)
            }
            
            if record.canDelete == 1 && (delegate is ProfileController2 || delegate is GroupProfileController2 || delegate is PostponedWallController) {
                let action3 = UIAlertAction(title: "Удалить запись", style: .destructive) { action in
                 
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
                        
                        let url = "/method/wall.delete"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": "\(record.ownerID)",
                            "post_id": "\(record.id)",
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
                                OperationQueue.main.addOperation {
                                    self.navigationController?.popViewController(animated: true)
                                    if let delegateController = self.delegate as? ProfileController2 {
                                        delegateController.refresh()
                                    } else if let delegateController = self.delegate as? GroupProfileController2 {
                                        delegateController.refresh()
                                    } else if let delegateController = self.delegate as? PostponedWallController {
                                        
                                        
                                        let preDelegate = delegateController.previousViewController
                                        self.delegate.navigationController?.popViewController(animated: true)
                                        
                                        if let dc = preDelegate as? ProfileController2 {
                                            dc.refresh()
                                        } else if let dc = preDelegate as? GroupProfileController2 {
                                            dc.refresh()
                                        }
                                    }
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertView.addButton("Отмена, я передумал") {
                        
                    }
                    alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить запись? Это действие необратимо.")
                }
                alertController.addAction(action3)
            }
            
            if type == "photo" && photo != nil {
                
                
                let action6 = UIAlertAction(title: "Сохранить фотографию", style: .default) { action in
                    
                    self.copyPhotoToSaveAlbum(ownerID: "\(self.photo.userID)", photoID: "\(self.photo.photoID)", accessKey: self.accessKey)
                }
                alertController.addAction(action6)
                
                let action8 = UIAlertAction(title: "Сохранить на устройство", style: .default) { action in
                    
                    let getCacheImage = GetCacheImage(url: self.photo.xxbigPhotoURL, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        if let image = getCacheImage.outputImage {
                            OperationQueue.main.addOperation {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            }
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    self.showSuccessMessage(title: "Сохранение на устройство", msg: "Фотография успешно сохранена на ваше устройство.")
                }
                alertController.addAction(action8)
                
                let action7 = UIAlertAction(title: "Установить фото на аватар", style: .default) { action in
                    
                    let getCacheImage = GetCacheImage(url: self.photo.bigPhotoURL, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            let controller = PECropViewController()
                            controller.view.backgroundColor = vkSingleton.shared.backColor
                            controller.delegate = self
                            controller.image = getCacheImage.outputImage
                            controller.keepingCropAspectRatio = true
                            controller.cropAspectRatio = 1.0
                            controller.toolbarHidden = true
                            controller.isRotationEnabled = false
                            
                            self.navigationController?.pushViewController(controller, animated: true)
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                }
                alertController.addAction(action7)
                
                if (photo.ownerID == vkSingleton.shared.userID || photo.userID == vkSingleton.shared.userID || photo.userID == "100") &&
                    (delegate is ProfileController2 || delegate is GroupProfileController2 || delegate is PhotoViewController || delegate is PhotoAlbumController) {
                    let action7 = UIAlertAction(title: "Удалить фотографию", style: .destructive) { action in
                        
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
                            
                            self.deletePhotoFromSite(ownerID: self.photo.ownerID, photoID: self.photo.photoID, delegate: self.delegate)
                        }
                        alertView.addButton("Отмена, я передумал") {
                            
                        }
                        alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить фотографию? Это действие необратимо.")
                    }
                    alertController.addAction(action7)
                    
                }
            }
            
            let videos = record.mediaType.filter({ $0 == "video" })
            if videos.count == 1 {
                let action = UIAlertAction(title: "Открыть видео ВКонтакте", style: .destructive) { action in
                    let url = "https://vk.com/video\(record.photoOwnerID[0])_\(record.photoID[0])"
                    self.openBrowserControllerNoCheck(url: url)
                }
                alertController.addAction(action)
            } else if videos.count > 0 {
                let action = UIAlertAction(title: "Открыть видео ВКонтакте", style: .destructive) { action in
                    let alertController2 = UIAlertController(title: "Выберите видеозапись:", message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController2.addAction(cancelAction)
                    
                    for index in 0..<record.mediaType.count {
                        if record.mediaType[index] == "video" {
                            var title = "«\(record.photoText[index])»"
                            if record.photoText[index].isEmpty {
                                title = "Видеозапись (\(record.size[index].getVideoDurationToString())"
                            }
                            
                            let action = UIAlertAction(title: title, style: .default) { action in
                                let url = "https://vk.com/video\(record.photoOwnerID[index])_\(record.photoID[index])"
                                self.openBrowserControllerNoCheck(url: url)
                            }
                            alertController2.addAction(action)
                        }
                    }
                    
                    self.present(alertController2, animated: true)
                }
                alertController.addAction(action)
            }
            
            let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                self.reportOnObject(ownerID: self.ownerID, itemID: self.itemID, type: self.type)
            }
            alertController.addAction(action6)
            
            self.present(alertController, animated: true)
        }
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        controller.dismiss(animated: true)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!, transform: CGAffineTransform, cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        
        let crop = "\(Int(cropRect.minX)),\(Int(cropRect.minY)),\(Int(cropRect.width))"
        self.loadOwnerPhoto(image: controller.image, filename: "photo.jpg", squareCrop: crop)
    }
    
    @objc func tapRepostButton() {
        
        if news.count > 0 {
            let record = news[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if record.canRepost == 1 && record.userPeposted == 0 {
                let action1 = UIAlertAction(title: "Опубликовать на своей стене", style: .default) { action in
                    
                    if self.type == "post" {
                        let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
                        
                        newRecordController.ownerID = vkSingleton.shared.userID
                        newRecordController.type = "repost"
                        newRecordController.message = ""
                        newRecordController.title = "Репост записи"
                        
                
                        newRecordController.repostOwnerID = Int(self.ownerID)!
                        newRecordController.repostItemID = Int(self.itemID)!
                        
                        newRecordController.delegate2 = self
                        
                        if newRecordController.repostOwnerID > 0 {
                            let users = self.newsProfiles.filter({ $0.uid == newRecordController.repostOwnerID })
                            if users.count > 0 {
                                newRecordController.repostTitle = "Репост записи со стены пользователя\n«\(users[0].firstName) \(users[0].lastName)»"
                            }
                        }
                        
                        if newRecordController.repostOwnerID < 0 {
                            let groups = self.newsGroups.filter({ $0.gid == abs(newRecordController.repostOwnerID) })
                            if groups.count > 0 {
                                newRecordController.repostTitle = "Репост записи со стены сообщества\n«\(groups[0].name)»"
                            }
                        }
                        
                        if let image = UIApplication.shared.screenShot {
                            let attachment = "wall\(self.ownerID)_\(self.itemID)"
                            
                            newRecordController.attachments = attachment
                            newRecordController.attach.append(attachment)
                            newRecordController.photos.append(image)
                            newRecordController.isLoad.append(false)
                            newRecordController.typeOf.append("wall")
                        }
                        
                        self.navigationController?.pushViewController(newRecordController, animated: true)
                    } else if self.type == "photo" {
                        let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
                        
                        newRecordController.ownerID = vkSingleton.shared.userID
                        newRecordController.type = "repost"
                        newRecordController.message = ""
                        newRecordController.title = "Репост фотографии"
                        
                        
                        newRecordController.repostOwnerID = Int(self.ownerID)!
                        newRecordController.repostItemID = Int(self.itemID)!
                        newRecordController.repostAccessKey = self.accessKey
                        
                        newRecordController.delegate2 = self
                        
                        var title = ""
                        if record.text != "" {
                            title = record.text
                            if title.length > 90 {
                                title = "\(title.prefix(90))..."
                            }
                            title = " \"\(title)\""
                        }
                        newRecordController.repostTitle = "Репост фотографии\(title)"
                        
                        if let image = UIApplication.shared.screenShot {
                            let attachment = "photo\(self.ownerID)_\(self.itemID)_\(self.accessKey)"
                            
                            newRecordController.attachments = attachment
                            newRecordController.attach.append(attachment)
                            newRecordController.photos.append(image)
                            newRecordController.isLoad.append(false)
                            newRecordController.typeOf.append("photo")
                        }
                        
                        self.navigationController?.pushViewController(newRecordController, animated: true)
                    }
                }
                alertController.addAction(action1)
            }
            
            if self.type == "post" {
                let action3 = UIAlertAction(title: "Переслать ссылку на запись", style: .default){ action in
                
                    let attachment = "https://vk.com/wall\(self.ownerID)_\(self.itemID)"
                    self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
                }
                alertController.addAction(action3)
            } else if self.type == "photo" {
                let action3 = UIAlertAction(title: "Переслать ссылку на фото", style: .default){ action in
                
                    let attachment = "https://vk.com/photo\(self.ownerID)_\(self.itemID)"
                    self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
                }
                alertController.addAction(action3)
            }
            
            let action2 = UIAlertAction(title: "Переслать сообщением", style: .default){ action in
                if self.type == "post" {
                    let attachment = "wall\(self.ownerID)_\(self.itemID)"
                    let image = UIApplication.shared.screenShot
                    self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
                } else if self.type == "photo" {
                    let getCacheImage = GetCacheImage(url: self.photo.bigPhotoURL, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        let image = getCacheImage.outputImage
                        OperationQueue.main.addOperation {
                            let attachment = "photo\(self.ownerID)_\(self.itemID)_\(self.accessKey)"
                            self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                }
                
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        }
    }
    
    func closeComments() {
        
        let record = news[0]
        
        var url = ""
        
        if record.canComment == 1 {
            url = "/method/wall.closeComments"
        } else {
            url = "/method/wall.openComments"
        }
        
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(record.ownerID)",
            "post_id": "\(record.id)",
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
                OperationQueue.main.addOperation {
                    OperationQueue.main.addOperation {
                        self.tableView.removeFromSuperview()
                        self.commentView.removeFromSuperview()
                        
                        self.configureTableView()
                        
                        if record.canComment == 1 {
                            record.canComment = 0
                            
                            self.tableView.frame = CGRect(x: 0, y: self.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - self.navHeight - self.tabHeight)
                            self.view.addSubview(self.tableView)
                            self.commentView.removeFromSuperview()
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        } else {
                            record.canComment = 1
                            self.view.addSubview(self.commentView)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            } else {
                error.showErrorMessage(controller: self)
            }
        }
        OperationQueue().addOperation(request)
    }
}

extension Comments {
    func getReplyCommentFromID(id: Int, users: [CommentsProfiles], groups: [CommentsGroups]) -> String {
        
        var res = ""
        
        if id > 0 {
            let user = users.filter({ $0.uid == id })
            if user.count > 0 {
                res = "\(user[0].firstNameDat)"
            }
        } else {
            let group = groups.filter({ $0.gid == abs(id) })
            if group.count > 0{
                res = "сообществу"
            }
        }
        
        return res
    }
    
    func getReplyTextFromID(id: Int, users: [CommentsProfiles], groups: [CommentsGroups]) -> String {
        
        var res = ""
        
        if id > 0 {
            let user = users.filter({ $0.uid == id })
            if user.count > 0 {
                res = "[id\(id)|\(user[0].firstName)], "
            }
        } else {
            let group = groups.filter({ $0.gid == abs(id) })
            if group.count > 0{
                res = "[club\(abs(id))|\(group[0].name)], "
            }
        }
        
        return res
    }
    
    func allowCommentFromGroup() {
        
        let code1 = "var user = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(vkSingleton.shared.userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        let code2 = "var groups = API.groups.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(vkSingleton.shared.userID)\",\"filter\":\"admin\",\"extended\":\"1\",\"fields\":\"name,cover,members_count,type,is_closed,deactivated,invited_by\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        let code = "\(code1)\(code2)return [user, groups];"
        print("code = \(code)")
    }
}
extension Int {
    func getCounterToString() -> String {
        var str = "\(self)"
        
        if self >= 100000 {
            str = ">100K"
        } else if self >= 10000 {
            let num1 = lround(Double(self) / 1000)
            str = "\(Double(num1) / 10)K"
        }
        
        return str
    }
}

