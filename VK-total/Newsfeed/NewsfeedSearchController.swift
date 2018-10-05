//
//  NewsfeedSearchController.swift
//  VK-total
//
//  Created by Сергей Никитин on 08.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class NewsfeedSearchController: UITableViewController {

    var ownerID = ""
    var searchText = ""
    
    var wall = [Wall]()
    var wallProfiles = [WallProfiles]()
    var wallGroups = [WallGroups]()
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            self.tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "wallRecordCell")
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        getSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func getSearch() {
        let opq = OperationQueue()
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        
        let url = "/method/newsfeed.search"
        let parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "q": searchText,
            "extended": "1",
            "count": "200",
            "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseWall = ParseUserWall()
        parseWall.addDependency(getServerDataOperation)
        opq.addOperation(parseWall)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadNewsfeedSearchController(controller: self)
        reloadTableController.addDependency(parseWall)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return wall.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
            
            let height = cell.getRowHeight(record: wall[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell2
            
            let height = cell.getRowHeight(record: wall[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let record = wall[indexPath.section]
        
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let cell = tableView.cellForRow(at: indexPath) as! WallRecordCell2
                    
                    let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                    
                    if action == "show_record" {
                        
                        self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                    }
                    
                    if action == "show_repost_record" {
                        
                        self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
                    }
                    
                    if action == "show_owner" {
                        
                        self.openProfileController(id: record.ownerID, name: "")
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
                            
                            self.navigationController?.pushViewController(photoViewController, animated: true)
                        }
                        
                        if action == "show_video_\(index)" {
                            
                            self.openVideoController(ownerID: "\(record.photoOwnerID[index])", vid: "\(record.photoID[index])", accessKey: record.photoAccessKey[index], title: "Видеозапись")
                            
                        }
                        
                        if action == "show_music_\(index)" {
                            
                            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                            alertController.addAction(cancelAction)
                            
                            let action1 = UIAlertAction(title: "Открыть песню в iTunes", style: .default) { action in
                                
                                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                                self.getITunesInfo(searchString: "\(record.audioTitle[index]) \(record.audioArtist[index])", searchType: "song")
                            }
                            alertController.addAction(action1)
                            
                            let action3 = UIAlertAction(title: "Открыть исполнителя в iTunes", style: .default) { action in
                                
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
                    
                    if record.ownerID > 0 {
                        newRecordController.repostTitle = "Репост записи со стены пользователя"
                    }
                    
                    if record.ownerID < 0 {
                        newRecordController.repostTitle = "Репост записи со стены сообщества"
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
