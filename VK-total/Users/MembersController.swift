//
//  MembersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON

class MembersController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var groupID = 0
    var filters = ""
    var offset = 0
    var count = 1000
    var total = 0
    
    var isRefresh = false
    var isSearch = false
    var isAdmin = false
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    var users = [Friends]()
    var members = [Friends]()
    var searchMembers = [Friends]()
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        OperationQueue.main.addOperation {
            if UIScreen.main.nativeBounds.height == 2436 {
                self.navHeight = 88
                self.tabHeight = 83
            }
            
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            self.tableView.separatorStyle = .none
        }
        
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: 54))
        
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = UIColor(white: 0, alpha: 0.2)
            searchField.textColor = .black
        } else {
            if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchField.backgroundColor = UIColor(white: 0, alpha: 0.2)
                searchField.textColor = .black
            }
        }
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabHeight - searchBar.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MembersCell.self, forCellReuseIdentifier: "memberCell")
        
        self.view.addSubview(tableView)
    }
    
    func refresh() {
        let opq = OperationQueue()
        isRefresh = true
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let url = "/method/groups.getMembers"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "sort": "id_desc",
            "offset": "\(offset)",
            "count": "\(count)",
            "fields": "online,photo_max,last_seen,sex,is_friend",
            "filter": filters,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseFriends = ParseFriendList()
        parseFriends.addDependency(getServerDataOperation)
        opq.addOperation(parseFriends)
        
        let reloadTableController = ReloadMembersController(controller: self)
        reloadTableController.addDependency(parseFriends)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = UIColor.white
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! MembersCell
        
        cell.configureCell(user: users[indexPath.row], filter: filters, indexPath: indexPath, cell: cell, tableView: tableView)
        
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let user = users[indexPath.row]
                    
                    if let id = Int(user.userID) {
                        openProfileController(id: id, name: "")
                    }
                }
            }
        }
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
        
        searchMembers = members.filter({ "\($0.firstName) \($0.lastName)".containsIgnoringCase(find: searchText) })
            
        if searchMembers.count == 0 {
            users = members
            isSearch = false
        } else {
            users = searchMembers
            isSearch = true
        }
            
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && offset < total {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isAdmin {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if filters != "managers" {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Исключить") { (rowAction, indexPath) in
                let user = self.users[indexPath.row]
                
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
                    let url = "/method/groups.removeUser"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "group_id": "\(self.groupID)",
                        "user_id": user.uid,
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
                            self.users.remove(at: indexPath.row)
                            self.offset = 0
                            self.refresh()
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                
                alertView.addButton("Отмена, я передумал") {
                    
                }
                alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите исключить подписчика «\(user.firstName) \(user.lastName)» из сообщества?")
                
            }
            deleteAction.backgroundColor = UIColor.red
            
            let addAction = UITableViewRowAction(style: .normal, title: "Назначить") { (rowAction, indexPath) in
                
                let user = self.users[indexPath.row]
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Модератор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "moderator", type: "add", controller: self)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Редактор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "editor", type: "add", controller: self)
                }
                alertController.addAction(action2)
                
                let action3 = UIAlertAction(title: "Администратор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "administrator", type: "add", controller: self)
                }
                alertController.addAction(action3)
                
                self.present(alertController, animated: true)
            }
            
            addAction.backgroundColor = UIColor.blue
            
            return [addAction,deleteAction]
        } else {
            let changeAction = UITableViewRowAction(style: .normal, title: "Изменить") { (rowAction, indexPath) in
                
                let user = self.users[indexPath.row]
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Модератор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "moderator", type: "change", controller: self)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Редактор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "editor", type: "change", controller: self)
                }
                alertController.addAction(action2)
                
                let action3 = UIAlertAction(title: "Администратор", style: .default) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "administrator", type: "change", controller: self)
                }
                alertController.addAction(action3)
                
                let action4 = UIAlertAction(title: "Разжаловать", style: .destructive) { action in
                    self.editManager(groupID: "\(abs(self.groupID))", userID: "\(user.userID)", role: "", type: "change", controller: self)
                }
                alertController.addAction(action4)
                
                self.present(alertController, animated: true)
            }
            
            changeAction.backgroundColor = UIColor.init(red: 79/255, green: 143/255, blue: 0/255, alpha: 1)
            
            return [changeAction]
        }
    }
}
