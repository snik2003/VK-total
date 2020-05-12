//
//  NewsTableViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import BTNavigationDropdownMenu
import SwiftyJSON

class NewsTableViewController: UITableViewController {
    
    var news = [News]()
    var newsProfiles = [NewsProfiles]()
    var newsGroups = [NewsGroups]()
    
    var filters = "post"
    var sourceIDs = ""
    var startFrom = ""
    let count = 100
    var isRefresh = false
    
    var tapGesture1: UITapGestureRecognizer!
    var tapGesture2: UITapGestureRecognizer!
    
    var selectedMenu = 0
    let itemsMenu = ["Новости", "Друзья", "Сообщества", "Рекомендации", "Фотографии"]
    
    var userID = vkSingleton.shared.userID

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

        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(readMoreClick1(sender:)))
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(readMoreClick2(sender:)))
        
        let menuView = BTNavigationDropdownMenu(title: itemsMenu[0], items: itemsMenu)
        menuView.cellBackgroundColor = UIColor.white
        menuView.cellSelectionColor = UIColor.white
        menuView.cellTextLabelAlignment = .center
        menuView.cellTextLabelColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        menuView.selectedCellTextLabelColor = UIColor.red
        menuView.cellTextLabelFont = UIFont.boldSystemFont(ofSize: 15)
        menuView.navigationBarTitleFont = UIFont.boldSystemFont(ofSize: 17)
        menuView.cellSeparatorColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self?.selectedMenu = indexPath
            switch indexPath {
            case 0:
                self?.filters = "post"
                self?.sourceIDs = ""
                self?.startFrom = ""
                self?.refresh()
                break
            case 1:
                self?.filters = "post"
                self?.sourceIDs = "friends,following"
                self?.startFrom = ""
                self?.refresh()
                break
            case 2:
                self?.filters = "post"
                self?.sourceIDs = "groups,pages"
                self?.startFrom = ""
                self?.refresh()
                break
            case 3:
                self?.filters = "post"
                self?.sourceIDs = "recommend"
                self?.startFrom = ""
                self?.refresh()
                break
            case 4:
                self?.filters = "wall_photo"
                self?.sourceIDs = "friends"
                self?.startFrom = ""
                self?.refresh()
                break
            default:
                break
            }
        }
        
        self.refreshControl?.addTarget(self, action: #selector(NewsTableViewController.refreshButtonClick), for: UIControl.Event.valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)

        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func refreshButtonClick()
    {
        startFrom = ""
        refresh()
    }
    
    func refresh() {
        let opq = OperationQueue()
        var url: String
        var parameters: Parameters
        isRefresh = true
        
        OperationQueue.main.addOperation {
            //self.refreshControl?.beginRefreshing()
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        if startFrom == "" {
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
        let reloadTableController = ReloadNewsfeedController(controller: self)
        reloadTableController.addDependency(parseNewsfeed)
        OperationQueue.main.addOperation(reloadTableController)
    }

    @IBAction func UpdateNewsFeed() {
        startFrom = ""
        self.refresh()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 60
        case 1:
            let summary = news[indexPath.section].text
            let str = summary.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            if str == "" {
                return 0
            }
            return UITableView.automaticDimension
        case 2:
            if news[indexPath.section].repostOwnerID != 0 {
                return 44
            }
            return 0
        case 3:
            let summary = news[indexPath.section].repostText
            let str = summary.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            if str == "" {
                return 0
            }
            return UITableView.automaticDimension
        case 4...13:
            let record = news[indexPath.section]
            
            if record.mediaType[indexPath.row-4] == "photo" ||  record.mediaType[indexPath.row-4] == "link" || record.mediaType[indexPath.row-4] == "doc" {
                
                if record.photoURL[indexPath.row-4] != "" {
                    return UIScreen.main.bounds.width * CGFloat(record.photoHeight[indexPath.row-4]) / CGFloat(record.photoWidth[indexPath.row-4])
                }
            }
            
            if record.mediaType[indexPath.row - 4] == "video" {
                return UIScreen.main.bounds.width * 240.0 / 320.0
            }
            
            return 0
        case 14...23:
            let record = news[indexPath.section]
            if record.mediaType[indexPath.row - 14] == "link" {
                return 60
            }
            return 0
        case 24...33:
            let record = news[indexPath.section]
            if record.mediaType[indexPath.row - 24] == "audio" &&
                record.audioTitle[indexPath.row - 24] != "" {
                return 40
            }
            return 0
        case 34:
            return 40
        default:
            return UITableView.automaticDimension
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

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section < news.count {
            if indexPath.row >= 4 && indexPath.row <= 13 {
                let record = news[indexPath.section]
                let index = indexPath.row - 4
                let photoImage: UIImageView = cell.viewWithTag(1) as! UIImageView
                
                OperationQueue.main.addOperation {
                    photoImage.image = nil
                    
                    if record.mediaType[index] == "doc" {
                        if record.photoText[index] == "gif" {
                            let subviews = photoImage.subviews
                            for subview in subviews {
                                subview.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row >= 4 && indexPath.row <= 13 {
            let photoImage: UIImageView = cell.viewWithTag(1) as! UIImageView
            
            let record = news[indexPath.section]
            let index = indexPath.row - 4
            
            if record.mediaType[index] == "photo" || record.mediaType[index] == "video" || record.mediaType[index] == "link" {
                
                let url = record.photoURL[index]
                let getCacheImage = GetCacheImage(url: url, lifeTime: .newsFeedImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photoImage, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
            } else if record.mediaType[index] == "doc" {
                if record.photoText[index] == "gif" {
                    
                    if record.photoURL[index] != "" {
                        let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .userWallImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photoImage, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        queue.addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                    }
                    
                    /*if record.videoURL[index] != "" {
                        queue.addOperation {
                            let imageURL = UIImage.gifImageWithURL(gifUrl: record.videoURL[index])
                            OperationQueue.main.addOperation {
                                let imageView = UIImageView(image: imageURL)
                                imageView.center = photoImage.center
                                photoImage.image = nil
                                photoImage.addSubview(imageView)
                            }
                        }
                    }*/
                }
            }
        }
        
        if indexPath.row >= 14 && indexPath.row <= 23 {
            let record = news[indexPath.section]
            
            if record.mediaType[indexPath.row - 14] == "link" {
                cell.textLabel?.text = record.linkText[indexPath.row - 14]
                cell.detailTextLabel?.text = record.linkURL[indexPath.row - 14]
            }
        }
        
        if indexPath.row >= 24 && indexPath.row <= 33 {
            let record = news[indexPath.section]
            
            if record.mediaType[indexPath.row - 24] == "audio" {
                cell.textLabel?.text = record.audioArtist[indexPath.row - 24]
                cell.detailTextLabel?.text = record.audioTitle[indexPath.row - 24]
            }
        }
        
        if indexPath.section == tableView.numberOfSections - 1 {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsHeaderCell", for: indexPath)
            
            let record = news[indexPath.section]
            cell.textLabel?.tag = record.sourceID
            
            if record.sourceID > 0 {
                let profile = newsProfiles.filter({ $0.uid == record.sourceID })
                
                if profile.count > 0 {
                    cell.textLabel?.text = "\(profile[0].firstName) \(profile[0].lastName)"
                    
                    let getCacheImage = GetCacheImage(url: profile[0].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        cell.imageView?.layer.cornerRadius = 29
                        cell.imageView?.clipsToBounds = true
                    }
                }
            } else {
                let group = newsGroups.filter({ $0.gid == abs(record.sourceID) })
                
                if group.count > 0 {
                    cell.textLabel?.text = "\(group[0].name)"
                    
                    let getCacheImage = GetCacheImage(url: group[0].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        cell.imageView?.layer.cornerRadius = 29
                        cell.imageView?.clipsToBounds = true
                    }
                }
            }
                
            cell.detailTextLabel?.text = record.date.toStringLastTime()
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsRepostTextCell", for: indexPath)
            
            let record = news[indexPath.section]
            let summary = record.text
            let str = summary.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            cell.textLabel?.lineBreakMode = .byTruncatingTail
            cell.textLabel?.text = str
            if record.readMore1 == 1 {
                if let countLines = cell.textLabel?.numberOfVisibleLines {
                    if countLines > 10 && str.length > 250 {
                        cell.textLabel?.numberOfLines = 10
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.tag = indexPath.section
                        cell.detailTextLabel?.addGestureRecognizer(tapGesture1)
                    }  else if str.length > 250 {
                        cell.textLabel?.numberOfLines = 5
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.tag = indexPath.section
                        cell.detailTextLabel?.addGestureRecognizer(tapGesture1)
                    } else  {
                        cell.textLabel?.numberOfLines = 0
                        cell.detailTextLabel?.isHidden = true
                    }
                }
            } else {
                cell.textLabel?.numberOfLines = 0
                cell.detailTextLabel?.isHidden = true
            }
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsRepostHeaderCell", for: indexPath)
            
            let record = news[indexPath.section]
            cell.textLabel?.tag = record.repostOwnerID
            
            if record.repostOwnerID > 0 {
                let profile = newsProfiles.filter({ $0.uid == record.repostOwnerID })
                
                if profile.count > 0 {
                    cell.textLabel?.text = "\(profile[0].firstName) \(profile[0].lastName)"
                    
                    let getCacheImage = GetCacheImage(url: profile[0].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        cell.imageView?.layer.cornerRadius = 21
                        cell.imageView?.clipsToBounds = true
                    }
                }
            } else {
                let group = newsGroups.filter({ $0.gid == abs(record.repostOwnerID) })
                
                if group.count > 0 {
                    cell.textLabel?.text = "\(group[0].name)"
                    
                    let getCacheImage = GetCacheImage(url: group[0].photoURL, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        cell.imageView?.layer.cornerRadius = 21
                        cell.imageView?.clipsToBounds = true
                    }
                }
            }
            
            cell.detailTextLabel?.text = record.repostDate.toStringLastTime()
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsTextCell", for: indexPath)
            
            let summary = news[indexPath.section].repostText
            let str = summary.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            cell.textLabel?.lineBreakMode = .byTruncatingTail
            cell.textLabel?.text = str
            
            if news[indexPath.section].readMore2 == 1 {
                if let countLines = cell.textLabel?.numberOfVisibleLines {
                    if countLines > 10 && str.length > 250 {
                        cell.textLabel?.numberOfLines = 10
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.tag = indexPath.section
                        cell.detailTextLabel?.addGestureRecognizer(tapGesture2)
                    }  else if str.length > 250 {
                        cell.textLabel?.numberOfLines = 5
                        cell.detailTextLabel?.isHidden = false
                        cell.detailTextLabel?.tag = indexPath.section
                        cell.detailTextLabel?.addGestureRecognizer(tapGesture2)
                    } else  {
                        cell.textLabel?.numberOfLines = 0
                        cell.detailTextLabel?.isHidden = true
                    }
                }
            } else {
                cell.textLabel?.numberOfLines = 0
                cell.detailTextLabel?.isHidden = true
            }
            
            return cell
        case 4...13:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsPhotoCell", for: indexPath)
            
            
            return cell
        case 14...23:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsLinkCell", for: indexPath)
            
            
            return cell
        case 24...33:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsAudioCell", for: indexPath)
            
            
            return cell
        case 34:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsLikesCell", for: indexPath) as! NewsfeedLikesCell
            
            cell.likesButton.isHidden = false
            cell.commentsButton.isHidden = false
            cell.repostsButton.isHidden = false
            
            let record = news[indexPath.section]
            
            cell.likesButton.setTitle("\(record.countLikes)", for: UIControl.State.normal)
            cell.likesButton.setTitle("\(record.countLikes)", for: UIControl.State.selected)
            
            cell.repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.normal)
            cell.repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.selected)
            
            cell.commentsButton.setTitle("\(record.countComments)", for: UIControl.State.normal)
            cell.commentsButton.setTitle("\(record.countComments)", for: UIControl.State.selected)
            
            if record.userLikes == 1 {
                cell.likesButton.setTitleColor(UIColor.purple, for: .normal)
                cell.likesButton.setImage(UIImage(named: "filled-like2")?.tint(tintColor:  UIColor.purple), for: .normal)
            } else {
                cell.likesButton.setTitleColor(UIColor.darkGray, for: .normal)
                cell.likesButton.setImage(UIImage(named: "filled-like2")?.tint(tintColor:  UIColor.darkGray), for: .normal)
            }
            
            if record.canComment == 0 {
                cell.commentsButton.isEnabled = false
            }
            
            if record.canRepost == 0 {
                cell.repostsButton.isEnabled = false
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 2 {
            let cell = tableView.cellForRow(at: indexPath)
            if let uid = cell?.textLabel?.tag {
                if uid > 0 {
                    let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
                
                    profileController.userID = "\(uid)"
                    profileController.title =  cell?.textLabel?.text
            
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
                
                if uid < 0 {
                    let groupProfileController = self.storyboard?.instantiateViewController(withIdentifier: "GroupProfileController") as! GroupProfileController
                    
                    groupProfileController.groupID = abs(uid)
                    if let name = cell?.textLabel?.text {
                        if name.length > 20 {
                            groupProfileController.title =  "\((name).prefix(20))..."
                        } else {
                            groupProfileController.title = name
                        }
                    } else {
                        groupProfileController.title = "Сообщество"
                    }
                    self.navigationController?.pushViewController(groupProfileController, animated: true)
                }
            }
        }
        
        if indexPath.row == 1 || (indexPath.row >= 4 && indexPath.row <= 34) {
            let record = news[indexPath.section]
            
            self.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
        }
        
        if indexPath.row == 3 {
            let record = news[indexPath.section]
            
            if record.repostOwnerID == 0 {
                self.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
            } else {
                self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
            }
        }
    }
    
    @objc func moreReadTapped(sender: UITapGestureRecognizer) {
        if let moreReadLabel: UILabel = sender.view as? UILabel {
            if let cell = self.tableView.dequeueReusableCell(withIdentifier: "newsTextCell") as? NewsTableViewCell {
                if cell.detailTextLabel?.tag == moreReadLabel.tag {
                    cell.textLabel?.numberOfLines = 0
                    cell.detailTextLabel?.isHidden = true
                }
            }
        }
    }
    
    @objc func readMoreClick1(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let readMoreLabel: UILabel = (sender.view as? UILabel)!
            let tapLocation = sender.location(in: self.tableView)
            
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tapCell = self.tableView.cellForRow(at: tapIndexPath) {
                    if tapCell.detailTextLabel?.tag == readMoreLabel.tag {
                        news[tapIndexPath.section].readMore1 = 0
                        tapCell.textLabel?.numberOfLines = 0
                        tapCell.detailTextLabel?.isHidden = true
                        tableView.beginUpdates()
                        tableView.reloadRows(at: [tapIndexPath], with: .automatic)
                        tableView.endUpdates()
                    }
                }
            }
        }
    }

    @objc func readMoreClick2(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let readMoreLabel: UILabel = (sender.view as? UILabel)!
            let tapLocation = sender.location(in: self.tableView)
            
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if let tapCell = self.tableView.cellForRow(at: tapIndexPath) {
                    if tapCell.detailTextLabel?.tag == readMoreLabel.tag {
                        news[tapIndexPath.section].readMore2 = 0
                        tapCell.textLabel?.numberOfLines = 0
                        tapCell.detailTextLabel?.isHidden = true
                        tableView.beginUpdates()
                        tableView.reloadRows(at: [tapIndexPath], with: .automatic)
                        tableView.endUpdates()
                    }
                }
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
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
                            self.tableView.endUpdates()
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
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
                            self.tableView.endUpdates()
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

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}
