//
//  AlbumSettingsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 09.07.2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import UIKit
import DropDown
import SwiftyJSON

enum AlbumMode {
    case create
    case edit
}

class AlbumSettingsController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {

    var delegate: InnerViewController!
    var mode = AlbumMode.create
    
    var ownerID = ""
    var album: PhotoAlbum!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var descriptionCell: UITableViewCell!
    @IBOutlet weak var privacyViewCell: UITableViewCell!
    @IBOutlet weak var privacyCommentCell: UITableViewCell!
    @IBOutlet weak var uploadCell: UITableViewCell!
    @IBOutlet weak var commentOnCell: UITableViewCell!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var privacyViewLabel: UILabel!
    @IBOutlet weak var privacyCommentLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var commentOnLabel: UILabel!
    
    var textColor = UIColor.black
    var fieldBackgroundColor = vkSingleton.shared.backColor
    var dropBackgroundColor = vkSingleton.shared.backColor
    var shadowColor = UIColor.darkGray
    var fieldBackgroundColorDisabled = UIColor.red.withAlphaComponent(0.4)
    var selectedBackgroundColor = vkSingleton.shared.mainColor
    
    var privacyView: [String] = ["all"]
    var privacyComment: [String] = ["all"]
    var uploadPhoto = 0
    var commentsDisabled = 0
    
    let privacyDrop = DropDown()
    let privacyDrop2 = DropDown()
    let privacyDrop3 = DropDown()
    let privacyDrop4 = DropDown()
    
    let privacyPicker = ["все пользователи",
                         "друзья",
                         "друзья и друзья друзей",
                         "никто, кроме меня"]
    
    let uploadPicker = ["все пользователи",
                        "только редакторы и администраторы"]
    
    let commentOnPicker = ["комментирование включено",
                           "комментирование отключено"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(backButtonAction))
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = backButton
        
