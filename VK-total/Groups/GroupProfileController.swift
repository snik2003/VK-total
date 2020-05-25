//
//  GroupProfileController.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GroupProfileController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var groupID = 0
    
    var groupProfile = [GroupProfile]()
    var wall = [Wall]()
    var groups = [WallGroups]()
    var profiles = [WallProfiles]()
    var countersSection = [InfoInProfile]()
    var offset = 0
    let count = 100
    var isRefresh = false
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    var viewFirstAppear: Bool = true
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
        }
        
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewFirstAppear {
            OperationQueue.main.addOperation {
                self.tableView.separatorStyle = .none
                ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
            }
        }
        viewFirstAppear = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
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
            "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count",
            "v": vkSingleton.shared.version
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
            "filter": "owner",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        
        // парсим объект
        let parseGroupWall = ParseGroupWall()
        parseGroupWall.addDependency(getServerDataOperation2)
        opq.addOperation(parseGroupWall)
        
        // обновляем данные на UI
        let reloadTableController = ReloadGroupProfileController(controller: self)
        reloadTableController.addDependency(parseGroupWall)
        reloadTableController.addDependency(parseGroupProfile)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + wall.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if indexPath.section == 0 {
            if groupProfile.count > 0 {
                if let height = estimatedHeightCache[indexPath] {
                    return height
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "groupProfileCell") as! GroupProfileCell
                    
                    let height = cell.getRowHeight(profile: groupProfile[0])
                    estimatedHeightCache[indexPath] = height
                    return height
                }
            }
        }
        
        if indexPath.section > 2 {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell
                
                let height = cell.getRowHeight(record: wall[indexPath.section - 2])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if groupProfile.count > 0 {
                if let height = estimatedHeightCache[indexPath] {
                    return height
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "groupProfileCell") as! GroupProfileCell
                    
                    let height = cell.getRowHeight(profile: groupProfile[0])
                    estimatedHeightCache[indexPath] = height
                    return height
                }
            }
            return 0
        case 1:
            if getNumberOfCounters() > 0 {
                return 65
            }
            return 0
        default:
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell
                
                let height = cell.getRowHeight(record: wall[indexPath.section - 2])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if groupProfile.count > 0 {
            if section > 1 {
                return 15
            }
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupProfileCell", for: indexPath) as! GroupProfileCell
            
            if groupProfile.count > 0 {
                cell.configureCell(profile: groupProfile[0], indexPath: indexPath, cell: cell, tableView: tableView)
            }
            
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "countersCell", for: indexPath) as! GroupCountersCell
            
            cell.collectionView.reloadData()
            cell.collectionViewFrame()
            
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell", for: indexPath) as! WallRecordCell
            
            cell.configureCell(record: wall[indexPath.section - 2], profiles: profiles, groups: groups, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        

        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == 1 + offset {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isRefresh == false {
            refresh()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 1 {
            let record = wall[indexPath.section - 2]
            
            if let visibleIndexPath = tableView.indexPathsForVisibleRows {
                for index in visibleIndexPath {
                    if index == indexPath {
                        let cell = tableView.cellForRow(at: indexPath) as! WallRecordCell
                    
                        let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                        
                        if action == "show_record" {
                            
                            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: false)
                        }
                        
                        if action == "show_repost_record" {
                            
                            self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post", scrollToComment: false)
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
                        }
                    }
                }
            }
        }
    }
    
    
    func getNumberOfCounters() -> Int {
        var count = 0
        
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
            if profile.audiosCounter > 0 {
                count += 1
                infoCounters = InfoInProfile("аудио", self.getCounterToString(profile.audiosCounter),"audiosCount")
                self.countersSection.append(infoCounters)
            }
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
    
    @IBAction func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if wall[(indexPath?.section)! - 2].readMore1 == 1 {
            wall[(indexPath?.section)! - 2].readMore1 = 0
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if wall[(indexPath?.section)! - 2].readMore2 == 1 {
            wall[(indexPath?.section)! - 2].readMore2 = 0
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func joinGroup() {
        if groupProfile.count > 0 {

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
                                    self.tableView.beginUpdates()
                                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                    self.tableView.endUpdates()
                                }
                            } else {
                                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
                                    self.tableView.beginUpdates()
                                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                    self.tableView.endUpdates()
                                }
                            } else {
                                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                            }
                        }
                        
                        leaveQueue.addOperation(sendLeaveGroupRequest)
                    }
                    alertController.addAction(OKAction)
                    
                    present(alertController, animated: true)
                    
                    
                }
            }
        }
    }
    
    @IBAction func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section, index > 1 {
            let record = wall[index - 2]
            
            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: true)
        }
    }
    
    @IBAction func likePost(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section, index > 1 {
            let record = wall[index - 2]
            
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
                        self.wall[index - 2].countLikes += 1
                        self.wall[index - 2].userLikes = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? WallRecordCell {
                                cell.setLikesButton(record: self.wall[index - 2])
                            }
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
                        self.wall[index - 2].countLikes -= 1
                        self.wall[index - 2].userLikes = 0
                        OperationQueue.main.addOperation {
                            let cell = self.tableView.cellForRow(at: indexPath!) as! WallRecordCell
                            cell.setLikesButton(record: self.wall[index - 2])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                
                likeQueue.addOperation(request)
                
            }
        }
    }
}

extension GroupProfileController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return getNumberOfCounters()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "counterCell", for: indexPath)
        
        let countLabel: UILabel = cell.viewWithTag(1) as! UILabel
        let nameLabel: UILabel = cell.viewWithTag(2) as! UILabel
        
        countLabel.text = countersSection[indexPath.row].value
        nameLabel.text = countersSection[indexPath.row].image
        
        return cell
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
}
