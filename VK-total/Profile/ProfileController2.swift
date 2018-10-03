//
//  ProfileController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation

class ProfileController2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var barItem: UIBarButtonItem!
    
    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var profileView: ProfileView!
    
    var userProfile = [UserProfileInfo]()
    var photos = [Photos]()
    
    var wall = [Wall]()
    var wallProfiles = [WallProfiles]()
    var wallGroups = [WallGroups]()
    
    var postponedWall = [Wall]()
    var postponedWallProfiles = [WallProfiles]()
    var postponedWallGroups = [WallGroups]()
    
    var filterRecords = "owner"
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    var viewFirstAppear = true
    var userID = vkSingleton.shared.userID
    
    var countersSection = [InfoInProfile]()
    var photoX: [Int : CGFloat] = [:]
    
    var offset = 0
    let count = 20
    var isRefresh = false
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            if UIScreen.main.nativeBounds.height == 2436 {
                self.navHeight = 88
                self.tabHeight = 83
            }
            
            self.createTableView()
            
            self.barItem.isEnabled = true
            self.barItem.tintColor = UIColor.white
            //self.barItem.addBadge(number: 22)
            
            self.tableView.separatorStyle = .none
            
            self.refreshControl.attributedTitle = NSAttributedString(string: "Обновляем данные")
            self.refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: UIControl.Event.valueChanged)
            self.refreshControl.tintColor = UIColor.gray
            self.tableView.addSubview(self.refreshControl)
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        refreshExecute()
        if self.userID == vkSingleton.shared.userID {
            StoreReviewHelper.checkAndAskForReview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLongPollServer()
        if !viewFirstAppear {
            self.refreshUserInfo()
        }
        viewFirstAppear = false
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
    
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "wallRecordCell")
    
        self.view.addSubview(tableView)
    }
    
    @objc func pullToRefresh() {
        offset = 0
        refreshExecute()
    }
    
    func refreshExecute() {
        
        isRefresh = true
        estimatedHeightCache.removeAll(keepingCapacity: false)
     
        var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var b = API.photos.getAll({\"owner_id\":\"\(userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":1,\"count\":100,\"photo_sizes\":0,\"skip_hidden\":0,\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"\(filterRecords)\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var d = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"postponed\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) return [a,b,c,d];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            self.userProfile = json["response"][0].compactMap { UserProfileInfo(json: $0.1) }
            self.photos = json["response"][1]["items"].compactMap { Photos(json: $0.1) }
            
            //print(json["response"][4])
            
            if self.userID == vkSingleton.shared.userID {
                OperationQueue.main.addOperation {
                    if self.userProfile.count > 0 {
                        vkSingleton.shared.avatarURL = self.userProfile[0].maxPhotoURL
                        if vkSingleton.shared.avatarURL == "" {
                            vkSingleton.shared.avatarURL = self.userProfile[0].maxPhotoOrigURL
                        }
                    }
                    if let userInfo = vkSingleton.shared.pushInfo {
                        vkSingleton.shared.pushInfo = nil
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.tapPushNotification(userInfo, controller: self)
                            OperationQueue.main.addOperation {
                                AudioServicesPlaySystemSound(1003)
                            }
                        }
                    }
                }
            }
            
            if self.userProfile.count > 0 {
                let user = self.userProfile[0]
                if user.blacklisted == 1 {
                    if user.canSendFriendRequest == 1 || user.canWritePrivateMessage == 1 {
                        if user.sex == 1 {
                            self.showErrorMessage(title: "Это закрытый профиль", msg: "Добавьте \(user.firstNameAcc) в друзья, чтобы смотреть её записи, фотографии и другие материалы.")
                        } else {
                            self.showErrorMessage(title: "Это закрытый профиль", msg: "Добавьте \(user.firstNameAcc) в друзья, чтобы смотреть его записи, фотографии и другие материалы.")
                        }
                    } else {
                        self.showErrorMessage(title: "Предупреждение", msg: "Вы находитесь в черном списке \(user.firstNameGen).")
                    }
                }
            }
            
            self.postponedWall = json["response"][3]["items"].compactMap { Wall(json: $0.1) }
            self.postponedWallProfiles = json["response"][3]["profiles"].compactMap { WallProfiles(json: $0.1) }
            self.postponedWallGroups = json["response"][3]["groups"].compactMap { WallGroups(json: $0.1) }
            
            let wallData = json["response"][2]["items"].compactMap { Wall(json: $0.1) }
            let profilesData = json["response"][2]["profiles"].compactMap { WallProfiles(json: $0.1) }
            let groupsData = json["response"][2]["groups"].compactMap { WallGroups(json: $0.1) }
            
            if self.offset == 0 {
                self.wall = wallData
                self.wallProfiles = profilesData
                self.wallGroups = groupsData
            } else {
                for record in wallData {
                    self.wall.append(record)
                }
                for group in groupsData {
                    self.wallGroups.append(group)
                }
                for profile in profilesData {
                    self.wallProfiles.append(profile)
                }
            }
            
            self.offset += self.count
            OperationQueue.main.addOperation {
                self.setProfileView()
                self.tableView.reloadData()
                if self.userProfile.count > 0 {
                    let user = self.userProfile[0]
                    self.title = "\(user.firstName) \(user.lastName)"
                }
                self.refreshControl.endRefreshing()
                self.saveAccountToRealm()
                ViewControllerUtils().hideActivityIndicator()
            }
            
            
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func refresh() {
        let opq = OperationQueue()
        isRefresh = true
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        
        let url1 = "/method/users.get"
        let parameters1 = [
            "access_token": vkSingleton.shared.accessToken,
            "user_id": userID,
            "fields": "id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default",
            "name_case": "nom",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
        opq.addOperation(getServerDataOperation1)
        
        let parseUserProfile = ParseUserProfile()
        parseUserProfile.completionBlock = {
            if parseUserProfile.outputData.count > 0 {
                self.filterRecords = parseUserProfile.outputData[0].wallDefault
            }
        }
        parseUserProfile.addDependency(getServerDataOperation1)
        opq.addOperation(parseUserProfile)
        
        // получаем объект с фотографиями с сервера ВК
        let url2 = "/method/photos.getAll"
        let parameters2 = [
            "owner_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "extended": "1",
            "count": "100",
            "photo_sizes": "0",
            "skip_hidden": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        // парсим объект с фотографиями
        let parsePhotos = ParsePhotosList()
        parsePhotos.addDependency(getServerDataOperation2)
        opq.addOperation(parsePhotos)
        
        // получаем объект с записями на стене пользователя с сервера ВК
        let url3 = "/method/wall.get"
        let parameters3 = [
            "owner_id": userID,
            "domain": "id\(userID)",
            "offset": "\(offset)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "\(count)",
            "filter": filterRecords,
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        opq.addOperation(getServerDataOperation3)
        
        // парсим объект с записями на стене
        let parseUserWall = ParseUserWall()
        parseUserWall.addDependency(getServerDataOperation3)
        opq.addOperation(parseUserWall)
        
        let url4 = "/method/wall.get"
        let parameters4 = [
            "owner_id": userID,
            "domain": "id\(userID)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "100",
            "filter": "postponed",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation4 = GetServerDataOperation(url: url4, parameters: parameters4)
        opq.addOperation(getServerDataOperation4)
        
        // парсим объект с записями на стене
        let parsePostponed = ParseUserWall()
        parsePostponed.addDependency(getServerDataOperation4)
        opq.addOperation(parsePostponed)
        
        
        // обновляем данные на UI
        let reloadTableController = ReloadProfileController2(controller: self)
        reloadTableController.addDependency(parsePhotos)
        reloadTableController.addDependency(parseUserWall)
        reloadTableController.addDependency(parseUserProfile)
        reloadTableController.addDependency(parsePostponed)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func refreshWall() {
        let opq = OperationQueue()
        isRefresh = true
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        
        let url = "/method/wall.get"
        let parameters = [
            "owner_id": userID,
            "domain": "id\(userID)",
            "offset": "\(offset)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "\(count)",
            "filter": filterRecords,
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseUserWall = ParseUserWall()
        parseUserWall.completionBlock = {
            self.wall = parseUserWall.wall
            self.wallProfiles = parseUserWall.profiles
            self.wallGroups = parseUserWall.groups
            self.offset += self.count
            OperationQueue.main.addOperation {
                self.setProfileView()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        parseUserWall.addDependency(getServerDataOperation)
        opq.addOperation(parseUserWall)
    }

    func refreshUserInfo() {
        let opq = OperationQueue()
        
        let url = "/method/users.get"
        let parameters = [
            "user_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,personal,relatives",
            "name_case": "nom",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseUserProfile = ParseUserProfile()
        parseUserProfile.addDependency(getServerDataOperation)
        parseUserProfile.completionBlock = {
            self.userProfile = parseUserProfile.outputData
            if self.userProfile.count > 0 {
                OperationQueue.main.addOperation {
                    if self.userProfile[0].onlineStatus == 1 {
                        self.profileView.onlineStatusLabel.text = " онлайн"
                        self.profileView.onlineStatusLabel.textColor = UIColor.blue
                    } else {
                        if self.userProfile[0].deactivated == "" {
                            self.profileView.onlineStatusLabel.textColor = UIColor.black //UIColor.white
                            self.profileView.onlineStatusLabel.text = " заходил " + self.userProfile[0].lastSeen.toStringLastTime()
                            if self.userProfile[0].sex == 1 {
                                self.profileView.onlineStatusLabel.text = " заходила " + self.userProfile[0].lastSeen.toStringLastTime()
                            }
                        }
                    }
                    
                    if self.userProfile[0].platform > 0 && self.userProfile[0].platform != 7 {
                        self.profileView.onlineStatusLabel.setPlatformStatus(text: "\(self.profileView.onlineStatusLabel.text!)", platform: self.userProfile[0].platform, online: self.userProfile[0].onlineStatus)
                    }
                    
                    if self.profileView.collectionView1 != nil {
                        self.profileView.collectionView1.reloadData()
                    }
                }
            }
        }
        opq.addOperation(parseUserProfile)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
                
            let height = cell.getRowHeight(record: wall[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
                
            let height = cell.getRowHeight(record: wall[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if userProfile.count > 0 {
                if userProfile[0].deactivated == "" {
                    return 5
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell", for: indexPath) as! WallRecordCell2
        
        cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset - 1 {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            OperationQueue.main.addOperation {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                self.refreshExecute()
            }
        }
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = wall[indexPath.section]
        
        if let cell = tableView.cellForRow(at: indexPath) as? WallRecordCell2 {
            
            let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
            
            if action == "show_record" {
                
                self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
            }
            
            if action == "show_repost_record" {
                
                self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
            }
            
            if action == "show_owner" {
                
                self.openProfileController(id: record.fromID, name: "")
            }
            
            if action == "show_repost_owner" {
                
                self.openProfileController(id: record.repostOwnerID, name: "")
            }
            
            for index in 0...9 {
                if action == "show_photo_\(index)" {
                    let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                    
                    var newIndex = 0
                    for ind in 0...9 {
                        if record.mediaType[ind] == "photo" {
                            let photos = Photos(json: JSON.null)
                            photos.uid = "\(record.photoOwnerID[ind])"
                            photos.pid = "\(record.photoID[ind])"
                            photos.xxbigPhotoURL = record.photoURL[ind]
                            photos.xbigPhotoURL = record.photoURL[ind]
                            photos.bigPhotoURL = record.photoURL[ind]
                            photos.photoURL = record.photoURL[ind]
                            photos.width = record.photoWidth[ind]
                            photos.height = record.photoHeight[ind]
                            photoViewController.photos.append(photos)
                            if ind == index {
                                photoViewController.numPhoto = newIndex
                            }
                            newIndex += 1
                        }
                    }
                    
                    photoViewController.delegate = self
                    
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                }
                
                if action == "show_video_\(index)" {
                    
                    self.openVideoController(ownerID: "\(record.photoOwnerID[index])", vid: "\(record.photoID[index])", accessKey: record.photoAccessKey[index], title: "Видеозапись")
                    
                }
                
                if action == "show_music_\(index)" {
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Открыть песню в ITunes", style: .default) { action in
                        
                        ViewControllerUtils().showActivityIndicator(uiView: self.view)
                        self.getITunesInfo(searchString: "\(record.audioTitle[index]) \(record.audioArtist[index])", searchType: "song")
                    }
                    alertController.addAction(action1)
                    
                    let action3 = UIAlertAction(title: "Открыть исполнителя в ITunes", style: .default) { action in
                        
                        ViewControllerUtils().showActivityIndicator(uiView: self.view)
                        self.getITunesInfo(searchString: "\(record.audioArtist[index])", searchType: "artist")
                    }
                    alertController.addAction(action3)
                    
                    let action2 = UIAlertAction(title: "Скопировать название", style: .default) { action in
                        
                        let link = "\(record.audioArtist[index]). \(record.audioTitle[index])"
                        UIPasteboard.general.string = link
                        if let string = UIPasteboard.general.string {
                            self.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
                        }
                    }
                    alertController.addAction(action2)
                    
                    self.present(alertController, animated: true)
                    
                }
            }
            
            if action == "show_signer_profile" {
                self.openProfileController(id: record.signerID, name: "")
            }
        }
    }
    
    @IBAction func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore1 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
                wall[indexPath.section].readMore1 = 0
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: wall[indexPath.section])
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    @IBAction func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
                wall[indexPath.section].readMore2 = 0
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: wall[indexPath.section])
            
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    @objc func pollVote(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: position)
        
        if let cell = tableView.cellForRow(at: indexPath!) as? WallRecordCell2, let label = sender.view as? UILabel {
            let num = label.tag
            
            if cell.poll.answerID == 0 {
                let alertController = UIAlertController(title: "Вы выбрали следующий вариант:", message: "\(num+1). \(cell.poll.answers[num].text)", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Отдать свой голос", style: .default) { action in
                    let url = "/method/polls.addVote"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(cell.poll.ownerID)",
                        "poll_id": "\(cell.poll.id)",
                        "answer_id": "\(cell.poll.answers[num].id)",
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
                                cell.poll.votes += 1
                                cell.poll.answers[num].votes += 1
                                for answer in cell.poll.answers {
                                    answer.rate = Int(Double(answer.votes) / Double(cell.poll.votes) * 100)
                                }
                                cell.poll.answerID = cell.poll.answers[num].id
                                cell.updatePoll()
                            }
                        } else if error.errorCode == 250 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Нет доступа к опросу.")
                        } else if error.errorCode == 251 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор опроса.")
                        } else if error.errorCode == 252 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор ответа. ")
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
                
                present(alertController, animated: true)
            } else {
                
                var message = ""
                for index in 0...cell.poll.answers.count-1 {
                    if cell.poll.answers[index].id == cell.poll.answerID {
                        message = "\(index+1). \(cell.poll.answers[index].text)"
                    }
                }
                
                let alertController = UIAlertController(title: "Вы проголосовали за вариант:", message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Отозвать свой голос", style: .destructive) { action in
                    let url = "/method/polls.deleteVote"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(cell.poll.ownerID)",
                        "poll_id": "\(cell.poll.id)",
                        "answer_id": "\(cell.poll.answerID)",
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
                                cell.poll.votes -= 1
                                cell.poll.answers[num].votes -= 1
                                for answer in cell.poll.answers {
                                    answer.rate = Int(Double(answer.votes) / Double(cell.poll.votes) * 100)
                                }
                                cell.poll.answerID = 0
                                cell.updatePoll()
                            }
                        } else if error.errorCode == 250 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Нет доступа к опросу.")
                        } else if error.errorCode == 251 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор опроса.")
                        } else if error.errorCode == 252 {
                            self.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор ответа. ")
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
                
                present(alertController, animated: true)
            }
        }
    }
    
    @IBAction func likePost(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            let index = indexPath.section
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
                            let cell = self.tableView.cellForRow(at: indexPath) as! WallRecordCell2
                            cell.setLikesButton(record: self.wall[index])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                            let cell = self.tableView.cellForRow(at: indexPath) as! WallRecordCell2
                            cell.setLikesButton(record: self.wall[index])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                
                likeQueue.addOperation(request)
                
            }
        }
    }
    
    @IBAction func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            let record = wall[indexPath.section]
            
            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
        }
    }
    
    @IBAction func barButtonTouch(sender: UIBarButtonItem) {
        if userProfile.count > 0 {
            let user = userProfile[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            /*if self.userID == "357365563" && vkSingleton.shared.userID == "357365563" {
                let action = UIAlertAction(title: "Статистика приложения", style: .destructive) { action in
                    
                    self.getAppVkStat()
                }
                alertController.addAction(action)
            }*/
            
            if self.userID != vkSingleton.shared.userID {
                
                if user.isFavorite == 1 {
                    let action1 = UIAlertAction(title: "Удалить \(user.firstNameAcc) из «Избранное»", style: .destructive) { action in
                        
                        let url = "/method/fave.removeUser"
                        let parameters = [
                            "user_id": "\(self.userID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                user.isFavorite = 0
                                
                                var act = "удален"
                                if user.sex == 1 {
                                    act = "удалена"
                                }
                                
                                OperationQueue.main.addOperation {
                                    self.profileView.setCustomFields(profile: user)
                                }
                                self.showSuccessMessage(title: "Избранные пользователи", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) из Ваших закладок.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                } else {
                    let action1 = UIAlertAction(title: "Добавить \(user.firstNameAcc) в «Избранное»", style: .default) { action in
                        
                        let url = "/method/fave.addUser"
                        let parameters = [
                            "user_id": "\(self.userID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                user.isFavorite = 1
                                
                                var act = "добавлен"
                                if user.sex == 1 {
                                    act = "добавлена"
                                }
                                
                                OperationQueue.main.addOperation {
                                    self.profileView.setCustomFields(profile: user)
                                }
                                self.showSuccessMessage(title: "Избранные пользователи", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) в Ваши закладки.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                }
            }
            
            if self.userID == vkSingleton.shared.userID {
                if let item = self.tabBarController?.tabBar.items?[0] {
                    if let str = item.badgeValue, let count = Int(str), count > 0 {
                        let action7 = UIAlertAction(title: "Новые заявки в друзья (\(count))", style: .default) { action in
                            
                            self.openUsersController(uid: vkSingleton.shared.userID, title: "Заявки в друзья", type: "requests")
                        }
                        alertController.addAction(action7)
                    }
                }
            }
            
            if postponedWall.count > 0 {
                let action7 = UIAlertAction(title: "Отложенные записи (\(postponedWall.count))", style: .default) { action in
                    
                    self.tapPostponedWallButton(sender: self.profileView.postponedWallButton)
                }
                alertController.addAction(action7)
            }
            
            let action5 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/\(user.domain)"
                var title = "Ссылка на профиль \(user.firstNameGen):"
                if self.userID == vkSingleton.shared.userID {
                    title = "Ссылка на ваш профиль:"
                }
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: title, msg: "\(string)")
                }
            }
            alertController.addAction(action5)
            
            if self.userID != vkSingleton.shared.userID {
                if user.isHiddenFromFeed == 0 {
                    let action7 = UIAlertAction(title: "Скрывать новости в ленте", style: .destructive) { action in
                        self.hideUserFromFeed(userID: user.uid, name: "\(user.firstName) \(user.lastName)", controller: self)
                    }
                    alertController.addAction(action7)
                } else {
                    let action7 = UIAlertAction(title: "Показывать новости в ленте", style: .default) { action in
                        self.showUserInFeed(userID: user.uid, name: "\(user.firstName) \(user.lastName)", controller: self)
                    }
                    alertController.addAction(action7)
                }
            }
            
            if self.userID != vkSingleton.shared.userID {
                if user.blacklistedByMe == 1 {
                    let action1 = UIAlertAction(title: "Удалить из черного списка", style: .destructive) { action in
                        
                        let url = "/method/account.unbanUser"
                        let parameters = [
                            "user_id": "\(self.userID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                user.blacklistedByMe = 0
                                
                                var act = "удален"
                                if user.sex == 1 {
                                    act = "удалена"
                                }
                                self.showSuccessMessage(title: "Черный список", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) из черного списка.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                } else {
                    let action1 = UIAlertAction(title: "Добавить в черный список", style: .destructive) { action in
                        
                        let url = "/method/account.banUser"
                        let parameters = [
                            "user_id": "\(self.userID)",
                            "access_token": vkSingleton.shared.accessToken,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            guard let json = try? JSON(data: data) else { print("json error"); return }
                            let result = json["response"].intValue
                            
                            if result == 1 {
                                user.blacklistedByMe = 1
                                
                                var act = "добавлен"
                                if user.sex == 1 {
                                    act = "добавлена"
                                }
                                self.showSuccessMessage(title: "Черный список", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) в черный список.\n")
                            } else {
                                let error = ErrorJson(json: JSON.null)
                                error.errorCode = json["error"]["error_code"].intValue
                                error.errorMsg = json["error"]["error_msg"].stringValue
                                print("#\(error.errorCode): \(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                }
                
                let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                    
                    self.reportOnUser(userID: self.userID)
                }
                alertController.addAction(action6)
            }
            
            present(alertController, animated: true)
        }
    }
    
    @objc func addFriendButton(sender: UIButton) {
        if userProfile.count > 0 {
            
            sender.buttonTouched()
            
            let user = userProfile[0]
            
            // не является другом
            if user.friendStatus == 0 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Отправить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.add"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
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
                            self.userProfile[0].friendStatus = 1
                            self.userProfile[0].followersCount += 1
                            OperationQueue.main.addOperation {
                                self.profileView.updateFriendButton(profile: self.userProfile[0])
                                if self.profileView.collectionView1 != nil {
                                    self.profileView.collectionView1.reloadData()
                                }
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // отправлена заявка/подписка пользователю
            if user.friendStatus == 1 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Отменить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.delete"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
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
                            self.userProfile[0].friendStatus = 0
                            self.userProfile[0].followersCount -= 1
                            OperationQueue.main.addOperation {
                                self.profileView.updateFriendButton(profile: self.userProfile[0])
                                if self.profileView.collectionView1 != nil {
                                    self.profileView.collectionView1.reloadData()
                                }
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // имеется входящая заявка/подписка от пользователя
            if user.friendStatus == 2 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Одобрить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.add"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
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
                            self.userProfile[0].friendStatus = 3
                            self.userProfile[0].friendsCount += 1
                            OperationQueue.main.addOperation {
                                self.profileView.updateFriendButton(profile: self.userProfile[0])
                                if self.profileView.collectionView1 != nil {
                                    self.profileView.collectionView1.reloadData()
                                }
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // является другом
            if user.friendStatus == 3 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Удалить из друзей"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.delete"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
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
                            self.userProfile[0].friendStatus = 2
                            self.userProfile[0].friendsCount -= 1
                            OperationQueue.main.addOperation {
                                self.profileView.updateFriendButton(profile: self.userProfile[0])
                                if self.profileView.collectionView1 != nil {
                                    self.profileView.collectionView1.reloadData()
                                }
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
        }
    }
    
    @objc func tapAvatarImage() {
        if userProfile.count > 0 {
            let user = userProfile[0]
            
            if user.avatarID != "" {
                let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                
                
                let photos = Photos(json: JSON.null)
                photos.uid = "\(user.uid)"
                let comps = user.avatarID.components(separatedBy: "_")
                if comps.count > 1 {
                    photos.pid = comps[1]
                    
                    for index in 0...self.photos.count - 1 {
                        if photos.pid == self.photos[index].pid {
                            photos.xxbigPhotoURL = self.photos[index].xxbigPhotoURL
                            photos.xbigPhotoURL = self.photos[index].xbigPhotoURL
                            photos.bigPhotoURL = self.photos[index].bigPhotoURL
                            photos.photoURL = self.photos[index].photoURL
                            photos.width = self.photos[index].width
                            photos.height = self.photos[index].height
                            
                            photoViewController.numPhoto = index
                            photoViewController.photos = self.photos
                        }
                    }
                    
                    if photos.width == 0 {
                        photos.xxbigPhotoURL = user.maxPhotoOrigURL
                        photos.xbigPhotoURL = user.maxPhotoOrigURL
                        photos.bigPhotoURL = user.maxPhotoOrigURL
                        photos.photoURL = user.maxPhotoOrigURL
                        photos.width = Int(UIScreen.main.bounds.width)
                        photos.height = Int(UIScreen.main.bounds.width)
                        
                        photoViewController.numPhoto = 0
                        photoViewController.photos.append(photos)
                    }
                    
                    photoViewController.delegate = self
                    
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                }
            }
        }
    }
    
    func setProfileView() {
        if userProfile.count > 0 {
            profileView = ProfileView()
            profileView.delegate = self
            profileView.backgroundColor = UIColor.white
            
            var height: CGFloat = profileView.configureCell(profile: userProfile[0])
            
            if userProfile[0].deactivated == "" {
                if getCountCountersSection() > 0 {
                    let layout1: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout1.scrollDirection = .horizontal
                    layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    layout1.itemSize = CGSize(width: 65, height: 65)
                    
                    self.profileView.collectionView1 = UICollectionView(frame: CGRect(x: 10, y: height, width: self.tableView.bounds.width - 20, height: 65), collectionViewLayout: layout1)
                    self.profileView.collectionView1.tag = 2
                    self.profileView.collectionView1.delegate = self
                    self.profileView.collectionView1.dataSource = self
                    self.profileView.collectionView1.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "counterCell")
                    self.profileView.collectionView1.backgroundColor = UIColor.white
                    self.profileView.collectionView1.showsVerticalScrollIndicator = false
                    self.profileView.collectionView1.showsHorizontalScrollIndicator = true
                    profileView.addSubview(self.profileView.collectionView1)
                    self.profileView.collectionView1.reloadData()
                    height += 65
                }
                
                if photos.count > 0 {
                    let photosCountLabel = UILabel()
                    photosCountLabel.text = "\(userProfile[0].photosCount) фото"
                    photosCountLabel.font = UIFont(name: "Verdana", size: 13)
                    photosCountLabel.textColor = UIColor.lightGray
                    photosCountLabel.contentMode = .center
                    photosCountLabel.textAlignment = .left
                    photosCountLabel.frame = CGRect(x: 10, y: height, width: UIScreen.main.bounds.width - 60, height: 25)
                    profileView.addSubview(photosCountLabel)
                    profileView.addSubview(photosCountLabel)
                    
                    if photos.count > 2 {
                        let photosDiscCountLabel = UILabel()
                        photosDiscCountLabel.text = "▸"
                        photosDiscCountLabel.font = UIFont(name: "Verdana", size: 20)
                        photosDiscCountLabel.textColor = UIColor.lightGray
                        photosDiscCountLabel.contentMode = .center
                        photosDiscCountLabel.textAlignment = .right
                        photosDiscCountLabel.frame = CGRect(x: UIScreen.main.bounds.width - 40, y: height, width: 30, height: 25)
                        profileView.addSubview(photosDiscCountLabel)
                    }
                    
                    height += 25
                    
                    let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout2.scrollDirection = .horizontal
                    layout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
                    layout2.itemSize = CGSize(width: 120, height: 100)
                    
                    self.profileView.collectionView2 = UICollectionView(frame: CGRect(x: 10, y: height, width: self.tableView.bounds.width - 20, height: 100), collectionViewLayout: layout2)
                    self.profileView.collectionView2.tag = 4
                    self.profileView.collectionView2.delegate = self
                    self.profileView.collectionView2.dataSource = self
                    self.profileView.collectionView2.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
                    self.profileView.collectionView2.backgroundColor = UIColor.white
                    self.profileView.collectionView2.showsVerticalScrollIndicator = false
                    self.profileView.collectionView2.showsHorizontalScrollIndicator = true
                    profileView.addSubview(self.profileView.collectionView2)
                    self.profileView.collectionView2.reloadData()
                    height += 100
                }
                
                let separator1 = UIView()
                 separator1.frame = CGRect(x: 0, y: height + 5, width: UIScreen.main.bounds.width, height: 5)
                 separator1.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
                 profileView.addSubview(separator1)
                
                let tap = UITapGestureRecognizer()
                tap.addTarget(self, action: #selector(self.tapAvatarImage))
                tap.numberOfTapsRequired = 1
                self.profileView.avatarImage.addGestureRecognizer(tap)
                self.profileView.avatarImage.isUserInteractionEnabled = true
                
                height = profileView.setOwnerButton(profile: userProfile[0], filter: self.filterRecords, postponed: self.postponedWall.count, topY: height + 10)
            }
            
            profileView.infoButton.addTarget(self, action: #selector(self.infoUserTouch(sender:)), for: .touchUpInside)
            profileView.newRecordButton.addTarget(self, action: #selector(self.tapNewRecordButton(sender:)), for: .touchUpInside)
            profileView.postponedWallButton.addTarget(self, action: #selector(self.tapPostponedWallButton(sender:)), for: .touchUpInside)
            
            profileView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: height)
            
            profileView.allRecordsButton.addTarget(self, action: #selector(self.tapAllRecordsButton(sender:)), for: .touchUpInside)
            profileView.ownerButton.addTarget(self, action: #selector(self.tapOwnerButton(sender:)), for: .touchUpInside)
            
            self.tableView.tableHeaderView = profileView
        }
    }
    
    @objc func tapMessageButton(sender: UIButton) {
        
        sender.buttonTouched()
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "user_id": "\(self.userID)",
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
                self.openDialogController(userID: self.userID, chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)
    }
    
    @objc func tapPostponedWallButton(sender: UIButton) {
    
        if self.postponedWall.count > 0 {
            let postponedController = self.storyboard?.instantiateViewController(withIdentifier: "PostponedWallController") as! PostponedWallController
        
            for postponed in postponedWall {
                postponed.readMore1 = 1
            }
            postponedController.wall = self.postponedWall
            postponedController.wallProfiles = self.postponedWallProfiles
            postponedController.wallGroups = self.postponedWallGroups
            postponedController.ownerID = self.userID
            postponedController.title = "Отложенные записи"
        
            self.navigationController?.pushViewController(postponedController, animated: true)
        }
    }
    
    @objc func tapNewRecordButton(sender: UIButton) {
        if userProfile.count > 0, userProfile[0].canPost == 1 {
            
            openNewRecordController(ownerID: userProfile[0].uid, type: "new", message: "", title: "Новая запись", controller: nil, delegate: self)
        }
    }
    
    @objc func infoUserTouch(sender: UIButton) {
        self.openUserInfoProfile(profiles: userProfile)
    }
    
    @objc func tapAllRecordsButton(sender: UIButton) {
        sender.buttonTouched()
        
        filterRecords = "all"
        offset = 0
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        refreshWall()
    }
    
    @objc func tapOwnerButton(sender: UIButton) {
        sender.buttonTouched()
        
        filterRecords = "owner"
        offset = 0
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        refreshWall()
    }
    
    func saveAccountToRealm() {
        if self.userID == vkSingleton.shared.userID {
            if userProfile.count > 0 {
                let account = AccountVK()
                let user = userProfile[0]
                
                account.userID = Int(self.userID)!
                account.token = vkSingleton.shared.accessToken
                account.firstName = user.firstName
                account.lastName = user.lastName
                account.screenName = user.domain
                account.lastSeen = user.lastSeen
                account.avatarURL = user.maxPhotoOrigURL
                self.updateAccountInRealm(account: account)
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
                    
                    newRecordController.repostOwnerID = record.ownerID
                    newRecordController.repostItemID = record.id
                    
                    newRecordController.delegate2 = self
                    
                    if self.userProfile.count > 0 {
                        newRecordController.repostTitle = "Репост записи со стены пользователя\n\"\(self.userProfile[0].firstName) \(self.userProfile[0].lastName)\""
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

extension ProfileController2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 2 {
            return getCountCountersSection()
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collectionView.tag == 2 {
            return 65
        }
        
        if collectionView.tag == 4 {
            return 100
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 2 {
            if countersSection[indexPath.section].comment == "photosCount" {
                
                var title = "Мои фотографии"
                if userID != vkSingleton.shared.userID {
                    title = "Фотографии"
                    if userProfile.count > 0 {
                        title = "Фото \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openPhotosListController(ownerID: userID, title: title, type: "photos")
            }
            
            if countersSection[indexPath.section].comment == "friendsCount" {
                
                var title = "Мои друзья"
                
                if userID != vkSingleton.shared.userID {
                    title = "Друзья"
                    if userProfile.count > 0 {
                        title = "Друзья \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openUsersController(uid: userID, title: title, type: "friends")
            }
            
            if countersSection[indexPath.section].comment == "commonFriendsCount" {
                
                let title = "Общие друзья"
                
                self.openUsersController(uid: userID, title: title, type: "commonFriends")
            }
            
            if countersSection[indexPath.section].comment == "followersCount" {
                
                var title = "Мои подписчики"
                if userID != vkSingleton.shared.userID {
                    title = "Подписчики"
                    if userProfile.count > 0 {
                        title = "Подписчики \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openUsersController(uid: userID, title: title, type: "followers")
            }
            
            if countersSection[indexPath.section].comment == "groupsCount" {
                
                var title = "Мои группы"
                if userID != vkSingleton.shared.userID {
                    title = "Группы"
                    if userProfile.count > 0 {
                        title = "Группы \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openGroupsListController(uid: userID, title: title, type: "groups")
            }
            
            if countersSection[indexPath.section].comment == "pagesCount" {
                
                var title = "Мои страницы"
                if userID != vkSingleton.shared.userID {
                    title = "Страницы"
                    if userProfile.count > 0 {
                        title = "Страницы \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openGroupsListController(uid: userID, title: title, type: "pages")
            }
            
            if countersSection[indexPath.section].comment == "videosCount" {
                
                var title = "Видеозаписи"
                if userID == vkSingleton.shared.userID {
                    title = "Мои видеозаписи"
                } else {
                    if userProfile.count > 0 {
                        title = "Видеозаписи \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openVideoListController(ownerID: userID, title: title, type: "")
            }
            
            /*if countersSection[indexPath.section].comment == "notesCount" {
                
                var title = "Заметки"
                if userID == vkSingleton.shared.userID {
                    title = "Мои заметки"
                } else {
                    if userProfile.count > 0 {
                        title = "Заметки \(userProfile[0].firstNameGen)"
                    }
                }
                
                self.openNotesController(userID: userID, title: title)
            }*/
        }
        
        if collectionView.tag == 4 {
            self.openPhotoViewController(numPhoto: indexPath.section, photos: photos)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "counterCell", for: indexPath)
            
            let subviews = cell.subviews
            for subview in subviews {
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
            
            countLabel.text = countersSection[indexPath.section].value
            nameLabel.text = countersSection[indexPath.section].image
            
            countLabel.textAlignment = .center
            nameLabel.textAlignment = .center
            
            countLabel.frame = CGRect(x: 0, y: 10, width: cell.bounds.width, height: 24)
            nameLabel.frame = CGRect(x: 0, y: 36, width: cell.bounds.width, height: 14)
            
            cell.addSubview(countLabel)
            cell.addSubview(nameLabel)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
            
            let subviews = cell.subviews
            for subview in subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
            }
            
            let photo = photos[indexPath.section]
            
            var url = photo.bigPhotoURL
            if url == "" { url = photo.photoURL }
            if url == "" { url = photo.smallPhotoURL }
            
            let imageView = UIImageView()
            let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
            let setImageToRow = SetImageToRowOfCollectionView(cell: cell, imageView: imageView, indexPath: indexPath, collectionView: collectionView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                imageView.layer.borderColor = UIColor.black.cgColor
                imageView.layer.borderWidth = 0.5
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
            }
            
            imageView.contentMode = .scaleAspectFill
            
            let width = cell.bounds.width
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: collectionView.bounds.height)
            
            cell.addSubview(imageView)
            
            return cell
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
    
    func getCountCountersSection() -> Int {
        
        var count = 0
        
        countersSection.removeAll(keepingCapacity: false)
        
        if userProfile.count > 0 {
            var infoCounters: InfoInProfile
            
            let user = userProfile[0]
            
            if user.deactivated == "" {
                count += 1
                infoCounters = InfoInProfile("друзей", getCounterToString(user.friendsCount),"friendsCount")
                countersSection.append(infoCounters)
                
                
                if user.commonFriendsCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("общих",getCounterToString(user.commonFriendsCount), "commonFriendsCount")
                    countersSection.append(infoCounters)
                }
                
                if user.followersCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("подписчиков", getCounterToString(user.followersCount), "followersCount")
                    countersSection.append(infoCounters)
                }
                
                if user.groupsCount - user.pagesCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("групп", getCounterToString(user.groupsCount - user.pagesCount), "groupsCount")
                    countersSection.append(infoCounters)
                }
                
                if user.pagesCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("страниц", getCounterToString(user.pagesCount), "pagesCount")
                    countersSection.append(infoCounters)
                }
                
                if user.photosCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("фото", getCounterToString(user.photosCount), "photosCount")
                    countersSection.append(infoCounters)
                }
                
                if user.videosCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("видео", getCounterToString(user.videosCount), "videosCount")
                    countersSection.append(infoCounters)
                }
                
                if user.notesCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("заметки", getCounterToString(user.notesCount), "notesCount")
                    countersSection.append(infoCounters)
                }
            }
        }
        
        return count
    }
}
