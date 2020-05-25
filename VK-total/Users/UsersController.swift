//
//  UsersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import BEMCheckBox

class UsersController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var delegate: UIViewController!
    
    var userID = ""
    var type = "friends"
    var source = ""
    var isSearch = false
    
    var attachment = ""
    var attachImage: UIImage?
    
    var friends = [Friends]()
    var sortedFriends = [Friends]()
    
    var users = [Friends]()
    var searchUsers = [Friends]()
    var sections = [Sections]()
    
    let alphabet =  [
                    "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л",
                    "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш",
                    "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я", "A", "B", "C", "D", "E", "F",
                    "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                    "T", "U", "V", "W", "X", "Y", "Z" ]

    var chatTitle = ""
    var chatUsers: [Int] = []
    var chatButton = UIBarButtonItem()
    var chatMarkCheck: [IndexPath: BEMCheckBox] = [:]
    var chatAdminID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = .separator
            searchField.textColor = .label
        } else {
            if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchField.backgroundColor = UIColor(white: 0, alpha: 0.2)
                searchField.textColor = .black
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        OperationQueue.main.addOperation {
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.backgroundColor = vkSingleton.shared.backColor
            self.searchBar.placeholder = ""
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            
            if self.type == "requests" {
                let deleteButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapDeleteAllRequests(sender:)))
                self.navigationItem.rightBarButtonItem = deleteButton
            }
            
            if self.source == "create_chat" {
                self.tableView.allowsMultipleSelection = true
            } else {
                self.tableView.allowsMultipleSelection = false
            }
            
            if #available(iOS 13, *) {} else {
                self.segmentedControl.tintColor = vkSingleton.shared.mainColor
                self.segmentedControl.backgroundColor = vkSingleton.shared.backColor
            }
        }
        
        refresh()
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.showMessageNotification(title: "Новое сообщение", text: "Всем привет! 😉", userID: 46616527, chatID: 0, groupID: 0, startID: -1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func refresh() {
        let opq = OperationQueue()
        
        var url: String = ""
        var parameters: Parameters = [:]
        
        if type == "friends" || type == "commonFriends" {
            url = "/method/friends.get"
            parameters = [
                "user_id": self.userID,
                "access_token": vkSingleton.shared.accessToken,
                "order": "hints",
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseFriends = ParseFriendList()
            parseFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseFriends)
            
            let reloadTableController = ReloadUsersController(controller: self, type: type)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
            
        } else if type == "followers" {
            url = "/method/users.getFollowers"
            parameters = [
                "user_id": userID,
                "offset": "0",
                "count": "1000",
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseFriends = ParseFriendList()
            parseFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseFriends)
            
            let reloadTableController = ReloadUsersController(controller: self, type: type)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
            
        } else if type == "subscript" {
            let url1 = "/method/friends.getRequests"
            let parameters1 = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "out": "1",
                "count": "1000",
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
            opq.addOperation(getServerDataOperation1)
            
            let parseRequest = ParseRequest()
            parseRequest.addDependency(getServerDataOperation1)
            parseRequest.completionBlock = {
                if parseRequest.count > 0 {
                    let listID = parseRequest.outputData
                    
                    url = "/method/users.get"
                    parameters = [
                        "user_ids": listID,
                        "access_token": vkSingleton.shared.accessToken,
                        "fields": "online,photo_max,last_seen,sex,is_friend",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    opq.addOperation(getServerDataOperation)
                    
                    let parseFriends = ParseRequestList()
                    parseFriends.addDependency(getServerDataOperation)
                    opq.addOperation(parseFriends)
                    
                    let reloadTableController = ReloadUsersController(controller: self, type: self.type)
                    reloadTableController.addDependency(parseFriends)
                    OperationQueue.main.addOperation(reloadTableController)
                } else {
                    OperationQueue.main.addOperation {
                        self.segmentedControl.setTitle("Подписки: 0", forSegmentAt: 0)
                        self.segmentedControl.setTitle("Онлайн: 0", forSegmentAt: 1)
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.reloadData()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
            }
            opq.addOperation(parseRequest)
        } else if type == "requests" {
            let url1 = "/method/friends.getRequests"
            let parameters1 = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "out": "0",
                "sort": "0",
                "count": "1000",
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
            opq.addOperation(getServerDataOperation1)
            
            let parseRequest = ParseRequest()
            parseRequest.addDependency(getServerDataOperation1)
            parseRequest.completionBlock = {
                if parseRequest.count > 0 {
                    let listID = parseRequest.outputData
                    
                    url = "/method/users.get"
                    parameters = [
                        "user_ids": listID,
                        "access_token": vkSingleton.shared.accessToken,
                        "fields": "online,photo_max,last_seen,sex,is_friend",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    opq.addOperation(getServerDataOperation)
                    
                    let parseFriends = ParseRequestList()
                    parseFriends.addDependency(getServerDataOperation)
                    opq.addOperation(parseFriends)
                    
                    let reloadTableController = ReloadUsersController(controller: self, type: self.type)
                    reloadTableController.addDependency(parseFriends)
                    OperationQueue.main.addOperation(reloadTableController)
                } else {
                    OperationQueue.main.addOperation {
                        self.segmentedControl.setTitle("Заявки: 0", forSegmentAt: 0)
                        self.segmentedControl.setTitle("Онлайн: 0", forSegmentAt: 1)
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.reloadData()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
            }
            opq.addOperation(parseRequest)
        } else if type == "chat_users" {
            OperationQueue.main.addOperation {
                self.sortedFriends = self.friends
                self.users = self.friends
                
                self.segmentedControl.setTitle("Участники: \(self.users.count)", forSegmentAt: 0)
                var onlineCount = 0
                for user in self.users {
                    if user.onlineStatus == 1 {
                        onlineCount += 1
                    }
                }
                self.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
                self.tableView.separatorStyle = .singleLine
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
    }

    @objc func tapDeleteAllRequests(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Пометить всё как просмотренные", style: .destructive){ action in
            
            self.deleteAllRequests(controller: self)
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapOKButton(sender: UIBarButtonItem) {
        
        var users = ""
        for user in chatUsers {
            if users != "" {
                users = "\(users),"
            }
            users = "\(users)\(user)"
        }
        if let vc = delegate as? DialogsController {
            self.createChat(userIDs: users, title: chatTitle, controller: vc)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        isSearch = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchUsers = sortedFriends.filter({ "\($0.firstName) \($0.lastName)".containsIgnoringCase(find: searchText) })
        
        if searchUsers.count == 0 {
            if segmentedControl.selectedSegmentIndex == 0 {
                users = sortedFriends
            } else {
                users = sortedFriends.filter({ $0.onlineStatus == 1 })
            }
            
            if type == "folowers" {
                segmentedControl.setTitle("Подписчики: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                segmentedControl.setTitle("Все друзья: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                segmentedControl.setTitle("Подписки: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "requests" {
                segmentedControl.setTitle("Заявки: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "chat_users" {
                segmentedControl.setTitle("Участники: \(self.sortedFriends.count)", forSegmentAt: 0)
            }
            segmentedControl.setTitle("Онлайн: \(self.sortedFriends.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            
            isSearch = false
        } else {
            if segmentedControl.selectedSegmentIndex == 0 {
                users = searchUsers
            } else {
                users = searchUsers.filter({ $0.onlineStatus == 1 })
            }
            
            if type == "followers" {
                segmentedControl.setTitle("Подписчики: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                segmentedControl.setTitle("Все друзья: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                segmentedControl.setTitle("Подписки: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "requests" {
                segmentedControl.setTitle("Заявки: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "chat_users" {
                segmentedControl.setTitle("Участники: \(self.searchUsers.count)", forSegmentAt: 0)
            }
            segmentedControl.setTitle("Онлайн: \(self.searchUsers.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            
            isSearch = true
        }
        
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //self.searchBar.text = nil
        self.searchBar.endEditing(true)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        users.removeAll(keepingCapacity: false)
        tableView.reloadData()
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        switch sender.selectedSegmentIndex {
        case 0:
            if isSearch {
                users = searchUsers
                
                sender.setTitle("Онлайн: \(self.searchUsers.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            } else {
                users = sortedFriends
                sender.setTitle("Онлайн: \(self.sortedFriends.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            }
            if type == "followers" {
                sender.setTitle("Подписчики: \(self.users.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                sender.setTitle("Все друзья: \(self.users.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                sender.setTitle("Подписки: \(self.users.count)", forSegmentAt: 0)
            } else if type == "requests" {
                sender.setTitle("Заявки: \(self.users.count)", forSegmentAt: 0)
            } else if type == "chat_users" {
                sender.setTitle("Участники: \(self.users.count)", forSegmentAt: 0)
            }
        case 1:
            if isSearch {
                users = searchUsers.filter({ $0.onlineStatus == 1 })
                if type == "followers" {
                    sender.setTitle("Подписчики: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type.containsIgnoringCase(find: "friends") {
                    sender.setTitle("Все друзья: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "subscript" {
                    sender.setTitle("Подписки: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "requests" {
                    sender.setTitle("Заявки: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "chat_users" {
                    sender.setTitle("Участники: \(self.searchUsers.count)", forSegmentAt: 0)
                }
            } else {
                users = sortedFriends.filter({ $0.onlineStatus == 1 })
                if type == "followers" {
                    sender.setTitle("Подписчики: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type.containsIgnoringCase(find: "friends") {
                    sender.setTitle("Все друзья: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "subscript" {
                    sender.setTitle("Подписки: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "requests" {
                    sender.setTitle("Заявки: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "chat_users" {
                    sender.setTitle("Участники: \(self.sortedFriends.count)", forSegmentAt: 0)
                }
            }
            sender.setTitle("Онлайн: \(self.users.count)", forSegmentAt: 1)
        default:
            break
        }
        tableView.reloadData()
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        ViewControllerUtils().hideActivityIndicator()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let count = getNumberOfSection()
        if count == 0 {
            tableView.separatorStyle = .none
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch type {
        case "friends":
            return sections[section].countRows
        case "commonFriends":
            return sections[section].countRows
        case "followers":
            return sections[section].countRows
        case "subscript":
            return sections[section].countRows
        case "requests":
            return sections[section].countRows
        case "chat_users":
            return sections[section].countRows
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if type == "friends" || type == "commonFriends" {
            return 18
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 18
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        
        if #available(iOS 13.0, *) {
            viewHeader.backgroundColor = .separator
        } else {
            viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
        
        if type == "friends" || type == "commonFriends" {
            let label = UILabel()
            label.font = UIFont(name: "Verdana-Bold", size: 14)!
            label.frame = CGRect(x: 10, y: 1, width: tableView.frame.width - 20, height: 16)
            label.textAlignment = .right
            label.text = sections[section].letter
            
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
            
            viewHeader.addSubview(label)
        }
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = vkSingleton.shared.backColor
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let user = sections[indexPath.section].users[indexPath.row]
                    
                    if source == "add_mention" {
                        let mention = "[id\(user.userID)|\(user.firstName) \(user.lastName)]"
                        if let vc = delegate as? NewRecordController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_comment_mention" {
                        let mention = "[id\(user.userID)|\(user.firstName) \(user.lastName)]"
                        if let vc = delegate as? NewCommentController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_topic_mention" {
                        let mention = "[id\(user.userID)|\(user.firstName) \(user.lastName)]"
                        if let vc = delegate as? AddTopicController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_dialog" {
                        
                        self.openDialog(userID: user.userID, attachment: attachment)
                    } else if source == "invite" {
                        if let vc = delegate as? GroupProfileController2 {
                            self.inviteInGroup(groupID: "\(vc.groupID)", userID: user.userID, name: "\(user.firstName) \(user.lastName)")
                        }
                    } else if source == "add_to_chat" {
                        if let vc = delegate as? DialogController {
                            self.addUserToChat(chatID: vc.chatID, userID: user.userID, controller: vc)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "create_chat" {
                        if let id  = Int(user.userID), !self.chatUsers.contains(id) {
                            self.chatUsers.append(id)
                            if chatUsers.count > 0 {
                                chatButton.isEnabled = true
                                chatButton.title = "Готово (\(chatUsers.count))"
                            } else {
                                chatButton.isEnabled = false
                                chatButton.title = "Готово"
                            }
                            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                            self.chatMarkCheck[indexPath]?.setOn(true, animated: true)
                        }
                    } else {
                        self.openProfileController(id: Int(user.userID)!, name: "\(user.firstName) \(user.lastName)")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let user = sections[indexPath.section].users[indexPath.row]
                    
                    if source == "create_chat" {
                        if let id  = Int(user.userID), self.chatUsers.contains(id) {
                            chatUsers.remove(object: id)
                            if chatUsers.count > 0 {
                                chatButton.isEnabled = true
                                chatButton.title = "Готово (\(chatUsers.count))"
                            } else {
                                chatButton.isEnabled = false
                                chatButton.title = "Готово"
                            }
                            self.tableView.deselectRow(at: indexPath, animated: false)
                            self.chatMarkCheck[indexPath]?.setOn(false, animated: true)
                        }
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if type == "requests" {
            return true
        }
        
        let user = self.sections[indexPath.section].users[indexPath.row]
        if type == "chat_users" && chatAdminID == vkSingleton.shared.userID && chatAdminID != user.userID {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
        }
        
        if editingStyle == .insert {
            
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if type == "requests" {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Оставить в\nподписчиках") { (rowAction, indexPath) in
                
                let user = self.sections[indexPath.section].users[indexPath.row]
                self.deleteRequest(userID: user.userID, controller: self)
            }
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
        
        if type == "chat_users" && chatAdminID == vkSingleton.shared.userID {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить\nиз чата") { (rowAction, indexPath) in
                if let delegate = self.delegate as? DialogController {
                    let user = self.sections[indexPath.section].users[indexPath.row]
                    self.removeFromChat(chatID: delegate.chatID, userID: user.userID, controller: delegate)
                }
                self.navigationController?.popViewController(animated: true)
            }
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
        
        return []
    }
    
    func openDialog(userID: String, attachment: String) {
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "user_id": userID,
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
                self.navigationController?.popViewController(animated: true)
                self.openDialogController(userID: userID, chatID: "", startID: startID, attachment: attachment, messIDs: [], image: self.attachImage)
                
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)
        
        for subview in cell.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        switch type {
        case "friends","commonFriends","followers","subscript","requests","chat_users":
            
            let user = sections[indexPath.section].users[indexPath.row]
            
            cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
            if type == "friends" && user.inLove {
                cell.textLabel?.text = "\(user.firstName) \(user.lastName) 💞"
            }
            
            if user.deactivated != "" {
                if user.deactivated == "banned" {
                    cell.detailTextLabel?.text = "страница заблокирована"
                }
                if user.deactivated == "deleted" {
                    cell.detailTextLabel?.text = "страница удалена"
                }
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .secondaryLabel
                } else {
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.isEnabled = false
                }
            } else {
                if user.onlineStatus == 1 {
                    cell.detailTextLabel?.text = "онлайн"
                    if user.onlineMobile == 1 {
                        cell.detailTextLabel?.text = "онлайн (моб.)"
                    }
                    cell.detailTextLabel?.textColor = cell.detailTextLabel?.tintColor
                    cell.detailTextLabel?.isEnabled = true
                } else {
                    if user.sex == 1 {
                        cell.detailTextLabel?.text = "заходила \(user.lastSeen.toStringLastTime())"
                    } else {
                        cell.detailTextLabel?.text = "заходил \(user.lastSeen.toStringLastTime())"
                    }
                    if #available(iOS 13.0, *) {
                        cell.detailTextLabel?.textColor = .secondaryLabel
                    } else {
                        cell.detailTextLabel?.textColor = UIColor.black
                        cell.detailTextLabel?.isEnabled = false
                    }
                }
            }
            
            cell.imageView?.image = UIImage(named: "error")
            let getCacheImage = GetCacheImage(url: user.photoURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = 25.0
                cell.imageView?.clipsToBounds = true
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            if type == "chat_users" {
                if chatAdminID == user.userID {
                    let adminLabel = UILabel()
                    adminLabel.tag = 200
                    adminLabel.text = "создатель\nчата"
                    adminLabel.font = UIFont(name: "Verdana", size: 9)!
                    adminLabel.numberOfLines = 2
                    adminLabel.textAlignment = .center
                    adminLabel.textColor = UIColor.red
                    adminLabel.frame = CGRect(x: cell.bounds.width - 70, y: 5, width: 50, height: cell.bounds.height-10)
                    cell.addSubview(adminLabel)
                }
                
                cell.accessoryType = .none
            }
            
            if self.source == "create_chat" {
                let markCheck = BEMCheckBox()
                markCheck.tag = 200
                markCheck.onTintColor = vkSingleton.shared.mainColor
                markCheck.onCheckColor = vkSingleton.shared.mainColor
                markCheck.lineWidth = 2
                markCheck.isEnabled = false
                if let id = Int(user.userID) {
                    markCheck.on = chatUsers.contains(id)
                }
                markCheck.frame = CGRect(x: cell.bounds.width - 40, y: cell.bounds.height/2 - 10, width: 20, height: 20)
                cell.addSubview(markCheck)
                chatMarkCheck[indexPath] = markCheck
                
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        return cell
    }
    
    func getNumberOfSection() -> Int {
        
        sections.removeAll(keepingCapacity: false)
        var num = 0
        
        if userID == vkSingleton.shared.userID && isSearch == false && friends.count > 0 && segmentedControl.selectedSegmentIndex == 0 && type == "friends" && source != "create_chat"{
            var users = [Friends]()
            var count = 0
            if friends.count >= 5 {
                for index in 0...4 {
                    users.append(friends[index])
                }
                count = 5
            } else {
                for index in 0...friends.count - 1 {
                    users.append(friends[index])
                }
                count = friends.count
            }
            num = 1
            let section = Sections(num: num - 1, letter: "Важные", count: count, users: users)
            sections.append(section)
        }
        
        if type == "followers" || type == "subscript" {
            num = 1
            let section = Sections(num: num - 1, letter: "", count: users.count, users: users)
            sections.append(section)
        } else {
            for alf in alphabet {
                let users = self.users.filter( { $0.lastName.prefix(1).uppercased() == alf } )
                if users.count > 0 {
                    num += 1
                    let section = Sections(num: num - 1, letter: alf, count: users.count, users: users)
                    sections.append(section)
                }
            }
        }
        
        return num
    }
}

struct Sections {
    var numSection: Int
    var letter: String
    var countRows: Int
    var users: [Friends]
    
    init(num: Int, letter: String, count: Int, users: [Friends]) {
        self.numSection = num
        self.letter = letter
        self.countRows = count
        self.users = users
    }
}

extension Int {
    func toStringLastTime() -> String {
        var str = ""
        
        if self <= Int(NSDate().timeIntervalSince1970) {
            let interval = Int(NSDate().timeIntervalSince1970) - self
            
            if interval < 60 {
                str = "только что"
            }
            
            if interval >= 60 && interval < 3600 {
                let min = interval / 60
                
                if min % 10 == 1 {
                    str = "\(min) минуту назад"
                }
                
                if min > 10 && min < 20 {
                    if min % 10 >= 1 && min % 10 <= 9 {
                        str = "\(min) минут назад"
                    }
                } else {
                    if min % 10 > 1 && min % 10 < 5 {
                        str = "\(min) минуты назад"
                    }
                    
                }
                
                if min % 10 >= 5 || min % 10 == 0 {
                    str = "\(min) минут назад"
                }
            }
            
            if interval >= 3600 && interval <= 18000 {
                let hour = interval / 3600
                
                if hour == 1 {
                    str = "час назад"
                }
                if hour == 2 {
                    str = "два часа назад"
                }
                if hour == 3 {
                    str = "три часа назад"
                }
                if hour == 4 {
                    str = "четыре часа назад"
                }
                if hour == 5 {
                    str = "пять часов назад"
                }
                
            }
            
            if interval > 18000 {
                let date = NSDate(timeIntervalSince1970: Double(self))
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
                dateFormatter.timeZone = TimeZone.current
                
                str = dateFormatter.string(from: date as Date)
            }
        } else {
            let date = NSDate(timeIntervalSince1970: Double(self))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
            dateFormatter.timeZone = TimeZone.current
            
            str = dateFormatter.string(from: date as Date)
        }
        
        return str
    }
    
    func toStringCommentLastTime() -> String {
        var str = ""
        
        if self <= Int(NSDate().timeIntervalSince1970) {
            let interval = Int(NSDate().timeIntervalSince1970) - self
            
            if interval < 60 {
                str = "только что"
            }
            
            if interval >= 60 && interval < 3600 {
                let min = interval / 60
                
                if min % 10 == 1 {
                    str = "\(min) минуту назад"
                }
                
                if min > 10 && min < 20 {
                    if min % 10 >= 1 && min % 10 <= 9 {
                        str = "\(min) минут назад"
                    }
                } else {
                    if min % 10 > 1 && min % 10 < 5 {
                        str = "\(min) минуты назад"
                    }
                    
                }
                
                if min % 10 >= 5 || min % 10 == 0 {
                    str = "\(min) минут назад"
                }
            }
            
            if interval >= 3600 && interval <= 18000 {
                let hour = interval / 3600
                
                if hour == 1 {
                    str = "час назад"
                }
                if hour == 2 {
                    str = "два часа назад"
                }
                if hour == 3 {
                    str = "три часа назад"
                }
                if hour == 4 {
                    str = "четыре часа назад"
                }
                if hour == 5 {
                    str = "пять часов назад"
                }
                
            }
            
            if interval > 18000 {
                let date = NSDate(timeIntervalSince1970: Double(self))
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                dateFormatter.dateFormat = "dd.MM.yyyy в HH:mm"
                dateFormatter.timeZone = TimeZone.current
                
                str = dateFormatter.string(from: date as Date)
            }
        } else {
            let date = NSDate(timeIntervalSince1970: Double(self))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            dateFormatter.dateFormat = "dd.MM.yyyy в HH:mm"
            dateFormatter.timeZone = TimeZone.current
            
            str = dateFormatter.string(from: date as Date)
        }
        
        return str
    }
}
