//
//  DialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover
import SCLAlertView
import SwiftyJSON
import BTNavigationDropdownMenu

class DialogsController: InnerTableViewController {

    var selectedMenu = 0
    let itemsMenu = ["Все диалоги", "Избранные диалоги", "Групповые чаты", "Диалоги с сообществами", "Непрочитанные диалоги"]
    
    var isFirstAppear = true
    var isRefresh = false
    var type = ""
    var source = ""
    var attachment = ""
    var attachImage: UIImage?
    
    var offset = 0
    var count = 200
    var totalCount = 0
    
    var scrollTableViewToTop = false
    
    var importantConversationIds: [Int] = []
    var conversations: [Conversation] = []
    var menuDialogs: [Message] = []
    var dialogs: [Message] = []
    var users: [DialogsUsers] = []
    
    var fwdMessagesID: [Int] = []
    
    let feedbackText = "Внимание!\n\nВ режиме «Невидимка» некоторые диалоги могут не отображаться в общем списке.\n\nЭто связано с особенностями работы социальной сети ВКонтакте.\n\nЕсли Вы заметили такую ситуацию, то мы рекомендуем Вам выполнить один раз загрузку всех диалогов из верхнего меню •••.\n\nЭто поменяет Ваш статус в сети на «заходил только что», но все диалоги будут отображаться в общем списке и в дальнейшем обновляться уже в режиме «Невидимка»."
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]
    
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
            
            offset = 0
            
            if AppConfig.shared.setOfflineStatus {
                if readMenuDialogs().count == 0 {
                    requestGetAllDialogsAlert()
                } else {
                    if let aView = self.tableView.superview { ViewControllerUtils().showActivityIndicator(uiView: aView) }
                    else { ViewControllerUtils().showActivityIndicator(uiView: self.view) }
                    refreshExecute()
                }
            } else {
                getAllDialogsOnline()
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
        
        menuView.cellHeight = 43
        menuView.checkMarkImage = UIImage(named: "checkmark")
        
        menuView.cellTextLabelAlignment = .center
        menuView.selectedCellTextLabelColor = .systemRed
        menuView.cellTextLabelFont = UIFont.boldSystemFont(ofSize: 15)
        menuView.navigationBarTitleFont = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            guard let self = self else { return }
            
            self.selectedMenu = indexPath
            self.view.tag = indexPath
            
            switch indexPath {
            case 0:
                self.removeDuplicatesFromMenuDialogs()
                self.dialogs = self.menuDialogs
                self.dialogs.sort(by: { $0.date > $1.date })
                self.tableView.reloadData()
                break
            case 1:
                self.removeDuplicatesFromMenuDialogs()
                self.conversations = self.actualConversationArray(conversations: self.conversations)
                var importantDialogs: [Message] = []
                for dialog in self.menuDialogs {
                    if let conversation = self.conversations.filter({ $0.peerID == dialog.peerID }).first, conversation.important {
                        importantDialogs.append(dialog)
                    }
                }
                self.dialogs = importantDialogs
                self.dialogs.sort(by: { $0.date > $1.date })
                self.tableView.reloadData()
                break
            case 2:
                self.removeDuplicatesFromMenuDialogs()
                self.dialogs = self.menuDialogs.filter({ $0.chatID > 0 })
                self.dialogs.sort(by: { $0.date > $1.date })
                self.tableView.reloadData()
                break
            case 3:
                self.removeDuplicatesFromMenuDialogs()
                self.dialogs = self.menuDialogs.filter({ $0.userID < 0 })
                self.dialogs.sort(by: { $0.date > $1.date })
                self.tableView.reloadData()
                break
            case 4:
                self.removeDuplicatesFromMenuDialogs()
                self.dialogs = self.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
                self.dialogs.sort(by: { $0.date > $1.date })
                self.tableView.reloadData()
                break
            default:
                break
            }
        }
    }
    
    func checkAndShowFeedbackDialogsView() {
        
        guard let appOpenCount = UserDefaults.standard.value(forKey: vkSingleton.shared.dialogsOpenedCountKey) as? Int else {
            UserDefaults.standard.set(1, forKey: vkSingleton.shared.dialogsOpenedCountKey)
            checkAndShowFeedbackDialogsView()
            return
        }
        
        if appOpenCount == 1 {
            showFeedbackDialogsView()
        } else if appOpenCount == 10 {
            showFeedbackDialogsView()
        } else if appOpenCount == 50 {
            showFeedbackDialogsView()
        } else if appOpenCount % 200 == 0 {
            showFeedbackDialogsView()
        }
        
        print("Dialogs Opened Count is : \(appOpenCount)")
        UserDefaults.standard.set(appOpenCount + 1, forKey: vkSingleton.shared.dialogsOpenedCountKey)
    }
    
    func showFeedbackDialogsView() {
        
        let maxWidth = UIScreen.main.bounds.width - 60
        let feedFont = UIFont(name: "Verdana", size: 13)!
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = feedbackText.boundingRect(with: textBlock, options: [.usesFontLeading,.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: feedFont], context: nil)
        
        let width = maxWidth + 20
        let height = rect.size.height + 40
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let textView = UITextView(frame: CGRect(x: 10, y: 10, width: maxWidth, height: height - 20))
        textView.text = feedbackText
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.font = feedFont
        textView.textAlignment = .center
        textView.changeKeyboardAppearanceMode()
        view.addSubview(textView)
        
        textView.textColor = vkSingleton.shared.labelPopupColor
        
        let startPoint = CGPoint(x: UIScreen.main.bounds.width - 24, y: 70)
        
        self.popover = Popover(options: [.type(.down),
                                         .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
                                         .color(vkSingleton.shared.backPopupColor)])
        self.popover.show(view, point: startPoint)
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
        
        conversations.removeAll(keepingCapacity: false)
        menuDialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        
        convertMenuDialogs()
        
        var code =  "var conversations = API.messages.searchConversations({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"q\":\" \",\"count\":\"255\",\"extended\":\"0\",\"v\":\"\(vkSingleton.shared.version)\" });\n"
        
        code = "\(code) return [conversations];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": "\(vkSingleton.shared.version)"
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
            
            //print("response = \(json["response"])")
            
            let conversations = json["response"][0]["items"].compactMap({ Conversation(json: $0.1) })
            
            let peerIdArray = self.addNewConversations(conversations: conversations)
            let peer100 = self.splitMenuDialogsArrayOn100(dialogsIDs: peerIdArray)
            
            let dispatchRequest = DispatchGroup()
            
            for index in 0 ..< peer100.count {
                dispatchRequest.enter()
                
                let peerIDs = ",".join(array: peer100[index])
                //print("peerIDs = \(peerIDs)")
                
                var code =  "var conversations = API.messages.getConversationsById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"peer_ids\":\"\(peerIDs)\",\"count\":\"100\",\"extended\":\"0\",\"v\":\"\(vkSingleton.shared.version)\" });\n"
                
                code = "\(code) var mess_ids = conversations.items@.last_message_id;\n"
                
                code = "\(code) var dialogs = API.messages.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"message_ids\":mess_ids,\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
                
                code = "\(code) return [conversations,dialogs];"
                
                let url = "/method/execute"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "code": code,
                    "v": "\(vkSingleton.shared.version)"
                ]
                
                let getServerDataOperation2 = GetServerDataOperation(url: url, parameters: parameters)
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
                    
                    //print("json = \(json)")
                    
                    let conversations = json["response"][0]["items"].compactMap({ Conversation(json: $0.1) })
                    let menuDialogs = json["response"][1]["items"].compactMap { Message(json: $0.1, conversations: conversations) }
                    
                    var users = json["response"][1]["profiles"].compactMap { DialogsUsers(json: $0.1) }
                    let groups = json["response"][1]["groups"].compactMap { GroupProfile(json: $0.1) }
                    for group in groups {
                        let newGroup = DialogsUsers(json: JSON.null)
                        newGroup.uid = "-\(group.gid)"
                        newGroup.firstName = group.name
                        newGroup.photo100 = group.photo100
                        users.append(newGroup)
                    }
                    
                    self.conversations.append(contentsOf: conversations)
                    self.menuDialogs.append(contentsOf: menuDialogs)
                    self.users.append(contentsOf: users)
                    
                    self.setOfflineStatus(dependence: getServerDataOperation2)
                    
                    dispatchRequest.leave()
                }
                OperationQueue().addOperation(getServerDataOperation2)
            }
            
            
            dispatchRequest.notify(queue: .main) {
                self.conversations = self.actualConversationArray(conversations: self.conversations)
                
                self.removeDuplicatesFromMenuDialogs()
                self.menuDialogs = self.menuDialogs.sorted(by: { $0.date > $1.date })
                
                switch self.selectedMenu {
                case 0:
                    self.dialogs = self.menuDialogs
                    break
                case 1:
                    var importantDialogs: [Message] = []
                    for dialog in self.menuDialogs {
                        if let conversation = conversations.filter({ $0.peerID == dialog.peerID }).first, conversation.important {
                            importantDialogs.append(dialog)
                        }
                    }
                    self.dialogs = importantDialogs
                    break
                case 2:
                    self.dialogs = self.menuDialogs.filter({ $0.chatID > 0 })
                    break
                case 3:
                    self.dialogs = self.menuDialogs.filter({ $0.userID < 0 })
                    break
                case 4:
                    self.dialogs = self.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
                    break
                default:
                    break
                }
                
                self.totalCount = self.menuDialogs.count
                self.offset = self.totalCount
                self.tableView.reloadData()
                self.tableView.separatorStyle = .none
                self.refreshControl?.endRefreshing()
                
                let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
                
                ViewControllerUtils().hideActivityIndicator()
                self.checkAndShowFeedbackDialogsView()
            }
            
            self.setOfflineStatus(dependence: getServerDataOperation)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
        
    func getAllDialogsOnline() {
        let opq = OperationQueue()
        isRefresh = true
        
        if let aView = self.tableView.superview { ViewControllerUtils().showActivityIndicator(uiView: aView) }
        else { ViewControllerUtils().showActivityIndicator(uiView: self.view) }
        
        if offset == 0 {
            menuDialogs.removeAll(keepingCapacity: false)
            dialogs.removeAll(keepingCapacity: false)
            users.removeAll(keepingCapacity: false)
        }
        
        let url = "/method/messages.getConversations"
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
            OperationQueue.main.addOperation {
                self.conversations = self.actualConversationArray(conversations: parseDialogs.conversations)
                self.menuDialogs = parseDialogs.outputData
                self.users = parseDialogs.users
                
                let _ = self.addNewConversations(conversations: self.conversations)
                
                self.removeDuplicatesFromMenuDialogs()
                self.menuDialogs = self.menuDialogs.sorted(by: { $0.date > $1.date })
                
                switch self.selectedMenu {
                case 0:
                    self.dialogs = self.menuDialogs
                    break
                case 1:
                    var importantDialogs: [Message] = []
                    for dialog in self.menuDialogs {
                        if let conversation = self.conversations.filter({ $0.peerID == dialog.peerID }).first, conversation.important {
                            importantDialogs.append(dialog)
                        }
                    }
                    self.dialogs = importantDialogs
                    break
                case 2:
                    self.dialogs = self.menuDialogs.filter({ $0.chatID > 0 })
                    break
                case 3:
                    self.dialogs = self.menuDialogs.filter({ $0.userID < 0 })
                    break
                case 4:
                    self.dialogs = self.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
                    break
                default:
                    break
                }
                
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as? DialogsCell {
            return cell.userAvatarSize + 2 * cell.topInsets
        }
        
        return 0
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
            let mess = dialogs[indexPath.section]
            let conversation = conversations.filter({ $0.peerID == mess.peerID }).first
            
            cell.configureCell(mess: mess, conversation: conversation, users: users, indexPath: indexPath, cell: cell, tableView: tableView)
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
                let peerID = dialog.chatID > 0 ? 2000000000 + dialog.chatID : dialog.userID
                
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
                            self.removeConversationWith(peerID: peerID)
                            self.menuDialogs = self.menuDialogs.filter({ $0.peerID != peerID })
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
        
        if isRefresh == false && selectedMenu == 100 {
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
                if let peerID = Int(text) {
                    let userID = text.digitsOnly()
                    self.openCustomDialog(userID)
                } else {
                    self.openCustomDialogByShortLink(text)
                }
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "\nПожалуйста, введите идентификатор пользователя\n", completion: {
                    self.getCustomDialogID()
                })
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
        
        alert.showInfo("Введите идентификатор, короткое имя или ссылку на пользователя/сообщество:", subTitle: "")
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
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var startID = parseDialog.inRead
            if parseDialog.outRead > startID { startID = parseDialog.outRead }
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                
                self.openDialogController(userID: userID, chatID: "", startID: parseDialog.lastMessageId, attachment: "", messIDs: [], image: nil)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
    
    func openCustomDialogByShortLink(_ vkLink: String) {
        
        let link = vkLink.replacingOccurrences(of: "https://vk.com/", with: "")
        
        if let aView = self.tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let url = "/method/utils.resolveScreenName"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "screen_name": link,
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
            
            //print("resolveScreenName json = \(json)")
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                
                let errorMessage = "Пользователь или сообщество «\(vkLink)» не найдено. Проверьте написание и повторите попытку."
                let objectID = json["response"]["object_id"].intValue
                
                if objectID > 0 {
                    let type = json["response"]["type"].stringValue
                    
                    if type == "user" {
                        self.openCustomDialog("\(objectID)")
                    } else if type == "group" {
                        self.openCustomDialog("-\(objectID)")
                    } else {
                        self.showErrorMessage(title: "Внимание!", msg: errorMessage)
                    }
                } else {
                    self.showErrorMessage(title: "Внимание!", msg: errorMessage)
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    @objc func showGetAllDialogsAlert() {
        
        self.showSetOnlineAlert(title: "\nВнимание!", body: "Загрузка всех диалогов в приложение изменяет ваш статус ВКонтакте на «онлайн».\n\nЕсли у вас активирован режим «Невидимка», то приложение сразу выставит вам статус «заходил только что».\n", doneCompletion: {
            self.offset = 0
            self.scrollTableViewToTop = true
            self.getAllDialogsOnline()
        })
    }
    
    @objc func requestGetAllDialogsAlert() {
        
        self.showSetOnlineAlert(title: "\nВнимание!", body: "Перед первым открытием диалогов рекомендуется сделать загрузку всех диалогов, что поменяет ваш статус ВКонтакте на «онлайн».\n\nЕсли у вас активирован режим «Невидимка», то приложение сразу выставит вам статус «заходил только что».\n", doneCompletion: {
            self.offset = 0
            self.scrollTableViewToTop = true
            self.getAllDialogsOnline()
        }, cancelCompletion: {
            if let aView = self.tableView.superview { ViewControllerUtils().showActivityIndicator(uiView: aView) }
            else { ViewControllerUtils().showActivityIndicator(uiView: self.view) }
            
            self.refreshExecute()
        })
    }
    
    func removeDuplicatesFromMenuDialogs() {
        
        var newDialogs: [Message] = []
        
        for dialog in menuDialogs {
            if let newDialog = newDialogs.filter({ $0.peerID == dialog.peerID }).first {
                if dialog.id > newDialog.id {
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
            if let newDialog = newDialogs.filter({ $0.peerID == dialog.peerID }).first {
                if dialog.id > newDialog.id {
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
        
        var peerID = "\(dialog.userID)"
        if dialog.chatID > 0 { peerID = "\(2000000000 + dialog.chatID)" }
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "peer_id": peerID,
            "start_message_id": "-1",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogController") as? DialogController {
                
                    controller.userID = peerID
                    controller.chatID = dialog.chatID == 0 ? "" : "\(dialog.chatID)"
                    controller.startMessageID = dialog.id
                    controller.attachments = self.attachment
                    controller.fwdMessagesID = self.fwdMessagesID
                    controller.attachImage = self.attachImage
                    controller.delegate = self
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                    self.fwdMessagesID.removeAll(keepingCapacity: false)
                }
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
}
