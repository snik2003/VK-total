//
//  PhotoViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 22.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import CMPhotoCropEditor

class PhotoViewController: InnerTableViewController, PECropViewControllerDelegate {

    var delegate: UIViewController!
    
    var photos = [Photos]()
    var photo = [Photo]()
    var numPhoto = 1
    
    var likes = [Likes]()
    var reposts = [Likes]()
    
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
    
    var singleTap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        let currentPhoto = photos[numPhoto]
        
        var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(currentPhoto.ownerID)_\(currentPhoto.pid)_\(currentPhoto.photoAccessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.ownerID)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.ownerID)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) return [a,b,c];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            print(json)
            
            let photos = json["response"][0].compactMap { Photo(json: $0.1) }
            let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
            let reposts = json["response"][2]["items"].compactMap { Likes(json: $0.1) }
            
            OperationQueue.main.addOperation {
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                
                leftSwipe.direction = .left
                rightSwipe.direction = .right
                upSwipe.direction = .up
                downSwipe.direction = .down
                
                self.singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandle(sender:)))
                self.singleTap.numberOfTapsRequired = 1
                
                self.photo = photos
                self.likes = likes
                self.reposts = reposts
                
                if self.photo.count > 0 {
                    for photo in self.photos {
                        if photo.pid == self.photo[0].photoID {
                            photo.text = self.photo[0].text
                            photo.uid = self.photo[0].userID
                            photo.ownerID = self.photo[0].ownerID
                        }
                    }
                    
                    let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                    self.navigationItem.rightBarButtonItem = barButton
                } else {
                    let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem2(sender:)))
                    self.navigationItem.rightBarButtonItem = barButton
                }
                
                self.title = "Фото \(self.numPhoto + 1)/\(self.photos.count)"
                
                self.tableView.backgroundColor = vkSingleton.shared.backColor
                self.tableView.sectionIndexBackgroundColor = vkSingleton.shared.backColor
                self.tableView.sectionIndexTrackingBackgroundColor = vkSingleton.shared.backColor
                self.tableView.separatorColor = vkSingleton.shared.separatorColor
                
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
                
                self.view.addGestureRecognizer(leftSwipe)
                self.view.addGestureRecognizer(rightSwipe)
                self.view.addGestureRecognizer(upSwipe)
                self.view.addGestureRecognizer(downSwipe)
                self.view.addGestureRecognizer(self.singleTap)
            }
        }
        OperationQueue.main.addOperation(getServerDataOperation)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if let nav = self.navigationController, nav.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.tabBarController?.tabBar.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if let photo = self.photo.first {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            let action1 = UIAlertAction(title: "Сохранить фотографию", style: .default) { action in
                
                self.copyPhotoToSaveAlbum(ownerID: "\(photo.userID)", photoID: "\(photo.photoID)", accessKey: photo.photoAccessKey)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Сохранить на устройство", style: .default) { action in
                
                var url = photo.xxbigPhotoURL
                if url.isEmpty { url = photo.xbigPhotoURL }
                if url.isEmpty { url = photo.bigPhotoURL }
                if url.isEmpty { url = photo.photoURL }
                if url.isEmpty { url = photo.smallPhotoURL }
                
                let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    if let image = getCacheImage.outputImage {
                        OperationQueue.main.addOperation {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                self.showSuccessMessage(title: "Сохранение на устройство", msg: "Фотография успешно сохранена на ваше устройство.")
            }
            alertController.addAction(action2)
            
            let action7 = UIAlertAction(title: "Установить фото на аватар", style: .default) { action in
                
                let getCacheImage = GetCacheImage(url: photo.bigPhotoURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        let controller = PECropViewController()
                        controller.view.backgroundColor = vkSingleton.shared.backColor
                        controller.delegate = self
                        controller.image = getCacheImage.outputImage
                        controller.keepingCropAspectRatio = true
                        controller.cropAspectRatio = 1.0
                        controller.toolbarHidden = true
                        controller.isRotationEnabled = false
                        
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            }
            alertController.addAction(action7)
            
            if photo.ownerID == vkSingleton.shared.userID || photo.userID == vkSingleton.shared.userID || photo.userID == "100" {
                let action3 = UIAlertAction(title: "Удалить фотографию", style: .destructive) { action in
                    
                    var titleColor = UIColor.black
                    var backColor = UIColor.white
                    
                    titleColor = vkSingleton.shared.labelColor
                    backColor = vkSingleton.shared.backColor
                    
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
                        
                        self.deletePhotoFromSite(ownerID: photo.ownerID, photoID: photo.photoID, delegate: self.delegate)
                    }
                    alertView.addButton("Отмена, я передумал") {
                        
                    }
            
                    alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить фотографию? Это действие необратимо.")
                    
                }
                alertController.addAction(action3)
                
                if let albumID = Int(photo.albumID), albumID > 0 {
                    let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController2.addAction(cancelAction)
                    
                    let action2 = UIAlertAction(title: "Изменить порядок фото в альбоме", style: .default) { action in
                        let action1 = UIAlertAction(title: "Переместить фото в начало альбома", style: .default) { action in
                            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
                            
                            let url = "/method/photos.get"
                            let parameters = [
                                "access_token": vkSingleton.shared.accessToken,
                                "owner_id": photo.ownerID,
                                "album_id": albumID,
                                "rev": 1,
                                "count": 10,
                                "v": vkSingleton.shared.version
                            ] as [String : Any]
                             
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
                                    let photos = json["response"]["items"].compactMap { Photos(json: $0.1) }
                                    if let photo1 = photos.first {
                                        print("last id = \(photo1.pid)")
                                        let url2 = "/method/photos.reorderPhotos"
                                        let parameters2 = [
                                            "access_token": vkSingleton.shared.accessToken,
                                            "owner_id": photo.ownerID,
                                            "photo_id": photo.photoID,
                                            "after": photo1.pid,
                                            "v": vkSingleton.shared.version
                                        ] as [String : Any]
                                        
                                        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                                        getServerDataOperation2.completionBlock = {
                                            guard let data = getServerDataOperation2.data else {
                                                ViewControllerUtils().hideActivityIndicator()
                                                return
                                            }
                                            
                                            guard let json2 = try? JSON(data: data) else {
                                                print("json error")
                                                ViewControllerUtils().hideActivityIndicator()
                                                return
                                            }
                                            
                                            //print(json)
                                            let error = ErrorJson(json: JSON.null)
                                            error.errorCode = json2["error"]["error_code"].intValue
                                            error.errorMsg = json2["error"]["error_msg"].stringValue
                                            
                                            if error.errorCode == 0 {
                                                OperationQueue.main.addOperation {
                                                    ViewControllerUtils().hideActivityIndicator()
                                                    self.showSuccessMessage(title: "Внимание!", msg: "Фотография успешно перенесена в начало альбома.")
                                                    
                                                    if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                                                        
                                                        for controller in controllers {
                                                            if let vc = controller as? PhotoAlbumController {
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
                                        OperationQueue().addOperation(getServerDataOperation2)
                                    } else {
                                        ViewControllerUtils().hideActivityIndicator()
                                        self.showErrorMessage(title: "Внимание!", msg: "Ошибка перенесения фотографии в начало альбома.")
                                    }
                                } else {
                                    ViewControllerUtils().hideActivityIndicator()
                                    error.showErrorMessage(controller: self)
                                }
                            }
                            OperationQueue().addOperation(getServerDataOperation)
                        }
                        alertController2.addAction(action1)
                        
                        let action2 = UIAlertAction(title: "Переместить фото в конец альбома", style: .default) { action in
                            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
                            
                            let url = "/method/photos.reorderPhotos"
                            let parameters = [
                                "access_token": vkSingleton.shared.accessToken,
                                "owner_id": photo.ownerID,
                                "photo_id": photo.photoID,
                                "after": 111,
                                "v": vkSingleton.shared.version
                            ] as [String : Any]
                            
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
                                        self.showSuccessMessage(title: "Внимание!", msg: "Фотография успешно перенесена в конец альбома.")
                                        
                                        if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                                            
                                            for controller in controllers {
                                                if let vc = controller as? PhotoAlbumController {
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
                        alertController2.addAction(action2)
                        
                        self.present(alertController2, animated: true)
                    }
                    alertController.addAction(action2)
                    
                    let action3 = UIAlertAction(title: "Сделать фото обложкой альбома", style: .default) { action in
                        
                        ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
                        
                        let url = "/method/photos.makeCover"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": photo.ownerID,
                            "photo_id": photo.photoID,
                            "album_id": photo.albumID,
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
                                    self.showSuccessMessage(title: "Внимание!", msg: "Фотография успешно установлена как обложка альбома, в котором она содержится.")
                                    
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
                    alertController.addAction(action3)
                }
            }
            
            let action4 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/photo\(photo.userID)_\(photo.photoID)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на фотографию:" , msg: "\(string)")
                }
            }
            alertController.addAction(action4)
        
            let action5 = UIAlertAction(title: "Добавить ссылку в «Избранное»", style: .default) { action in
                
                let link = "https://vk.com/photo\(photo.userID)_\(photo.photoID)"
                self.addLinkToFave(link: link, text: "Фотография")
            }
            alertController.addAction(action5)
            
            let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                    
                self.reportOnObject(ownerID: photo.userID, itemID: photo.photoID, type: "photo")
            }
            alertController.addAction(action6)
            
            self.present(alertController, animated: true)
        }
    }
    
    @objc func tapBarButtonItem2(sender: UIBarButtonItem) {
        
        let photo = self.photos[numPhoto]
        playSoundEffect(vkSingleton.shared.buttonSound)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Сохранить на устройство", style: .default) { action in
            
            var url = photo.xxbigPhotoURL
            if url.isEmpty { url = photo.xbigPhotoURL }
            if url.isEmpty { url = photo.bigPhotoURL }
            if url.isEmpty { url = photo.photoURL }
            if url.isEmpty { url = photo.smallPhotoURL }
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                if let image = getCacheImage.outputImage {
                    OperationQueue.main.addOperation {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
            self.showSuccessMessage(title: "Сохранение на устройство", msg: "Фотография успешно сохранена на ваше устройство.")
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
            self.reportOnObject(ownerID: photo.ownerID, itemID: photo.pid, type: "photo")
        }
        alertController.addAction(action2)
        
        self.present(alertController, animated: true)
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        controller.dismiss(animated: true)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!, transform: CGAffineTransform, cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        
        let crop = "\(Int(cropRect.minX)),\(Int(cropRect.minY)),\(Int(cropRect.width))"
        self.loadOwnerPhoto(image: controller.image, filename: "photo.jpg", squareCrop: crop)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photo.count > 0 && navigationController?.isNavigationBarHidden == false {
            return 2
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoImageCell
            cell.backgroundColor = .clear
            cell.delegate = self
            
            if photos.count > 0 {
                let photo = photos[numPhoto]
                
                cell.scrollView.delegate = cell
                var url = photo.xxbigPhotoURL
                if url == "" { url = photo.xbigPhotoURL }
                if url == "" { url = photo.bigPhotoURL }
                if url == "" { url = photo.photoURL }
                if url == "" { url = photo.smallPhotoURL }

                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.photoImage, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                
                /*let imgURL = URL(string: url)
                let imgData = NSData(contentsOf: imgURL!)
                cell.photoImage.image = UIImage(data: imgData! as Data)*/
                
                var topPhoto: CGFloat = 0
                var leftPhoto: CGFloat = 0
                var heightPhoto: CGFloat = 0
                var widthPhoto: CGFloat = 0
                
                if photo.width >= photo.height {
                    heightPhoto = CGFloat(photo.width) * cell.scrollView.bounds.height / cell.scrollView.bounds.width
                
                    if heightPhoto > cell.scrollView.bounds.height {
                        heightPhoto = cell.scrollView.bounds.height
                        topPhoto = CGFloat(0)
                    } else {
                        topPhoto = (cell.scrollView.bounds.height - heightPhoto) * 0.5
                    }
                    
                    cell.photoImage.frame = CGRect(x: 0, y: topPhoto, width: cell.scrollView.bounds.width, height: heightPhoto)
                } else {
                    widthPhoto = CGFloat(photo.height) * cell.scrollView.bounds.width / cell.scrollView.bounds.height
                    
                    if widthPhoto > cell.scrollView.bounds.width {
                        widthPhoto = cell.scrollView.bounds.width
                        leftPhoto = CGFloat(0)
                    } else {
                        leftPhoto = (cell.scrollView.bounds.width - widthPhoto) * 0.5
                    }
                    
                    cell.photoImage.frame = CGRect(x: leftPhoto, y: 0, width: widthPhoto, height: cell.scrollView.bounds.height)
                }
                
                if !photo.text.isEmpty {
                    let text = photo.text.prepareTextForPublic().replacingOccurrences(of: "\n\n", with: "\n")
                    cell.label.text = text
                    cell.label.textColor = cell.label.tintColor
                    cell.label.numberOfLines = 5
                    cell.label.tag = 1
                    cell.label.isHidden = navigationController?.isNavigationBarHidden == true
                    
                    let labelTap = UITapGestureRecognizer()
                    labelTap.add {
                        if let ownerID = Int(photo.ownerID), let photoID = Int(photo.pid) {
                            self.openWallRecord(ownerID: ownerID, postID: photoID, accessKey: photo.photoAccessKey, type: "photo", scrollToComment: false)
                        }
                    }
                    cell.label.isUserInteractionEnabled = true
                    cell.label.addGestureRecognizer(labelTap)
                } else {
                    cell.label.tag = 0
                    cell.label.isHidden = true
                }
                
                let doubleTap = UITapGestureRecognizer(target: cell, action: #selector(cell.doubleTapAction(sender:)))
                doubleTap.numberOfTapsRequired = 2
                cell.addGestureRecognizer(doubleTap)
                
                singleTap.require(toFail: doubleTap)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "likesCell", for: indexPath)
            cell.backgroundColor = .clear
            
            let likesButton: UIButton = cell.viewWithTag(1) as! UIButton
            let commentsButton: UIButton = cell.viewWithTag(2) as! UIButton
            let likesListButton: UIButton = cell.viewWithTag(3) as! UIButton
            
            if photo.count > 0 {
                let curPhoto = photo[0]
                
                likesButton.setTitle("\(curPhoto.likesCount)", for: UIControl.State.normal)
                likesButton.setTitle("\(curPhoto.likesCount)", for: UIControl.State.selected)
                
                var titleColor = vkSingleton.shared.secondaryLabelColor
                var tintColor = vkSingleton.shared.secondaryLabelColor
                
                if curPhoto.userLikesThisPhoto == 1 {
                    titleColor = vkSingleton.shared.likeColor.withAlphaComponent(0.8)
                    tintColor = vkSingleton.shared.likeColor.withAlphaComponent(0.8)
                }
                
                likesButton.setTitleColor(titleColor, for: .normal)
                likesButton.tintColor = tintColor
                
                likesListButton.tintColor = vkSingleton.shared.secondaryLabelColor
                
                commentsButton.setTitle("\(curPhoto.commentsCount)", for: UIControl.State.normal)
                commentsButton.setTitle("\(curPhoto.commentsCount)", for: UIControl.State.selected)

                commentsButton.setTitleColor(commentsButton.tintColor.withAlphaComponent(0.8), for: .normal)
                commentsButton.imageView?.tintColor = commentsButton.tintColor.withAlphaComponent(0.8)
                
                likesButton.isHidden = false
                likesListButton.isHidden = curPhoto.likesCount == 0
                commentsButton.isHidden = false
                
                likesListButton.isEnabled = true
                commentsButton.isEnabled = true
                
                likesListButton.isUserInteractionEnabled = true
                commentsButton.isUserInteractionEnabled = true //curPhoto.commentsCount > 0
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if photo.count > 0 {
                if navigationController?.isNavigationBarHidden == false {
                    return tableView.bounds.height - 40 - navHeight - tabHeight
                } else {
                    return tableView.bounds.height
                }
            }
            return tableView.bounds.height - navHeight - tabHeight
        }
        if indexPath.row == 1 {
            return 40
        }
        return 0
    }
    
    @objc func tapHandle(sender: UITapGestureRecognizer) {
        self.navigationController?.setNavigationBarHidden(navigationController?.isNavigationBarHidden == false, animated: false)
        self.tabBarController?.tabBar.isHidden = self.navigationController?.isNavigationBarHidden == true
        self.tableView.reloadData()
    }
    
    @objc func handleSwipes(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .down {
            self.tapHandle(sender: self.singleTap)
        }
        
        if sender.direction == .up {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.popViewController(animated: true)
        }
        
        var start = false
        if sender.direction == .right {
            if numPhoto > 0 {
                numPhoto -= 1
                start = true
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            } else if numPhoto == 0 {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if sender.direction == .left {
            if numPhoto < photos.count-1 {
                numPhoto += 1
                start = true
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            } else if numPhoto == photos.count-1 {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if start {
            let currentPhoto = photos[numPhoto]
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            }
            
            var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(currentPhoto.ownerID)_\(currentPhoto.pid)_\(currentPhoto.photoAccessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.ownerID)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.ownerID)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) return [a,b,c];"
            
            let url = "/method/execute"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                let photos = json["response"][0].compactMap { Photo(json: $0.1) }
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                let reposts = json["response"][2]["items"].compactMap { Likes(json: $0.1) }
                
                OperationQueue.main.addOperation {
                    self.photo = photos
                    self.likes = likes
                    self.reposts = reposts
                    
                    if self.photo.count > 0 {
                        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                        self.navigationItem.rightBarButtonItem = barButton
                    }
                    
                    self.title = "Фото \(self.numPhoto + 1)/\(self.photos.count)"
                    self.tableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator()
                    
                    
                    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipes(sender:)))
                    
                    leftSwipe.direction = .left
                    rightSwipe.direction = .right
                    
                    self.view.addGestureRecognizer(leftSwipe)
                    self.view.addGestureRecognizer(rightSwipe)
                }
            }
            OperationQueue.main.addOperation(getServerDataOperation)
        }
    }
    
    @IBAction func likePost(sender: UIButton) {
        
        if photo.count > 0 {
            let photo1 = photo[0]
            
            if photo1.userLikesThisPhoto == 0 {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.add"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "photo",
                    "owner_id": "\(photo1.ownerID)",
                    "item_id": "\(photo1.photoID)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.photo[0].likesCount += 1
                        self.photo[0].userLikesThisPhoto = 1
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.likeSound)
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
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
                    "type": "photo",
                    "owner_id": "\(photo1.ownerID)",
                    "item_id": "\(photo1.photoID)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.photo[0].likesCount -= 1
                        self.photo[0].userLikesThisPhoto = 0
                        OperationQueue.main.addOperation {
                            self.playSoundEffect(vkSingleton.shared.unlikeSound)
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                            self.tableView.endUpdates()
                        }
                    } else {
                        error.showErrorMessage(controller: self)
                    }
                }
                likeQueue.addOperation(request)
            }
        }
    }
    
    @IBAction func infoLikesButtonClick() {
        let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
        
        likesController.likes = likes
        likesController.reposts = reposts
        likesController.title = "Оценили"
        self.navigationController?.pushViewController(likesController, animated: true)
    }
    
    @IBAction func commentsButtonClick() {
        
        if photo.count > 0 {
            self.openWallRecord(ownerID: Int(photo[0].ownerID)!, postID: Int(photo[0].photoID)!, accessKey: photos[numPhoto].photoAccessKey, type: "photo", scrollToComment: true)
        }
    }
}


