//
//  DialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON
import BTNavigationDropdownMenu

class DialogsController: InnerTableViewController {

    var selectedMenu = 0
    let itemsMenu = ["Все диалоги", "Групповые чаты", "Диалоги с сообществами", "Непрочитанные диалоги"]
    
    var isFirstAppear = true
    var isRefresh = false
    var type = ""
    var source = ""
    var attachment = ""
    var attachImage: UIImage?
    
    var offset = 0
    var count = 30
    var totalCount = 0
    
    var menuDialogs: [Message] = []
    var dialogs: [Message] = []
    var users: [DialogsUsers] = []
    
    var fwdMessagesID: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: vkSingleton.shared.labelColor]
        let myAttrString = NSAttributedString(string: "Обновляем данные", attributes: myAttribute)
        self.refreshControl?.attributedTitle = myAttrString
        self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        self.refreshControl?.tintColor = vkSingleton.shared.labelColor
        tableView.addSubview(refreshControl!)
        
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(DialogsCell.self, forCellReuseIdentifier: "dialogCell")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstAppear {
            isFirstAppear = false
            
            if let aView = self.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            } else {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
            self.offset = 0
            
            if AppConfig.shared.setOfflineStatus {
                self.refreshExecute()
            } else {
                self.getAllDialogsOnline()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: itemsMenu[view.tag], items: itemsMenu)
        menuView.cellBackgroundColor = vkSingleton.shared.separatorColor2
        menuView.cellSelectionColor = vkSingleton.shared.separatorColor2
        menuView.cellTextLabelColor = vkSingleton.shared.mainColor
        menuView.cellSeparatorColor = vkSingleton.shared.mainColor
        
        menuView.checkMarkImage = UIImage(named: "checkmark")
        
        menuView.cellTextLabelAlignment = .center
        menuView.selectedCellTextLabelColor = .systemRed
        menuView.cellTextLabelFont = UIFont.boldSystemFont(ofSize: 15)
        menuView.navigationBarTitleFont = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self?.selectedMenu = indexPath
            self?.view.tag = indexPath
            
            switch indexPath {
            case 0:
                if let dialogs = self?.menuDialogs {
                    self?.removeDuplicatesFromMenuDialogs()
                    self?.dialogs = dialogs
                    self?.dialogs.sort(by: { $0.date > $1.date })
                    self?.tableView.reloadData()
                }
                break
            case 1:
                if let dialogs = self?.menuDialogs {
                    self?.removeDuplicatesFromMenuDialogs()
                    self?.dialogs = dialogs.filter({ $0.chatID > 0 })
                    self?.dialogs.sort(by: { $0.date > $1.date })
                    self?.tableView.reloadData()
                }
                break
            case 2:
                if let dialogs = self?.menuDialogs {
                    self?.removeDuplicatesFromMenuDialogs()
                    self?.dialogs = dialogs.filter({ $0.userID < 0 })
                    self?.dialogs.sort(by: { $0.date > $1.date })
                    self?.tableView.reloadData()
                }
                break
            case 3:
                if let dialogs = self?.menuDialogs {
                    self?.removeDuplicatesFromMenuDialogs()
                    self?.dialogs = dialogs.filter({ $0.readState == 0 && $0.out == 0 })
                    self?.dialogs.sort(by: { $0.date > $1.date })
                    self?.tableView.reloadData()
                }
                break
            default:
                break
            }
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Новый диалог", style: .default) { action in
            
            self.addDialog()
        }
        alertController.addAction(action1)
        
        if self.source.isEmpty {
            let action2 = UIAlertAction(title: "Новый групповой чат", style: .default) { action in
                
                self.createNewChat()
            }
            alertController.addAction(action2)
        }
        
        let action3 = UIAlertAction(title: "Загрузка всех диалогов", style: .destructive) { action in
            
            self.showGetAllDialogsAlert()
        }
        alertController.addAction(action3)
        
        self.present(alertController, animated: true)
    }
    
    @objc func tapCloseButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func addDialog() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Диалог с одним из друзей", style: .default) { action in
            let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
            
            usersController.userID = vkSingleton.shared.userID
            usersController.type = "friends"
            usersController.source = "add_dialog"
            usersController.title = "Добавить диалог"
            usersController.attachment = self.attachment
            usersController.attachImage = self.attachImage
            
            usersController.delegate = self
            
            self.navigationController?.pushViewController(usersController, animated: true)
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Диалог из списка моих подписок", style: .default) { action in
            let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
            
            usersController.userID = vkSingleton.shared.userID
            usersController.type = "subscript"
            usersController.source = "add_dialog"
            usersController.title = "Добавить диалог"
            usersController.attachment = self.attachment
            usersController.attachImage = self.attachImage
            
            usersController.delegate = self
            
            self.navigationController?.pushViewController(usersController, animated: true)
        }
        alertController.addAction(action2)
        
        
        let action3 = UIAlertAction(title: "Диалог из списка подписчиков", style: .default) { action in
            let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
            
            usersController.userID = vkSingleton.shared.userID
            usersController.type = "followers"
            usersController.source = "add_dialog"
            usersController.title = "Добавить диалог"
            usersController.attachment = self.attachment
            usersController.attachImage = self.attachImage
            
            usersController.delegate = self
            
            self.navigationController?.pushViewController(usersController, animated: true)
        }
        alertController.addAction(action3)
        
        let action5 = UIAlertAction(title: "Произвольный пользователь", style: .destructive) { action in
            
            self.getCustomDialogID()
        }
        alertController.addAction(action5)
        
        self.present(alertController, animated: true)
    }
    
    @objc func pullToRefresh() {
        offset = 0
        
        if AppConfig.shared.setOfflineStatus {
            self.refreshExecute()
        } else {
            self.getAllDialogsOnline()
        }
    }
    
    func refreshExecute() {
        isRefresh = true
        
        menuDialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        
        menuDialogs = menuDialogs.loadFromUserDefaults(KeyName: "\(vkSingleton.shared.userID)_all-dialogs")
        users = users.loadFromUserDefaults(KeyName: "\(vkSingleton.shared.userID)_dialogs-users")
        
        var code =  "var conversations = API.messages.searchConversations({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"q\":\"\",\"count\":\"200\",\"extended\":\"1\",\"v\":\"5.80\" });\n"
        
        code = "\(code) var mess_ids = conversations.items@.last_message_id;\n"
        
        code = "\(code) var dialogs = API.messages.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"message_ids\":mess_ids,\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) return [dialogs,mess_ids];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
       
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else {
                ViewControllerUtils().hideActivityIndicator()
                return
            }
            
            guard let json = try? JSON(data: data) else {
                print("json error")
                ViewControllerUtils().hideActivityIndicator()
                return
            }
            
            //print(json)
            var dialogs = json["response"][0]["items"].compactMap { Message(json: $0.1, class: 2) }
            dialogs = dialogs.filter({ $0.chatID == 0 || ($0.chatID > 0 && $0.chatActive.count > 0) })
            
            var unreadDialogs: [Message] = []
            for dialog in self.menuDialogs {
                if dialogs.filter({ $0.userID == dialog.userID && $0.chatID == dialog.chatID }).first == nil { unreadDialogs.append(dialog) }
            }
            
            for dialog in dialogs {
                if let oldDialog = self.menuDialogs.filter({ $0.userID == dialog.userID && $0.chatID == dialog.chatID }).first {
                    self.menuDialogs.remove(object: oldDialog)
                }
                self.menuDialogs.append(dialog)
            }
            
            let users = json["response"][0]["profiles"].compactMap { DialogsUsers(json: $0.1) }
            self.users.append(contentsOf: users)
            
            let groups = json["response"][0]["groups"].compactMap { GroupProfile(json: $0.1) }
            for group in groups {
                let newGroup = DialogsUsers(json: JSON.null)
                newGroup.uid = "-\(group.gid)"
                newGroup.firstName = group.name
                newGroup.photo100 = group.photo100
                self.users.append(newGroup)
            }
            
            if unreadDialogs.count > 0 {
                for dialog in unreadDialogs {
                    usleep(333333)
                    var peerID = dialog.userID
                    if dialog.chatID > 0 { peerID = 2000000000 + dialog.chatID }
                    
                    var code = "var history = API.messages.getHistory({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"offset\":\"0\",\"count\":\"1\",\"extended\":\"0\",\"peer_id\": \"\(peerID)\",\"start_message_id\":\"-1\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
                    
                    code = "\(code) return history;\n"
                    
                    let url2 = "/method/execute"
                    let parameters2 = [
                        "access_token": vkSingleton.shared.accessToken,
                        "code": code,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                    getServerDataOperation2.completionBlock = {
                        guard let data = getServerDataOperation2.data else {
                            ViewControllerUtils().hideActivityIndicator()
                            return
                        }
                        
                        guard let json = try? JSON(data: data) else {
                            print("json error")
                            ViewControllerUtils().hideActivityIndicator()
                            return
                        }
                        
                        //print(json)
                        
                        let unread = json["response"]["unread"].intValue
                        let inRead = json["response"]["in_read"].intValue
                        let outRead = json["response"]["out_read"].intValue
                        let startID = max(inRead,outRead)
                        
                        if let user = json["response"]["profiles"].compactMap({ DialogsUsers(json: $0.1) }).first {
                            if !self.users.contains(where: { $0.uid == user.uid }) { self.users.append(user) }
                        }
                        
                        if let group = json["response"]["groups"].compactMap({ GroupProfile(json: $0.1) }).first {
                            let newGroup = DialogsUsers(json: JSON.null)
                            newGroup.uid = "-\(group.gid)"
                            newGroup.firstName = group.name
                            newGroup.photo100 = group.photo100
                            if !self.users.contains(where: { $0.uid == newGroup.uid }) { self.users.append(newGroup) }
                        }
                            
                        if startID != dialog.id || unread > 0 || (dialog.readState == 0 && unread == 0) {
                            usleep(333333)
                            
                            let url3 = "/method/messages.getHistory"
                            let parameters3 = [
                                "access_token": vkSingleton.shared.accessToken,
                                "offset": "0",
                                "count": "1",
                                "peer_id": "\(peerID)",
                                "start_message_id": "\(startID)",
                                "extended": "1",
                                "v": vkSingleton.shared.version
                            ]
                            
                            let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
                            OperationQueue.main.addOperation(getServerDataOperation3)
                            let parseDialog3 = ParseDialogHistory()
                            parseDialog3.completionBlock = {
                                if let newDialogHistory = parseDialog3.outputData.first {
                                    let newMessage = dialog
                                    newMessage.id = newDialogHistory.id
                                    newMessage.chatID = newDialogHistory.chatID
                                    newMessage.userID = newDialogHistory.userID
                                    newMessage.fromID = newDialogHistory.fromID
                                    newMessage.date = newDialogHistory.date
                                    newMessage.readState = newDialogHistory.readState
                                    newMessage.out = newDialogHistory.out
                                    newMessage.body = newDialogHistory.body
                                    newMessage.typeAttach = newDialogHistory.typeAttach
                                    newMessage.deleted = newDialogHistory.deleted
                                    newMessage.attach = newDialogHistory.attach
                                    newMessage.fwdMessage = newDialogHistory.fwdMessage
                                    
                                    if newDialogHistory.chatID != 0 {
                                        newMessage.chatActive = newDialogHistory.chatActive
                                        newMessage.usersCount = newDialogHistory.usersCount
                                        newMessage.adminID = newDialogHistory.adminID
                                        newMessage.actionID = newDialogHistory.actionID
                                        newMessage.action = newDialogHistory.action
                                        newMessage.actionEmail = newDialogHistory.actionEmail
                                        newMessage.actionText = newDialogHistory.actionText
                                    }
                                    
                                    self.menuDialogs.removeAll(where: { $0.userID == dialog.userID && $0.chatID == dialog.chatID })
                                    self.menuDialogs.append(newMessage)
                                }
                            }
                            parseDialog3.addDependency(getServerDataOperation3)
                            OperationQueue.main.addOperation(parseDialog3)
                        }
                        
                        if dialog == unreadDialogs.last {
                            self.menuDialogs.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_all-dialogs")
                            self.users.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_dialogs-users")
                            
                            OperationQueue.main.addOperation {
                                switch self.selectedMenu {
                                case 0:
                                    self.dialogs = self.menuDialogs
                                    break
                                case 1:
                                    self.dialogs = self.menuDialogs.filter({ $0.chatID > 0 })
                                    break
                                case 2:
                                    self.dialogs = self.menuDialogs.filter({ $0.userID < 0 })
                                    break
                                case 3:
                                    self.dialogs = self.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
                                    break
                                default:
                                    break
                                }
                                
                                self.removeDuplicatesFromDialogs()
                                self.dialogs.sort(by: { $0.date > $1.date })
                        
                                self.totalCount = self.menuDialogs.count
                                self.offset = self.totalCount
                                self.tableView.reloadData()
                                self.tableView.separatorStyle = .none
                                self.refreshControl?.endRefreshing()
                                
                                let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                                self.navigationItem.rightBarButtonItem = barButton
                            
                                ViewControllerUtils().hideActivityIndicator()
                            }
                        
                            self.setOfflineStatus(dependence: getServerDataOperation)
                        }
                    }
                    OperationQueue().addOperation(getServerDataOperation2)
                }
            } else {
                self.menuDialogs.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_all-dialogs")
                self.users.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_dialogs-users")
                
                OperationQueue.main.addOperation {
                    switch self.selectedMenu {
                    case 0:
                        self.dialogs = self.menuDialogs
                        break
                    case 1:
                        self.dialogs = self.menuDialogs.filter({ $0.chatID > 0 })
                        break
                    case 2:
                        self.dialogs = self.menuDialogs.filter({ $0.userID < 0 })
                        break
                    case 3:
                        self.dialogs = self.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
                        break
                    default:
                        break
                    }
                    
                    self.removeDuplicatesFromDialogs()
                    self.dialogs.sort(by: { $0.date > $1.date })
            
                    self.totalCount = self.menuDialogs.count
                    self.offset = self.totalCount
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .none
                    self.refreshControl?.endRefreshing()
                    
                    let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                    self.navigationItem.rightBarButtonItem = barButton
                    
                    ViewControllerUtils().hideActivityIndicator()
                }
            
                self.setOfflineStatus(dependence: getServerDataOperation)
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
        
    func getAllDialogsOnline() {
        let opq = OperationQueue()
        isRefresh = true
        
        if let aView = self.tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        if offset == 0 {
            menuDialogs.removeAll(keepingCapacity: false)
            dialogs.removeAll(keepingCapacity: false)
            users.removeAll(keepingCapacity: false)
        }
        
        let url = "/method/messages.getDialogs"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "filter": "all",
            "extended": "1",
            "fields": "id, first_name, last_name, sex, photo_50, photo_100, online, screen_name, online_info, last_seen",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseDialogs = ParseDialogs()
        parseDialogs.completionBlock = {
            self.menuDialogs.append(contentsOf: parseDialogs.outputData)
            self.removeDuplicatesFromMenuDialogs()
            self.dialogs = self.menuDialogs
            self.dialogs.sort(by: { $0.date > $1.date })
            
            var userIDs = ""
            for dialog in self.dialogs {
                if userIDs != "" {
                    userIDs = "\(userIDs),"
                }
                userIDs = "\(userIDs)\(dialog.userID)"
                
                if dialog.chatID != 0 {
                    if dialog.chatActive.count > 0 {
                        for index in 0...dialog.chatActive.count-1 {
                            if userIDs != "" {
                                userIDs = "\(userIDs),"
                            }
                            userIDs = "\(userIDs)\(dialog.chatActive[index])"
                        }
                    }
                    if userIDs != "" {
                        userIDs = "\(userIDs),"
                    }
                    userIDs = "\(userIDs)\(dialog.adminID)"
                    if userIDs != "" {
                        userIDs = "\(userIDs),"
                    }
                    userIDs = "\(userIDs)\(dialog.actionID)"
                }
            }
            userIDs = "\(userIDs),\(vkSingleton.shared.userID)"
            
            let url = "/method/users.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "user_ids": userIDs,
                "fields": "id, first_name, last_name, last_seen, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, online,  can_write_private_message,sex,photo_100",
                "name_case": "nom",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            self.setOfflineStatus(dependence: getServerDataOperation)
            
            let parseDialogsUsers = ParseDialogsUsers()
            parseDialogsUsers.addDependency(getServerDataOperation)
            opq.addOperation(parseDialogsUsers)
        
            var groupIDs = ""
            for dialog in self.dialogs {
                if dialog.userID < 0 {
                    if groupIDs != "" {
                        groupIDs = "\(groupIDs),"
                    }
                    groupIDs = "\(groupIDs)\(abs(dialog.userID))"
                }
            }
            
            let url2 = "/method/groups.getById"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "group_ids": groupIDs,
                "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,photo_100",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            opq.addOperation(getServerDataOperation2)
            
            let parseGroupProfile = ParseGroupProfile()
            parseGroupProfile.addDependency(getServerDataOperation2)
            opq.addOperation(parseGroupProfile)
            
            let reloadController = ReloadDialogsController(controller: self)
            reloadController.addDependency(parseDialogs)
            reloadController.addDependency(parseDialogsUsers)
            reloadController.addDependency(parseGroupProfile)
            OperationQueue.main.addOperation(reloadController)
        }
        parseDialogs.addDependency(getServerDataOperation)
        opq.addOperation(parseDialogs)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dialogs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogsCell
        
        return cell.userAvatarSize + 2 * cell.topInsets
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 6
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 6
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogsCell
        
        if indexPath.section < dialogs.count {
            cell.configureCell(mess: dialogs[indexPath.section], users: users, indexPath: indexPath, cell: cell, tableView: tableView)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dialog = dialogs[indexPath.section]
        openDialog(dialog: dialog)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить диалог") { (rowAction, indexPath) in
            let dialog = self.dialogs[indexPath.section]
            
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
                var peerID = dialog.userID
                if dialog.chatID > 0 {
                    peerID = 2000000000 + dialog.chatID
                }
                
                let url = "/method/messages.deleteConversation"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "peer_id": "\(peerID)",
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
                            self.dialogs.remove(at: indexPath.section)
                            
                            self.menuDialogs = self.menuDialogs.filter({ ($0.chatID == dialog.chatID && $0.userID != dialog.userID) || $0.chatID != dialog.chatID })
                            self.menuDialogs.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_all-dialogs")
                            
                            self.totalCount -= 1
                            self.offset -= 1
                            
                            self.tableView.reloadData()
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка при удалении диалога", msg: "\(error.errorMsg)")
                    }
                }
                OperationQueue().addOperation(request)
            }
            
            alertView.addButton("Отмена, я передумал") {
                
            }
            
            let user = self.users.filter({ $0.uid == "\(dialog.userID)" })
            var name = "данный диалог"
            if user.count > 0 {
                if dialog.chatID > 0 {
                    name = "групповой чат «\(dialog.title)»"
                } else if dialog.userID > 0 {
                    name = "диалог с пользователем «\(user[0].firstName) \(user[0].lastName)»"
                } else {
                    name = "диалог с сообществом «\(user[0].firstName)»"
                }
            }
            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить \(name)? Это действие необратимо.")
            
        }
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && offset < totalCount {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false && selectedMenu == 3 {
            getAllDialogsOnline()
        }
    }
    
    func getCustomDialogID() {
        
        let titleColor = vkSingleton.shared.labelColor
        let backColor = vkSingleton.shared.backColor
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false,
            circleBackgroundColor: backColor,
            contentViewColor: backColor,
            titleColor: titleColor
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 30))
        
        textField.layer.borderColor = titleColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.backgroundColor = vkSingleton.shared.backColor
        textField.font = UIFont(name: "Verdana", size: 13)
        textField.textColor = vkSingleton.shared.secondaryLabelColor
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.text = ""
        textField.textColor = vkSingleton.shared.secondaryLabelColor
        textField.changeKeyboardAppearanceMode()
        
        alert.customSubview = textField
        
        alert.addButton("Открыть диалог", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            self.view.endEditing(true);
            if let text = textField.text, !text.isEmpty {
                let userID = text.digitsOnly()
                self.openCustomDialog(userID)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "\nПожалуйста, введите идентификатор пользователя\n", completion: {
                    self.getCustomDialogID()
                })
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
        
        alert.showInfo("Введите идентификатор пользователя (цифры после id):", subTitle: "")
    }
    
    func openCustomDialog(_ userID: String) {
        
        if let aView = self.tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "user_id": "\(userID)",
            "start_message_id": "-1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var startID = parseDialog.inRead
            if parseDialog.outRead > startID {
                startID = parseDialog.outRead
            }
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                self.openDialogController(userID: userID, chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
    
    @objc func showGetAllDialogsAlert() {
        
        self.showSetOnlineAlert(title: "\nВнимание!", body: "Загрузка всех диалогов в приложение изменяет ваш статус ВКонтакте на «онлайн».\n\nЕсли у вас активирован режим «Невидимка», то приложение сразу выставит вам статус «заходил только что».\n", doneCompletion: {
            self.offset = 0
            self.getAllDialogsOnline()
        })
    }
    
    func removeDuplicatesFromMenuDialogs() {
        
        var newDialogs: [Message] = []
        
        for dialog in menuDialogs {
            if let newDialog = newDialogs.filter({ $0.userID == dialog.userID && $0.chatID == dialog.chatID }).first {
                if dialog.date > newDialog.date {
                    newDialogs.remove(object: newDialog)
                    newDialogs.append(dialog)
                }
            } else {
                newDialogs.append(dialog)
            }
        }
        
        menuDialogs = newDialogs
    }
    
    func removeDuplicatesFromDialogs() {
        
        var newDialogs: [Message] = []
        
        for dialog in dialogs {
            if let newDialog = newDialogs.filter({ $0.userID == dialog.userID && $0.chatID == dialog.chatID }).first {
                if dialog.date > newDialog.date {
                    newDialogs.remove(object: newDialog)
                    newDialogs.append(dialog)
                }
            } else {
                newDialogs.append(dialog)
            }
        }
        
        dialogs = newDialogs
    }
    
    func openDialog(dialog: Message) {
        
        if let aView = self.tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let url = "/method/messages.getHistory"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "peer_id": "\(dialog.userID)",
            "start_message_id": "-1",
            "v": vkSingleton.shared.version
        ]
        
        if dialog.chatID > 0 {
            parameters["peer_id"] = "\(2000000000 + dialog.chatID)"
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var startID = parseDialog.inRead
            if parseDialog.outRead > startID {
                startID = parseDialog.outRead
            }
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                if dialog.chatID == 0 {
                    self.openDialogController(userID: "\(dialog.userID)", chatID: "", startID: dialog.id, attachment: self.attachment, messIDs: self.fwdMessagesID, image: self.attachImage)
                } else {
                    self.openDialogController(userID: "\(2000000000 + dialog.chatID)", chatID: "\(dialog.chatID)", startID: dialog.id, attachment: self.attachment, messIDs: self.fwdMessagesID, image: self.attachImage)
                }
                
                self.fwdMessagesID.removeAll(keepingCapacity: false)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
}
