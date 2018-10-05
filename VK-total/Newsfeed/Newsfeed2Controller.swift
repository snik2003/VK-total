//
//  Newsfeed2Controller.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BTNavigationDropdownMenu

class Newsfeed2Controller: UITableViewController {

    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var selectedMenu = 0
    let itemsMenu = ["Рекомендации", "Новости", "Друзья", "Сообщества", "Фотографии"]
    
    var userID = vkSingleton.shared.userID
    var news = [News]()
    var newsProfiles = [NewsProfiles]()
    var newsGroups = [NewsGroups]()
    
    var filters = "post"
    var sourceIDs = "recommend"
    var startFrom = ""
    var offset = 0
    let count = 100
    var isRefresh = false
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let menuView = BTNavigationDropdownMenu(title: itemsMenu[0], items: itemsMenu)
        menuView.cellBackgroundColor = UIColor.white
        menuView.cellSelectionColor = UIColor.white
        menuView.cellTextLabelAlignment = .center
        menuView.cellTextLabelColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        menuView.selectedCellTextLabelColor = UIColor.red
        menuView.cellTextLabelFont = UIFont.boldSystemFont(ofSize: 15)
        menuView.navigationBarTitleFont = UIFont.boldSystemFont(ofSize: 17)
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self?.selectedMenu = indexPath
            switch indexPath {
            case 0:
                self?.filters = "post"
                self?.sourceIDs = "recommend"
                self?.startFrom = ""
                self?.offset = 0
                self?.refresh()
                break
            case 1:
                self?.filters = "post"
                self?.sourceIDs = ""
                self?.startFrom = ""
                self?.offset = 0
                self?.refresh()
                break
            case 2:
                self?.filters = "post"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.offset = 0
                self?.refresh()
                break
            case 3:
                self?.filters = "post"
                self?.sourceIDs = "groups,pages"
                self?.startFrom = ""
                self?.offset = 0
                self?.refresh()
                break
            case 4:
                self?.filters = "wall_photo"
                self?.sourceIDs = "friends"
                self?.startFrom = ""
                self?.offset = 0
                self?.refresh()
                break
            default:
                break
            }
        }
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshButtonClick), for: UIControl.Event.valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)
        
        refresh()
    }

    @objc func refreshButtonClick()
    {
        startFrom = ""
        offset = 0
        refresh()
    }
    
    func refresh() {
        let opq = OperationQueue()
        var url: String
        var parameters: Parameters
        isRefresh = true
        
        estimatedHeightCache.removeAll(keepingCapacity: false)
        
        OperationQueue.main.addOperation {
            self.refreshControl?.beginRefreshing()
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        if startFrom == "" && offset == 0 {
            news.removeAll(keepingCapacity: false)
            newsProfiles.removeAll(keepingCapacity: false)
            newsGroups.removeAll(keepingCapacity: false)
            tableView.reloadData()
        }
        
        // получаем данные с сервера ВК
        if sourceIDs == "recommend" {
            url = "/method/newsfeed.getRecommended"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "filters": filters,
                "max_photos": "10",
                "star_from": "\(startFrom)",
                "count": "\(count)",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": vkSingleton.shared.version
            ]
        } else {
            url = "/method/newsfeed.get"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "filters": filters,
                "source_ids": sourceIDs,
                "return_banned": "0",
                "start_time": Date().timeIntervalSince1970 - 15552000,
                "end_time": Date().timeIntervalSince1970,
                "start_from": "\(startFrom)",
                "count": "\(count)",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": vkSingleton.shared.version
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект с данными
        let parseNewsfeed = ParseNewsfeed(filters: filters, source: sourceIDs)
        parseNewsfeed.addDependency(getServerDataOperation)
        opq.addOperation(parseNewsfeed)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        // обновляем данные на UI
        let reloadTableController = ReloadNewsfeed2Controller(controller: self)
        reloadTableController.addDependency(parseNewsfeed)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! Newsfeed2Cell
            
            let height = cell.getRowHeight(record: news[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! Newsfeed2Cell
            
            let height = cell.getRowHeight(record: news[indexPath.section])
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 15
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! Newsfeed2Cell

        cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
        
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
    
    @IBAction func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if news[indexPath.section].readMore1 == 1 {
                news[indexPath.section].readMore1 = 0
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! Newsfeed2Cell
                
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: news[indexPath.section])
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    @IBAction func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if news[indexPath.section].readMore2 == 1 {
                news[indexPath.section].readMore2 = 0
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! Newsfeed2Cell
                
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: news[indexPath.section])
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset - 1 {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    if filters != "wall_photo" {
                        let record = news[indexPath.section]
                        
                        let cell = tableView.cellForRow(at: indexPath) as! Newsfeed2Cell
                        
                        let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                        
                        if action == "show_record" {
                            
                            self.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
                        }
                        
                        if action == "show_repost_record" {
                            
                            self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
                        }
                        
                        if action == "show_owner" {
                            
                            self.openProfileController(id: record.sourceID, name: "")
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
                        
                    } else {
                        let record = news[indexPath.section]
                        let cell = tableView.cellForRow(at: indexPath) as! Newsfeed2Cell
                        
                        let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                        
                        if action == "show_owner" {
                            
                            self.openProfileController(id: record.sourceID, name: "")
                        }
                        
                        if action == "show_photo" {
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            let record = news[index]
            
            self.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
        }
    }
    
    @objc func pollVote(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: position)
        
        if let cell = tableView.cellForRow(at: indexPath!) as? Newsfeed2Cell, let label = sender.view as? UILabel {
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
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if filters == "wall_photo" {
            
        } else if let index = indexPath?.section {
            let record = news[index]
            
            if record.userLikes == 0 {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.add"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "post",
                    "owner_id": "\(record.sourceID)",
                    "item_id": "\(record.postID)",
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
                        self.news[index].countLikes += 1
                        self.news[index].userLikes = 1
                        OperationQueue.main.addOperation {
                            let cell = self.tableView.cellForRow(at: indexPath!) as! Newsfeed2Cell
                            cell.setLikesButton(record: self.news[index])
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
                    "owner_id": "\(record.sourceID)",
                    "item_id": "\(record.postID)",
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
                        self.news[index].countLikes -= 1
                        self.news[index].userLikes = 0
                        OperationQueue.main.addOperation {
                            let cell = self.tableView.cellForRow(at: indexPath!) as! Newsfeed2Cell
                            cell.setLikesButton(record: self.news[index])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
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
            let record = news[index]
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if record.canRepost == 1 && record.userReposted == 0 {
                let action1 = UIAlertAction(title: "Опубликовать на своей стене", style: .default) { action in
                    
                    let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
                    
                    newRecordController.ownerID = vkSingleton.shared.userID
                    newRecordController.type = "repost"
                    newRecordController.message = ""
                    newRecordController.title = "Репост записи"
                    
                    newRecordController.repostOwnerID = record.sourceID
                    newRecordController.repostItemID = record.postID
                    
                    newRecordController.delegate2 = self
                    
                    if record.sourceID > 0 {
                        newRecordController.repostTitle = "Репост записи со стены пользователя"
                    }
                    
                    if record.sourceID < 0 {
                        newRecordController.repostTitle = "Репост записи со стены сообщества"
                    }
                    
                    if let image = UIApplication.shared.screenShot {
                        let attachment = "wall\(record.sourceID)_\(record.postID)"
                        
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
                
                let attachment = "https://vk.com/wall\(record.sourceID)_\(record.postID)"
                self.openDialogsController(attachments: attachment, image: nil, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action3)
            
            let action2 = UIAlertAction(title: "Переслать сообщением", style: .default){ action in
                
                let attachment = "wall\(record.sourceID)_\(record.postID)"
                let image = UIApplication.shared.screenShot
                self.openDialogsController(attachments: attachment, image: image, messIDs: [], source: "add_attach_message")
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        }
    }
}
