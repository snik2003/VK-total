//
//  CountersInfoTableViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire

class CountersInfoTableViewController: UITableViewController, UISearchBarDelegate {
    var userID = vkSingleton.shared.userID
    var typeData = ""
    
    let alphabet =  ["А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л",
                     "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш",
                     "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я", "A", "B", "C", "D", "E", "F",
                     "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                     "T", "U", "V", "W", "X", "Y", "Z"]

    var friends = [Friends]()
    var searchFriends = [Friends]()
    var friendsOnline = [Friends]()
    var mutualFriends = [Friends]()
    var searchMutualFriends = [Friends]()
    var followers = [Followers]()
    var groups = [Groups]()
    var searchGroups = [Groups]()
    var pages = [Groups]()
    var searchPages = [Groups]()
    var photos = [Photos]()
    var userProfile = [UserProfileInfo]()
    
    var isSearching = false
    var searchBar: UISearchBar!
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        self.refreshControl?.addTarget(self, action: #selector(CountersInfoTableViewController.refresh), for: UIControl.Event.valueChanged)
        self.refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(self.refreshControl!)

        OperationQueue.main.addOperation {
            if self.typeData != "photosCount" && self.typeData != "followersCount"{
                self.searchBar = UISearchBar()
                self.searchBar.delegate = self
                self.searchBar.searchBarStyle = UISearchBar.Style.minimal
                self.searchBar.sizeToFit()
                self.searchBar.placeholder = ""
                self.searchBar.showsCancelButton = false
                self.searchBar.returnKeyType = UIReturnKeyType.done
                self.tableView.tableHeaderView = self.searchBar
                
                if #available(iOS 13.0, *) {
                    let searchField = self.searchBar.searchTextField
                    searchField.backgroundColor = UIColor(white: 0, alpha: 0.2)
                    searchField.textColor = .black
                } else {
                    if let searchField = self.searchBar.value(forKey: "_searchField") as? UITextField {
                        searchField.backgroundColor = UIColor(white: 0, alpha: 0.2)
                        searchField.textColor = .black
                    }
                }
            }
        
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
        }
        
        var url: String
        var parameters: Parameters
        let opq = OperationQueue()
        
        if self.typeData == "friendsCount" {
            self.title = "Друзья \(self.userProfile[0].firstNameGen)"
            
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
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
        }
        
        if typeData == "commonFriendsCount" {
            self.title = "Общие друзья"
            
            url = "/method/friends.get"
            parameters = [
                "user_id": self.userID,
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseMutualFriends = ParseFriendList()
            parseMutualFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseMutualFriends)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseMutualFriends)
            OperationQueue.main.addOperation(reloadTableController)
        }
        
