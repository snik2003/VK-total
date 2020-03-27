//
//  PhotoAlbumController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import CMPhotoCropEditor

class PhotoAlbumController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: UIViewController!
    var source = ""
    
    var ownerID = ""
    var albumID = ""
    var offset = 0
    var count = 1000
    var photosCount = 0
    var isRefresh = false
    
    var photos: [Photos] = []
    
    var heightRow: CGFloat = (UIScreen.main.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
    
    var markPhotos: [Int:UIImage] = [:]
    var selectButton: UIBarButtonItem!
    
    var tableView = UITableView()
    
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
        
        OperationQueue.main.addOperation {
            self.configureTableView()
            
            if self.source != "" && self.source != "change_avatar" {
                self.selectButton = UIBarButtonItem(title: "Вложить", style: .done, target: self, action: #selector(self.tapSelectButton(sender:)))
                self.navigationItem.rightBarButtonItem = self.selectButton
                self.selectButton.isEnabled = false
            }
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getPhotos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
        
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        
        self.view.addSubview(tableView)
    }
    
    func getPhotos() {
        isRefresh = true
        let opq = OperationQueue()
        
        let url = "/method/photos.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "album_id": albumID,
            "rev": "1",
            "extended": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "photo_sizes": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parsePhotos = ParsePhotosList()
        parsePhotos.addDependency(getServerDataOperation)
        opq.addOperation(parsePhotos)
        
        let reloadTableController = ReloadPhotoAlbumController(controller: self)
        reloadTableController.addDependency(parsePhotos)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return photos.count / 3 + photos.count % 3
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotosListCell
        
        cell.delegate = self
        cell.configureCell(photos: photos, indexPath: indexPath)
        cell.selectionStyle = .none
        
        if cell.tap1 != nil {
            cell.tap1.addTarget(self, action: #selector(self.tapPhoto1(sender:)))
        }
        
        if cell.tap2 != nil {
            cell.tap2.addTarget(self, action: #selector(self.tapPhoto2(sender:)))
        }
        
        if cell.tap3 != nil {
            cell.tap3.addTarget(self, action: #selector(self.tapPhoto3(sender:)))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableView.numberOfRows(inSection: 0)-1 && offset < photosCount {
                
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            getPhotos()
        }
    }
    
    @objc func tapSelectButton(sender: UIBarButtonItem) {
        if source == "add_message_photo" {
            if let vc = delegate as? DialogController {
                if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                    for photo in self.photos {
                        if let id = Int(photo.pid) {
                            if let photoImage = markPhotos[id] {
                                let attachment = "photo\(photo.uid)_\(photo.pid)"
                                vc.attach.append(attachment)
                                vc.isLoad.append(false)
                                vc.typeOf.append("photo")
                                vc.photos.append(photoImage)
                            }
                        }
                    }
                    vc.setAttachments()
                    vc.configureStartView()
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
                }
            }
            
            if let vc = delegate as? GroupDialogController {
                if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                    for photo in self.photos {
                        if let id = Int(photo.pid) {
                            if let photoImage = markPhotos[id] {
                                let attachment = "photo\(photo.uid)_\(photo.pid)"
                                vc.attach.append(attachment)
                                vc.isLoad.append(false)
                                vc.typeOf.append("photo")
                                vc.photos.append(photoImage)
                            }
                        }
                    }
                    vc.setAttachments()
                    vc.configureStartView()
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
                }
            }
        }
        
        if source == "add_photo", let vc = delegate as? NewRecordController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for photo in self.photos {
                    if let id = Int(photo.pid) {
                        if let photoImage = markPhotos[id] {
                            let attachment = "photo\(photo.uid)_\(photo.pid)"
                            vc.attach.append(attachment)
                            vc.isLoad.append(false)
                            vc.typeOf.append("photo")
                            vc.photos.append(photoImage)
                        }
                    }
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: false)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
        
        if source == "add_comment_photo", let vc = delegate as? NewCommentController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for photo in self.photos {
                    if let id = Int(photo.pid) {
                        if let photoImage = markPhotos[id] {
                            let attachment = "photo\(photo.uid)_\(photo.pid)"
                            vc.attach.append(attachment)
                            vc.isLoad.append(false)
                            vc.typeOf.append("photo")
                            vc.photos.append(photoImage)
                        }
                    }
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: false)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
        
        if source == "add_topic_photo", let vc = delegate as? AddTopicController {
            if vc.attach.count + markPhotos.count <= vc.maxCountAttach {
                for photo in self.photos {
                    if let id = Int(photo.pid) {
                        if let photoImage = markPhotos[id] {
                            let attachment = "photo\(photo.uid)_\(photo.pid)"
                            vc.attach.append(attachment)
                            vc.isLoad.append(false)
                            vc.typeOf.append("photo")
                            vc.photos.append(photoImage)
                        }
                    }
                }
                vc.setAttachments()
                vc.startConfigureView()
                vc.collectionView.reloadData()
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.popViewController(animated: false)
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
    }
    
    @objc func tapPhoto1(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position), let cell = tableView.cellForRow(at: indexPath) as? PhotosListCell {
            
            if source == "change_avatar" {
                if self.albumID == "-6" {
                    let photo = photos[3 * indexPath.row]
                    self.changeAvatar(newID: photo.pid, oldID: photos[0].pid)
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                    
                    if let vc = self.delegate as? UserInfoTableViewController {
                        let controller = PECropViewController()
                        controller.delegate = vc
                        controller.image = cell.photoView[0]!.image!
                        controller.keepingCropAspectRatio = true
                        controller.cropAspectRatio = 1.0
                        controller.toolbarHidden = true
                        controller.isRotationEnabled = false
                        
                        vc.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else if source == "" {
                self.openPhotoViewController(numPhoto: 3 * indexPath.row, photos: photos)
            } else {
                let photo = photos[3 * indexPath.row]
                
                if let id = Int(photo.pid) {
                    if markPhotos[id] != nil {
                        markPhotos[id] = nil
                    } else {
                        markPhotos[id] = cell.photoView[0]?.image!
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                if markPhotos.count > 0 {
                    selectButton.isEnabled = true
                    selectButton.title = "Вложить (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Вложить"
                }
            }
        }
    }
    
    @objc func tapPhoto2(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position), let cell = tableView.cellForRow(at: indexPath) as? PhotosListCell {
            
            if source == "change_avatar" {
                if self.albumID == "-6" {
                    let photo = photos[3 * indexPath.row + 1]
                    self.changeAvatar(newID: photo.pid, oldID: photos[0].pid)
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                    
                    if let vc = self.delegate as? UserInfoTableViewController {
                        let controller = PECropViewController()
                        controller.delegate = vc
                        controller.image = cell.photoView[1]!.image!
                        controller.keepingCropAspectRatio = true
                        controller.cropAspectRatio = 1.0
                        controller.toolbarHidden = true
                        controller.isRotationEnabled = false
                        
                        vc.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else if source == "" {
                self.openPhotoViewController(numPhoto: 3 * indexPath.row + 1, photos: photos)
            } else {
                let photo = photos[3 * indexPath.row + 1]
                
                if let id = Int(photo.pid) {
                    if markPhotos[id] != nil {
                        markPhotos[id] = nil
                    } else {
                        markPhotos[id] = cell.photoView[1]?.image!
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                if markPhotos.count > 0 {
                    selectButton.isEnabled = true
                    selectButton.title = "Вложить (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Вложить"
                }
            }
        }
    }
    
    @objc func tapPhoto3(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position), let cell = tableView.cellForRow(at: indexPath) as? PhotosListCell {
            
            if source == "change_avatar" {
                if self.albumID == "-6" {
                    let photo = photos[3 * indexPath.row + 2]
                    self.changeAvatar(newID: photo.pid, oldID: photos[0].pid)
                    
                    self.navigationController?.popViewController(animated: true)
                    self.navigationController?.popViewController(animated: false)
                } else {
                    let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
                    
                    if let vc = self.delegate as? UserInfoTableViewController {
                        let controller = PECropViewController()
                        controller.delegate = vc
                        controller.image = cell.photoView[2]!.image!
                        controller.keepingCropAspectRatio = true
                        controller.cropAspectRatio = 1.0
                        controller.toolbarHidden = true
                        controller.isRotationEnabled = false
                        
                        vc.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else if source == "" {
                self.openPhotoViewController(numPhoto: 3 * indexPath.row + 2, photos: photos)
            } else {
                let photo = photos[3 * indexPath.row + 2]
                
                if let id = Int(photo.pid) {
                    if markPhotos[id] != nil {
                        markPhotos[id] = nil
                    } else {
                        markPhotos[id] = cell.photoView[2]?.image!
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                if markPhotos.count > 0 {
                    selectButton.isEnabled = true
                    selectButton.title = "Вложить (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Вложить"
                }
            }
        }
    }
}

