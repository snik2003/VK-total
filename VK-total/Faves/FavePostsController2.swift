//
//  FavePostsController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BTNavigationDropdownMenu
import SCLAlertView

class FavePostsController2: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var userID = vkSingleton.shared.userID
    var source = "post"
    
    var selectedMenu = 0
    let itemsMenu = ["Избранные посты", "Избранные фотографии", "Избранные видеозаписи", "Избранные пользователи", "Избранные сообщества", "Избранные ссылки", "Черный список"]
    
    var wall = [Wall]()
    var wallProfiles = [WallProfiles]()
    var wallGroups = [WallGroups]()
    
    var photos = [Photos]()
    var videos = [Videos]()
    var newsProfiles = [NewsProfiles]()
    var newsGroups = [NewsGroups]()
    
    var faveUsers = [NewsProfiles]()
    
    var faveLinks = [FaveLinks]()
    
    var offset = 0
    let count = 100
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        createTableView()
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, title: itemsMenu[0], items: itemsMenu)
        menuView.cellBackgroundColor = .white
        menuView.cellSelectionColor = .white
        menuView.cellTextLabelAlignment = .center
        menuView.cellTextLabelColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        menuView.selectedCellTextLabelColor = .red
        menuView.cellTextLabelFont = UIFont.boldSystemFont(ofSize: 15)
        menuView.navigationBarTitleFont = UIFont.boldSystemFont(ofSize: 17)
        menuView.cellSeparatorColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self?.selectedMenu = indexPath
            switch indexPath {
            case 0:
                self?.source = "post"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 1:
                self?.source = "photo"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 2:
                self?.source = "video"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 3:
                self?.source = "users"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 4:
                self?.source = "groups"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 5:
                self?.source = "links"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            case 6:
                self?.source = "banned"
                self?.offset = 0
                self?.refresh()
                self?.estimatedHeightCache.removeAll(keepingCapacity: false)
                break
            default:
                break
            }
        }
        
        refresh()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(WallRecordCell2.self, forCellReuseIdentifier: "recordCell")
        tableView.register(FavePhotoCell.self, forCellReuseIdentifier: "photoCell")
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(FaveUsersCell.self, forCellReuseIdentifier: "usersCell")
        tableView.register(FaveLinksCell.self, forCellReuseIdentifier: "linksCell")
        
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
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        if offset == 0 {
            wall.removeAll(keepingCapacity: false)
            wallProfiles.removeAll(keepingCapacity: false)
            wallGroups.removeAll(keepingCapacity: false)
            photos.removeAll(keepingCapacity: false)
            videos.removeAll(keepingCapacity: false)
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
        } else if source == "links" || source == "groups" {
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
                "fields": "id, first_name, last_name, photo_100",
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
                "v": vkSingleton.shared.version
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект с данными
        let parseFaves = ParseFaves(type: source)
        parseFaves.addDependency(getServerDataOperation)
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
        case "photo":
            return 1
        case "video":
            return videos.count
        case "users":
            return faveUsers.count
        case "groups":
            return faveLinks.count
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
                
                let height = cell.getRowHeight(record: wall[indexPath.section])
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "photo" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let photo = photos[indexPath.section]
                
                let height = self.tableView.bounds.width * CGFloat(photo.height) / CGFloat(photo.width)
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
        } else if source == "users" || source == "banned" {
            return 50
        } else if source == "links" || source == "groups" {
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
                
                let height = cell.getRowHeight(record: wall[indexPath.section])
                estimatedHeightCache[indexPath] = height
                return height
            }
        } else if source == "photo" {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let photo = photos[indexPath.section]
                
                let height = self.tableView.bounds.width * CGFloat(photo.height) / CGFloat(photo.width)
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
        } else if source == "users" || source == "banned" {
            return 50
        } else if source == "links" || source == "groups" {
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
            return 15
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
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
        
        switch source {
        case "post":
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! WallRecordCell2
            
            cell.configureCell(record: wall[indexPath.section], profiles: wallProfiles, groups: wallGroups, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
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
            
            return cell
        case "photo":
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! FavePhotoCell
            
            cell.configureCell(photo: photos[indexPath.section], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            
            return cell
        case "video":
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoListCell
            
            cell.delegate = self
            
            cell.configureCell(video: videos[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.leftInsets, bottom: 0, right: cell.leftInsets)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            
            return cell
        case "users":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! FaveUsersCell
            
            cell.configureCell(user: faveUsers[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case "groups":
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath) as! FaveLinksCell
            
            cell.configureCell(link: faveLinks[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case "links":
            let cell = tableView.dequeueReusableCell(withIdentifier: "linksCell", for: indexPath) as! FaveLinksCell
            
            cell.configureCell(link: faveLinks[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case "banned":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! FaveUsersCell
            
            cell.configureCell(user: faveUsers[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch source {
        case "post":
            if let cell = tableView.cellForRow(at: indexPath) as? WallRecordCell2 {
            
                let record = wall[indexPath.section]
                
                let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                
                if action == "show_record" {
                    
                    self.openWallRecord(ownerID: record.fromID, postID: record.id, accessKey: "", type: "post")
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
            
            self.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
            
        case "users":
            let user = faveUsers[indexPath.row]
            self.openProfileController(id: user.uid, name: "\(user.firstName) \(user.lastName)")
        
        case "groups":
            let link = faveLinks[indexPath.row]
            self.openBrowserController(url: link.url)
            
        case "links":
            let link = faveLinks[indexPath.row]
            self.openBrowserController(url: link.url)
            
            /*let arr = group.id.components(separatedBy: "_")
            if arr.count > 2 {
                if arr[0] == "2", let id = Int("-\(arr[2])") {
                    
                    self.openProfileController(id: id, name: "\(group.title)")
                }
            }*/
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
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 32.0,
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                kTextFont: UIFont(name: "Verdana", size: 13)!,
                kButtonFont: UIFont(name: "Verdana", size: 14)!,
                showCloseButton: false,
                showCircularIcon: true
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
            
            self.openWallRecord(ownerID: record.fromID, postID: record.id, accessKey: "", type: "post")
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
                wall[indexPath.section].readMore1 = 0
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: wall[indexPath.section])
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
    
    @objc func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            if wall[indexPath.section].readMore2 == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! WallRecordCell2
                wall[indexPath.section].readMore2 = 0
                estimatedHeightCache[indexPath] = cell.getRowHeight(record: wall[indexPath.section])
                
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
    }
}
