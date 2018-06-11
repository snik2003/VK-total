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

class PhotoViewController: UITableViewController, PECropViewControllerDelegate {

    var delegate: UIViewController!
    
    var photos = [Photos]()
    var photo = [Photo]()
    var numPhoto = 1
    
    var likes = [Likes]()
    var reposts = [Likes]()
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIScreen.main.nativeBounds.height == 2436 {
            self.navHeight = 88
            self.tabHeight = 83
        }
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        let currentPhoto = photos[numPhoto]
        
        var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(currentPhoto.uid)_\(currentPhoto.pid)_\(currentPhoto.photoAccessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.uid)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.uid)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if photo.count > 0 {
            let photo = self.photo[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            let action1 = UIAlertAction(title: "Сохранить фотографию", style: .default) { action in
                
                self.copyPhotoToSaveAlbum(ownerID: "\(photo.userID)", photoID: "\(photo.photoID)", accessKey: photo.photoAccessKey)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Сохранить на устройство", style: .default) { action in
                
                let getCacheImage = GetCacheImage(url: photo.bigPhotoURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    let image = getCacheImage.outputImage
                    OperationQueue.main.addOperation {
                        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
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
            
            if photo.userID == vkSingleton.shared.userID {
                let action3 = UIAlertAction(title: "Удалить фотографию", style: .destructive) { action in
                    
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
                        
                        self.deletePhotoFromSite(ownerID: photo.userID, photoID: photo.photoID, delegate: self.delegate)
                    }
                    alertView.addButton("Отмена, я передумал") {
                        
                    }
            
                    alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить фотографию? Это действие необратимо.")
                    
                }
                alertController.addAction(action3)
                    
            }
            
            let action4 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/photo\(photo.userID)_\(photo.photoID)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на фотографию:" , msg: "\(string)")
                }
            }
            alertController.addAction(action4)
        
            let action5 = UIAlertAction(title: "Добавить ссылку в \"Избранное\"", style: .default) { action in
                
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
        if photo.count > 0 {
            return 2
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoImageCell

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
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "likesCell", for: indexPath)
            
            let likesButton: UIButton = cell.viewWithTag(1) as! UIButton
            let commentsButton: UIButton = cell.viewWithTag(2) as! UIButton
            let likesListButton: UIButton = cell.viewWithTag(3) as! UIButton
            
            if photo.count > 0 {
                let curPhoto = photo[0]
                
                likesButton.setTitle("\(curPhoto.likesCount)", for: UIControlState.normal)
                likesButton.setTitle("\(curPhoto.likesCount)", for: UIControlState.selected)
                
                if curPhoto.userLikesThisPhoto == 1 {
                    likesButton.setTitleColor(UIColor.init(red: 228/255, green: 71/255, blue: 71/255, alpha: 1), for: .normal)
                    likesButton.setImage(UIImage(named: "filled-like"), for: .normal)
                } else {
                    likesButton.setTitleColor(UIColor.white, for: .normal)
                    likesButton.setImage(UIImage(named: "like"), for: .normal)
                }
                
                commentsButton.setTitle("\(curPhoto.commentsCount)", for: UIControlState.normal)
                commentsButton.setTitle("\(curPhoto.commentsCount)", for: UIControlState.selected)

                commentsButton.isEnabled = true
                likesButton.isHidden = false
                commentsButton.isHidden = false
                likesListButton.isHidden = false
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if photo.count > 0 {
                return tableView.bounds.height - 40 - navHeight - tabHeight
            }
            return tableView.bounds.height - navHeight - tabHeight
        }
        if indexPath.row == 1 {
            return 40
        }
        return 0
    }
    

    @objc func handleSwipes(sender: UISwipeGestureRecognizer) {
        
        var start = false
        if (sender.direction == .right) {
            if numPhoto > 0 {
                numPhoto -= 1
                start = true
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            }
        }
        
        if (sender.direction == .left) {
            if numPhoto < photos.count-1 {
                numPhoto += 1
                start = true
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            }
        }
        
        if start {
            let currentPhoto = photos[numPhoto]
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
            }
            
            var code = "var a = API.photos.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"photos\":\"\(currentPhoto.uid)_\(currentPhoto.pid)_\(currentPhoto.photoAccessKey)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.uid)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(currentPhoto.uid)\",\"item_id\":\"\(currentPhoto.pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
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
                    "owner_id": "\(photo1.userID)",
                    "item_id": "\(photo1.photoID)",
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
                        self.photo[0].likesCount += 1
                        self.photo[0].userLikesThisPhoto = 1
                        OperationQueue.main.addOperation {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
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
                    "type": "photo",
                    "owner_id": "\(photo1.userID)",
                    "item_id": "\(photo1.photoID)",
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
                        self.photo[0].likesCount -= 1
                        self.photo[0].userLikesThisPhoto = 0
                        OperationQueue.main.addOperation {
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
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
    
    @IBAction func infoLikesButtonClick() {
        let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
        
        likesController.likes = likes
        likesController.reposts = reposts
        likesController.title = "Оценили"
        self.navigationController?.pushViewController(likesController, animated: true)
    }
    
    @IBAction func commentsButtonClick() {
        
        if photo.count > 0 {
            self.openWallRecord(ownerID: Int(photo[0].userID)!, postID: Int(photo[0].photoID)!, accessKey: photos[numPhoto].photoAccessKey, type: "photo")
        }
    }
}


