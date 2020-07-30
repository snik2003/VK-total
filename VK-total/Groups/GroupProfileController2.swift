//
//  GroupProfileController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import Popover
import WebKit

class GroupProfileController2: InnerViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    var collectionView: UICollectionView!
    var webview: WKWebView!
    
    let userDefaults = UserDefaults.standard
    
    var profileView: GroupProfileView!
    
    var groupID = 0
    var isBanned = false
    
    var groupProfile = [GroupProfile]()

    var wall = [Wall]()
    var groups = [WallGroups]()
    var profiles = [WallProfiles]()
    var videos = [Videos]()
    
    var postponedWall = [Wall]()
    var postponedGroups = [WallGroups]()
    var postponedProfiles = [WallProfiles]()
    
    var countersSection = [InfoInProfile]()
    var offset = 0
    var viewCount = 0
    let count = 30
    
    var isRefresh = false
    
    var spinner: UIActivityIndicatorView!
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
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
    
    var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]
    
    var barButton: UIBarButtonItem!
    
    var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
            self.navigationItem.rightBarButtonItem = self.barButton
            
            let myAttribute = [NSAttributedString.Key.foregroundColor: vkSingleton.shared.labelColor]
            let myAttrString = NSAttributedString(string: "Обновляем данные", attributes: myAttribute)
            self.refreshControl.attributedTitle = myAttrString
            self.refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: UIControl.Event.valueChanged)
            self.refreshControl.tintColor = vkSingleton.shared.labelColor
            self.tableView.addSubview(self.refreshControl)
            
            self.spinner = UIActivityIndicatorView(style: .white)
            self.spinner.color = vkSingleton.shared.labelColor
            self.spinner.stopAnimating()
            self.spinner.hidesWhenStopped = true
            self.spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60)
            self.tableView.tableFooterView = self.spinner
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "wallRecordCell2")
            self.tableView.showsVerticalScrollIndicator = false
            
            self.tableView.backgroundColor = vkSingleton.shared.backColor
            self.tableView.sectionIndexBackgroundColor = vkSingleton.shared.backColor
            self.tableView.sectionIndexTrackingBackgroundColor = vkSingleton.shared.backColor
            self.tableView.separatorColor = vkSingleton.shared.separatorColor
            
            self.tableView.separatorStyle = .none
            if let aView = self.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            } else {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
        }
        
        refresh()
        //print(groupID)
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func pullToRefresh() {
        offset = 0
        viewCount = 0
        spinner.stopAnimating()
        tableView.tableFooterView = spinner
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        refresh()
    }
    
    @objc func refresh() {
        let opq = OperationQueue()
        opq.maxConcurrentOperationCount = 1
        
        isRefresh = true
        
        // получаем объект с сервера ВК
        let url1 = "/method/groups.getById"
        let parameters1 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,can_message,contacts,age_limits,ban_info",
            "v": "5.100"
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url1, parameters: parameters1)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект
        let parseGroupProfile = ParseGroupProfile()
        parseGroupProfile.addDependency(getServerDataOperation)
        opq.addOperation(parseGroupProfile)
        
        let url2 = "/method/wall.get"
        let parameters2 = [
            "owner_id": "-\(groupID)",
            "domain": "",
            "offset": "\(offset)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "\(count)",
            "filter": "all",
            "extended": "1",
            "v": "5.85"
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        
        // парсим объект
        let parseGroupWall = ParseGroupWall()
        parseGroupWall.completionBlock = {
            var videoIDs = ""
            for wall in parseGroupWall.wall {
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
                    "owner_id": "-\(self.groupID)",
                    "videos": videoIDs,
                    "extended": "0",
                    "fields": "id, first_name, last_name, photo_100",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation5 = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation5.completionBlock = {
                    guard let data = getServerDataOperation5.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    let wallVideos = json["response"]["items"].compactMap({ Videos(json: $0.1) })
                    if self.offset == 0 {
                        self.videos = wallVideos
                    } else {
                        self.videos.append(contentsOf: wallVideos)
                    }
                }
                opq.addOperation(getServerDataOperation5)
            }
        }
        parseGroupWall.addDependency(getServerDataOperation2)
        opq.addOperation(parseGroupWall)
        
        let url3 = "/method/wall.get"
        let parameters3 = [
            "owner_id": "-\(self.groupID)",
            "domain": "",
            "access_token": vkSingleton.shared.accessToken,
            "count": "100",
            "filter": "postponed",
            "extended": "1",
            "v": "5.85"
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        opq.addOperation(getServerDataOperation3)
        
        
        // парсим объект
        let parsePostponedGroupWall = ParseGroupWall()
        parsePostponedGroupWall.addDependency(getServerDataOperation3)
        opq.addOperation(parsePostponedGroupWall)
        
        let url4 = "/method/account.getBanned"
        let parameters4 = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "200",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": "5.100"
        ]
        
        let getServerDataOperation4 = GetServerDataOperation(url: url4, parameters: parameters4)
        getServerDataOperation4.completionBlock = {
            guard let data = getServerDataOperation4.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            //print(json)
            let bannedGroupsIDs = json["response"]["items"].arrayValue.map({ $0.intValue })
            if bannedGroupsIDs.contains(-1 * self.groupID) {
                self.isBanned = true
            }
        }
        opq.addOperation(getServerDataOperation4)
        
        let reloadTableController = ReloadGroupProfileController2(controller: self)
        reloadTableController.addDependency(parseGroupWall)
        reloadTableController.addDependency(parseGroupProfile)
        reloadTableController.addDependency(parsePostponedGroupWall)
        reloadTableController.addDependency(getServerDataOperation4)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return wall.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell2") as! WallRecordCell2
            cell.delegate = self
            cell.drawCell = false
            
            let height = cell.configureCell(record: wall[indexPath.section], profiles: profiles, groups: groups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell2") as! WallRecordCell2
            cell.delegate = self
            cell.drawCell = false
            
            let height = cell.configureCell(record: wall[indexPath.section], profiles: profiles, groups: groups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return 10
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell2", for: indexPath) as! WallRecordCell2
        cell.delegate = self
        
        estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: profiles, groups: groups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
        
        cell.selectionStyle = .none
        cell.readMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap1(sender:)), for: .touchUpInside)
        cell.repostReadMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap2(sender:)), for: .touchUpInside)
        cell.likesButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)
        cell.commentsButton.addTarget(self, action: #selector(self.tapCommentsButton(sender:)), for: .touchUpInside)
        cell.repostsButton.addTarget(self, action: #selector(self.tapRepostButton(sender:)), for: .touchUpInside)
        
        if cell.poll != nil {
            for aLabel in cell.answerLabels {
                let tap = UITapGestureRecognizer()
                tap.addTarget(self, action: #selector(self.pollVote(sender:)))
                aLabel.addGestureRecognizer(tap)
                aLabel.isUserInteractionEnabled = true
            }
        }
            
        tableView.beginUpdates()
        tableView.endUpdates()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isRefresh && tableView.numberOfSections == viewCount && indexPath.section == tableView.numberOfSections - 2 {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        
        if y >= (h - 30.0) {
            if viewCount >= offset {
                if !isRefresh { refresh() }
            } else {
                tableView.tableFooterView = nil
            }
        }
    }
    
    @objc func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore1 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell2") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                wall[indexPath.section].readMore1 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: profiles, groups: groups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
    }
    
    @objc func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
        
            if wall[indexPath.section].readMore2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell2") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                wall[indexPath.section].readMore2 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: wall[indexPath.section], profiles: profiles, groups: groups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
    }
    
    @objc func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            let record = wall[index]
            
            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: true)
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
                    "owner_id": "\(record.ownerID)",
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
                    "owner_id": "\(record.ownerID)",
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
    
    @objc func tapMessageButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "user_id": "-\(self.groupID)",
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
                self.openDialogController(userID: "-\(self.groupID)", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
    
    @objc func joinGroup(sender: UIButton) {
        if groupProfile.count > 0 {
            
            sender.buttonTouched(controller: self)
            
            let group = groupProfile[0]
            
            if group.isAdmin != 1 {
                if group.isMember == 0 {
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    var title = "Подписаться"
                    if group.type == "group" {
                        title = "Подать заявку"
                        if group.isClosed == 0 {
                            title = "Присоединиться"
                        }
                    }
                    let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                        
                        let joinQueue = OperationQueue()
                        joinQueue.qualityOfService = .userInitiated
                        
                        let url = "/method/groups.join"
                        
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "group_id": "\(self.groupID)",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let sendJoinGroupRequest = GetServerDataOperation(url: url, parameters: parameters)
                        
                        sendJoinGroupRequest.completionBlock = {
                            guard let data = sendJoinGroupRequest.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                self.groupProfile[0].isMember = 1
                                self.groupProfile[0].membersCounter += 1
                                OperationQueue.main.addOperation {
                                    self.profileView.updateMemberButton(profile: self.groupProfile[0])
                                    self.profileView.updateMembersLabel(profile: self.groupProfile[0])
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        joinQueue.addOperation(sendJoinGroupRequest)
                    }
                    alertController.addAction(OKAction)
                    
                    present(alertController, animated: true)
                }
                
                if group.isMember == 1 {
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let OKAction = UIAlertAction(title: "Отписаться", style: .destructive) { action in
                        
                        let leaveQueue = OperationQueue()
                        leaveQueue.qualityOfService = .userInitiated
                        
                        let url = "/method/groups.leave"
                        
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "group_id": "\(self.groupID)",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let sendLeaveGroupRequest = GetServerDataOperation(url: url, parameters: parameters)
                        
                        sendLeaveGroupRequest.completionBlock = {
                            guard let data = sendLeaveGroupRequest.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                self.groupProfile[0].isMember = 0
                                self.groupProfile[0].membersCounter -= 1
                                OperationQueue.main.addOperation {
                                    self.profileView.updateMemberButton(profile: self.groupProfile[0])
                                    self.profileView.updateMembersLabel(profile: self.groupProfile[0])
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        leaveQueue.addOperation(sendLeaveGroupRequest)
                    }
                    alertController.addAction(OKAction)
                    
                    present(alertController, animated: true)
                }
            } else {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Пригласить друзей", style: .default) { action in
                    
                    let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                    
                    usersController.userID = vkSingleton.shared.userID
                    usersController.type = "friends"
                    usersController.source = "invite"
                    usersController.title = "Пригласить друзей"
                    
                    usersController.navigationItem.hidesBackButton = true
                    let cancelButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: usersController, action: #selector(usersController.tapCancelButton(sender:)))
                    usersController.navigationItem.leftBarButtonItem = cancelButton
                    usersController.delegate = self
                    
                    self.navigationController?.pushViewController(usersController, animated: true)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Покинуть сообщество", style: .destructive) { action in
                    
                    let url = "/method/groups.leave"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "group_id": "\(self.groupID)",
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
                            self.groupProfile[0].isMember = 0
                            self.groupProfile[0].isAdmin = 0
                            self.groupProfile[0].membersCounter -= 1
                            
                            UserDefaults.standard.removeObject(forKey: "\(vkSingleton.shared.userID)_groupToken_\(self.groupID)")
                            
                            if vkSingleton.shared.adminGroupID.contains(self.groupID) {
                                vkSingleton.shared.adminGroupID.remove(object: self.groupID)
                            }
                            
                            if let request = vkGroupLongPoll.shared.request[self.groupID] {
                                request.cancel()
                                vkGroupLongPoll.shared.firstLaunch[self.groupID] = true
                            }
                            
                            OperationQueue.main.addOperation {
                                self.profileView.updateMemberButton(profile: self.groupProfile[0])
                                self.profileView.updateMembersLabel(profile: self.groupProfile[0])
                            }
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action2)
                
                present(alertController, animated: true)
            }
        }
    }
    
    func setProfileView() {
        if groupProfile.count > 0 {
            profileView = GroupProfileView()
            profileView.delegate = self
            
            view.backgroundColor = UIColor.white
            
            var height = profileView.configureCell(profile: groupProfile[0])
            profileView.isMemberButton.addTarget(self, action: #selector(self.joinGroup(sender:)), for: .touchUpInside)
            profileView.messageButton.addTarget(self, action: #selector(self.tapMessageButton(sender:)), for: .touchUpInside)
            profileView.groupMessagesButton.addTarget(self, action: #selector(self.tapGroupMessagesButton(sender:)), for: .touchUpInside)
            if getNumberOfCounters() > 0 {
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                layout.itemSize = CGSize(width: 65, height: 65)
                
                collectionView = UICollectionView(frame: CGRect(x: 0, y: height, width: self.tableView.bounds.width, height: 65), collectionViewLayout: layout)
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "counterCell")
                collectionView.backgroundColor = vkSingleton.shared.backColor
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                profileView.addSubview(collectionView)
                collectionView.reloadData()
                profileView.addSeparator4(height + 65)
                height += 65 + profileView.statusSeparatorHeight
            }
            
            height = profileView.setNewRecordButton(profile: groupProfile[0], postponed: postponedWall.count, topY: height)
            
            profileView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: height)
            
            profileView.newRecordButton.addTarget(self, action: #selector(self.tapNewRecordButton(sender:)), for: .touchUpInside)
            profileView.postponedWallButton.addTarget(self, action: #selector(self.tapPostponedWallButton(sender:)), for: .touchUpInside)
            
            let tap = UITapGestureRecognizer()
            tap.addTarget(self, action: #selector(self.tabMembersLabel))
            tap.numberOfTapsRequired = 1
            self.profileView.membersLabel.addGestureRecognizer(tap)
            self.profileView.membersLabel.isUserInteractionEnabled = true
            
            self.tableView.tableHeaderView = profileView
        }
    }
    
    func openGroupDialogs() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GroupDialogsController") as! GroupDialogsController
        
        controller.groupID = "\(self.groupID)"
        if groupProfile.count > 0 {
            controller.title = groupProfile[0].name
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func tapGroupMessagesButton(sender: UIButton) {
        
        sender.buttonTouched(controller: self)
        openGroupDialogs()
    }
    
    @objc func tabMembersLabel() {
        if groupProfile.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            var isAdmin = false
            if self.groupProfile[0].isAdmin == 1 {
                isAdmin = true
            }
            
            let action1 = UIAlertAction(title: "Все участники", style: .default) { action in
                self.openMembersController(groupID: self.groupProfile[0].gid, filters: "", title: "Все участники", isAdmin: isAdmin)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Только друзья", style: .default) { action in
                self.openMembersController(groupID: self.groupProfile[0].gid, filters: "friends", title: "Участники-друзья", isAdmin: isAdmin)
            }
            alertController.addAction(action2)
            
            if self.groupProfile[0].isAdmin == 1 {
                let action3 = UIAlertAction(title: "Руководители сообщества", style: .default) { action in
                    self.openMembersController(groupID: self.groupProfile[0].gid, filters: "managers", title: "Руководители сообщества", isAdmin: isAdmin)
                }
                alertController.addAction(action3)
            }
            
            self.present(alertController, animated: true)
        }
    }
    
    @objc func tapPostponedWallButton(sender: UIButton) {
        
        if self.postponedWall.count > 0 {
            let postponedController = self.storyboard?.instantiateViewController(withIdentifier: "PostponedWallController") as! PostponedWallController
            
            for postponed in postponedWall {
                postponed.readMore1 = 1
            }
            postponedController.wall = self.postponedWall
            postponedController.wallProfiles = self.postponedProfiles
            postponedController.wallGroups = self.postponedGroups
            postponedController.ownerID = "-\(self.groupID)"
            postponedController.title = "Отложенные записи"
            
            self.navigationController?.pushViewController(postponedController, animated: true)
        }
    }
    
    @objc func tapNewRecordButton(sender: UIButton) {
        if groupProfile.count > 0 {
            
            var title = "Предложить новость"
            if groupProfile[0].canPost == 1 {
                title = "Новая запись"
            }
            openNewRecordController(ownerID: "-\(groupProfile[0].gid)", type: "new", message: "", title: title, controller: nil, delegate: self)
        }
    }
    
    func contactView(user: DialogsUsers, contact: Contact, topY: CGFloat) -> UIView {
    
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        
        let width = UIScreen.main.bounds.width - 40
        var height: CGFloat = 0
        
        let getCacheImage = GetCacheImage(url: user.maxPhotoOrigURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                let avatarImage = UIImageView()
                avatarImage.image = getCacheImage.outputImage
                avatarImage.clipsToBounds = true
                avatarImage.layer.cornerRadius = 19
                avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
                avatarImage.contentMode = .scaleAspectFill
                view.addSubview(avatarImage)
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        var start: CGFloat = 15
        if contact.desc != "" {
            start += 15
        }
        if contact.phone != "" {
            start += 15
        }
        if contact.email != "" {
            start += 15
        }
        var startX: CGFloat = 0
        if start < 40 {
            startX = (40 - start) / 2
        }
        
        let nameLabel = UILabel()
        nameLabel.attributedText = nil
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.textColor = vkSingleton.shared.labelColor
        
        if user.online == 1 {
            if user.onlineMobile == 1 {
                let fullString = "\(user.firstName) \(user.lastName) "
                nameLabel.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
            } else {
                let fullString = "\(user.firstName) \(user.lastName) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: nameLabel.tintColor], range: rangeOfColoredString)
                
                nameLabel.attributedText = attributedString
            }
        }
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.frame = CGRect(x: 60, y: 5 + startX, width: width - 120, height: 15)
        view.addSubview(nameLabel)
        height += 20 + startX
        
        if contact.desc != "" {
            let label = UILabel()
            label.text = "\(contact.desc)"
            label.textColor = vkSingleton.shared.secondaryLabelColor
            label.font = UIFont(name: "Verdana", size: 10)!
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.frame = CGRect(x: 60, y: height, width: width - 120, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        if contact.phone != "" {
            let label = UILabel()
            label.text = "\(contact.phone)"
            label.textColor = vkSingleton.shared.secondaryLabelColor
            label.font = UIFont(name: "Verdana", size: 10)!
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.frame = CGRect(x: 60, y: height, width: width - 120, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        if contact.email != "" {
            let label = UILabel()
            label.text = "\(contact.email)"
            label.textColor = vkSingleton.shared.secondaryLabelColor
            label.font = UIFont(name: "Verdana", size: 10)!
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.frame = CGRect(x: 60, y: height, width: width - 120, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        if height < 50 {
            height = 50
        }
        view.frame = CGRect(x: 20, y: topY, width: width - 60, height: height)
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.add {
            self.popover.dismiss()
            self.openProfileController(id: contact.userID, name: "\(user.firstName) \(user.lastName)")
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }
    
    func showContactsView(profile: GroupProfile) {
        var contactsIDs = ""
        for contact in profile.contacts {
            if contactsIDs != "" {
                contactsIDs = "\(contactsIDs),"
            }
            contactsIDs = "\(contactsIDs)\(contact.userID)"
        }
        
        let url = "/method/users.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_ids": contactsIDs,
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,deactivated,online,sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseDialogsUsers = ParseDialogsUsers()
        parseDialogsUsers.addDependency(getServerDataOperation)
        parseDialogsUsers.completionBlock = {
            OperationQueue.main.addOperation {
                let users = parseDialogsUsers.outputData
                
                let contactsView = UIView()
            
                let width = UIScreen.main.bounds.width - 2 * 10
                var height: CGFloat = 20
                
                for contact in profile.contacts {
                    let user = users.filter({ $0.uid == "\(contact.userID)" })
                    if user.count > 0 {
                        let view = self.contactView(user: user[0], contact: contact, topY: height)
                        contactsView.addSubview(view)
                        height += view.frame.height
                    }
                }
                
                
                height += 20
                contactsView.frame = CGRect(x: 0, y: 0, width: width - 20, height: height)
                let startPoint = CGPoint(x: UIScreen.main.bounds.width - 30, y: 70)
                
                self.popover = Popover(options: self.popoverOptions)
                self.popover.show(contactsView, point: startPoint)
            }
        }
        OperationQueue().addOperation(parseDialogsUsers)
    }
    
    func showDescriptionView(profile: GroupProfile) {
        
        let text = profile.description.prepareTextForPublic()
        let dFont = UIFont(name: "Verdana", size: 12)!
        
        let maxWidth = UIScreen.main.bounds.width - 4 * 10
        let maxHeight = UIScreen.main.bounds.height - navHeight - tabHeight - 20
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: dFont], context: nil)
        
        let width = maxWidth + 20
        var height = rect.size.height + 40
        if height > maxHeight {
            height = maxHeight
        }

        let descView = UIView(frame: CGRect(x: 0, y: 0, width: width - 20, height: height))
        descView.backgroundColor = vkSingleton.shared.backColor
        
        let textView = UILabel(frame: CGRect(x: 10, y: 10, width: width - 40, height: height - 20))
        textView.text = profile.description
        textView.textColor = vkSingleton.shared.labelColor
        
        textView.prepareTextForPublish2(self)
        textView.backgroundColor = .clear
        textView.font = dFont
        textView.textAlignment = .center
        textView.numberOfLines = 0
        descView.addSubview(textView)
        
        let startPoint = CGPoint(x: UIScreen.main.bounds.width - 30, y: 70)
        
        self.popover = Popover(options: self.popoverOptions)
        self.popover.show(descView, point: startPoint)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if groupProfile.count > 0 {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let group = self.groupProfile[0]
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if group.status != "" && group.description != "" {
                let action = UIAlertAction(title: "Описание сообщества", style: .default) { action in
                    
                    self.showDescriptionView(profile: group)
                }
                alertController.addAction(action)
            }
            
            if group.contacts.count > 0 {
                let action = UIAlertAction(title: "Контакты сообщества", style: .default) { action in
                    
                    self.showContactsView(profile: group)
                }
                alertController.addAction(action)
            }
            
            if group.isFavorite == 0 {
                let action1 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
                    
                    self.addGroupToFave(group: group)
                }
                alertController.addAction(action1)
            } else {
                let action1 = UIAlertAction(title: "Удалить из «Избранное»", style: .destructive) { action in
                    
                    self.removeGroupFromFave(group: group)
                }
                alertController.addAction(action1)
            }
            
            /*if group.type == "group" && group.canPost == 1 {
                let action7 = UIAlertAction(title: "Создать новую запись", style: .default) { action in
                    
                    self.tapNewRecordButton(sender: self.profileView.newRecordButton)
                }
                alertController.addAction(action7)
            } else if group.type == "page" {
                let action7 = UIAlertAction(title: "Предложить новость", style: .default) { action in
                    
                    self.tapNewRecordButton(sender: self.profileView.newRecordButton)
                }
                alertController.addAction(action7)
            }*/
            
            if postponedWall.count > 0 {
                let action7 = UIAlertAction(title: "Отложенные записи (\(postponedWall.count))", style: .default) { action in
                    
                    self.tapPostponedWallButton(sender: self.profileView.postponedWallButton)
                }
                alertController.addAction(action7)
            }
            
            if group.isAdmin == 1 {
                let action8 = UIAlertAction(title: "Создать тему для обсуждения", style: .default) { action in
                    
                    self.openAddTopicController(ownerID: "\(group.gid)", title: "Новое обсуждение", delegate: self)
                }
                alertController.addAction(action8)
            }
            
            let action5 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                var link = "https://vk.com/\(group.screenName)"
                if group.screenName == "" {
                    link = "https://vk.com/club\(self.groupID)"
                    if group.type == "page" {
                        link = "https://vk.com/public\(self.groupID)"
                    } else if group.type == "event" {
                        link = "https://vk.com/event\(self.groupID)"
                    }
                }
                    
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на профиль сообщества:" , msg: "\(string)")
                }
            }
            alertController.addAction(action5)
            
            if group.isHiddenFromFeed == 0 {
                let action7 = UIAlertAction(title: "Скрывать новости в ленте", style: .destructive) { action in
                    self.hideGroupFromFeed(groupID: "\(group.gid)", name: group.name, controller: self)
                }
                alertController.addAction(action7)
            } else {
                let action7 = UIAlertAction(title: "Показывать новости в ленте", style: .default) { action in
                    self.showGroupInFeed(groupID: "\(group.gid)", name: group.name, controller: self)
                }
                alertController.addAction(action7)
            }
            
            if self.isBanned {
                let action9 = UIAlertAction(title: "Удалить из черного списка", style: .destructive) { action in
                    
                    let alertController = UIAlertController(title: nil, message: "Вы уверены, что хотите удалить сообщество «\(group.name)» из черного списка?", preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action = UIAlertAction(title: "Да", style: .destructive) { action in
                        let url = "/method/account.unban"
                        let parameters = [
                            "owner_id": "-\(self.groupID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                self.isBanned = false
                                self.showSuccessMessage(title: "Черный список", msg: "\nСообщество успешно удалено из черного списка.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action)
                    
                    self.present(alertController, animated: true)
                }
                alertController.addAction(action9)
            } else {
                let action9 = UIAlertAction(title: "Добавить в черный список", style: .destructive) { action in
                    
                    let alertController = UIAlertController(title: nil, message: "Вы уверены, что хотите добавить сообщество «\(group.name)» в черный список?", preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action = UIAlertAction(title: "Да", style: .destructive) { action in
                        
                        let url = "/method/account.ban"
                        let parameters = [
                            "owner_id": "-\(self.groupID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                self.isBanned = true
                                self.showSuccessMessage(title: "Черный список", msg: "\nСообщество успешно добавлено в черный список.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action)
                    
                    self.present(alertController, animated: true)
                }
                alertController.addAction(action9)
            }
            
            let action8 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                if self.wall.count > 0 {
                    self.reportOnObject(ownerID: "-\(self.groupID)", itemID: "\(self.wall[0].id)", type: "group")
                } else {
                    let title = "Жалоба на сообщество"
                    let text = "Ваша жалоба на сообщество успешно отправлена."
                    self.showSuccessMessage(title: title, msg: text)
                }
            }
            alertController.addAction(action8)
            
            present(alertController, animated: true)
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
                    
                    newRecordController.repostOwnerID = record.ownerID
                    newRecordController.repostItemID = record.id
                    
                    newRecordController.delegate2 = self
                    
                    if self.groupProfile.count > 0 {
                        newRecordController.repostTitle = "Репост записи со стены сообщества\n«\(self.groupProfile[0].name)»"
                    }
                    
                    if let image = UIApplication.shared.screenShot {
                        let attachment = "wall\(record.ownerID)_\(record.id)"
                        
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
                
                let attachment = "https://vk.com/wall\(record.ownerID)_\(record.id)"
                self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action3)
            
            let action2 = UIAlertAction(title: "Переслать сообщением", style: .default){ action in
                
                let attachment = "wall\(record.ownerID)_\(record.id)"
                let image = UIApplication.shared.screenShot
                self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        }
    }
}

extension GroupProfileController2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return getNumberOfCounters()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "counterCell", for: indexPath)
        cell.backgroundColor = .clear
        
        for subview in cell.subviews {
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        let countLabel = UILabel()
        let nameLabel = UILabel()
        
        countLabel.font = UIFont(name: "Verdana-Bold", size: 20)
        nameLabel.font = UIFont(name: "Verdana", size: 11)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        
        nameLabel.isEnabled = false
        
        countLabel.text = countersSection[indexPath.row].value
        countLabel.textAlignment = .center
        nameLabel.text = countersSection[indexPath.row].image
        nameLabel.textAlignment = .center
        
        countLabel.frame = CGRect(x: 0, y: 10, width: cell.bounds.width, height: 24)
        nameLabel.frame = CGRect(x: 0, y: 36, width: cell.bounds.width, height: 14)
        
        
        countLabel.textColor = vkSingleton.shared.labelColor
        nameLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
        cell.addSubview(countLabel)
        cell.addSubview(nameLabel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var isAdmin = false
        if self.groupProfile[0].isAdmin == 1 {
            isAdmin = true
        }
        
        if countersSection[indexPath.row].comment == "photosCount" {
            
            if groupProfile.count > 0 {
                self.openPhotosListController(ownerID: "-\(groupProfile[0].gid)", title: "Фотографии", type: "photos", isAdmin: isAdmin)
            }
        }
        
        if countersSection[indexPath.row].comment == "albumsCount" {
            
            if groupProfile.count > 0 {
                self.openPhotosListController(ownerID: "-\(groupProfile[0].gid)", title: "Фотографии", type: "albums", isAdmin: isAdmin)
            }
        }
        
        if countersSection[indexPath.row].comment == "videosCount" {
            
            if groupProfile.count > 0 {
                self.openVideoListController(ownerID: "-\(groupProfile[0].gid)", title: "Видеозаписи", type: "")
            }
        }
        
        if countersSection[indexPath.row].comment == "topicsCount" {
            
            if groupProfile.count > 0 {
                self.openTopicsController(groupID: "\(groupProfile[0].gid)", group: groupProfile[0], title: "Обсуждения")
            }
        }
    }
    
    func getCounterToString(_ num: Int) -> String {
        var str = "\(num)"
        
        if num >= 10000 {
            str = "10K"
        } else {
            if num > 1000 {
                let num1 = lround(Double(num) / 100)
                str = "\(Double(num1) / 10)K"
            }
        }
        
        return str
    }
    
    func getNumberOfCounters() -> Int {
        var count = 0
        
        countersSection.removeAll(keepingCapacity: false)
        
        
        if groupProfile.count > 0 {
            let profile = groupProfile[0]
            var infoCounters: InfoInProfile!
            
            if profile.photosCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("фото", self.getCounterToString(profile.photosCounter),"photosCount")
                self.countersSection.append(infoCounters)
            }
            if profile.albumsCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("альбомы", self.getCounterToString(profile.albumsCounter),"albumsCount")
                self.countersSection.append(infoCounters)
            }
            /*if profile.audiosCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("аудио", self.getCounterToString(profile.audiosCounter),"audiosCount")
                self.countersSection.append(infoCounters)
            }*/
            if profile.videosCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("видео", self.getCounterToString(profile.videosCounter),"videosCount")
                self.countersSection.append(infoCounters)
            }
            if profile.topicsCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("обсуждения", self.getCounterToString(profile.topicsCounter),"topicsCount")
                self.countersSection.append(infoCounters)
            }
            if profile.docsCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("документы", self.getCounterToString(profile.docsCounter),"docsCount")
                self.countersSection.append(infoCounters)
            }
        }
        
        return count
    }
}
