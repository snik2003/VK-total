//
//  Newsfeed2Controller.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import SCLAlertView
import BTNavigationDropdownMenu

class Newsfeed2Controller: InnerTableViewController {

    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var selectedMenu = 0
    let itemsMenu = ["Лента новостей", "Новости друзей", "Новости сообществ", "Интересные записи", "Фотографии друзей", "Видеозаписи друзей", "Аудиозаписи друзей"]
    
    var userID = vkSingleton.shared.userID
    var news = [Wall]()
    var newsProfiles = [WallProfiles]()
    var newsGroups = [WallGroups]()
    var videos = [Videos]()
    
    var filters = "post"
    var sourceIDs = ""
    var startFrom = ""
    var offset = 0
    let count = 32
    let leftCellCount = 3
    var viewCount = 0
    
    var firstAppear = true
    var isRefresh = false
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var menuView: BTNavigationDropdownMenu!
    
    var player = AVPlayer()
    
    var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "recordCell")
        tableView.showsVerticalScrollIndicator = false
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: vkSingleton.shared.labelColor]
        let myAttrString = NSAttributedString(string: "Обновляем данные", attributes: myAttribute)
        refreshControl?.attributedTitle = myAttrString
        refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        refreshControl?.tintColor = vkSingleton.shared.labelColor
        tableView.addSubview(refreshControl!)
        
        spinner = UIActivityIndicatorView(style: .white)
        spinner.color = vkSingleton.shared.labelColor
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60)
        tableView.tableFooterView = spinner
        
        menuView = BTNavigationDropdownMenu(title: itemsMenu[view.tag], items: itemsMenu)
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
            self?.menuView.isUserInteractionEnabled = false
            self?.selectedMenu = indexPath
            self?.view.tag = indexPath
            
            if let aView = self?.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            }
            
            switch indexPath {
            case 0:
                self?.filters = "post"
                self?.sourceIDs = ""
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            case 1:
                self?.filters = "post"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            case 2:
                self?.filters = "post"
                self?.sourceIDs = "groups,pages"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            case 3:
                self?.filters = "post"
                self?.sourceIDs = "recommend"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = nil
                self?.refresh()
                break
            case 4:
                self?.filters = "wall_photo"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            case 5:
                self?.filters = "video"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            case 6:
                self?.filters = "audio"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.offset = 0
                self?.viewCount = 0
                self?.spinner.stopAnimating()
                self?.tableView.tableFooterView = self?.spinner
                self?.refresh()
                break
            default:
                break
            }
        }
        
        menuView.isUserInteractionEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            
            if let aView = self.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            } else {
                ViewControllerUtils().showActivityIndicator(uiView: view)
            }
            
            refresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let menuView = navigationItem.titleView as? BTNavigationDropdownMenu {
            menuView.hide()
        }
    }
    
    @objc func pullToRefresh() {
        startFrom = ""
        offset = 0
        viewCount = 0
        spinner.startAnimating()
        
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
        }
        
        if startFrom == "" && offset == 0 {
            news.removeAll(keepingCapacity: false)
            newsProfiles.removeAll(keepingCapacity: false)
            newsGroups.removeAll(keepingCapacity: false)
            videos.removeAll(keepingCapacity: false)
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
                "count": "100",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": "5.85"
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
                "v": "5.85"
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект с данными
        let parseNewsfeed = ParseNewsfeed(filters: filters, source: sourceIDs)
        parseNewsfeed.addDependency(getServerDataOperation)
        parseNewsfeed.completionBlock = {
            var videoIDs = ""
            for wall in parseNewsfeed.news {
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
                let url2 = "/method/video.get"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": vkSingleton.shared.userID,
                    "videos": videoIDs,
                    "extended": "0",
                    "fields": "id, first_name, last_name, photo_100",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                getServerDataOperation2.completionBlock = {
                    guard let data = getServerDataOperation2.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    if self.filters == "video" {
                    //    print(json)
                    }
                    
                    let newsVideos = json["response"]["items"].compactMap({ Videos(json: $0.1) })
                    for video in newsVideos {
                        if video.id != 0 { self.videos.append(video) }
                    }
                    
                    let reloadTableController = ReloadNewsfeed2Controller(controller: self)
                    reloadTableController.addDependency(parseNewsfeed)
                    OperationQueue.main.addOperation(reloadTableController)
                }
                OperationQueue().addOperation(getServerDataOperation2)
            } else {
                let reloadTableController = ReloadNewsfeed2Controller(controller: self)
                reloadTableController.addDependency(parseNewsfeed)
                OperationQueue.main.addOperation(reloadTableController)
            }
        }
        opq.addOperation(parseNewsfeed)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
            cell.delegate = self
            cell.drawCell = false
            
            let height = cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            estimatedHeightCache[indexPath] = height
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = estimatedHeightCache[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
            cell.delegate = self
            cell.drawCell = false
            
            let height = cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
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
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! WallRecordCell2
        cell.delegate = self
        
        estimatedHeightCache[indexPath] = cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
        
        cell.readMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap1(sender:)), for: .touchUpInside)
        cell.repostReadMoreButton.addTarget(self, action: #selector(self.readMoreButtonTap2(sender:)), for: .touchUpInside)
        cell.likesButton.addTarget(self, action: #selector(self.likePost(sender:)), for: .touchUpInside)

        cell.repostsButton.addTarget(self, action: #selector(self.tapRepostButton(sender:)), for: .touchUpInside)
        cell.commentsButton.addTarget(self, action: #selector(self.tapCommentsButton(sender:)), for: .touchUpInside)
        
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
        
        cell.selectionStyle = .none
        return cell
    }
    
    @IBAction func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if news[indexPath.section].readMore1 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                news[indexPath.section].readMore1 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if news[indexPath.section].readMore2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                cell.delegate = self
                cell.drawCell = false
                
                news[indexPath.section].readMore2 = 0
                estimatedHeightCache[indexPath] = cell.configureCell(record: news[indexPath.section], profiles: newsProfiles, groups: newsGroups, videos: videos, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
                
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isRefresh && tableView.numberOfSections >= count && indexPath.section == tableView.numberOfSections - 1 {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        
        if y >= (h - 20) {
            if viewCount >= offset {
                if sourceIDs == "recommend" {
                    tableView.tableFooterView = nil
                    if !menuView.isShown { menuView.show() }
                } else if !isRefresh {
                    tableView.isScrollEnabled = false
                    refresh()
                }
            } else {
                tableView.tableFooterView = nil
                if !menuView.isShown { menuView.show() }
            }
        }
    }
    
    @IBAction func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            let record = news[index]
            
            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post", scrollToComment: true)
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
                        self.news[index].countLikes += 1
                        self.news[index].userLikes = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? WallRecordCell2 {
                                cell.setLikesButton(record: self.news[index])
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
                        self.news[index].countLikes -= 1
                        self.news[index].userLikes = 0
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            if let cell = self.tableView.cellForRow(at: indexPath!) as? WallRecordCell2 {
                                cell.setLikesButton(record: self.news[index])
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
            let record = news[index]
            
            
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

extension UITableView {
    func scrollToBottom(animated: Bool) {
        OperationQueue.main.addOperation {
            guard self.numberOfSections > 0 else { return }

            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)

            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)

                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }

            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }

            self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}
