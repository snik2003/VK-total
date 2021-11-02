//
//  GroupDialogController.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import DCCommentView
import Popover
import SwiftyJSON

class GroupDialogController: InnerViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var chat: [ChatInfo] = []
    var dialogs: [DialogHistory] = []
    var users: [DialogsUsers] = []
    var chatUsers: [Friends] = []
    
    var startMessageID = -1
    var offset = 0
    var count = 50
    var totalCount = 0
    var mode = ""
    
    var userID = ""
    var groupID = ""
    
    var fwdMessages = ""
    var fwdMessagesID: [Int] = []
    
    let maxCountAttach = 10
    var attachments = ""
    var attachImage: UIImage?
    
    var photos: [UIImage] = []
    var attach: [String] = []
    var typeOf: [String] = []
    var isLoad: [Bool] = []
    
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
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var statusLabel = UILabel()
    var timer = Timer()
    var isTimer = false
    
    let pickerController = UIImagePickerController()
    let pickerController2 = UIImagePickerController()
    var collectionView: UICollectionView!
    
    var markMessages: [Int] = []
    let deleteButton = UIButton()
    let resendButton = UIButton()
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]
    
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = Int(self.groupID) {
            getGroupLongPollServer(groupID: id)
        }
        
        self.navigationItem.hidesBackButton = true
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.tapCloseButton(sender:)))
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
            
            self.configureTableView()
            self.tableView.separatorStyle = .none
            
            self.pickerController.delegate = self
            self.pickerController2.delegate = self
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 80, height: 80)
            
            self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80), collectionViewLayout: layout)
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
            self.collectionView.backgroundColor = self.tableView.backgroundColor
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = true
            self.view.addSubview(self.collectionView)
            
            ViewControllerUtils().showActivityIndicator(uiView: self.commentView)
            getDialog()
            
            self.getAttachments()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OperationQueue.main.addOperation {
            var unread = 0
            for dialog in self.dialogs {
                if dialog.out == 0 && dialog.readState == 0 {
                    unread += 1
                }
            }
            self.markAsReadMessages(controller: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let popover = self.popover {
            self.markMessages.removeAll(keepingCapacity: false)
            self.mode = ""
            popover.dismiss()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapCloseButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    func configureStartView() {
        collectionView.reloadData()
        tableView.reloadData()
        if tableView.numberOfSections > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
        }
        commentView.attachCount = attach.count + fwdMessagesID.count
        print("attachments = \(attachments)")
        print("forward_messages = \(fwdMessages)")
    }
    
    func configureTableView() {
        tableView.backgroundColor = vkSingleton.shared.backColor
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
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
        
        if let gid = Int(self.groupID) {
            setCommentFromGroupID(id: gid, controller: self)
        }
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        tableView.register(DialogCell.self, forCellReuseIdentifier: "dialogCell")
        self.view.addSubview(commentView)
    }
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        
        var isLoadAttach = false
        for load in isLoad {
            if load == true {
                isLoadAttach = true
            }
        }
        
        if !isLoadAttach {
            self.sendMessageGroupDialog(message: text, attachment: self.attachments, fwdMessages: self.fwdMessages, stickerID: 0, controller: self)
        } else {
            self.showInfoMessage(title: "Внимание!", msg: "Дождитесь завершения загрузки вложений.")
        }
    }
    
    func getDialog() {
        
        let opq = OperationQueue()
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        
        let url = "/method/messages.getHistory"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "peer_id": "\(userID)",
            "start_message_id": "-1",
            "group_id": groupID,
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        if startMessageID > 0 {
            parameters["offset"] = "0"
            parameters["start_message_id"] = "\(startMessageID)"
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var userIDs = "\(vkSingleton.shared.userID)"
            
            if let id = Int(self.userID), id > 0 {
                userIDs = "\(id),\(userIDs)"
            }
            
            var groupIDs = self.groupID
            if let id = Int(self.userID), id < 0 {
                groupIDs = "\(id),\(groupIDs)"
            }
            
            for dialog in parseDialog.outputData {
                if dialog.out == 1 { dialog.readState = dialog.id > parseDialog.outRead ? 0 : 1 }
                else if dialog.out == 0 { dialog.readState = dialog.id > parseDialog.inRead ? 0 : 1 }
                
                for index in 0...9 {
                    if dialog.attach[index].type == "wall" {
                        let id = dialog.attach[index].wall[0].fromID
                        if id > 0 {
                            userIDs = "\(id),\(userIDs)"
                        } else {
                            if groupIDs != "" {
                                groupIDs = "\(groupIDs),"
                            }
                            groupIDs = "\(groupIDs)\(abs(id))"
                        }
                    }
                }
                
                if dialog.fwdMessage.count > 0 {
                    for mess in dialog.fwdMessage {
                        let id = mess.userID
                        if id > 0 {
                            userIDs = "\(id),\(userIDs)"
                        } else {
                            if groupIDs != "" {
                                groupIDs = "\(groupIDs),"
                            }
                            groupIDs = "\(groupIDs)\(abs(id))"
                        }
                    }
                }
            }
            
            var code = ""
            
            var index = -1
            var usersIndex = 0
            if userIDs != "" {
                code = "\(code) var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userIDs)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
                index += 1
                usersIndex = index
            }
            
            var groupsIndex = 0
            if groupIDs != "" {
                code = "\(code) var b = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_ids\":\"\(groupIDs)\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
                index += 1
                groupsIndex = index
            }
            
            var returnString = ""
            if userIDs != "" {
                returnString = "a"
            }
            
            if groupIDs != "" {
                if returnString == "" {
                    returnString = "b"
                } else {
                    returnString = "\(returnString),b"
                }
            }
            
            if returnString != "" {
                code = "\(code) return [\(returnString)];"
                
                let url2 = "/method/execute"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "code": code,
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                getServerDataOperation2.addDependency(parseDialog)
                getServerDataOperation2.completionBlock = {
                    guard let data = getServerDataOperation2.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    self.users = json["response"][usersIndex].compactMap { DialogsUsers(json: $0.1) }
                    let groups = json["response"][groupsIndex].compactMap { GroupProfile(json: $0.1) }
                    
                    if groups.count > 0 {
                        for group in groups {
                            let newGroup = DialogsUsers(json: JSON.null)
                            newGroup.uid = "-\(group.gid)"
                            newGroup.firstName = group.name
                            newGroup.maxPhotoOrigURL = group.photo200
                            if group.type == "group" {
                                if group.isClosed == 0 {
                                    newGroup.firstNameAbl = "Открытая группа"
                                } else if group.isClosed == 1 {
                                    newGroup.firstNameAbl = "Закрытая группа"
                                } else {
                                    newGroup.firstNameAbl = "Частная группа"
                                }
                            } else if group.type == "page" {
                                newGroup.firstNameAbl = "Публичная страница"
                            } else {
                                newGroup.firstNameAbl = "Мероприятие"
                            }
                            self.users.append(newGroup)
                        }
                    }
                    
                    for dialog in parseDialog.outputData.reversed() {
                        self.dialogs.append(dialog)
                    }
                    self.totalCount = parseDialog.count
                    
                    OperationQueue.main.addOperation {
                        let users = self.users.filter({ $0.uid == self.userID })
                        if users.count > 0 {
                            let titleItem = UIBarButtonItem(customView: self.setTitleView(user: users[0], status: ""))
                                self.navigationItem.rightBarButtonItem = titleItem
                                self.title = ""
                        }
                        
                        self.offset += self.count
                        self.collectionView.reloadData()
                        self.tableView.reloadData()
                        self.tableView.separatorStyle = .none
                        if self.tableView.numberOfSections > 1 {
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                        }
                        if parseDialog.unread > 0 {
                            self.markAsReadMessages(controller: self)
                        }
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
                opq.addOperation(getServerDataOperation2)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        opq.addOperation(parseDialog)
    }
    
    @objc func loadMoreMessages() {
        
        let opq = OperationQueue()
    
        estimatedHeightCache.removeAll(keepingCapacity: false)
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.commentView)
        }
        
        let startID = dialogs[0].id
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "\(count+1)",
            "peer_id": "\(userID)",
            "start_message_id": "\(startID)",
            "extended": "1",
            "group_id": groupID,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var userIDs = "\(vkSingleton.shared.userID)"
            if let id = Int(self.userID), id > 0 {
                userIDs = "\(id),\(userIDs)"
            }
            
            var groupIDs = ""
            if let id = Int(self.userID), id < 0 {
                groupIDs = "\(abs(id))"
            }
            
            for dialog in parseDialog.outputData {
                for index in 0...9 {
                    if dialog.attach[index].type == "wall" {
                        let id = dialog.attach[index].wall[0].fromID
                        if id > 0 {
                            userIDs = "\(id),\(userIDs)"
                        } else {
                            if groupIDs != "" {
                                groupIDs = "\(groupIDs),"
                            }
                            groupIDs = "\(groupIDs)\(abs(id))"
                        }
                    }
                }
                
                if dialog.fwdMessage.count > 0 {
                    for mess in dialog.fwdMessage {
                        let id = mess.userID
                        if id > 0 {
                            userIDs = "\(id),\(userIDs)"
                        } else {
                            if groupIDs != "" {
                                groupIDs = "\(groupIDs),"
                            }
                            groupIDs = "\(groupIDs)\(abs(id))"
                        }
                    }
                }
            }
            
            let url2 = "/method/users.get"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "user_ids": userIDs,
                "fields": "id, first_name, last_name, last_seen, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, online,  can_write_private_message, sex",
                "name_case": "nom",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            getServerDataOperation2.addDependency(parseDialog)
            opq.addOperation(getServerDataOperation2)
            
            let parseDialogsUsers = ParseDialogsUsers()
            parseDialogsUsers.addDependency(getServerDataOperation2)
            opq.addOperation(parseDialogsUsers)
            
            let url3 = "/method/groups.getById"
            let parameters3 = [
                "access_token": vkSingleton.shared.accessToken,
                "group_ids": groupIDs,
                "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
            opq.addOperation(getServerDataOperation3)
            
            let parseGroupProfile = ParseGroupProfile()
            parseGroupProfile.addDependency(getServerDataOperation3)
            opq.addOperation(parseGroupProfile)
            
            let reloadController = ReloadGroupDialogController(controller: self, startID: startID)
            reloadController.addDependency(parseDialog)
            reloadController.addDependency(parseDialogsUsers)
            reloadController.addDependency(parseGroupProfile)
            OperationQueue.main.addOperation(reloadController)
        }
        parseDialog.addDependency(getServerDataOperation)
        opq.addOperation(parseDialog)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            return dialogs.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogCell
                
                
                cell.drawCell = false
                let height = cell.configureCell(dialog: dialogs[indexPath.row], users: users, indexPath: indexPath, cell: cell, tableView: tableView)
                
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogCell
                
                cell.drawCell = false
                let height = cell.configureCell(dialog: dialogs[indexPath.row], users: users, indexPath: indexPath, cell: cell, tableView: tableView)
                
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if dialogs.count < totalCount {
                return 50
            }
            return 10
        }
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            if typeOf.count > 0 || fwdMessagesID.count > 0 {
                return 100
            }
            return 40
        }
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        if section == 0 {
            view.backgroundColor = .clear
            
            if dialogs.count < totalCount {
                
                let total = totalCount - dialogs.count
                var count = self.count
                if total < count { count = total }
                let countButton = UIButton()
                countButton.setTitle("Загрузить еще \(count) из \(total) сообщений", for: .normal)
                countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
                countButton.contentMode = .center
                countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
                countButton.titleLabel?.adjustsFontSizeToFitWidth = true
                countButton.titleLabel?.minimumScaleFactor = 0.5
                countButton.frame = CGRect(x: 0, y: 10, width: self.view.bounds.width, height: 30)
                countButton.addTarget(self, action: #selector(self.loadMoreMessages), for: .touchUpInside)
                view.addSubview(countButton)
                
                view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
                return view
            }
            
            view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            if typeOf.count > 0 || fwdMessagesID.count > 0 {
                let view = UIView()
                collectionView.frame = CGRect(x: 0, y: 10, width: self.view.bounds.width, height: 80)
                view.backgroundColor = tableView.backgroundColor
                view.addSubview(collectionView)
                view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
                return view
            }
            let view = UIView()
            collectionView.removeFromSuperview()
            view.backgroundColor = .clear
            view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40)
            return view
        }
        let view = UIView()
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogCell
        
        if indexPath.section == 1 {
            cell.delegate = self
            cell.drawCell = true
            
            let _ = cell.configureCell(dialog: dialogs[indexPath.row], users: users, indexPath: indexPath, cell: cell, tableView: tableView)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.actionMessage(sender:)))
            longPress.minimumPressDuration = 0.6
            cell.addGestureRecognizer(longPress)
            
            cell.selectionStyle = .none
        } else {
            for subview in cell.messView.subviews {
                if subview.tag == 200 {
                    subview.removeFromSuperview()
                }
            }
            
            for subview in cell.subviews {
                if subview.tag == 200 {
                    subview.removeFromSuperview()
                }
            }
        }
        
        return cell
    }
    
    @objc func actionMessage(sender: UILongPressGestureRecognizer) {
        
        
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition), indexPath.section == 1 {
                let dialog = dialogs[indexPath.row]
                
                if dialog.action == "" {
                    var title = ""
                    if dialog.out == 1 {
                        title = "\(dialog.date.toStringLastTime()) Вы написали:"
                    } else {
                        let user = users.filter({ $0.uid == "\(dialog.userID)" })
                        if user.count > 0 {
                            if user[0].sex == 1 {
                                title = "\(dialog.date.toStringLastTime())\n\(user[0].firstName) \(user[0].lastName) написала:"
                            } else {
                                title = "\(dialog.date.toStringLastTime())\n\(user[0].firstName) \(user[0].lastName) написал:"
                            }
                        }
                    }
                    
                    var mess = dialog.body.replacingOccurrences(of: "\n", with: " ")
                    if mess.length > 100 {
                        mess = "\(String(mess.prefix(100)))..."
                    }
                    
                    for attach in dialog.attach {
                        if mess != "" && attach.type != "" {
                            mess = "\(mess)\n"
                        }
                        
                        if attach.type == "photo" {
                            mess = "\(mess)[Фотография]"
                        } else if attach.type == "video" {
                            mess = "\(mess)[Видеозапись]"
                        } else if attach.type == "sticker" {
                            mess = "\(mess)[Стикер]"
                        } else if attach.type == "gift" {
                            mess = "\(mess)[Подарок]"
                        } else if attach.type == "wall" {
                            mess = "\(mess)[Запись на стене]"
                        } else if attach.type == "doc" {
                            if let doc = attach.docs.first {
                                if doc.type == 3 {
                                    mess = "\(mess)[GIF]"
                                } else if doc.type == 4 {
                                    mess = "\(mess)[Фотография]"
                                } else if doc.type == 5 {
                                    mess = "\(mess)[Голосовое сообщение]"
                                } else if doc.type == 6 {
                                    mess = "\(mess)[Видеозапись]"
                                } else {
                                    mess = "\(mess)[Документ]"
                                }
                            } else {
                                mess = "\(mess)[Документ]"
                            }
                        }
                    }
                    
                    for fwdMess in dialog.fwdMessage {
                        if fwdMess.userID != 0 {
                            if mess != "" {
                                mess = "\(mess)\n"
                            }
                            mess = "\(mess)[Пересланное сообщение]"
                        }
                    }
                    
                    let alertController = UIAlertController(title: title, message: mess, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Удалить", style: .destructive){ action in
                        
                        self.deleteMessageGroupDialog(messIDs: "\(dialog.id)", forAll: false, spam: false, controller: self)
                    }
                    alertController.addAction(action1)
                    
                    if dialog.out == 1 {
                        if Int(Date().timeIntervalSince1970) - dialog.date < 24 * 60 * 60 {
                            let action2 = UIAlertAction(title: "Удалить для всех", style: .destructive){ action in
                                
                                self.deleteMessageGroupDialog(messIDs: "\(dialog.id)", forAll: true, spam: false, controller: self)
                            }
                            alertController.addAction(action2)
                        }
                    }
                    
                    if dialog.out == 0 {
                        let action5 = UIAlertAction(title: "Пометить как спам", style: .destructive){ action in
                            
                            self.deleteMessageGroupDialog(messIDs: "\(dialog.id)", forAll: false, spam: true, controller: self)
                        }
                        alertController.addAction(action5)
                    }
                    
                    if dialog.canEdit() {
                        let action3 = UIAlertAction(title: "Редактировать", style: .default){ action in
                            
                            self.tapEditMessage(dialog: dialog)
                        }
                        alertController.addAction(action3)
                    }
                    
                    if dialog.body != "" {
                        let action4 = UIAlertAction(title: "Скопировать текст", style: .default){ action in
                            
                            UIPasteboard.general.string = dialog.body
                            if let string = UIPasteboard.general.string {
                                self.showInfoMessage(title: "Скопированное сообщение:" , msg: "\(string)")
                            }
                        }
                        alertController.addAction(action4)
                    }
                    
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    func tapEditMessage(dialog: DialogHistory) {
        
        let editController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
        
        editController.ownerID = self.userID
        editController.type = "edit_message"
        editController.message = dialog.body
        editController.title = "Редактировать"
        
        editController.delegate2 = self
        editController.dialog = dialog
        
        self.navigationController?.pushViewController(editController, animated: true)
    }
    
    func forwardMarkMessages() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Переслать \(markMessages.count.messageAdder())", style: .destructive){ action in
            
            self.openDialogsController(attachments: "", image: nil, messIDs: self.markMessages, source: "forward_message")
            self.markMessages.removeAll(keepingCapacity: false)
            self.mode = ""
            self.popover.dismiss()
            self.tableView.reloadData()
            if self.tableView.numberOfSections > 1 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
            }
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
}