        let saveButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(saveButtonAction))
        self.navigationItem.rightBarButtonItem = saveButton
        
        switch mode {
        case .edit:
            self.title = "Редактировать альбом"
            if let album = self.album {
                titleField.text = album.title
                descriptionTextView.text = album.descriptionText
                privacyViewLabel.text = privacyPicker[0]
                privacyCommentLabel.text = privacyPicker[0]
                
                privacyView = album.privacyView
                privacyComment = album.privacyComment
                uploadPhoto = album.uploadByAdminsOnly
                commentsDisabled = album.commentsDisabled
                
                if uploadPhoto < 2 {
                    uploadLabel.text = uploadPicker[uploadPhoto]
                } else {
                    uploadLabel.text = uploadPicker[0]
                }
                
                if commentsDisabled < 2 {
                    commentOnLabel.text = commentOnPicker[commentsDisabled]
                } else {
                    commentOnLabel.text = commentOnPicker[0]
                }
                
                if let value = privacyView.first {
                    privacyViewLabel.text = privacyPicker[privacyToIndex(value: value)]
                }
                
                if let value = privacyComment.first {
                    privacyCommentLabel.text = privacyPicker[privacyToIndex(value: value)]
                }
            }
        case .create:
            self.title = "Создать альбом"
            
            privacyView = ["all"]
            privacyComment = ["all"]
            
            uploadLabel.text = uploadPicker[uploadPhoto]
            commentOnLabel.text = commentOnPicker[commentsDisabled]
            privacyViewLabel.text = privacyPicker[privacyToIndex(value: privacyView[0])]
            privacyCommentLabel.text = privacyPicker[privacyToIndex(value: privacyComment[0])]
        }
        
        
        textColor = vkSingleton.shared.labelColor
        fieldBackgroundColorDisabled = vkSingleton.shared.separatorColor
        
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
        } else {
            selectedBackgroundColor = vkSingleton.shared.mainColor
            dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
            shadowColor = .darkGray
            textColor = .black
        }
        
        titleField.textColor = textColor
        titleField.backgroundColor = fieldBackgroundColor
        titleField.layer.cornerRadius = 4
        titleField.layer.borderColor = textColor.cgColor
        titleField.layer.borderWidth = 0.8
        titleField.changeKeyboardAppearanceMode()
        
        descriptionTextView.textColor = textColor
        descriptionTextView.backgroundColor = fieldBackgroundColor
        descriptionTextView.layer.cornerRadius = 4
        descriptionTextView.layer.borderColor = textColor.cgColor
        descriptionTextView.layer.borderWidth = 0.8
        descriptionTextView.changeKeyboardAppearanceMode()
        
        privacyViewLabel.textColor = textColor
        privacyViewLabel.backgroundColor = fieldBackgroundColor
        privacyViewLabel.layer.cornerRadius = 4
        privacyViewLabel.layer.borderColor = textColor.cgColor
        privacyViewLabel.layer.borderWidth = 0.8
        
        privacyCommentLabel.textColor = textColor
        privacyCommentLabel.backgroundColor = fieldBackgroundColor
        privacyCommentLabel.layer.cornerRadius = 4
        privacyCommentLabel.layer.borderColor = textColor.cgColor
        privacyCommentLabel.layer.borderWidth = 0.8
        
        uploadLabel.textColor = textColor
        uploadLabel.backgroundColor = fieldBackgroundColor
        uploadLabel.layer.cornerRadius = 4
        uploadLabel.layer.borderColor = textColor.cgColor
        uploadLabel.layer.borderWidth = 0.8
        
        commentOnLabel.textColor = textColor
        commentOnLabel.backgroundColor = fieldBackgroundColor
        commentOnLabel.layer.cornerRadius = 4
        commentOnLabel.layer.borderColor = textColor.cgColor
        commentOnLabel.layer.borderWidth = 0.8
        
        let privacyViewTap = UITapGestureRecognizer(target: self, action: #selector(self.tapPrivacyViewLabel))
        privacyViewLabel.addGestureRecognizer(privacyViewTap)
        
        privacyDrop.anchorView = privacyViewLabel
        privacyDrop.dataSource = privacyPicker
        
        privacyDrop.textColor = textColor
        privacyDrop.textFont = UIFont(name: "Verdana", size: 12)!
        privacyDrop.selectedTextColor = textColor
        privacyDrop.backgroundColor = dropBackgroundColor
        privacyDrop.selectionBackgroundColor = selectedBackgroundColor
        privacyDrop.cellHeight = 30
        privacyDrop.shadowColor = shadowColor
        
        privacyDrop.selectionAction = { [unowned self] (index: Int, item: String) in
            self.privacyView = [self.privacyToString(index: index)]
            self.privacyViewLabel.text = item
            self.privacyDrop.hide()
        }
        
        let privacyCommentTap = UITapGestureRecognizer(target: self, action: #selector(self.tapPrivacyCommentLabel))
        privacyCommentLabel.addGestureRecognizer(privacyCommentTap)
        
        privacyDrop2.anchorView = privacyCommentLabel
        privacyDrop2.dataSource = privacyPicker
        
        privacyDrop2.textColor = textColor
        privacyDrop2.textFont = UIFont(name: "Verdana", size: 12)!
        privacyDrop2.selectedTextColor = textColor
        privacyDrop2.backgroundColor = dropBackgroundColor
        privacyDrop2.selectionBackgroundColor = selectedBackgroundColor
        privacyDrop2.cellHeight = 30
        privacyDrop2.shadowColor = shadowColor
        
        privacyDrop2.selectionAction = { [unowned self] (index: Int, item: String) in
            self.privacyComment = [self.privacyToString(index: index)]
            self.privacyCommentLabel.text = item
            self.privacyDrop2.hide()
        }
        
        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(self.tapUploadLabel))
        uploadLabel.addGestureRecognizer(uploadTap)
        
        privacyDrop3.anchorView = uploadLabel
        privacyDrop3.dataSource = uploadPicker
        
        privacyDrop3.textColor = textColor
        privacyDrop3.textFont = UIFont(name: "Verdana", size: 12)!
        privacyDrop3.selectedTextColor = textColor
        privacyDrop3.backgroundColor = dropBackgroundColor
        privacyDrop3.selectionBackgroundColor = selectedBackgroundColor
        privacyDrop3.cellHeight = 30
        privacyDrop3.shadowColor = shadowColor
        
        privacyDrop3.selectionAction = { [unowned self] (index: Int, item: String) in
            self.uploadPhoto = index
            self.uploadLabel.text = item
            self.privacyDrop3.hide()
        }
        
        let commentOnTap = UITapGestureRecognizer(target: self, action: #selector(self.tapCommentOnLabel))
        commentOnLabel.addGestureRecognizer(commentOnTap)
        
        privacyDrop4.anchorView = commentOnLabel
        privacyDrop4.dataSource = commentOnPicker
        
        privacyDrop4.textColor = textColor
        privacyDrop4.textFont = UIFont(name: "Verdana", size: 12)!
        privacyDrop4.selectedTextColor = textColor
        privacyDrop4.backgroundColor = dropBackgroundColor
        privacyDrop4.selectionBackgroundColor = selectedBackgroundColor
        privacyDrop4.cellHeight = 30
        privacyDrop4.shadowColor = shadowColor
        
        privacyDrop4.selectionAction = { [unowned self] (index: Int, item: String) in
            self.commentsDisabled = index
            self.commentOnLabel.text = item
            self.privacyDrop4.hide()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tableView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height + 10, right: 0)
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func saveButtonAction() {
        self.hideKeyboard()
        
        
        if let aView = tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: view)
        }
        
        if mode == .create, let title = titleField.text, let desc = descriptionTextView.text, let ownerID = Int(self.ownerID) {
            
            if title.length < 2 {
                ViewControllerUtils().hideActivityIndicator()
                showErrorMessage(title: "Внимание!", msg: "Название альбома должно содержать\nне менее 2 символов")
                return
            }
            
            let url = "/method/photos.createAlbum"
            var parameters: [String: Any] = [
                "access_token": vkSingleton.shared.accessToken,
                "title": title,
                "description": desc,
                "v": vkSingleton.shared.version
            ]
            
            if ownerID > 0 {
                parameters["privacy_view"] = privacyView
                parameters["privacy_comment"] = privacyComment
            } else {
                parameters["group_id"] = abs(ownerID)
                parameters["upload_by_admins_only"] = uploadPhoto
                parameters["comments_disabled"] = commentsDisabled
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
                        ViewControllerUtils().hideActivityIndicator()
                        self.navigationController?.popViewController(animated: true)
                        
                        if let controller = self.delegate as? PhotosListController {
                            if let aView = controller.tableView.superview {
                                ViewControllerUtils().showActivityIndicator(uiView: aView)
                            } else {
                                ViewControllerUtils().showActivityIndicator(uiView: controller.view)
                            }
                            controller.offset = 0
                            controller.getPhotos()
                        }
                    }
                } else {
                    ViewControllerUtils().hideActivityIndicator()
                    error.showErrorMessage(controller: self)
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        }
        
        if mode == .edit, let title = titleField.text, let desc = descriptionTextView.text, let ownerID = Int(self.ownerID) {
            
            if title.length < 2 {
                ViewControllerUtils().hideActivityIndicator()
                showErrorMessage(title: "Внимание!", msg: "Название альбома должно содержать\nне менее 2 символов")
                return
            }
            
            let url = "/method/photos.editAlbum"
            var parameters: [String: Any] = [
                "access_token": vkSingleton.shared.accessToken,
                "album_id": album.id,
                "owner_id": ownerID,
                "title": title,
                "description": desc,
                "v": vkSingleton.shared.version
            ]
            
            if ownerID > 0 {
                parameters["privacy_view"] = privacyView
                parameters["privacy_comment"] = privacyComment
            } else {
                parameters["upload_by_admins_only"] = uploadPhoto
                parameters["comments_disabled"] = commentsDisabled
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
                        if let controller = self.delegate as? PhotoAlbumController {
                            controller.album.title = title
                            controller.album.descriptionText = desc
                            controller.album.privacyView = self.privacyView
                            controller.album.privacyComment = self.privacyComment
                            controller.album.uploadByAdminsOnly = self.uploadPhoto
                            controller.album.commentsDisabled = self.commentsDisabled
                            
                            controller.title = title
                        }
                        
                        if let window = UIApplication.shared.keyWindow, let appDelegate = UIApplication.shared.delegate as? AppDelegate, let currentVC = appDelegate.topViewControllerWithRootViewController(rootViewController: window.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
                            
                            for controller in controllers {
                                if let vc = controller as? PhotosListController {
                                    vc.offset = 0
                                    vc.getPhotos()
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
    
    @objc func tapPrivacyViewLabel() {
        self.hideKeyboard()
        privacyDrop.selectRow(privacyToIndex(value: privacyView[0]))
        privacyDrop.show()
    }
    
    @objc func tapPrivacyCommentLabel() {
        self.hideKeyboard()
        privacyDrop2.selectRow(privacyToIndex(value: privacyComment[0]))
        privacyDrop2.show()
    }
    
    @objc func tapUploadLabel() {
        self.hideKeyboard()
        privacyDrop3.selectRow(uploadPhoto)
        privacyDrop3.show()
    }
    
    @objc func tapCommentOnLabel() {
        self.hideKeyboard()
        privacyDrop4.selectRow(commentsDisabled)
        privacyDrop4.show()
    }
    
    func privacyToString(index: Int) -> String {
        var value = "only_me"
        
        if index == 0 { value = "all" }
        if index == 1 { value = "friends" }
        if index == 2 { value = "friends_of_friends" }
        if index == 3 { value = "only_me" }
        
        return value
    }
    
    func privacyToIndex(value: String) -> Int {
        
        var index = 3
        
        if value == "all" { index = 0 }
        if value == "friends" { index = 1 }
        if value == "friends_of_friends" || value == "friends_of_friends_only" { index = 2 }
        if value == "nobody" || value == "only_me" { index = 3 }
        
        return index
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 70
        case 1:
            return 200
        case 2:
            return 60
        case 3:
            return 60
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return titleCell
        case 1:
            return descriptionCell
        case 2:
            if let ownerID = Int(self.ownerID), ownerID > 0 { return privacyViewCell }
            else { return uploadCell }
        case 3:
            if let ownerID = Int(self.ownerID), ownerID > 0 { return privacyCommentCell }
            else { return commentOnCell }
        default:
            return UITableViewCell()
        }
    }
}
