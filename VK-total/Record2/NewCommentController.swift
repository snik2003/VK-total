//
//  NewCommentController.swift
//  VK-total
//
//  Created by Сергей Никитин on 22.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import Photos

class NewCommentController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var type = "new"
    var ownerID = ""
    var message = ""
    var attachments = ""
    
    var replyName = ""
    var replyID = 0
    
    var delegate: UIViewController!
    var comment: Comments!
    
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var selectVideoButton: UIButton!
    
    var postButton: UIBarButtonItem!
    let pickerController = UIImagePickerController()
    var collectionView: UICollectionView!
    var setupLabel: UILabel!
    
    let maxCountAttach = 2
    var photos: [UIImage] = []
    var attach: [String] = []
    var typeOf: [String] = []
    var isLoad: [Bool] = []
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if UIScreen.main.nativeBounds.height == 2436 {
            self.navHeight = 88
            self.tabHeight = 83
        }
        
        configureSetupLabel()
        
        pickerController.delegate = self
        textView.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 80, height: 80)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = true
        self.view.addSubview(collectionView)
        getAttachments()
        
        textView.text = message
        textView.placeholder = "Введите текст комментария..."
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        
        startConfigureView()
        
        postButton = UIBarButtonItem(title: "Отпр.", style: .done, target: self, action: #selector(self.tapPostButton(sender:)))
        self.navigationItem.rightBarButtonItem = postButton
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func setAttachments() {
        attachments = ""
        if attach.count > 0 {
            for index in 0...attach.count-1 {
                if attachments != "" {
                    attachments = "\(attachments),"
                }
                attachments = "\(attachments)\(attach[index])"
            }
        }
    }
    
    func getAttachments() {
        if type == "edit_record_comment" || type == "edit_video_comment" || type == "edit_topic_comment"{
            
            var getImage: [Operation] = []
            if comment.attach.count > 0 {
                for index in 0...comment.attach.count-1 {
                    if comment.attach[index].type == "photo" || comment.attach[index].type == "doc"{
                        let attach_text = "\(comment.attach[index].type)\(comment.attach[index].ownerID)_\(comment.attach[index].id)"
                        attach.append(attach_text)
                        typeOf.append(comment.attach[index].type)
                        isLoad.append(false)
                        startConfigureView()
                        
                        let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                        getImage.append(getCacheImage)
                        if getImage.count > 1 {
                            getImage[getImage.count-1].addDependency(getImage[getImage.count-2])
                        }
                        getImage[getImage.count-1].completionBlock = {
                            self.photos.append(getCacheImage.outputImage!)
                            OperationQueue.main.addOperation {
                                self.collectionView.reloadData()
                            }
                        }
                        OperationQueue().addOperation(getImage[getImage.count-1])
                    }
                    
                    if comment.attach[index].type == "video" {
                        let attach_text = "video\(comment.attach[index].ownerID)_\(comment.attach[index].id)"
                        attach.append(attach_text)
                        typeOf.append("video")
                        isLoad.append(false)
                        setAttachments()
                        startConfigureView()
                        
                        let getCacheImage = GetCacheImage(url: comment.attach[index].photoURL, lifeTime: .avatarImage)
                        getImage.append(getCacheImage)
                        if getImage.count > 1 {
                            getImage[getImage.count-1].addDependency(getImage[getImage.count-2])
                        }
                        getImage[getImage.count-1].completionBlock = {
                            self.photos.append(getCacheImage.outputImage!)
                            OperationQueue.main.addOperation {
                                self.collectionView.reloadData()
                            }
                        }
                        OperationQueue().addOperation(getImage[getImage.count-1])
                    }
                }
                setAttachments()
            }
        }
    }
    
    func configureSetupLabel() {
        if replyID != 0 {
            setupLabel = UILabel()
            setupLabel.font = UIFont(name: "Verdana", size: 10)!
            setupLabel.isEnabled = false
            setupLabel.textAlignment = .right
            setupLabel.contentMode = .center
            setupLabel.adjustsFontSizeToFitWidth = true
            setupLabel.minimumScaleFactor = 0.5
            setupLabel.numberOfLines = 1
            setupLabel.text = "Вы отвечаете \(replyName)"
            self.view.addSubview(setupLabel)
        }
    }
    
    func startConfigureView() {
        
        var setupLabelSize: CGFloat = 0
        if replyID != 0 {
            setupLabelSize = 10
        }
        
        if attach.count > 0 {
            textView.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 10 - tabHeight - 100 - setupLabelSize - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 80)
            
            if replyID != 0 {
                setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 90, width: UIScreen.main.bounds.width-20, height: 20)
            }
            
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 100 + setupLabelSize, width: UIScreen.main.bounds.width, height: 44)
        } else {
            textView.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 10 - tabHeight - 20 - setupLabelSize - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 0)
            
            if replyID != 0 {
                setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width-20, height: 20)
            }
            
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 20 + setupLabelSize, width: UIScreen.main.bounds.width, height: 44)
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapPostButton(sender: UIBarButtonItem) {
        
        var readyToPost = true
        
        if textView.text == "" && attach.count == 0 {
            readyToPost = false
            showErrorMessage(title: "Ошибка!", msg: "Комментарий не может быть пустым. Введите сообщение или прикрепите вложение.")
        }
        
        if readyToPost {
            self.navigationController?.popViewController(animated: true)
            
            if type == "new_record_comment" {
                if let vc = self.delegate as? Record2Controller {
                    vc.commentView.textView.text = ""
                    vc.createRecordComment(text: textView.text, attachments: attachments, replyID: replyID, guid: "\(Date().timeIntervalSince1970)", stickerID: 0, controller: vc)
                }
            }
            
            if type == "edit_record_comment" {
                if let vc = self.delegate as? Record2Controller {
                    vc.commentView.textView.text = ""
                    vc.editRecordComment(newComment: textView.text, attachments: attachments, commentID: "\(comment.id)", controller: vc)
                }
            }
            
            if type == "new_video_comment" {
                if let vc = self.delegate as? VideoController {
                    vc.commentView.textView.text = ""
                    vc.createVideoComment(text: textView.text!, attachments: attachments, stickerID: 0, replyID: replyID, guid: "\(Date().timeIntervalSince1970)", controller: vc)
                }
            }
            
            if type == "edit_video_comment" {
                if let vc = self.delegate as? VideoController {
                    vc.commentView.textView.text = ""
                    vc.editVideoComment(newComment: textView.text!, attachments: attachments, commentID: "\(comment.id)", controller: vc)
                }
            }
            
            if type == "new_topic_comment" {
                if let vc = self.delegate as? TopicController {
                    vc.commentView.textView.text = ""
                    vc.createTopicComment(text: textView.text!, attachments: attachments, stickerID: 0, guid: "\(Date().timeIntervalSince1970)", controller: vc)
                }
            }
            
            if type == "edit_topic_comment" {
                if let vc = self.delegate as? TopicController {
                    vc.commentView.textView.text = ""
                    vc.editTopicComment(newComment: textView.text!, attachments: attachments, commentID: "\(comment.id)", controller: vc)
                    
                }
            }
        }
    }
    
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        var setupLabelSize: CGFloat = 0
        if replyID != 0 {
            setupLabelSize = 10
        }
        
        if attach.count > 0 {
            textView.frame = CGRect(x: 10, y: 70, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - kbSize.height - 70 - 100 - setupLabelSize - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 80)
            
            if replyID != 0 {
                setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 90, width: UIScreen.main.bounds.width-20, height: 20)
            }
            
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 100 + setupLabelSize, width: UIScreen.main.bounds.width, height: 44)
        } else {
            textView.frame = CGRect(x: 10, y: 70, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - kbSize.height - 70 - 20 - setupLabelSize - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 0)
            
            if replyID != 0 {
                setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width-20, height: 20)
            }
            
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 20 + setupLabelSize, width: UIScreen.main.bounds.width, height: 44)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        self.textView.contentInset = contentInsets
        self.textView.scrollIndicatorInsets = contentInsets
        
        startConfigureView()
    }
    
    @IBAction func tapSelectPhoto(sender: UIButton) {
        
        textView.endEditing(false)
        
        if attach.count < maxCountAttach {
            pickerController.allowsEditing = false
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Выбрать фото из профиля", style: .default) { action in
                
                let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
                
                photosController.ownerID = vkSingleton.shared.userID
                photosController.title = "Мои фотографии"
                
                photosController.selectIndex = 0
                
                photosController.delegate = self
                photosController.source = "add_comment_photo"
                
                self.navigationController?.pushViewController(photosController, animated: true)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Выбрать фото на устройстве", style: .default) { action in
                
                
                self.pickerController.sourceType = .photoLibrary
                self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                
                self.present(self.pickerController, animated: true)
            }
            alertController.addAction(action2)
            
            let action3 = UIAlertAction(title: "Сфотографировать", style: .default) { action in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.pickerController.sourceType = .camera
                    self.pickerController.cameraCaptureMode = .photo
                    self.pickerController.modalPresentationStyle = .fullScreen
                    
                    self.present(self.pickerController, animated: true)
                } else {
                    self.showErrorMessage(title: "Ошибка на устройстве!", msg: "Камера на устройстве не активна.")
                }
            }
            alertController.addAction(action3)
            
            self.present(alertController, animated: true)
        } else {
            self.showInfoMessage(title: "Внимание!", msg: "Вы достигли максимального количества вложений: \(maxCountAttach)")
        }
    }
    
    @IBAction func tapSelectVideo(sender: UIButton) {
        
        textView.endEditing(false)
        
        if attach.count < maxCountAttach {
            let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
            
            videoController.ownerID = vkSingleton.shared.userID
            videoController.type = ""
            videoController.source = "add_comment_video"
            videoController.title = "Мои видеозаписи"
            videoController.delegate = self
            
            self.navigationController?.pushViewController(videoController, animated: true)
        } else {
            self.showInfoMessage(title: "Внимание!", msg: "Вы достигли максимального количества вложений: \(maxCountAttach)")
        }
        
        setAttachments()
    }
    
    @IBAction func tapProfile(sender: UIButton) {
        let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
        
        usersController.userID = vkSingleton.shared.userID
        usersController.type = "friends"
        usersController.source = "add_comment_mention"
        usersController.title = "Упомянуть в записи"
        
        usersController.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(usersController.tapCancelButton(sender:)))
        usersController.navigationItem.leftBarButtonItem = cancelButton
        usersController.delegate = self
        
        self.navigationController?.pushViewController(usersController, animated: true)
    }
    
    @IBAction func tapGroupProfile(sender: UIButton) {
        let groupsController = self.storyboard?.instantiateViewController(withIdentifier: "GroupsListController") as! GroupsListController
        
        groupsController.userID = vkSingleton.shared.userID
        groupsController.type = ""
        groupsController.source = "add_comment_mention"
        groupsController.title = "Упомянуть в записи"
        
        groupsController.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(groupsController.tapCancelButton(sender:)))
        groupsController.navigationItem.leftBarButtonItem = cancelButton
        groupsController.delegate = self
        
        self.navigationController?.pushViewController(groupsController, animated: true)
    }
    
    @IBAction func tapAddMusic(sender: UIButton) {
        let myMusicController = self.storyboard?.instantiateViewController(withIdentifier: "MyMusicController") as! MyMusicController
        
        myMusicController.ownerID = ownerID
        myMusicController.source = "add_comment_music"
        myMusicController.delegate = self
        
        self.navigationController?.pushViewController(myMusicController, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            var imageType = "JPG"
            var imagePath = NSURL(string: "photo.jpg")
            var imageData: Data!
            if pickerController.sourceType == .photoLibrary {
                if #available(iOS 11.0, *) {
                    imagePath = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.imageURL)] as? NSURL
                }
                
                if (imagePath?.absoluteString?.containsIgnoringCase(find: ".gif"))! {
                    imageType = "GIF"
                    imageData = try! Data(contentsOf: imagePath! as URL)
                }
            }
            
            postButton.isEnabled = false
            selectPhotoButton.isEnabled = false
            selectVideoButton.isEnabled = false
            
            if imageType == "JPG" {
                photos.append(chosenImage)
                isLoad.append(true)
                typeOf.append("photo")
                collectionView.reloadData()
                
                if photos.count > 0 {
                    collectionView.scrollToItem(at: IndexPath(row: 0, section: photos.count-1), at: .centeredHorizontally, animated: true)
                }
                
                loadWallPhotosToServer(ownerID: Int(ownerID)!, image: photos[photos.count-1], filename: (imagePath?.absoluteString)!) { attachment in
                    self.attach.append(attachment)
                    self.isLoad[self.photos.count-1] = false
                    self.setAttachments()
                    
                    OperationQueue.main.addOperation {
                        self.startConfigureView()
                        self.collectionView.reloadItems(at: [IndexPath(item: 0, section: self.photos.count-1)])
                        self.postButton.isEnabled = true
                        self.selectPhotoButton.isEnabled = true
                        self.selectVideoButton.isEnabled = true
                    }
                }
            } else if imageType == "GIF" {
                photos.append(chosenImage)
                isLoad.append(true)
                typeOf.append("doc")
                collectionView.reloadData()
                
                if photos.count > 0 {
                    collectionView.scrollToItem(at: IndexPath(row: 0, section: photos.count-1), at: .centeredHorizontally, animated: true)
                }
                
                loadDocsToServer(ownerID: Int(ownerID)!, image: photos[photos.count-1], filename: (imagePath?.absoluteString)!, imageData: imageData!) { attachment in
                    self.attach.append(attachment)
                    self.isLoad[self.photos.count-1] = false
                    self.setAttachments()
                    
                    OperationQueue.main.addOperation {
                        self.startConfigureView()
                        self.collectionView.reloadItems(at: [IndexPath(item: 0, section: self.photos.count-1)])
                        self.postButton.isEnabled = true
                        self.selectPhotoButton.isEnabled = true
                        self.selectVideoButton.isEnabled = true
                    }
                }
            }
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
}