extension GroupDialogController {
    func setChatTitleView(chatInfo: [ChatInfo]) -> UIView {
        
        let view = UIView(frame: CGRect(x: UIScreen.main.bounds.width - 250, y: 8, width: 250, height: 40))
        
        if chatInfo.count > 0 {
            let chat = chatInfo[0]
            
            let imageView = UIImageView()
            
            var url = chat.photo100
            if url == "" {
                url = "https://vk.com/images/community_200.png"
            }
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    imageView.image = getCacheImage.outputImage
                    imageView.layer.cornerRadius = 19
                    imageView.layer.borderWidth = 1.6
                    imageView.layer.borderColor = UIColor.white.cgColor
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.frame = CGRect(x: 214, y: 1, width: 38, height: 38)
                    imageView.contentMode = .scaleAspectFill
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            view.addSubview(imageView)
            
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.addTarget(self, action: #selector(self.tapAvatar))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tap)
            
            let nameLabel = UILabel()
            nameLabel.text = chat.title
            nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.4
            nameLabel.textAlignment = .right
            nameLabel.textColor = UIColor.white
            nameLabel.frame = CGRect(x: 0, y: 4, width: 200, height: 20)
            view.addSubview(nameLabel)
            
            statusLabel.text = "групповой чат (\(chat.membersCount.membersAdder()))"
            statusLabel.textColor = UIColor.white
            statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
            statusLabel.adjustsFontSizeToFitWidth = true
            statusLabel.minimumScaleFactor = 0.4
            statusLabel.textAlignment = .right
            statusLabel.frame = CGRect(x: 0, y: 20, width: 200, height: 16)
            
            view.addSubview(statusLabel)
        }
        
        return view
    }
    
    func setTitleView(user: DialogsUsers, status: String) -> UIView {
        
        let view = UIView(frame: CGRect(x: UIScreen.main.bounds.width - 250, y: 8, width: 250, height: 40))
        
        let groups = users.filter({ $0.uid == "-\(self.groupID)"})
        if groups.count > 0 {
            let groupImageView = UIImageView()
            let getCacheImage = GetCacheImage(url: groups[0].maxPhotoOrigURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    groupImageView.image = getCacheImage.outputImage
                    groupImageView.layer.cornerRadius = 19
                    groupImageView.layer.borderWidth = 2
                    groupImageView.layer.borderColor = UIColor.white.cgColor
                    groupImageView.contentMode = .scaleAspectFill
                    groupImageView.clipsToBounds = true
                    groupImageView.frame = CGRect(x: 214, y: 1, width: 38, height: 38)
                    groupImageView.contentMode = .scaleAspectFill
                }
            }
            OperationQueue().addOperation(getCacheImage)
            view.addSubview(groupImageView)
            
            let tap2 = UITapGestureRecognizer()
            tap2.numberOfTapsRequired = 1
            tap2.add {
                if let id = Int("-\(self.groupID)") {
                    self.openProfileController(id: id, name: "")
                }
            }
            groupImageView.isUserInteractionEnabled = true
            groupImageView.addGestureRecognizer(tap2)
        }
        
        let imageView = UIImageView()
        let getCacheImage2 = GetCacheImage(url: user.maxPhotoOrigURL, lifeTime: .avatarImage)
        getCacheImage2.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage2.outputImage
                imageView.layer.cornerRadius = 19
                imageView.layer.borderWidth = 2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 189, y: 1, width: 38, height: 38)
                imageView.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage2)
        view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(self.tapAvatar))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.4
        nameLabel.textAlignment = .right
        nameLabel.textColor = UIColor.white
        nameLabel.frame = CGRect(x: 0, y: 4, width: 175, height: 20)
        view.addSubview(nameLabel)
        
        setStatusLabel(user: user, status: status)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.4
        
        view.addSubview(statusLabel)
        
        return view
    }
    
    func setStatusLabel(user: DialogsUsers, status: String) {
        if status == "" {
            isTimer = false
            timer.invalidate()
            if let id = Int(user.uid), id > 0 {
                if user.deactivated == "" {
                    if user.online == 1 {
                        statusLabel.text = "онлайн"
                        if user.onlineMobile == 1 {
                            statusLabel.text = "онлайн (моб.)"
                        }
                        statusLabel.textColor = UIColor(displayP3Red: 0/255, green: 250/255, blue: 146/255, alpha: 1) //UIColor(displayP3Red: 255/255, green: 47/255, blue: 146/255, alpha: 1)
                        statusLabel.font = UIFont.boldSystemFont(ofSize: 12)
                    } else {
                        if user.sex == 1 {
                            statusLabel.text = "заходила \(user.lastSeen.toStringLastTime())"
                        } else {
                            statusLabel.text = "заходил \(user.lastSeen.toStringLastTime())"
                        }
                        statusLabel.textColor = UIColor.white
                        statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
                    }
                } else {
                    if user.deactivated == "deleted" {
                        statusLabel.text = "страница удалена"
                    } else {
                        statusLabel.text = "страница заблокирована"
                    }
                    statusLabel.textColor = UIColor.white
                    statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
                }
            }
            
            if let id = Int(user.uid), id < 0 {
                statusLabel.text = user.firstNameAbl
                statusLabel.textColor = UIColor.white
                statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
            }
            
            timer.invalidate()
            statusLabel.textAlignment = .right
            statusLabel.frame = CGRect(x: 0, y: 20, width: 175, height: 16)
        } else if !isTimer {
            statusLabel.text = "набирает сообщение..."
            statusLabel.textColor = UIColor.white
            statusLabel.font = UIFont.boldSystemFont(ofSize: 11)
            
            statusLabel.textAlignment = .left
            statusLabel.frame = CGRect(x: 40, y: 20, width: 135, height: 16)
            
            timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector:
                #selector(animateDots), userInfo: nil, repeats: true)
            timer.fire()
            isTimer = true
        }
    }
    
    @objc func animateDots() {
        switch (statusLabel.text!) {
        case "набирает сообщение":
            statusLabel.text = "набирает сообщение."
        case "набирает сообщение.":
            statusLabel.text = "набирает сообщение.."
        case "набирает сообщение..":
            statusLabel.text = "набирает сообщение..."
        case "набирает сообщение...":
            statusLabel.text = "набирает сообщение"
        default:
            statusLabel.text = "набирает сообщение..."
        }
        statusLabel.textColor = UIColor.white
    }
    
    @objc func tapAvatar() {
        
        commentView.endEditing(true)
        
        if let id = Int(self.userID) {
            self.openProfileController(id: id, name: "")
        }
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        
        commentView.endEditing(true)
        
        let stickersView = StickersView()
        stickersView.delegate = self
        stickersView.configure(width: self.view.bounds.width - 40)
        stickersView.show(fromView: self.commentView.stickerButton)
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
        commentView.endEditing(true)
        
        if attach.count < maxCountAttach {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action5 = UIAlertAction(title: "Сфотографировать", style: .default){ action in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.pickerController.sourceType = .camera
                    self.pickerController.cameraCaptureMode = .photo
                    self.pickerController.modalPresentationStyle = .fullScreen
                    
                    self.present(self.pickerController, animated: true)
                } else {
                    self.showErrorMessage(title: "Ошибка", msg: "Камера на устройстве не активна.")
                }
            }
            alertController.addAction(action5)
            
            let action2 = UIAlertAction(title: "Фотография с устройства", style: .default){ action in
                
                self.pickerController.allowsEditing = false
                
                self.pickerController.sourceType = .photoLibrary
                self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                
                self.present(self.pickerController, animated: true)
            }
            alertController.addAction(action2)
            
            let action1 = UIAlertAction(title: "Мои фотографии", style: .default){ action in
                let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
                
                photosController.ownerID = vkSingleton.shared.userID
                photosController.title = "Мои фотографии"
                
                photosController.selectIndex = 0
                
                photosController.delegate = self
                photosController.source = "add_message_photo"
                
                self.navigationController?.pushViewController(photosController, animated: true)
            }
            alertController.addAction(action1)
            
            /*let action3 = UIAlertAction(title: "Мои видеозаписи", style: .default){ action in
                let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
                
                videoController.ownerID = vkSingleton.shared.userID
                videoController.type = ""
                videoController.source = "add_message_video"
                videoController.title = "Мои видеозаписи"
                videoController.delegate = self
                
                self.navigationController?.pushViewController(videoController, animated: true)
            }
            alertController.addAction(action3)*/
            
            self.present(alertController, animated: true)
        } else {
            self.showInfoMessage(title: "Внимание!", msg: "Вы достигли максимального количества вложений: \(maxCountAttach)")
        }
    }
    
    func getAttachments() {
        if attachments != "" {
            let comp = attachments.components(separatedBy: "_")
            var type = comp[0].replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: nil)
            type = type.replacingOccurrences(of: "_", with: "")
            type = type.replacingOccurrences(of: "-", with: "")
            
            //print(type)
            if type == "wall" {
                attach.append(attachments)
                typeOf.append("wall")
                isLoad.append(false)
                if let image = attachImage {
                    photos.append(image)
                } else {
                    photos.append(UIImage(named: "add-record")!)
                }
                commentView.attachCount = attach.count + fwdMessagesID.count
            } else if type == "photo" {
                attach.append(attachments)
                typeOf.append("photo")
                isLoad.append(false)
                if let image = attachImage {
                    photos.append(image)
                } else {
                    photos.append(UIImage(named: "error")!)
                }
                commentView.attachCount = attach.count + fwdMessagesID.count
            } else if type == "video" {
                attach.append(attachments)
                typeOf.append("video")
                isLoad.append(false)
                if let image = attachImage {
                    photos.append(image)
                } else {
                    photos.append(UIImage(named: "error")!)
                }
                commentView.attachCount = attach.count + fwdMessagesID.count
            } else {
                commentView.textView.insertText(attachments)
                commentView.setNeedsLayout()
                commentView.layoutSubviews()
                attachments = ""
            }
        }
        setAttachments()
    }
    
    func setAttachments() {
        attachments = ""
        if attach.count > 0 {
            for index in 0...attach.count-1 {
                if attachments != "" {
                    attachments = "\(attachments),"
                }
                attachments = "\(attachments)\(attach[index])"
            }
        }
        
        OperationQueue.main.addOperation {
            self.commentView.attachCount = self.attach.count + self.fwdMessagesID.count
        }
        
        fwdMessages = ""
        if fwdMessagesID.count > 0 {
            for id in fwdMessagesID {
                if fwdMessages != "" {
                    fwdMessages = "\(fwdMessages),"
                }
                fwdMessages = "\(fwdMessages)\(id)"
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if picker == pickerController {
            if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                
                var imageType = "JPG"
                var imagePath = NSURL(string: "photo.jpg")
                var imageData: Data!
                if pickerController.sourceType == .photoLibrary {
                    if #available(iOS 11.0, *) {
                        imagePath = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? NSURL
                    }
                    
                    if (imagePath?.absoluteString?.containsIgnoringCase(find: ".gif"))! {
                        imageType = "GIF"
                        imageData = try! Data(contentsOf: imagePath! as URL)
                    }
                }
                
                commentView.accessoryButton.isEnabled = false
                commentView.stickerButton.isEnabled = false
                
                if imageType == "JPG" {
                    photos.append(chosenImage)
                    isLoad.append(true)
                    typeOf.append("photo")
                    configureStartView()
                    
                    
                    if photos.count > 0 {
                        collectionView.scrollToItem(at: IndexPath(row: 0, section: photos.count-1), at: .centeredHorizontally, animated: true)
                    }
                    
                    loadWallPhotosToServer(ownerID: Int(vkSingleton.shared.userID)!, image: photos[photos.count-1], filename: (imagePath?.absoluteString)!) { attachment in
                        self.attach.append(attachment)
                        self.isLoad[self.photos.count-1] = false
                        self.setAttachments()
                        
                        OperationQueue.main.addOperation {
                            self.configureStartView()
                            self.commentView.accessoryButton.isEnabled = true
                            self.commentView.stickerButton.isEnabled = true
                        }
                    }
                } else if imageType == "GIF" {
                    photos.append(chosenImage)
                    isLoad.append(true)
                    typeOf.append("doc")
                    self.configureStartView()
                    
                    if photos.count > 0 {
                        collectionView.scrollToItem(at: IndexPath(row: 0, section: photos.count-1), at: .centeredHorizontally, animated: true)
                    }
                    
                    loadDocsToServer(ownerID: Int(vkSingleton.shared.userID)!, image: photos[photos.count-1], filename: (imagePath?.absoluteString)!, imageData: imageData!) { attachment in
                        self.attach.append(attachment)
                        self.isLoad[self.photos.count-1] = false
                        self.setAttachments()
                        
                        OperationQueue.main.addOperation {
                            self.configureStartView()
                            self.commentView.accessoryButton.isEnabled = true
                            self.commentView.stickerButton.isEnabled = true
                        }
                    }
                }
            }
        }
        
        if picker == pickerController2 {
            if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                loadChatPhotoToServer(chatID: "", image: chosenImage, filename: "file")
            }
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
}

