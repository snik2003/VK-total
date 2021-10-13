//
//  VideoListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import MobileCoreServices

class VideoListController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

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
    
    var isGroup = false
    
    var markPhotos: [Int:UIImage] = [:]
    var selectButton: UIBarButtonItem!
    
    var rowHeightCache: [IndexPath: CGFloat] = [:]
    
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
    
    let pickerController = UIImagePickerController()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.pickerController.delegate = self
            self.pickerController.allowsEditing = false
            
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            self.searchBar.showsCancelButton = false
            self.searchBar.backgroundColor = vkSingleton.shared.backColor
            
            if self.ownerID == vkSingleton.shared.userID && self.type == "" && self.source == "" {
                let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
            } else if let groupID = Int(self.ownerID), vkSingleton.shared.adminGroupID.contains(abs(groupID)), self.type.isEmpty, self.source.isEmpty {
                self.isGroup = true
                let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItemForGroup(sender:)))
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
    
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: 54))
        searchBar.tintColor = vkSingleton.shared.labelColor
        
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = vkSingleton.shared.separatorColor
            searchField.textColor = vkSingleton.shared.labelColor
        } else {
            searchBar.changeKeyboardAppearanceMode()
            if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchField.backgroundColor = vkSingleton.shared.separatorColor
                searchField.textColor = vkSingleton.shared.labelColor
                searchField.changeKeyboardAppearanceMode()
            } else if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.backgroundColor = vkSingleton.shared.separatorColor
                searchField.textColor = vkSingleton.shared.labelColor
                searchField.changeKeyboardAppearanceMode()
            }
        }
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.backgroundColor = vkSingleton.shared.backColor
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
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
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
                            let attachment = "video\(video.ownerID)_\(video.id)_\(video.accessKey)"
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
                self.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись", scrollToComment: false)
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
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action0 = UIAlertAction(title: "Записать новое видео", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.pickerController.sourceType = .camera
                self.pickerController.mediaTypes =  [kUTTypeMovie as String]
                self.pickerController.cameraCaptureMode = .video
                self.pickerController.modalPresentationStyle = .fullScreen
                self.pickerController.videoQuality = .typeMedium
                
                self.present(self.pickerController, animated: true)
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "Камера на устройстве не активна.")
            }
        }
        alertController.addAction(action0)
        
        
        let action1 = UIAlertAction(title: "Загрузить видео с устройства", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            self.pickerController.sourceType = .photoLibrary
            self.pickerController.mediaTypes =  [kUTTypeMovie as String]
        
            self.present(self.pickerController, animated: true)
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Загрузить видео по ссылке", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            self.getUploadVideoURL(isLink: true, groupID: 0, isPrivate: 0, wallpost: 0, completion: { uploadURL, attachString in
                if !uploadURL.isEmpty {
                    self.myVideoUploadLinkRequest(url: uploadURL, completion: { result in
                        ViewControllerUtils().hideActivityIndicator()
                        if result == 1 {
                            OperationQueue.main.addOperation {
                                self.showSuccessMessage(title: "Видео успешно загружено!", msg: "После загрузки видеозапись проходит обработку и в списке видеозаписей может появиться спустя некоторое время.")
                            }
                        }
                    })
                }
            })
        }
        alertController.addAction(action2)
        
        
        let action3 = UIAlertAction(title: "Поиск новых видеозаписей", style: .destructive) { action in
            
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            self.openVideoListController(ownerID: self.ownerID, title: "Поиск", type: "search")
        }
        alertController.addAction(action3)
        
        
        self.present(alertController, animated: true)
    }
    
    @objc func tapBarButtonItemForGroup(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action0 = UIAlertAction(title: "Записать новое видео", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.pickerController.sourceType = .camera
                self.pickerController.mediaTypes =  [kUTTypeMovie as String]
                self.pickerController.cameraCaptureMode = .video
                self.pickerController.modalPresentationStyle = .fullScreen
                self.pickerController.videoQuality = .typeMedium
                
                self.present(self.pickerController, animated: true)
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "Камера на устройстве не активна.")
            }
        }
        alertController.addAction(action0)
        
        
        let action1 = UIAlertAction(title: "Загрузить видео с устройства", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            self.pickerController.sourceType = .photoLibrary
            self.pickerController.mediaTypes =  [kUTTypeMovie as String]
        
            self.present(self.pickerController, animated: true)
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Загрузить видео по ссылке", style: .default) { action in
                
            self.playSoundEffect(vkSingleton.shared.buttonSound)
            self.getUploadVideoURL(isLink: true, groupID: Int(self.ownerID)!, isPrivate: 0, wallpost: 0, completion: { uploadURL, attachString in
                if !uploadURL.isEmpty {
                    self.myVideoUploadLinkRequest(url: uploadURL, completion: { result in
                        ViewControllerUtils().hideActivityIndicator()
                        if result == 1 {
                            OperationQueue.main.addOperation {
                                self.showSuccessMessage(title: "Видео успешно загружено!", msg: "После загрузки видеозапись проходит обработку и в списке видеозаписей может появиться спустя некоторое время.")
                            }
                        }
                    })
                }
            })
        }
        alertController.addAction(action2)
        
        
        self.present(alertController, animated: true)
    }
}

extension VideoListController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            if isGroup {
                self.getUploadVideoURL(isLink: false, groupID: Int(ownerID)!, isPrivate: 0, wallpost: 0, completion: { uploadURL, attachString in
                    if !uploadURL.isEmpty {
                        print("uploadURL = \(uploadURL)")
                        print("attachment = \(attachString)")
                        
                        do {
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                            }
                            
                            let videoData = try Data(contentsOf: videoURL, options: .mappedIfSafe)
                            
                            self.myVideoUploadRequest(url: uploadURL, videoData: videoData, filename: "video_file", completion: { attachment, hash, size in
                                ViewControllerUtils().hideActivityIndicator()
                                if !hash.isEmpty && size > 0 && attachString == attachment {
                                    OperationQueue.main.addOperation {
                                        self.showSuccessMessage(title: "Видео успешно загружено!", msg: "После загрузки видеозапись проходит обработку и в списке видеозаписей может появиться спустя некоторое время.")
                                    }
                                }
                            })
                        } catch {
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().hideActivityIndicator()
                            }
                            
                            return
                        }
                    }
                })
            } else {
                self.getUploadVideoURL(isLink: false, groupID: 0, isPrivate: 0, wallpost: 0, completion: { uploadURL, attachString in
                    if !uploadURL.isEmpty {
                        do {
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().showActivityIndicator(uiView: self.view)
                            }
                            
                            let videoData = try Data(contentsOf: videoURL, options: .mappedIfSafe)
                            
                            self.myVideoUploadRequest(url: uploadURL, videoData: videoData, filename: "video_file", completion: { attachment, hash, size in
                                ViewControllerUtils().hideActivityIndicator()
                                if !hash.isEmpty && size > 0 && attachString == attachment {
                                    OperationQueue.main.addOperation {
                                        self.showSuccessMessage(title: "Видео успешно загружено!", msg: "После загрузки видеозапись проходит обработку и в списке видеозаписей может появиться спустя некоторое время.")
                                    }
                                }
                            })
                        } catch {
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().hideActivityIndicator()
                            }
                            return
                        }
                    }
                })
            }
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
}
