//
//  VideoListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class VideoListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    var delegate: UIViewController!
    
    let heightRow: CGFloat = (UIScreen.main.bounds.width * 0.5) * CGFloat(240) / CGFloat(320)
    
    var videos: [Videos] = []
    var searchVideos: [Videos] = []
    var requestVideos: [Videos] = []
    
    var ownerID = ""
    var offset = 0
    var count = 100
    var isRefresh = false
    var isSearch = false
    var type = ""
    var source = ""
    
    var markPhotos: [Int:UIImage] = [:]
    var selectButton: UIBarButtonItem!
    
    var rowHeightCache: [IndexPath: CGFloat] = [:]
    
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
            
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            if self.ownerID == vkSingleton.shared.userID && self.type == "" && self.source == "" {
                let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
            }
            
            if self.source != "" {
                self.selectButton = UIBarButtonItem(title: "Вложить", style: .done, target: self, action: #selector(self.tapSelectButton(sender:)))
                self.navigationItem.rightBarButtonItem = self.selectButton
                self.selectButton.isEnabled = false
            }
            
            self.tableView.separatorStyle = .none
            if self.type != "search" {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
        }
        
        if type != "search" {
            refresh()
        }
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: 54))
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabHeight - searchBar.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "videoCell")
        
        self.view.addSubview(tableView)
    }
    
    func refresh() {
        isRefresh = true
        
        
        let url = "/method/video.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        queue.addOperation(getServerDataOperation)
        
        let parseVideos = ParseVideos()
        parseVideos.addDependency(getServerDataOperation)
        queue.addOperation(parseVideos)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadVideoListController(controller: self)
        reloadTableController.addDependency(parseVideos)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func refreshSearch() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        isRefresh = true
        let text = searchBar.text!
        let opq = OperationQueue()
        
        let url = "/method/video.search"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "q": text,
            "sort": "0",
            "filters": "youtube",
            "offset": "0",
            "count": "\(count)",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseVideos = ParseVideos()
        parseVideos.addDependency(getServerDataOperation)
        queue.addOperation(parseVideos)
        
        self.setOfflineStatus(dependence: getServerDataOperation)
        
        let reloadTableController = ReloadVideoListController(controller: self)
        reloadTableController.addDependency(parseVideos)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoListCell
        
        cell.delegate = self
        
        cell.configureCell(video: videos[indexPath.row], indexPath: indexPath, cell: cell, tableView: tableView)
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.leftInsets, bottom: 0, right: cell.leftInsets)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && indexPath.row == offset - 1 {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false && type != "search" {
            refresh()
        }
    }
    
    @objc func tapSelectButton(sender: UIBarButtonItem) {
        if source == "add_video", let vc = delegate as? NewRecordController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for video in self.videos {
                    if let videoImage = markPhotos[video.id] {
                        let attachment = "video\(video.ownerID)_\(video.id)"
                        vc.attach.append(attachment)
                        vc.isLoad.append(false)
                        vc.typeOf.append("video")
                        vc.photos.append(videoImage)
                    }
                    
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
        
        if source == "add_comment_video", let vc = delegate as? NewCommentController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for video in self.videos {
                    if let videoImage = markPhotos[video.id] {
                        let attachment = "video\(video.ownerID)_\(video.id)"
                        vc.attach.append(attachment)
                        vc.isLoad.append(false)
                        vc.typeOf.append("video")
                        vc.photos.append(videoImage)
                    }
                    
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
        
        if source == "add_topic_video", let vc = delegate as? AddTopicController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for video in self.videos {
                    if let videoImage = markPhotos[video.id] {
                        let attachment = "video\(video.ownerID)_\(video.id)"
                        vc.attach.append(attachment)
                        vc.isLoad.append(false)
                        vc.typeOf.append("video")
                        vc.photos.append(videoImage)
                    }
                    
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
        if source == "add_message_video" {
            if let vc = delegate as? DialogController {
                if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                    for video in self.videos {
                        if let videoImage = markPhotos[video.id] {
                            let attachment = "video\(video.ownerID)_\(video.id)"
                            vc.attach.append(attachment)
                            vc.isLoad.append(false)
                            vc.typeOf.append("video")
                            vc.photos.append(videoImage)
                        }
                        
                    }
                    vc.setAttachments()
                    vc.configureStartView()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
                }
            }
            
            if let vc = delegate as? GroupDialogController {
                if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                    for video in self.videos {
                        if let videoImage = markPhotos[video.id] {
                            let attachment = "video\(video.ownerID)_\(video.id)"
                            vc.attach.append(attachment)
                            vc.isLoad.append(false)
                            vc.typeOf.append("video")
                            vc.photos.append(videoImage)
                        }
                        
                    }
                    vc.setAttachments()
                    vc.configureStartView()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? VideoListCell {
            let video = videos[indexPath.row]
            
            if source != "" {
                if markPhotos[video.id] != nil {
                    markPhotos[video.id] = nil
                } else {
                    markPhotos[video.id] = cell.videoImage.image!
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                
                if markPhotos.count > 0 {
                    selectButton.isEnabled = true
                    selectButton.title = "Вложить (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Вложить"
                }
            } else {
                self.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        isSearch = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if type != "search" {
            searchVideos = requestVideos.filter({ "\($0.title) \($0.description)".containsIgnoringCase(find: searchText) })
            
            if searchVideos.count == 0 {
                videos = requestVideos
                isSearch = false
            } else {
                videos = searchVideos
                isSearch = true
            }
            
            self.tableView.reloadData()
        } else {
            refreshSearch()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        playSoundEffect(vkSingleton.shared.buttonSound)
        self.openVideoListController(ownerID: ownerID, title: "Поиск", type: "search")
    }
}
