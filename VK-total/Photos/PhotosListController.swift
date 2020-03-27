//
//  PhotosListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import CMPhotoCropEditor

class PhotosListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: UIViewController!
    
    var ownerID = ""
    var offset = 0
    var count = 200
    var photosCount = 0
    var isRefresh = false
    var source = ""
    
    var photos: [Photos] = []
    var albums: [PhotoAlbum] = []

    var selectIndex = 0
    
    var heightRow: CGFloat = (UIScreen.main.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
    
    var markPhotos: [Int:UIImage] = [:]
    var selectButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
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
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
        }
        
        getPhotos()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
        tableView.register(PhotoAlbumsListCell.self, forCellReuseIdentifier: "albumCell")
        tableView.frame = CGRect(x: 0, y: segmentedControl.frame.maxY + 10.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - segmentedControl.bounds.height - 20 - 64)
        
        self.view.addSubview(tableView)
    }
    
    func getPhotos() {
        isRefresh = true
        
        let opq = OperationQueue()
        
        let url = "/method/photos.getAll"
        let parameters = [
            "owner_id": ownerID,
            "access_token": vkSingleton.shared.accessToken,
            "extended": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "photo_sizes": "0",
            "skip_hidden": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parsePhotos = ParsePhotosList()
        parsePhotos.addDependency(getServerDataOperation)
        opq.addOperation(parsePhotos)
        
        let url2 = "/method/photos.getAlbums"
        let parameters2 = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "need_system": "1",
            "need_covers": "1",
            "photo_sizes": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        let parsePhotoAlbums = ParsePhotoAlbums()
        parsePhotoAlbums.addDependency(getServerDataOperation2)
        opq.addOperation(parsePhotoAlbums)
        
        let reloadTableController = ReloadPhotosListController(controller: self)
        reloadTableController.addDependency(parsePhotos)
        reloadTableController.addDependency(parsePhotoAlbums)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        switch sender.selectedSegmentIndex {
        case 0:
            selectIndex = 0
            tableView.separatorStyle = .none
            heightRow = (UIScreen.main.bounds.width * 0.333) * CGFloat(240) /
                CGFloat(320)
        case 1:
            selectIndex = 1
            tableView.separatorStyle = .none
            heightRow = (UIScreen.main.bounds.width * 0.5) * CGFloat(240) / CGFloat(320) + 30
        default:
            break
        }
        
        self.tableView.estimatedRowHeight = heightRow
        self.tableView.rowHeight = heightRow
        self.tableView.reloadData()
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectIndex == 1 {
            return albums.count / 2 + albums.count % 2
        }
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
        
        if selectIndex == 0 {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! PhotoAlbumsListCell
            
            cell.configureCell(albums: albums, indexPath: indexPath)
            cell.selectionStyle = .none
            
            if cell.tap1 != nil {
                cell.tap1.addTarget(self, action: #selector(self.tapAlbum1(sender:)))
            }
            
            if cell.tap2 != nil {
                cell.tap2.addTarget(self, action: #selector(self.tapAlbum2(sender:)))
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if indexPath.row == tableView.numberOfRows(inSection: 0)-1 && offset < photosCount {
                
                isRefresh = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            if isRefresh == false {
                getPhotos()
            }
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
            } else {
                self.showInfoMessage(title: "Внимание!", msg: "Вы превысили максимальное количество вложений: \(vc.maxCountAttach)")
            }
        }
    }
    
    @objc func tapPhoto1(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position), let cell = tableView.cellForRow(at: indexPath) as? PhotosListCell {
            
            if source == "change_avatar" {
                let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
                
                self.navigationController?.popViewController(animated: true)
                
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
                let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
                
                self.navigationController?.popViewController(animated: true)
                
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
                let cell = tableView.cellForRow(at: indexPath) as! PhotosListCell
            
                self.navigationController?.popViewController(animated: true)
            
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
    
    @objc func tapAlbum1(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            self.openPhotoAlbumController(ownerID: "\(albums[2 * indexPath.row].ownerID)", albumID: "\(albums[2 * indexPath.row].id)", title: albums[2 * indexPath.row].title, controller: self)
        }
    }
    
    @objc func tapAlbum2(sender: UITapGestureRecognizer) {
        let position: CGPoint = sender.location(in: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            self.openPhotoAlbumController(ownerID: "\(albums[2 * indexPath.row + 1].ownerID)", albumID: "\(albums[2 * indexPath.row + 1].id)", title: albums[2 * indexPath.row + 1].title, controller: self)
        }
    }
}
