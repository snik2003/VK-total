//
//  AddGroupController.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension String {
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

class AddGroupController: UITableViewController, UISearchBarDelegate {
 
    var searchGroups = [Groups]()
    
    var resultSearchController: UISearchController!
    var searchBar: UISearchBar!
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            
            self.searchBar = UISearchBar()
            self.searchBar.delegate = self
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            self.searchBar.showsCancelButton = false
            self.searchBar.returnKeyType = UIReturnKeyType.done
            self.tableView.tableHeaderView = self.searchBar
            self.title = "Найти сообщество"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {            return searchGroups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if let gid = cell?.textLabel?.tag {
            let groupProfileController = self.storyboard?.instantiateViewController(withIdentifier: "GroupProfileController") as! GroupProfileController
            
            groupProfileController.groupID = gid
            groupProfileController.title =  cell?.textLabel?.text
            
            self.navigationController?.pushViewController(groupProfileController, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addGroupCell", for: indexPath)
        
        if indexPath.row < searchGroups.count {
            let searchGroup = searchGroups[indexPath.row]
            cell.textLabel?.text = searchGroup.name
            cell.textLabel?.tag = Int(searchGroup.gid)!
            
            if searchGroup.typeGroup == "group" {
                cell.detailTextLabel?.text = "группа"
            } else if searchGroup.typeGroup == "page" {
                cell.detailTextLabel?.text = "публичная страница"
            } else {
                cell.detailTextLabel?.text = "событие"
            }

            /*let imgURL = URL(string: searchGroup.coverURL)
            let imgData = NSData(contentsOf: imgURL!)
            cell.imageView?.image = UIImage(data: imgData! as Data)*/
        
            let getCacheImage = GetCacheImage(url: searchGroup.coverURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.borderColor = UIColor.black.cgColor
                cell.imageView?.layer.cornerRadius = 27.0
                cell.imageView?.layer.borderWidth = 0.0
                cell.imageView?.clipsToBounds = true
            }
        }

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            searchGroups.removeAll(keepingCapacity: false)
            tableView.reloadData()
        } else {
            searchGroups.removeAll(keepingCapacity: false)
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
            }
            
            let text = searchBar.text!
            let opq = OperationQueue()
            
            let url = "/method/groups.search"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "q": text,
                "type": "group,page,event",
                "count": "100",
                "v": vkSingleton.shared.version
                ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadAddGroupController(controller: self)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
            
        }
    }
}
