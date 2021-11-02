//
//  FavePostsController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import BTNavigationDropdownMenu
import SCLAlertView

class FavePostsController2: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var userID = vkSingleton.shared.userID
    var source = "users"
    
    var selectedMenu = 0
    let itemsMenu = ["Пользователи", "Избранные диалоги", "Записи на стене", "Фотографии", "Видеозаписи", "Сообщества", "Ссылки", "Черный список"]
    
    var wall = [Wall]()
    var wallProfiles = [WallProfiles]()
    var wallGroups = [WallGroups]()
    var wallVideos = [Videos]()
    
    var photos = [Photos]()
    var videos = [Videos]()
    var newsProfiles = [NewsProfiles]()
    var newsGroups = [NewsGroups]()
    
    var faveUsers = [NewsProfiles]()
    
    var faveLinks = [FaveLinks]()
    var favePages = [FavePages]()
    
    var conversations: [Conversation] = []
    var dialogs: [Message] = []
    var dialogsProfiles: [DialogsUsers] = []
    
    var offset = 0
    let count = 40
    var isRefresh = false
    
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
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var tableView: UITableView!
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
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
                self.source = "users"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 1:
                self.source = "important dialogs"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 2:
                self.source = "post"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 3:
                self.source = "photo"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 4:
                self.source = "video"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 5:
                self.source = "groups"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 6:
                self.source = "links"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 7:
                self.source = "banned"
                self.offset = 0
                self.refresh()
                self.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            default:
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let menuView = navigationItem.titleView as? BTNavigationDropdownMenu {
            menuView.hide()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.backgroundColor = vkSingleton.shared.backColor
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
        tableView.showsVerticalScrollIndicator = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "recordCell")
        tableView.register(DialogsCell.self, forCellReuseIdentifier: "dialogCell")
        tableView.register(FavePhotoCell.self, forCellReuseIdentifier: "photoCell")
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(FaveUsersCell.self, forCellReuseIdentifier: "usersCell")
        tableView.register(FaveLinksCell.self, forCellReuseIdentifier: "linksCell")
        tableView.register(FavePagesCell.self, forCellReuseIdentifier: "pagesCell")
        
        
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
    }
    
    func refresh() {
        let opq = OperationQueue()
        var url: String = ""
        var parameters: Parameters = [:]
        isRefresh = true
        
        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            if let aView = self.tableView.superview { ViewControllerUtils().showActivityIndicator(uiView: aView) }
            else { ViewControllerUtils().showActivityIndicator(uiView: self.view) }
        }
        
        if offset == 0 {
            wall.removeAll(keepingCapacity: false)
            wallProfiles.removeAll(keepingCapacity: false)
            wallGroups.removeAll(keepingCapacity: false)
            photos.removeAll(keepingCapacity: false)
            videos.removeAll(keepingCapacity: false)
            dialogs.removeAll(keepingCapacity: false)
            conversations.removeAll(keepingCapacity: false)
            dialogsProfiles.removeAll(keepingCapacity: false)
            
            tableView.separatorStyle = .none
            tableView.reloadData()
        }
        
        if source == "post" {
            url = "/method/fave.getPosts"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max, photo_100",
                "v": vkSingleton.shared.version
            ]
        } else if source == "important dialogs" {
            
            let importantIds = self.getImportantConversations()
            let peerIDs = ",".join(array: importantIds)
            
            var code =  "var conversations = API.messages.getConversationsById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"peer_ids\":\"\(peerIDs)\",\"count\":\"100\",\"extended\":\"0\",\"v\":\"\(vkSingleton.shared.version)\" });\n"
            
            code = "\(code) var mess_ids = conversations.items@.last_message_id;\n"
            
            code = "\(code) var dialogs = API.messages.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"message_ids\":mess_ids,\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
            
            code = "\(code) return [conversations,dialogs];"
            
            url = "/method/execute"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": "\(vkSingleton.shared.version)"
            ]
        } else if source == "photo" {
            url = "/method/fave.getPhotos"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "v": vkSingleton.shared.version
            ]
        } else if source == "video" {
            url = "/method/fave.getVideos"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max, photo_100",
                "v": vkSingleton.shared.version
            ]
        } else if source == "groups" {
            url = "/method/fave.getPages"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "50",
                "type": "groups",
                "v": "5.100"
            ]
        } else if source == "links" {
            url = "/method/fave.getLinks"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "v": vkSingleton.shared.version
            ]
        } else if source == "users" {
            url = "/method/fave.getUsers"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_100, screen_name",
                "v": vkSingleton.shared.version
            ]
        } else if source == "banned" {
            url = "/method/account.getBanned"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "count": "200",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_100",
                "v": "5.100"
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект с данными
        let parseFaves = ParseFaves(type: source)
        parseFaves.addDependency(getServerDataOperation)
        if source == "post" {
            parseFaves.completionBlock = {
                var videoIDs = ""
                for wall in parseFaves.wall {
                    for index in 0...9 {
                        if wall.mediaType[index] == "video" {
                            if videoIDs == "" {
                                if wall.photoAccessKey[index] == "" {
                                    videoIDs = "\(wall.photoOwnerID[index])_\(wall.photoID[index])"
                                } else {
                                    videoIDs = "\(wall.photoOwnerID[index])_\(wall.photoID[index])_\(wall.photoAccessKey[index])"
                                }
                            } else {
                                if wall.photoAccessKey[index] == "" {
                                    videoIDs = "\(videoIDs),\(wall.photoOwnerID[index])_\(wall.photoID[index])"
                                } else {
                                    videoIDs = "\(videoIDs),\(wall.photoOwnerID[index])_\(wall.photoID[index])_\(wall.photoAccessKey[index])"
                                }
                            }
                        }
                    }
                }
                
                if videoIDs != "" {
                    let url = "/method/video.get"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": vkSingleton.shared.userID,
                        "videos": videoIDs,
                        "extended": "0",
                        "fields": "id, first_name, last_name, photo_100",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation2 = GetServerDataOperation(url: url, parameters: parameters)
                    getServerDataOperation2.completionBlock = {
                        guard let data = getServerDataOperation2.data else { return }
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        //print(json)
                        
                        let wallVideos = json["response"]["items"].compactMap({ Videos(json: $0.1) })
                        if self.offset == 0 {
                            self.wallVideos = wallVideos
                        } else {
                            self.wallVideos.append(contentsOf: wallVideos)
                        }
                    }
                    opq.addOperation(getServerDataOperation2)
                }
            }
        }
        opq.addOperation(parseFaves)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        // обновляем данные на UI
        let reloadTableController = ReloadFavePostsController(controller: self, type: source)
        reloadTableController.addDependency(parseFaves)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch source {
        case "post":
            return wall.count
        case "important dialogs":
            return dialogs.count
        case "photo":
            return photos.count
        case "video":
            return 1
        case "users":
            return 1
        case "groups":
            return 1
        case "links":
            return 1
        case "banned":
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch source {
        case "post":
            return 1
        case "important dialogs":
            return 1
        case "photo":
            return 1
        case "video":
            return videos.count
        case "users":
            return faveUsers.count
        case "groups":
            return favePages.count
        case "links":
            return faveLinks.count
        case "banned":
            return faveUsers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if source == "post" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                let height = cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "important dialogs" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogsCell
            return cell.userAvatarSize + 2 * cell.topInsets
        } else if source == "photo" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let photo = photos[indexPath.section]
                
                var height = self.tableView.bounds.width
                if photo.height > 0 && photo.width > 0 {
                    height = self.tableView.bounds.width * CGFloat(photo.height) / CGFloat(photo.width)
                }
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "video" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let height = (UIScreen.main.bounds.width * 0.5) * CGFloat(240) / CGFloat(320)
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "users" || source == "banned" || source == "groups" {
            return 50
        } else if source == "links" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell") as! FaveLinksCell
                
                let height = cell.getRowHeight(link: faveLinks[indexPath.row])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if source == "post" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                let height = cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "important dialogs" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! DialogsCell
            return cell.userAvatarSize + 2 * cell.topInsets
        } else if source == "photo" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let photo = photos[indexPath.section]
                
                var height = self.tableView.bounds.width
                if photo.height > 0 && photo.width > 0 {
                    height = self.tableView.bounds.width * CGFloat(photo.height) / CGFloat(photo.width)
                }
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "video" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let height = (UIScreen.main.bounds.width * 0.5) * CGFloat(240) / CGFloat(320)
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "users" || source == "banned" || source == "groups" {
            return 50
        } else if source == "links" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell") as! FaveLinksCell
                
                let height = cell.getRowHeight(link: faveLinks[indexPath.row])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return source == "important dialogs" ? 6 : 8
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return source == "important dialogs" ? 6 : 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch source {
        case "post":
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! WallRecordCell2
            cell.delegate = self
            
            estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, videos: wallVideos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
            cell.repostsButton.addTarget(self, action: #selector(self.tapRepostButton(sender:)), for: .touchUpInside)
            cell.likesButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
            cell.commentsButton.addTarget(self, action: #selector(self.tapCommentsButton(sender:)), for: .touchUpInside)
            
            cell.readMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap1(sender:)), for: .touchUpInside)
            cell.repostReadMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap2(sender:)), for: .touchUpInside)
            
            if cell.poll != nil {
                for aLabel in cell.answerLabels {
                    let tap = UITapGestureRecognizer()
                    tap.addTarget(self, action: #selector(self.pollVote(sender:)))
                    aLabel.addGestureRecognizer(tap)
                    aLabel.isUserInteractionEnabled = true
                }
            }
            
            cell.selectionStyle = .none
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            cell.selectionStyle = .none
            return cell
        case "important dialogs":
            let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! DialogsCell
            let dialog = dialogs[indexPath.section]
            let conversation = conversations.filter({ $0.peerID == dialog.peerID }).first
                
            cell.configureCell(mess: dialog, conversation: conversation, users: dialogsProfiles, indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            return cell
        case "photo":
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! FavePhotoCell
            
            cell.configureCell(photo: photos[indexPath.section], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            
            cell.selectionStyle = .none
            return cell
        case "video":
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoListCell
            
            cell.delegate = self
            
            cell.configureCell(video: videos[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.leftInsets, bottom: 0, right: cell.leftInsets)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            
            cell.selectionStyle = .none
            return cell
        case "users":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! FaveUsersCell
            
            cell.configureCell(user: faveUsers[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView, source: source)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case "groups":
            let cell = tableView.dequeueReusableCell(withIdentifier: "pagesCell", for: indexPath) as! FavePagesCell
            
            cell.configureCell(group: favePages[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            cell.selectionStyle = .none
            return cell
        case "links":
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath) as! FaveLinksCell
            
            cell.configureCell(link: faveLinks[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            cell.selectionStyle = .none
            return cell
        case "banned":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! FaveUsersCell
            
            cell.configureCell(user: faveUsers[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView, source: source)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch source {
        case "post":
            break
            
        case "important dialogs":
            let dialog = dialogs[indexPath.section]
            openDialog(dialog: dialog)
            
        case "photo":
            if let visibleIndexPath = tableView.indexPathsForVisibleRows {
                for index in visibleIndexPath {
                    if index == indexPath {
                        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                        
                        photoViewController.numPhoto = index.section
                        photoViewController.photos = photos
                        
                        self.navigationController?.pushViewController(photoViewController, animated: true)
                    }
                }
            }
        case "video":
            let video = videos[indexPath.row]
            
            self.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись", scrollToComment: false)
            
        case "users":
            let user = faveUsers[indexPath.row]
            self.openProfileController(id: user.uid, name: "\(user.firstName) \(user.lastName)")
        
        case "groups":
            let link = "https://vk.com/\(favePages[indexPath.row].screenName)"
            self.openBrowserController(url: link)
            
        case "links":
            let link = faveLinks[indexPath.row]
            self.openBrowserController(url: link.url)
            
        case "banned":
            let user = faveUsers[indexPath.row]
            self.openProfileController(id: user.uid, name: "\(user.firstName) \(user.lastName)")
            
        default:
            break;
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if source == "links" {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить") { (rowAction, indexPath) in
            let link = self.faveLinks[indexPath.row]
            
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
                self.deleteLinkFromFave(linkID: link.id, controller: self)
            }
            
            alertView.addButton("Отмена, я передумал") {
                
            }
            
            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить ссылку «\(link.url)» из раздела «Избранное»?")
            
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if source == "post" || source == "photo" {
            if indexPath.section == tableView.numberOfSections - 1 {
                isRefresh = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    @objc func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            let record = wall[index]
            
            self.openWallRecord(ownerID: record.fromID, postID: record.id, accessKey: "", type: "post", scrollToComment: true)
        }
    }
    
    @objc func likePost(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            
            let record = wall[index]
            
            if record.userLikes == 0 {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.add"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "post",
                    "owner_id": "\(record.fromID)",
                    "item_id": "\(record.id)",
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
                        self.wall[index].countLikes += 1
                        self.wall[index].userLikes = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? WallRecordCell2 {
                                cell.setLikesButton(record: self.wall[index])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                likeQueue.addOperation(request)
            } else {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.delete"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "post",
                    "owner_id": "\(record.fromID)",
                    "item_id": "\(record.id)",
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
                        self.wall[index].countLikes -= 1
                        self.wall[index].userLikes = 0
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? WallRecordCell2 {
                                cell.setLikesButton(record: self.wall[index])
                            }
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                
                likeQueue.addOperation(request)
            }
        }
    }
    
    @objc func tapRepostButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            let index = indexPath.section
            let record = wall[index]
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if record.canRepost == 1 && record.userPeposted == 0 {
                let action1 = UIAlertAction(title: "Опубликовать на своей стене", style: .default) { action in
                    
                    let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
                    
                    newRecordController.ownerID = vkSingleton.shared.userID
                    newRecordController.type = "repost"
                    newRecordController.message = ""
                    newRecordController.title = "Репост записи"
                    
                    newRecordController.repostOwnerID = record.fromID
                    newRecordController.repostItemID = record.id
                    
                    newRecordController.delegate2 = self
                    
                    if record.fromID > 0 {
                        newRecordController.repostTitle = "Репост записи со стены пользователя"
                    }
                    
                    if record.fromID < 0 {
                        newRecordController.repostTitle = "Репост записи со стены сообщества"
                    }
                    
                    if let image = UIApplication.shared.screenShot {
                        let attachment = "wall\(record.fromID)_\(record.id)"
                        
                        newRecordController.attachments = attachment
                        newRecordController.attach.append(attachment)
                        newRecordController.photos.append(image)
                        newRecordController.isLoad.append(false)
                        newRecordController.typeOf.append("wall")
                    }
                    
                    self.navigationController?.pushViewController(newRecordController, animated: true)
                }
                alertController.addAction(action1)
            }
            
            let action3 = UIAlertAction(title: "Переслать ссылку на запись", style: .default){ action in
                
                let attachment = "https://vk.com/wall\(record.fromID)_\(record.id)"
                self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action3)
            
            let action2 = UIAlertAction(title: "Переслать сообщением", style: .default){ action in
                
                let attachment = "wall\(record.fromID)_\(record.id)"
                let image = UIApplication.shared.screenShot
                self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        }
    }
    
    @objc func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore1 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                wall[indexPath.section].readMore1 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
    }
    
    @objc func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                wall[indexPath.section].readMore2 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
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
                    controller.attachments = ""
                    controller.fwdMessagesID = []
                    controller.attachImage = nil
                    controller.delegate2 = self
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
}