extension NewCommentController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let index = indexPath.section
        
        
        if !isLoad[index] {
            if let cell = collectionView.cellForItem(at: indexPath) {
                textView.endEditing(false)
                
                let deleteView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
                deleteView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                cell.addSubview(deleteView)
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                    deleteView.removeFromSuperview()
                }
                alertController.addAction(cancelAction)
                
                var titleAlert = "Удалить фотографию"
                if typeOf[index] == "video" {
                    titleAlert = "Удалить видеозапись"
                } else if typeOf[index] == "doc" {
                    titleAlert = "Удалить GIF"
                }
                let action1 = UIAlertAction(title: titleAlert, style: .destructive) { action in
                    
                    self.photos.remove(at: index)
                    self.attach.remove(at: index)
                    self.isLoad.remove(at: index)
                    self.typeOf.remove(at: index)
                    self.setAttachments()
                    self.startConfigureView()
                    self.collectionView.reloadData()
                }
                alertController.addAction(action1)
                
                present(alertController, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        
        let subviews = cell.subviews
        for subview in subviews {
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        let photo = photos[indexPath.section]
        
        let imageView = UIImageView()
        imageView.image = photo
        imageView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        imageView.layer.borderWidth = 1.0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let width = cell.bounds.width
        let height = collectionView.bounds.height
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        cell.addSubview(imageView)
        
        let deleteView = UIImageView()
        deleteView.image = UIImage(named: "delete-sign")
        deleteView.tintColor = UIColor.black
        deleteView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        deleteView.contentMode = .scaleAspectFill
        deleteView.clipsToBounds = true
        deleteView.frame = CGRect(x: width-15, y: 0, width: 15, height: 15)
        
        cell.addSubview(deleteView)
        
        if typeOf[indexPath.section] == "video" {
            let videoView = UIImageView()
            videoView.image = UIImage(named: "video")
            videoView.contentMode = .scaleAspectFill
            videoView.clipsToBounds = true
            videoView.frame = CGRect(x: width/2-15, y: height/2-15, width: 30, height: 30)
            cell.addSubview(videoView)
        }
        
        if typeOf[indexPath.section] == "doc" {
            let gifView = UIImageView()
            gifView.image = UIImage(named: "gif")
            gifView.contentMode = .scaleAspectFill
            gifView.clipsToBounds = true
            gifView.frame = CGRect(x: width/2-15, y: height/2-15, width: 30, height: 30)
            cell.addSubview(gifView)
        }
        
        if isLoad[indexPath.section] == true {
            let loadImage = UIImageView()
            loadImage.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            loadImage.frame = CGRect(x: 0, y: 0, width: width, height: height)
            cell.addSubview(loadImage)
            
            let loadLabel = UILabel()
            loadLabel.font = UIFont(name: "Verdana-Bold", size: 10)!
            loadLabel.adjustsFontSizeToFitWidth = true
            loadLabel.minimumScaleFactor = 0.5
            loadLabel.textAlignment = .center
            loadLabel.contentMode = .center
            loadLabel.text = "Загрузка..."
            loadLabel.textColor = UIColor.white
            loadLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
            cell.addSubview(loadLabel)
        }
        
        return cell
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
