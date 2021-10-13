//
//  PhotoAlbumController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Photos
import Popover
import DropDown
import SwiftyJSON
import SCLAlertView
import CMPhotoCropEditor

class PhotoAlbumController: InnerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let maxCountUpload = 10
    var uploadPhotos: [Int:UIImage] = [:]
    
    var delegate: UIViewController!
    var source = ""
    
    var ownerID = ""
    var albumID = ""
    
    var album: PhotoAlbum!
    var albums: [PhotoAlbum] = []
    
    let downDrop = DropDown()
    
    var offset = 0
    var count = 1000
    var photosCount = 0
    var isRefresh = false
    
    var photos: [Photos] = []
    
    var heightRow: CGFloat = (UIScreen.main.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
    
    var markPhotos: [Int:UIImage] = [:]
    var selectButton: UIBarButtonItem!
    
    var tableView = UITableView()
    
    let pickerController = UIImagePickerController()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
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
    
    var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.delegate = self
        
        if self.source == "move_photo_in_album" {
            self.selectButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(self.tapSelectButton(sender:)))
            self.navigationItem.rightBarButtonItem = self.selectButton
            self.selectButton.isEnabled = false
        } else if self.source != "" && self.source != "change_avatar" {
            self.selectButton = UIBarButtonItem(title: "Вложить", style: .done, target: self, action: #selector(self.tapSelectButton(sender:)))
            self.navigationItem.rightBarButtonItem = self.selectButton
            self.selectButton.isEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
            
            configureTableView()
            
            if self.source == "" {
                if let aView = self.tableView.superview {
                    ViewControllerUtils().showActivityIndicator(uiView: aView)
                } else {
                    ViewControllerUtils().showActivityIndicator(uiView: self.view)
                }
                
                let url = "/method/photos.getAlbums"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": ownerID,
                    "need_covers": "1",
                    "photo_sizes": "0",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else {
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    guard let json = try? JSON(data: data) else {
                        print("json error")
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    //print(json)
                    
                    self.albums = json["response"]["items"].map({ PhotoAlbum(json: $0.1) }).filter({ $0.id > 0 })
                    
                    if let albumID = Int(self.albumID), self.albums.count > 0 {
                        self.album = self.albums.filter({ $0.id == albumID }).first
                    }
                    
                    OperationQueue.main.addOperation {
                        if let album = self.album {
                            self.title = album.title
                            
                            let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                            self.navigationItem.rightBarButtonItem = barButton
                        }
                        
                        self.getPhotos()
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            } else {
                if let aView = self.tableView.superview {
                    ViewControllerUtils().showActivityIndicator(uiView: aView)
                } else {
                    ViewControllerUtils().showActivityIndicator(uiView: self.view)
                }
                
                getPhotos()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
    
        if let album = self.album {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if !album.descriptionText.isEmpty {
                let action = UIAlertAction(title: "Описание альбома", style: .default) { action in
                    
                    self.showDescriptionView()
                }
                alertController.addAction(action)
            }
            
            if !album.isAdmin && album.canUpload == 1 {
                let action = UIAlertAction(title: "Загрузить фото в альбом", style: .default) { action in
                    
                    self.uploadPhotoMenu()
                }
                alertController.addAction(action)
            }
            
            if album.isAdmin {
                let action3 = UIAlertAction(title: "Редактировать альбом", style: .default) { action in
                    let albumVC = AlbumSettingsController()
                    albumVC.delegate = self
                    albumVC.mode = .edit
                    albumVC.ownerID = self.ownerID
                    albumVC.album = album
                    self.navigationController?.pushViewController(albumVC, animated: true)
                }
                alertController.addAction(action3)
                
                let action1 = UIAlertAction(title: "Загрузить фото в альбом", style: .default) { action in
                    
                    self.uploadPhotoMenu()
                }
                alertController.addAction(action1)
                
                if self.albums.count > 1 {
                    let action2 = UIAlertAction(title: "Изменить порядок альбома", style: .default) { action in
                        self.reorderAlbum()
                    }
                    alertController.addAction(action2)
                }
            }
            
            let action4 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                    
                let link = "https://vk.com/album\(album.ownerID)_\(album.id)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на альбом:" , msg: "\(string)")
                }
            }
            alertController.addAction(action4)
        
            let action5 = UIAlertAction(title: "Добавить ссылку в «Избранное»", style: .default) { action in
                
                let link = "https://vk.com/album\(album.ownerID)_\(album.id)"
                self.addLinkToFave(link: link, text: "Альбом")
            }
            alertController.addAction(action5)
                
            if album.isAdmin {
                let action4 = UIAlertAction(title: "Удалить альбом", style: .destructive) { action in
                    let titleColor = vkSingleton.shared.labelColor
                    let backColor = vkSingleton.shared.backColor
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleTop: 32.0,
                        kWindowWidth: UIScreen.main.bounds.width - 40,
                        kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                        kTextFont: UIFont(name: "Verdana", size: 13)!,
                        kButtonFont: UIFont(name: "Verdana", size: 14)!,
                        showCloseButton: false,
                        showCircularIcon: true,
                        circleBackgroundColor: backColor,
                        contentViewColor: backColor,
                        titleColor: titleColor
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    
                    alertView.addButton("Да, я уверен") {
                        self.deleteAlbum()
                    }
                    
                    alertView.addButton("Отмена, я передумал") {}
                    
                    alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить альбом «\(self.album.title)»? Это действие необратимо.")
                }
                alertController.addAction(action4)
            }
            
            self.present(alertController, animated: true)
        }
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
        tableView.backgroundColor = vkSingleton.shared.backColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
        tableView.separatorStyle = .none
        
        self.view.addSubview(tableView)
    }
    
    func showDescriptionView() {
        
        if let album = self.album {
            let text = album.descriptionText.prepareTextForPublic()
            let dFont = UIFont(name: "Verdana", size: 12)!
            
            let maxWidth = UIScreen.main.bounds.width - 4 * 10
            let maxHeight = UIScreen.main.bounds.height - navHeight - tabHeight - 20
            let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            
            let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: dFont], context: nil)
            
            let width = maxWidth + 20
            var height = rect.size.height + 40
            if height > maxHeight {
                height = maxHeight
            }

            let descView = UIView(frame: CGRect(x: 0, y: 0, width: width - 20, height: height))
            descView.backgroundColor = vkSingleton.shared.backColor
            
            let textView = UILabel(frame: CGRect(x: 10, y: 10, width: width - 40, height: height - 20))
            textView.text = album.descriptionText
            textView.textColor = vkSingleton.shared.labelColor
            
            textView.prepareTextForPublish2(self)
            textView.backgroundColor = .clear
            textView.font = dFont
            textView.textAlignment = .center
            textView.numberOfLines = 0
            descView.addSubview(textView)
            
            let startPoint = CGPoint(x: UIScreen.main.bounds.width - 30, y: 70)
            
            self.popover = Popover(options: self.popoverOptions)
            self.popover.show(descView, point: startPoint)
        }
    }
        
    func uploadPhotosFromProfile() {
        
        if let ownerID = Int(self.ownerID), let albumID = Int(self.albumID) {
            
            if let aView = self.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            } else {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
            
            if ownerID > 0 {
                var code = ""
                var index = 0
                for key in uploadPhotos.keys {
                    code = "\(code)var req\(index) =  API.photos.move({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\(ownerID),\"target_album_id\":\(albumID),\"photo_id\":\(key),\"v\":\"\(vkSingleton.shared.version)\"});\n "
                    
                    index += 1
                }
                
                code = "\(code) return ["
                for index in 0...uploadPhotos.count - 1 {
                    code = "\(code)req\(index)"
                    if index < uploadPhotos.count - 1 { code = "\(code)," }
                }
                code = "\(code)];"
                print(code)
                
                let url = "/method/execute"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "code": code,
                    "v": vkSingleton.shared.version
                ]
                
                uploadPhotos.removeAll(keepingCapacity: false)
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else {
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    guard let json = try? JSON(data: data) else {
                        ViewControllerUtils().hideActivityIndicator()
                        print("json error");
                        return
                    }
                    
                    
                    //print(json)
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["execute_errors"][0]["error_code"].intValue
                    error.errorMsg = json["execute_errors"][0]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        OperationQueue.main.addOperation {
                            self.offset = 0
                            self.getPhotos()
                        }
                    } else {
                        ViewControllerUtils().hideActivityIndicator()
                        error.showErrorMessage(controller: self)
                    }
                    
                }
                OperationQueue().addOperation(getServerDataOperation)
            } else if ownerID < 0 {
                if let key = uploadPhotos.keys.first, let chosenImage = uploadPhotos[key] {
                    let titleColor = vkSingleton.shared.labelColor
                    let backColor = vkSingleton.shared.backColor
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleTop: 12.0,
                        kWindowWidth: UIScreen.main.bounds.width - 40,
                        kTitleFont: UIFont(name: "Verdana", size: 13)!,
                        kTextFont: UIFont(name: "Verdana", size: 12)!,
                        kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                        showCloseButton: false,
                        showCircularIcon: false,
                        circleBackgroundColor: backColor,
                        contentViewColor: backColor,
                        titleColor: titleColor
                    )
                    
                    let alert = SCLAlertView(appearance: appearance)
                    
                    let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
                    
                    textView.layer.borderColor = titleColor.cgColor
                    textView.layer.borderWidth = 1
                    textView.layer.cornerRadius = 5
                    textView.backgroundColor = backColor
                    textView.font = UIFont(name: "Verdana", size: 13)
                    textView.textColor = vkSingleton.shared.secondaryLabelColor
                    textView.text = ""
                    textView.changeKeyboardAppearanceMode()
                    
                    alert.customSubview = textView
                    
                    alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                        var caption = ""
                        if let text = textView.text { caption = text }
                        
                        if let aView = self.tableView.superview {
                            ViewControllerUtils().showActivityIndicator(uiView: aView)
                        } else {
                            ViewControllerUtils().showActivityIndicator(uiView: self.view)
                        }
                        
                        self.loadPhotosAlbumToServer(ownerID: ownerID, albumID: albumID, image: chosenImage, caption: caption, filename: "photo.jpg", completion: { errorCode, error in
                            
                            if errorCode == 0 {
                                self.photos.removeAll(keepingCapacity: false)
                                self.offset = 0
                                self.getPhotos()
                            } else {
                                ViewControllerUtils().hideActivityIndicator()
                                error.showErrorMessage(controller: self)
                            }
                        })
                    }
                    
                    alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                        ViewControllerUtils().hideActivityIndicator()
                    }
                    
                    alert.showInfo("Введите текст описания фотографии\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
                } else {
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
        }
    }
    
    func uploadPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Выбрать фото из профиля", style: .default) { action in
            let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
            
            photosController.ownerID = vkSingleton.shared.userID
            photosController.selectIndex = 0
            
            photosController.delegate = self
            photosController.source = "move_photo_in_album"
            
            self.navigationController?.pushViewController(photosController, animated: true)
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Выбрать фото на устройстве", style: .default) { action in
                   self.pickerController.sourceType = .photoLibrary
                   self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
               
                   self.present(self.pickerController, animated: true)
        }
        alertController.addAction(action2)
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let action3 = UIAlertAction(title: "Сфотографировать", style: .default) { action in
                self.pickerController.sourceType = .camera
                self.pickerController.cameraCaptureMode = .photo
                self.pickerController.modalPresentationStyle = .fullScreen
               
                self.present(self.pickerController, animated: true)
            }
            alertController.addAction(action3)
        }
        
        self.present(alertController, animated: true)
    }
    
    func deleteAlbum() {
        if let album = self.album, let ownerID = Int(self.ownerID) {
            
            if let aView = self.tableView.superview {
                ViewControllerUtils().showActivityIndicator(uiView: aView)
            } else {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
            
            let url = "/method/photos.deleteAlbum"
            var parameters: [String: Any] = [
                "access_token": vkSingleton.shared.accessToken,
                "album_id": album.id,
                "v": vkSingleton.shared.version
            ]
            
            if ownerID < 0 {
                parameters["group_id"] = abs(ownerID)
            }
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else {
                    ViewControllerUtils().hideActivityIndicator()
                    return
                }
                
                guard let json = try? JSON(data: data) else {
                    print("json error")
                    ViewControllerUtils().hideActivityIndicator()
                    return
                }
                
                //print(json)
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                            
                            for controller in controllers {
                                if let vc = controller as? PhotosListController {
                                    vc.albums = vc.albums.filter({ $0.id != album.id })
                                    vc.tableView.reloadData()
                                }
                            }
                        }
                        
                        ViewControllerUtils().hideActivityIndicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    ViewControllerUtils().hideActivityIndicator()
                    error.showErrorMessage(controller: self)
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        }
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
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotosListCell
        cell.contentView.isUserInteractionEnabled = true
        
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
                                let attachment = "photo\(photo.ownerID)_\(photo.pid)"
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
                                loadWallPhotosToServer(ownerID: Int(vkSingleton.shared.userID)!, image: photoImage, filename: "photo.jpg") { attachment in
                                
                                    OperationQueue.main.addOperation {
                                        vc.attach.append(attachment)
                                        vc.isLoad.append(false)
                                        vc.typeOf.append("photo")
                                        vc.photos.append(photoImage)
                                    
                                        vc.setAttachments()
                                        vc.configureStartView()
                                        self.navigationController?.popViewController(animated: true)
                                        self.navigationController?.popViewController(animated: false)
                                    }
                                }
                            }
                        }
                    }
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
                            let attachment = "photo\(photo.ownerID)_\(photo.pid)"
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
                            let attachment = "photo\(photo.ownerID)_\(photo.pid)"
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
                            let attachment = "photo\(photo.ownerID)_\(photo.pid)"
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
        
        if source == "move_photo_in_album", let vc = delegate as? PhotoAlbumController {
            if markPhotos.count <= vc.maxCountUpload {
                vc.uploadPhotos = markPhotos
                self.navigationController?.popToViewController(vc, animated: true)
                vc.uploadPhotosFromProfile()
            } else {
                self.showErrorMessage(title: "Внимание!", msg: "Вы превысили максимальное количество фотографий для переноса в альбом: \(vc.maxCountUpload)")
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
                        controller.view.backgroundColor = vkSingleton.shared.backColor
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
            } else if source == "move_photo_in_album" {
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
                    selectButton.title = "Выбрать (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Выбрать"
                }
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
                        controller.view.backgroundColor = vkSingleton.shared.backColor
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
            } else if source == "move_photo_in_album" {
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
                    selectButton.title = "Выбрать (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Выбрать"
                }
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
                        controller.view.backgroundColor = vkSingleton.shared.backColor
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
            } else if source == "move_photo_in_album" {
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
                    selectButton.title = "Выбрать (\(markPhotos.count))"
                } else {
                    selectButton.isEnabled = false
                    selectButton.title = "Выбрать"
                }
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            
        picker.dismiss(animated: true, completion: nil)
    }
        
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage,
            let ownerID = Int(self.ownerID), let albumID = Int(self.albumID) {
            
            let titleColor = vkSingleton.shared.labelColor
            let backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 12.0,
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false,
                showCircularIcon: false,
                circleBackgroundColor: backColor,
                contentViewColor: backColor,
                titleColor: titleColor
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
            
            textView.layer.borderColor = titleColor.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 5
            textView.backgroundColor = backColor
            textView.font = UIFont(name: "Verdana", size: 13)
            textView.textColor = vkSingleton.shared.secondaryLabelColor
            textView.text = ""
            textView.changeKeyboardAppearanceMode()
            
            alert.customSubview = textView
            
            alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                var caption = ""
                if let text = textView.text { caption = text }
                
                if let aView = self.tableView.superview {
                    ViewControllerUtils().showActivityIndicator(uiView: aView)
                } else {
                    ViewControllerUtils().showActivityIndicator(uiView: self.view)
                }
                
                self.loadPhotosAlbumToServer(ownerID: ownerID, albumID: albumID, image: chosenImage, caption: caption, filename: "photo.jpg", completion: { errorCode, error in
                    
                    if errorCode == 0 {
                        self.photos.removeAll(keepingCapacity: false)
                        self.offset = 0
                        self.getPhotos()
                    } else {
                        ViewControllerUtils().hideActivityIndicator()
                        error.showErrorMessage(controller: self)
                    }
                })
            }
            
            alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                ViewControllerUtils().hideActivityIndicator()
            }
            
            alert.showInfo("Введите текст описания фотографии\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    func reorderAlbum() {
        if let albumID = Int(self.albumID) {
            let titleColor = vkSingleton.shared.labelColor
            let backColor = vkSingleton.shared.backColor
            
            var selectedBackgroundColor = vkSingleton.shared.mainColor
            var dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
            var shadowColor = UIColor.darkGray
            var textColor = UIColor.black
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                        dropBackgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                        shadowColor = .lightGray
                        textColor = .white
                    } else {
                        selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                        dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                        shadowColor = .darkGray
                        textColor = .black
                    }
                } else if AppConfig.shared.darkMode {
                    selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    dropBackgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                    shadowColor = .lightGray
                    textColor = .white
                } else {
                    selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                    dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                    shadowColor = .darkGray
                    textColor = .black
                }
            } else if AppConfig.shared.darkMode {
                selectedBackgroundColor = vkSingleton.shared.mainColor
                dropBackgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                shadowColor = .lightGray
                textColor = .white
            }
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 12.0,
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false,
                showCircularIcon: false,
                circleBackgroundColor: backColor,
                contentViewColor: backColor,
                titleColor: titleColor
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            var selectedAlbumIndex = 0
            
            let albums = self.albums.filter({ $0.id != albumID })
            var picker: [String] = []
            for album in albums {
                picker.append(album.title)
            }
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 22))
            label.text = albums[0].title
            label.textColor = titleColor
            label.font = UIFont(name: "Verdana", size: 13)!
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8
            label.backgroundColor = backColor
            label.layer.cornerRadius = 4
            label.layer.borderColor = titleColor.cgColor
            label.layer.borderWidth = 0.8
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            
            downDrop.anchorView = label
            downDrop.dataSource = picker
            
            downDrop.textColor = textColor
            downDrop.textFont = UIFont(name: "Verdana", size: 12)!
            downDrop.selectedTextColor = textColor
            downDrop.backgroundColor = dropBackgroundColor
            downDrop.selectionBackgroundColor = selectedBackgroundColor
            downDrop.cellHeight = 30
            downDrop.shadowColor = shadowColor
            
            downDrop.selectionAction = { [unowned self] (index: Int, item: String) in
                selectedAlbumIndex = index
                label.text = item
                self.downDrop.hide()
            }
            
            alert.customSubview = label
            
            alert.addButton("После выбранного альбома", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                
                if let aView = self.tableView.superview {
                    ViewControllerUtils().showActivityIndicator(uiView: aView)
                } else {
                    ViewControllerUtils().showActivityIndicator(uiView: self.view)
                }
                
                let url = "/method/photos.reorderAlbums"
                let parameters: [String: Any] = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": self.ownerID,
                    "album_id": albumID,
                    "after": albums[selectedAlbumIndex].id,
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else {
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    guard let json = try? JSON(data: data) else {
                        print("json error")
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    //print(json)
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        OperationQueue.main.addOperation {
                            ViewControllerUtils().hideActivityIndicator()
                            self.showSuccessMessage(title: "Внимание!", msg: "Порядок текущего альбома в списке альбомов успешно изменен")
                            
                            if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                                
                                for controller in controllers {
                                    if let vc = controller as? PhotosListController {
                                        vc.offset = 0
                                        vc.getPhotos()
                                    }
                                }
                            }
                        }
                    } else {
                        ViewControllerUtils().hideActivityIndicator()
                        error.showErrorMessage(controller: self)
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
            
            alert.addButton("До выбранного альбома", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                
                if let aView = self.tableView.superview {
                    ViewControllerUtils().showActivityIndicator(uiView: aView)
                } else {
                    ViewControllerUtils().showActivityIndicator(uiView: self.view)
                }
                
                let url = "/method/photos.reorderAlbums"
                let parameters: [String: Any] = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": self.ownerID,
                    "album_id": albumID,
                    "before": albums[selectedAlbumIndex].id,
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else {
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    guard let json = try? JSON(data: data) else {
                        print("json error")
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    //print(json)
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        OperationQueue.main.addOperation {
                            ViewControllerUtils().hideActivityIndicator()
                            self.showSuccessMessage(title: "Внимание!", msg: "Порядок текущего альбома в списке альбомов успешно изменен")
                            
                            if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                                
                                for controller in controllers {
                                    if let vc = controller as? PhotosListController {
                                        vc.offset = 0
                                        vc.getPhotos()
                                    }
                                }
                            }
                        }
                    } else {
                        ViewControllerUtils().hideActivityIndicator()
                        error.showErrorMessage(controller: self)
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
            
            alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
            
            alert.showInfo("Выберите до или после какого альбома следует разместить текущий альбом:", subTitle: "", closeButtonTitle: "Готово")
        }
    }
    
    @objc func tapLabel() {
        self.hideKeyboard()
        downDrop.selectRow(0)
        downDrop.show()
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