        if typeData == "followersCount" {
            self.title = "Подписчики \(userProfile[0].firstNameGen)"
            
            // получаем объект с сервера ВК
            url = "/method/users.getFollowers"
            parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            // парсим объект
            let parseFollowers = ParseFollowersList()
            parseFollowers.addDependency(getServerDataOperation)
            opq.addOperation(parseFollowers)
            
            // обновляем данные на UI
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseFollowers)
            OperationQueue.main.addOperation(reloadTableController)
        }
        
        if typeData == "groupsCount" {
            self.title = "Группы \(userProfile[0].firstNameGen)"
            
            let url = "/method/groups.get"
            let parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count",
                "filter": "groups",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
        }
        
        if typeData == "pagesCount" {
            self.title = "Страницы \(userProfile[0].firstNameGen)"
            
            let url = "/method/groups.get"
            let parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count",
                "filter": "publics",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
        }
        
        if typeData == "photosCount" {
            if userProfile.count > 0 {
                self.title = "Фото \(userProfile[0].firstNameGen)"
            }
            
            // получаем объект с фотографиями с сервера ВК
            url = "/method/photos.getAll"
            parameters = [
                "owner_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "count": "200",
                "photo_sizes": "0",
                "skip_hidden": "0",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            // парсим объект с фотографиями
            let parsePhotos = ParsePhotosList()
            parsePhotos.addDependency(getServerDataOperation)
            opq.addOperation(parsePhotos)
            
            // обновляем данные на UI
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parsePhotos)
            OperationQueue.main.addOperation(reloadTableController)
        }
    }
    
    @objc func refresh() {
        var url: String
        var parameters: Parameters
        let opq = OperationQueue()

        if self.typeData == "friendsCount" {
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
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
        }

        if typeData == "commonFriendsCount" {
            url = "/method/friends.get"
            parameters = [
                "user_id": self.userID,
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseMutualFriends = ParseFriendList()
            parseMutualFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseMutualFriends)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseMutualFriends)
            OperationQueue.main.addOperation(reloadTableController)
        }

        if typeData == "followersCount" {
            // получаем объект с сервера ВК
            url = "/method/users.getFollowers"
            parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            // парсим объект
            let parseFollowers = ParseFollowersList()
            parseFollowers.addDependency(getServerDataOperation)
            opq.addOperation(parseFollowers)
            
            // обновляем данные на UI
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseFollowers)
            OperationQueue.main.addOperation(reloadTableController)
        }

        if typeData == "groupsCount" {
            
            url = "/method/groups.get"
            parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count",
                "filter": "groups",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
            
        }

        if typeData == "pagesCount" {
            
            url = "/method/groups.get"
            parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count",
                "filter": "publics",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadCountersInfoController(controller: self, type: typeData)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            self.tableView?.reloadData()
        } else {
            isSearching = true
            let text = searchBar.text!
            
            
            
            if typeData == "friendsCount" {
                let opq = OperationQueue()
                let url = "/method/friends.search"
                let parameters = [
                    "user_id": self.userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "q": text,
                    "count": "1000",
                    "fields": "online,photo_max,last_seen,sex,is_friend",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                opq.addOperation(getServerDataOperation)
                
                let parseFriends = ParseFriendList()
                parseFriends.addDependency(getServerDataOperation)
                opq.addOperation(parseFriends)
                
                let reloadTableController = ReloadCountersInfoController(controller: self, type: "searchFriendsCount")
                reloadTableController.addDependency(parseFriends)
                OperationQueue.main.addOperation(reloadTableController)
            }
            if typeData == "commonFriendsCount" {
                let opq = OperationQueue()
                let url = "/method/friends.search"
                let parameters = [
                    "user_id": self.userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "q": text,
                    "count": "1000",
                    "fields": "online,photo_max,last_seen,sex,is_friend",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                opq.addOperation(getServerDataOperation)
                
                let parseFriends = ParseFriendList()
                parseFriends.addDependency(getServerDataOperation)
                opq.addOperation(parseFriends)
                
                let reloadTableController = ReloadCountersInfoController(controller: self, type: "searchMutualFriendsCount")
                reloadTableController.addDependency(parseFriends)
                OperationQueue.main.addOperation(reloadTableController)
                
                /*searchMutualFriends = mutualFriends.filter({ "\($0.firstName) \($0.lastName)".containsIgnoringCase(find: text) })*/
            }
            if typeData == "groupsCount" {
                searchGroups = groups.filter({ $0.name.containsIgnoringCase(find: text) })
            }
            if typeData == "pagesCount" {
                searchPages = pages.filter({ $0.name.containsIgnoringCase(find: text) })
            }
            
            
            self.tableView?.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath)
                
                if let gid = cell?.textLabel?.tag {
                    
                    let groupProfileController: GroupProfileController = segue.destination as! GroupProfileController
                    
                    
                    groupProfileController.groupID = gid
                    if let name = cell?.textLabel?.text {
                        if name.length > 20 {
                            groupProfileController.title =  "\((name).prefix(20))..."
                        } else {
                            groupProfileController.title = name
                        }
                    } else {
                        groupProfileController.title = "Сообщество"
                    }
                }
            }
        }
        
        if segue.identifier == "showUserProfile" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destVC: ProfileController = segue.destination as! ProfileController
                
                if typeData == "friendsCount" {
                    let char = getChar(indexPath.section)
                    var friendsAlphabet = [Friends]()
                    if isSearching {
                        friendsAlphabet = searchFriends.filter({ $0.lastName.prefix(1).uppercased() == char })
                    } else {
                        friendsAlphabet = friends.filter({ $0.lastName.prefix(1).uppercased() == char })
                    }
                    let sortedFriendsAlphabet = friendsAlphabet.sorted(by: {$0.lastName < $1.lastName})
                    let friend = sortedFriendsAlphabet[indexPath.row]

                    destVC.userID = friend.uid
                    destVC.title =  "\(friend.firstName) \(friend.lastName)"
                }
                if typeData == "commonFriendsCount" {
                    var sortedMutualFriends = [Friends]()
                    if isSearching {
                        sortedMutualFriends = searchMutualFriends.sorted(by: {$0.lastName < $1.lastName})
                    } else {
                        sortedMutualFriends = mutualFriends.sorted(by: {$0.lastName < $1.lastName})
                    }
                    
                    destVC.userID = sortedMutualFriends[indexPath.row].uid
                    destVC.title =  "\(sortedMutualFriends[indexPath.row].firstName) \(sortedMutualFriends[indexPath.row].lastName)"
                }
                if typeData == "followersCount" {
                    destVC.userID = followers[indexPath.row].uid
                    destVC.title =  "\(followers[indexPath.row].firstName) \(followers[indexPath.row].lastName)"
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if typeData == "friendsCount" {
            return getCountOfSectionSortByName()
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if typeData == "friendsCount" {
            return getChar(section)
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if typeData == "friendsCount" {
            return 22
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeData {
        case "friendsCount":
            return getNumberOfRowsInSectionSortByName(section)
        case "commonFriendsCount":
            
            if isSearching {
                return searchMutualFriends.count
            }
            return mutualFriends.count
        case "followersCount":
            return followers.count
        case "groupsCount":
            if isSearching {
                return searchGroups.count
            }
            return groups.count
        case "pagesCount":
            if isSearching {
                return searchPages.count
            }
            return pages.count
        case "photosCount":
            var count = photos.count / 3
            if (photos.count % 3 > 0) { count += 1 }
            return count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if typeData == "photosCount" {
            return UIScreen.main.bounds.height * 0.15
        }
        return 56
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch typeData {
        case "friendsCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
            
            let char = getChar(indexPath.section)
            var friendsAlphabet = [Friends]()
            if isSearching {
                friendsAlphabet = searchFriends.filter({ $0.lastName.prefix(1).uppercased() == char })
            } else {
                friendsAlphabet = friends.filter({ $0.lastName.prefix(1).uppercased() == char })
            }
            let sortedFriendsAlphabet = friendsAlphabet.sorted(by: {$0.lastName < $1.lastName})
            
            if indexPath.row < sortedFriendsAlphabet.count {
                let friend = sortedFriendsAlphabet[indexPath.row]
            
                cell.textLabel?.text = "\(friend.firstName) \(friend.lastName)"
                if friend.deactivated != "" {
                    if friend.deactivated == "banned" {
                        cell.detailTextLabel?.text = "заблокирован"
                    }
                    if friend.deactivated == "deleted" {
                        cell.detailTextLabel?.text = "страница удалена"
                    }
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.textLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.isEnabled = false
                }
                else {
                    if friend.onlineStatus == 1 {
                        cell.detailTextLabel?.text = "онлайн"
                        if friend.onlineMobile == 1 {
                            cell.detailTextLabel?.text = "онлайн (моб.)"
                        }
                        cell.detailTextLabel?.isEnabled = true
                        cell.detailTextLabel?.textColor = UIColor.blue
                        cell.textLabel?.textColor = UIColor.black
                        friendsOnline.append(friend)
                    }
                    else {
                        var sexLabel = "заходил "
                        if friend.sex == 1 {
                        sexLabel = "заходила "
                        }
                        cell.detailTextLabel?.text = sexLabel + friend.lastSeen.toStringLastTime()
                        cell.detailTextLabel?.isEnabled = false
                        cell.textLabel?.textColor = UIColor.black
                    }
                }
            
                let getCacheImage = GetCacheImage(url: friend.photoURL, lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    cell.imageView?.layer.borderColor = UIColor.black.cgColor
                    cell.imageView?.layer.cornerRadius = 27.0
                    cell.imageView?.layer.borderWidth = 0.0
                    cell.imageView?.clipsToBounds = true
                    cell.imageView?.isHidden = false
                }
            }
            
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
                
            return cell
            
        case "commonFriendsCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
            
            var sortedMutualFriends = [Friends]()
            if isSearching {
                sortedMutualFriends = searchMutualFriends.sorted(by: {$0.lastName < $1.lastName})
            } else {
                sortedMutualFriends = mutualFriends.sorted(by: {$0.lastName < $1.lastName})
            }
            let mutualFriend = sortedMutualFriends[indexPath.row]
            
            cell.textLabel?.text = "\(mutualFriend.firstName) \(mutualFriend.lastName)"

            if mutualFriend.deactivated != "" {
                if mutualFriend.deactivated == "banned" {
                    cell.detailTextLabel?.text = "заблокирован"
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.gray
                }
                if mutualFriend.deactivated == "deleted" {
                    cell.detailTextLabel?.text = "страница удалена"
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.gray
                }
            }
            else {
                if mutualFriend.onlineStatus == 1 {
                    cell.detailTextLabel?.text = "онлайн"
                    if mutualFriend.onlineMobile == 1 {
                        cell.detailTextLabel?.text = "онлайн (моб.)"
                    }
                    cell.detailTextLabel?.isEnabled = true
                    cell.detailTextLabel?.textColor = UIColor.blue
                    cell.textLabel?.textColor = UIColor.black
               }
                else {
                    var sexLabel = "заходил "
                    if mutualFriend.sex == 1 {
                        sexLabel = "заходила "
                    }
                    cell.detailTextLabel?.text = sexLabel + mutualFriend.lastSeen.toStringLastTime()
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.black
               }
            }
            
            let getCacheImage = GetCacheImage(url: mutualFriend.photoURL, lifeTime: .avatarImage)
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
        
            cell.imageView?.isHidden = false
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
            
            return cell
            
        case "followersCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
            
            let follower = followers[indexPath.row]
            
            cell.textLabel?.text = "\(follower.firstName) \(follower.lastName)"
            if follower.deactivated != "" {
                if follower.deactivated == "banned" {
                    cell.detailTextLabel?.text = "заблокирован"
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.gray
                }
                if follower.deactivated == "deleted" {
                    cell.detailTextLabel?.text = "страница удалена"
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.gray
                }
            }
            else {
                if follower.onlineStatus == 1 {
                    cell.detailTextLabel?.text = "онлайн"
                    if follower.onlineMobile == 1 {
                        cell.detailTextLabel?.text = "онлайн (моб.)"
                    }
                    cell.detailTextLabel?.isEnabled = true
                    cell.detailTextLabel?.textColor = UIColor.blue
                    cell.textLabel?.textColor = UIColor.black
                }
                else {
                    var sexLabel = "заходил "
                    if follower.sex == 1 {
                        sexLabel = "заходила "
                    }
                    cell.detailTextLabel?.text = sexLabel + follower.lastSeen.toStringLastTime()
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.isEnabled = false
                    cell.textLabel?.textColor = UIColor.black
                }
            }
            
            let getCacheImage = GetCacheImage(url: follower.photoURL, lifeTime: .avatarImage)
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
            
            cell.imageView?.isHidden = false
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
            
            return cell
            
        case "groupsCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath)
            
            var group = groups[indexPath.row]
            if isSearching {
                group = searchGroups[indexPath.row]
            }
            
            cell.textLabel?.text = group.name
            cell.textLabel?.tag = Int(group.gid)!
            
            cell.detailTextLabel?.text = "\(group.membersCount) подписчиков"
            
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
            
            cell.imageView?.isHidden = false
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
            
            return cell
            
        case "pagesCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath)
            
            var page = pages[indexPath.row]
            if isSearching {
                page = searchPages[indexPath.row]
            }
            cell.textLabel?.text = page.name
            cell.textLabel?.tag = Int(page.gid)!
            
            
            cell.detailTextLabel?.text = "\(page.membersCount) подписчиков"
            
            let getCacheImage = GetCacheImage(url: page.coverURL, lifeTime: .avatarImage)
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
            
            cell.imageView?.isHidden = false
            cell.textLabel?.isHidden = false
            cell.detailTextLabel?.isHidden = false
            
            return cell
            
        case "photosCount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath) as! PhotoTableViewCell
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height * 0.15)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            cell.collectionView!.collectionViewLayout = layout
            
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()

            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }

    func getCountOfSectionSortByName() -> Int {
        if friends.count > 0 {
            var countAlphabet = [Int]()
            var charAlphabet = [String]()
            var filteredFriends = [Friends]()

            for char in alphabet {
                if self.isSearching {
                    filteredFriends = self.searchFriends.filter({ $0.lastName.prefix(1).uppercased() == char })
                } else {
                    filteredFriends = self.friends.filter({ $0.lastName.prefix(1).uppercased() == char })
                }

                if filteredFriends.count > 0 {
                    charAlphabet.append(char)
                    countAlphabet.append(filteredFriends.count)
                }
            }

            return charAlphabet.count
        }
        
        return 0
    }
    
    func getNumberOfRowsInSectionSortByName(_ section: Int ) -> Int {
        var countAlphabet = [Int]()
        var charAlphabet = [String]()
        var filteredFriends = [Friends]()

        if friends.count > 0 {
            for char in alphabet {
                if isSearching {
                    filteredFriends = searchFriends.filter({ $0.lastName.prefix(1).uppercased() == char })
                } else {
                    filteredFriends = friends.filter({ $0.lastName.prefix(1).uppercased() == char })
                }
                
                if filteredFriends.count > 0 {
                    charAlphabet.append(char)
                    countAlphabet.append(filteredFriends.count)
                }
            }
            
            if section < countAlphabet.count {
                return countAlphabet[section]
            }
        }
        
        return 0
    }
    
    func getChar(_ section: Int ) -> String {
        var countAlphabet = [Int]()
        var charAlphabet = [String]()
        var filteredFriends = [Friends]()

        if friends.count > 0 {
            for char in alphabet {
                if isSearching {
                    filteredFriends = searchFriends.filter({ $0.lastName.prefix(1).uppercased() == char })
                } else {
                    filteredFriends = friends.filter({ $0.lastName.prefix(1).uppercased() == char })
                }
                
                if filteredFriends.count > 0 {
                    charAlphabet.append(char)
                    countAlphabet.append(filteredFriends.count)
                }
            }
            
            if section < charAlphabet.count {
                return charAlphabet[section]
            }
        }
        
        return ""
    }
}

extension CountersInfoTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == self.tableView.numberOfRows(inSection: 0) - 1 {
            if photos.count % 3 == 0 {
                return 3
            }
            return photos.count % 3
        }
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UIScreen.main.bounds.height * 0.15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.height);
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
        
        photoViewController.numPhoto = collectionView.tag * 3 + indexPath.row
        photoViewController.photos = photos
            
        self.navigationController?.pushViewController(photoViewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! PhotoCollectionViewCell
            
        let photoImage: UIImageView = cell.viewWithTag(1) as! UIImageView
        
        photoImage.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        
        let photo = photos[collectionView.tag * 3 + indexPath.row]
        var url = photo.bigPhotoURL
        if url == "" { url = photo.photoURL }
        if url == "" { url = photo.smallPhotoURL }
            
        let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
        let setImageToRow = SetImageToRowOfCollectionView(cell: cell, imageView: photoImage, indexPath: indexPath, collectionView: collectionView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            photoImage.layer.borderColor = UIColor.black.cgColor
            photoImage.layer.borderWidth = 0.5
        }
        
        return cell
    }
}

extension CountersInfoTableViewController {
    func colorWithHexString (hex: String, alpha: CGFloat) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if (cString.length != 6) {
            return UIColor.gray
        }
        
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
