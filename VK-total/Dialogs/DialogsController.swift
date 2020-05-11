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

class DialogsController: UITableViewController {

    var isFirstAppear = true
    var isRefresh = false
    var type = ""
    var source = ""
    var attachment = ""
    var attachImage: UIImage?
    
    var offset = 0
    var count = 30
    var totalCount = 0
    
    var dialogs: [Message] = []
    var users: [DialogsUsers] = []
    
    var fwdMessagesID: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            overrideUserInterfaceStyle = .light
        }

        self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)
        
        OperationQueue.main.addOperation {
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addDialog))
            self.navigationItem.rightBarButtonItem = addButton
            
            self.tableView.separatorStyle = .none
            self.tableView.register(DialogsCell.self, forCellReuseIdentifier: "dialogCell")
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
            self.offset = 0
            self.refresh()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @objc func tapCloseButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func addDialog() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Друзья", style: .default){ action in
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
        
        
        let action2 = UIAlertAction(title: "Подписки", style: .default){ action in
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
        
        
        let action3 = UIAlertAction(title: "Подписчики", style: .default){ action in
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
        
        let action5 = UIAlertAction(title: "Произвольный", style: .default){ action in
            
            self.getCustomDialogID()
        }
        alertController.addAction(action5)
        
        if self.source == "" {
            let action4 = UIAlertAction(title: "Создать новый чат", style: .destructive) { action in
                
                self.createNewChat()
            }
            alertController.addAction(action4)
        }
        
        self.present(alertController, animated: true)
    }
    
    @objc func pullToRefresh() {
        offset = 0
        refresh()
    }
    
    func refresh() {
        isRefresh = true
        
        if offset == 0 {
            dialogs.removeAll(keepingCapacity: false)
            users.removeAll(keepingCapacity: false)
        }
        
        let url = "/method/messages.searchConversations"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "q": "",
            "count": "200",
            "extended": "0",
            "v": vkSingleton.shared.version
        ]
        
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print("url = \(url)\nparameters = \(parameters)\nresponse = \(json)")
            
            var messIDs: [Int] = json["response"]["items"].map { $0.1["last_message_id"].intValue }
            messIDs = messIDs.filter({ $0 > 0 })
            
            if messIDs.count > 0 {
                let startIndex = self.offset
                let endIndex = min(self.offset + self.count, messIDs.count)
            
                messIDs = messIDs.sorted(by: >)
                let messIDs2 = messIDs[startIndex...endIndex-1]
                let url2 = "/method/messages.getById"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "message_ids": messIDs2.map{ String($0) }.joined(separator: ","),
                    "extended": "1",
                    "v": vkSingleton.shared.version
                ]
            
                let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                getServerDataOperation2.completionBlock = {
                    guard let data2 = getServerDataOperation2.data else { return }
                    guard let json2 = try? JSON(data: data2) else { print("json error"); return }
                    //print(json2)
                    
                    let dialogs = json2["response"]["items"].compactMap { Message(json: $0.1, class: 2) }
                    self.dialogs.append(contentsOf: dialogs)
                    self.dialogs = self.dialogs.removeDuplicates()
                    self.dialogs.sort(by: { $0.date > $1.date })
                    
                    let users = json2["response"]["profiles"].compactMap { DialogsUsers(json: $0.1) }
                    self.users.append(contentsOf: users)
                    
                    let groups = json2["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
                    for group in groups {
                        let newGroup = DialogsUsers(json: JSON.null)
                        newGroup.uid = "-\(group.gid)"
                        newGroup.firstName = group.name
                        newGroup.photo100 = group.photo100
                        self.users.append(newGroup)
                    }
                    
            
                
                    OperationQueue.main.addOperation {
                        self.totalCount = messIDs.count
                        self.offset += self.count
                        self.tableView.reloadData()
                        self.tableView.separatorStyle = .none
                        self.refreshControl?.endRefreshing()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                    
                    self.setOfflineStatus(dependence: getServerDataOperation2)
                }
                OperationQueue().addOperation(getServerDataOperation2)
            } else {
                OperationQueue.main.addOperation {
                    self.totalCount = 0
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    ViewControllerUtils().hideActivityIndicator()
                }
                
                self.setOfflineStatus(dependence: getServerDataOperation)
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func refresh2() {
        let opq = OperationQueue()
        isRefresh = true
        
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        let url = "/method/messages.getDialogs"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "preview_length": "90",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseDialogs = ParseDialogs()
        parseDialogs.completionBlock = {
            var userIDs = ""
            for dialog in parseDialogs.outputData {
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
                "fields": "id, first_name, last_name, last_seen, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, online,  can_write_private_message, sex",
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
            for dialog in parseDialogs.outputData {
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
                "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed",
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
        
        if dialog.chatID == 0 {
            openDialogController(userID: "\(dialog.userID)", chatID: "", startID: dialog.id, attachment: attachment, messIDs: fwdMessagesID, image: attachImage)
        } else {
            openDialogController(userID: "\(2000000000 + dialog.chatID)", chatID: "\(dialog.chatID)", startID: dialog.id, attachment: attachment, messIDs: fwdMessagesID, image: attachImage)
        }
        fwdMessagesID.removeAll(keepingCapacity: false)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить диалог") { (rowAction, indexPath) in
            let dialog = self.dialogs[indexPath.section]
            
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
                let url = "/method/messages.deleteDialog"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_id": "\(dialog.userID)",
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
                if dialog.userID > 0 {
                    name =  "диалог с пользователем «\(user[0].firstName) \(user[0].lastName)»"
                } else {
                    name =  "диалог с сообществом «\(user[0].firstName)»"
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
        
        if isRefresh == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
            refresh()
        }
    }
    
    func getCustomDialogID() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 30))
        
        textField.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textField.font = UIFont(name: "Verdana", size: 13)
        textField.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.text = ""
        
        alert.customSubview = textField
        
        alert.addButton("Готово", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            self.view.endEditing(true);
            if let userID = textField.text {
                self.openCustomDialog(userID)
            }
        }
        
        alert.addButton("Отмена", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {}
        
        alert.showInfo("Идентификатор пользователя:", subTitle: "")
    }
    
    func openCustomDialog(_ userID: String) {
        
        ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
        
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
                if startID > 0 {
                    ViewControllerUtils().hideActivityIndicator()
                    self.openDialogController(userID: userID, chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                } else {
                    ViewControllerUtils().hideActivityIndicator()
                    self.showErrorMessage(title: "", msg: "У Вас отсутствует диалог с этим пользователем (id \(userID))")
                }
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
}
