//
//  GroupsListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 06.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupsListController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: UIViewController!
    
    
    var userID = ""
    var type = ""
    var source = ""
    
    var isSearch = false
    
    var groups: [Groups] = []
    var searchGroups: [Groups] = []
    var groupsList: [Groups] = []
    
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
        
        OperationQueue.main.addOperation {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            self.searchBar.showsCancelButton = false
            self.searchBar.backgroundColor = vkSingleton.shared.backColor
            
            if self.userID == vkSingleton.shared.userID && self.type == "" && self.source == "" {
                
                if vkSingleton.shared.adminGroupID.count == 0 {
                    let actionButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.tapSearchButton(sender:)))
                    self.navigationItem.rightBarButtonItem = actionButton
                } else {
                    let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapActionButton(sender:)))
                    self.navigationItem.rightBarButtonItem = actionButton
                }
            }
            
            self.tableView.separatorStyle = .none
            if self.type != "search" {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
        }
        
        refresh()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
        let opq = OperationQueue()
        
        if type != "search" {
            
            let url = "/method/groups.get"
            var parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by,age_limits,status,description",
                "v": vkSingleton.shared.version
            ]
            
            if type == "groups" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "groups",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by,age_limits,status,description",
                    "v": vkSingleton.shared.version
                ]
            }
            
            if type == "pages" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "publics",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by,age_limits,status,description",
                    "v": vkSingleton.shared.version
                ]
            }
            
            if type == "admin" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "moder",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by,age_limits,status,description",
                    "v": vkSingleton.shared.version
                ]
            }
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadGroupsListController(controller: self)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
        }
    }
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func refreshSearch() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let text = searchBar.text!
        let opq = OperationQueue()
        
        let url = "/method/groups.search"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "q": text,
            "type": "group,page,event",
            "count": "1000",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseGroups = ParseGroupList()
        parseGroups.addDependency(getServerDataOperation)
        opq.addOperation(parseGroups)
        
        let reloadTableController = ReloadGroupsListController(controller: self)
        reloadTableController.addDependency(parseGroups)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
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
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        if #available(iOS 13.0, *) {
            viewFooter.backgroundColor = .separator
        } else {
            viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath)
        
        let group = groupsList[indexPath.row]
        
        cell.textLabel?.text = group.name
        
        if group.deactivated != "" {
            if group.deactivated == "deleted" {
                cell.detailTextLabel?.text = "Сообщество удалено"
            } else {
                cell.detailTextLabel?.text = "Сообщество заблокировано"
            }
        } else {
            if group.typeGroup == "group" {
                if group.isClosed == 0 {
                    cell.detailTextLabel?.text = "Открытая группа"
                } else if group.isClosed == 1 {
                    cell.detailTextLabel?.text = "Закрытая группа"
                } else {
                    cell.detailTextLabel?.text = "Частная группа"
                }
            } else if group.typeGroup == "page" {
                cell.detailTextLabel?.text = "Публичная страница"
            } else {
                cell.detailTextLabel?.text = "Мероприятие"
            }
        }
        
        let getCacheImage = GetCacheImage(url: group.coverURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            cell.imageView?.layer.cornerRadius = 25.0
            cell.imageView?.clipsToBounds = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let group = groupsList[indexPath.row]
                    
                    
                    if source == "add_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? NewRecordController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_comment_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? NewCommentController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_topic_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? AddTopicController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.openProfileController(id: -1 * Int(group.gid)!, name: group.name)
                    }
                    
                }
            }
        }
    }
    
    @objc func tapSearchButton(sender: UIBarButtonItem) {
        self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Поиск", type: "search")
    }
        
    @objc func tapActionButton(sender: UIBarButtonItem) {
     
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Поиск нового сообщества", style: .default){ action in
            
            self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Поиск", type: "search")
        }
        alertController.addAction(action1)
        
        if vkSingleton.shared.adminGroupID.count > 0 {
            let action2 = UIAlertAction(title: "Управление сообществами", style: .default){ action in
                
                self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Управление", type: "admin")
            }
            alertController.addAction(action2)
        }
        
        self.present(alertController, animated: true)
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
        
        if type != "search" {
            searchGroups = groups.filter({ $0.name.containsIgnoringCase(find: searchText) })
            
            if searchGroups.count == 0 {
                groupsList = groups
                isSearch = false
            } else {
                groupsList = searchGroups
                isSearch = true
            }
            
            self.tableView.reloadData()
        } else {
            refreshSearch()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
}