extension GroupDialogController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if fwdMessagesID.count > 0 {
            return photos.count + 1
        }
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let index = indexPath.section
        
        if indexPath.section < photos.count {
            if !isLoad[index] {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    let deleteView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
                    deleteView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    cell.addSubview(deleteView)
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        deleteView.removeFromSuperview()
                    }
                    alertController.addAction(cancelAction)
                    
                    var titleAlert = "Удалить фотографию"
                    if typeOf[index] == "video" {
                        titleAlert = "Удалить видеозапись"
                    } else if typeOf[index] == "doc" {
                        titleAlert = "Удалить GIF"
                    } else if typeOf[index] == "wall" {
                        titleAlert = "Удалить запись на стене"
                    }
                    
                    let action1 = UIAlertAction(title: titleAlert, style: .destructive) { action in
                        
                        self.photos.remove(at: index)
                        self.attach.remove(at: index)
                        self.isLoad.remove(at: index)
                        self.typeOf.remove(at: index)
                        self.setAttachments()
                        self.configureStartView()
                        self.collectionView.reloadData()
                    }
                    alertController.addAction(action1)
                    
                    if typeOf[index] == "wall" {
                        let action2 = UIAlertAction(title: "Открыть запись на стене", style: .default) { action in
                            
                            self.openBrowserController(url: "https://vk.com/\(self.attach[index])")
                            deleteView.removeFromSuperview()
                        }
                        alertController.addAction(action2)
                    } else if typeOf[index] == "photo" {
                        let action2 = UIAlertAction(title: "Открыть фотографию", style: .default) { action in
                            
                            self.openBrowserController(url: "https://vk.com/\(self.attach[index])")
                            deleteView.removeFromSuperview()
                        }
                        alertController.addAction(action2)
                    } else if typeOf[index] == "video" {
                        let action2 = UIAlertAction(title: "Открыть видеозапись", style: .default) { action in
                            
                            self.openBrowserController(url: "https://vk.com/\(self.attach[index])")
                            deleteView.removeFromSuperview()
                        }
                        alertController.addAction(action2)
                    }
                    
                    present(alertController, animated: true)
                }
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) {
                let deleteView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
                deleteView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                cell.addSubview(deleteView)
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                    deleteView.removeFromSuperview()
                }
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Удалить вложенные сообщения", style: .destructive) { action in
                    
                    self.fwdMessages = ""
                    self.fwdMessagesID.removeAll(keepingCapacity: false)
                    self.setAttachments()
                    self.configureStartView()
                    self.collectionView.reloadData()
                }
                alertController.addAction(action1)
                
                present(alertController, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        
        let subviews = cell.subviews
        for subview in subviews {
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        if indexPath.section < photos.count {
            let photo = photos[indexPath.section]
            
            let imageView = UIImageView()
            imageView.image = photo
            imageView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            imageView.layer.borderWidth = 1.0
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let width = cell.bounds.width
            let height = collectionView.bounds.height
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            cell.addSubview(imageView)
            
            let deleteView = UIImageView()
            deleteView.image = UIImage(named: "delete-sign")
            deleteView.tintColor = UIColor.black
            deleteView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
            deleteView.contentMode = .scaleAspectFill
            deleteView.clipsToBounds = true
            deleteView.frame = CGRect(x: width-15, y: 0, width: 15, height: 15)
            
            cell.addSubview(deleteView)
            
            if typeOf[indexPath.section] == "video" {
                let videoView = UIImageView()
                videoView.image = UIImage(named: "video")
                videoView.contentMode = .scaleAspectFill
                videoView.clipsToBounds = true
                videoView.frame = CGRect(x: width/2-15, y: height/2-15, width: 30, height: 30)
                cell.addSubview(videoView)
            }
            
            if typeOf[indexPath.section] == "doc" {
                let gifView = UIImageView()
                gifView.image = UIImage(named: "gif")
                gifView.contentMode = .scaleAspectFill
                gifView.clipsToBounds = true
                gifView.frame = CGRect(x: width/2-15, y: height/2-15, width: 30, height: 30)
                cell.addSubview(gifView)
            }
            
            if isLoad[indexPath.section] == true {
                let loadImage = UIImageView()
                loadImage.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
                loadImage.frame = CGRect(x: 0, y: 0, width: width, height: height)
                cell.addSubview(loadImage)
                
                let loadLabel = UILabel()
                loadLabel.font = UIFont(name: "Verdana-Bold", size: 10)!
                loadLabel.adjustsFontSizeToFitWidth = true
                loadLabel.minimumScaleFactor = 0.5
                loadLabel.textAlignment = .center
                loadLabel.contentMode = .center
                loadLabel.text = "Загрузка..."
                loadLabel.textColor = UIColor.white
                loadLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
                cell.addSubview(loadLabel)
            }
        } else {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "message")
            imageView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            imageView.layer.borderWidth = 1.0
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let width = cell.bounds.width
            let height = collectionView.bounds.height
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            cell.addSubview(imageView)
            
            let countLabel = UILabel()
            countLabel.text = "вложено\n\(fwdMessagesID.count.messageAdder())"
            countLabel.font = UIFont(name: "Verdana-Bold", size: 12)
            countLabel.backgroundColor = UIColor.clear
            countLabel.textColor = UIColor.black
            countLabel.textAlignment = .center
            countLabel.adjustsFontSizeToFitWidth = true
            countLabel.minimumScaleFactor = 0.5
            countLabel.numberOfLines = 2
            countLabel.frame = CGRect(x: 5, y: 0, width: width-10, height: height)
            
            cell.addSubview(countLabel)
            
            let deleteView = UIImageView()
            deleteView.image = UIImage(named: "delete-sign")
            deleteView.tintColor = UIColor.black
            deleteView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
            deleteView.contentMode = .scaleAspectFill
            deleteView.clipsToBounds = true
            deleteView.frame = CGRect(x: width-15, y: 0, width: 15, height: 15)
            
            cell.addSubview(deleteView)
        }
        
        return cell
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
