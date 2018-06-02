//
//  GroupsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupsController: UITableViewController, UISearchBarDelegate {
    
    var userID = vkSingleton.shared.userID
    
    var groups = [Groups]()
    var addGroups = [Groups]()
    var searchGroups = [Groups]()

    var isSearching = false
    var searchBar: UISearchBar!
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
            
            self.searchBar = UISearchBar()
            self.searchBar.delegate = self
            self.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            self.searchBar.showsCancelButton = false
            self.searchBar.returnKeyType = UIReturnKeyType.done
            self.tableView.tableHeaderView = self.searchBar
        }
        
        let opq = OperationQueue()
        
        let url = "/method/groups.get"
        let parameters = [
            "user_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "extended": "1",
            "fields": "name,cover,members_count",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseGroups = ParseGroupList()
        parseGroups.addDependency(getServerDataOperation)
        opq.addOperation(parseGroups)
        
        let reloadTableController = ReloadGroupsController(controller: self)
        reloadTableController.addDependency(parseGroups)
        OperationQueue.main.addOperation(reloadTableController)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            self.tableView?.reloadData()
        } else {
            isSearching = true
            let text = searchBar.text!
            DispatchQueue.global().async {
                self.searchGroups = self.groups.filter({$0.name.containsIgnoringCase(find: text)})
            }
            self.tableView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchGroups.count
        }
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if let gid = cell?.textLabel?.tag {
            
            var title = "Сообщество"
            if let name = cell?.textLabel?.text {
                if name.length > 20 {
                    title =  "\((name).prefix(20))..."
                } else {
                    title = name
                }
            }
            
            self.openProfileController(id: -1 * gid, name: title)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        
        var group = groups[indexPath.row]
        if isSearching {
            if indexPath.row < searchGroups.count {
                group = searchGroups[indexPath.row]
            }
        }
        cell.textLabel?.text = group.name
        cell.textLabel?.tag = Int(group.gid)!
        
        //cell.detailTextLabel?.text = "\(group.membersCount) подписчиков"
        if group.typeGroup == "group" {
           cell.detailTextLabel?.text = "группа"
        } else if group.typeGroup == "page" {
           cell.detailTextLabel?.text = "публичная страница"
        } else {
           cell.detailTextLabel?.text = "событие"
        }

        let getCacheImage = GetCacheImage(url: group.coverURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            cell.imageView?.layer.borderColor = UIColor.black.cgColor
            cell.imageView?.layer.cornerRadius = 27.0
            cell.imageView?.layer.borderWidth = 0.0
            cell.imageView?.clipsToBounds = true
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var group = groups[indexPath.row]
            if isSearching {
                group = searchGroups[indexPath.row]
            }

            let alter = UIAlertController (title:  "Внимание!",  message:  "Вы действительно хотите удалить сообщество \"\(group.name)\"?",  preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "Да", style: .default) { (_) ->
                Void in
                
                if self.isSearching {
                    self.searchGroups.remove(at: indexPath.row)
                } else {
                    self.groups.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            alter.addAction(action1)
            let action2 = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
            alter.addAction(action2)
            
            present(alter, animated: true, completion: nil)
        }
    }
    
    @IBAction func addGroup(segue: UIStoryboardSegue) {
        if segue.identifier == "addGroup" {
            let addGroupController = segue.source as! AddGroupController
            
            if let indexPath = addGroupController.tableView.indexPathForSelectedRow {
                let addGroup = addGroupController.searchGroups[indexPath.row]
                
                var userIsMember = false
                for group in groups {
                    if group.name == addGroup.name { userIsMember = true }
                }
                
                if !userIsMember {
                    groups.append(addGroup)
                    tableView.reloadData()
                }
            }
        }
    }
}
