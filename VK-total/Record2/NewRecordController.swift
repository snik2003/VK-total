//
//  NewRecordController.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import Photos

class NewRecordController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    var type = "new"
    var ownerID = ""
    var message = ""
    var attachments = ""
    
    var onlyFriends = 0
    var inTime = 0
    var fromGroup = 1
    var signed = 0
    var publishDate: Date!
    
    var delegate: Record2Controller!
    var delegate2: UIViewController!
    var record: Record!
    var dialog: DialogHistory!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var selectVideoButton: UIButton!
    @IBOutlet weak var addLinkButton: UIButton!
    @IBOutlet weak var addMusicButton: UIButton!
    
    @IBOutlet weak var setupButton: UIButton!
    
    var postButton: UIBarButtonItem!
    let pickerController = UIImagePickerController()
    var collectionView: UICollectionView!
    var setupLabel = UILabel()
    
    let maxCountAttach = 10
    var photos: [UIImage] = []
    var attach: [String] = []
    var typeOf: [String] = []
    var isLoad: [Bool] = []
    
    var link = ""
    var linkImageURL = ""
    var linkImage = UIImage()
    
    var repostTitle = ""
    var repostOwnerID = 0
    var repostItemID = 0
    var repostAccessKey = ""
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        OperationQueue.main.addOperation {
            if UIScreen.main.nativeBounds.height == 2436 {
                self.navHeight = 88
                self.tabHeight = 83
            }
            
            self.pickerController.delegate = self
            self.textView.delegate = self
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            layout.itemSize = CGSize(width: 80, height: 80)
            
            self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0), collectionViewLayout: layout)
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
            self.collectionView.backgroundColor = UIColor.white
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = true
            self.view.addSubview(self.collectionView)
            self.getAttachments()
            
            self.textView.text = self.message
            self.textView.placeholder = "Введите текст записи..."
            if self.type == "edit_message" {
                self.textView.placeholder = "Введите текст сообщения..."
            }
            self.textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
            self.textView.layer.borderWidth = 1.0
            self.textView.layer.cornerRadius = 5
            self.textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
            
            self.startConfigureView()
            self.configureSetupLabel()
            self.view.addSubview(self.setupLabel)
            
            self.postButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapPostButton(sender:)))
            self.navigationItem.rightBarButtonItem = self.postButton
            
            self.navigationItem.hidesBackButton = true
            let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
            self.navigationItem.leftBarButtonItem = cancelButton
        }
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
        if link != "" {
            attachments = "\(attachments),\(link)"
        }
        print(attachments)
    }
    
    func getAttachments() {
        if type == "edit" {
            if record.repostOwnerID == 0 {
                var getImage: [Operation] = []
                for index in 0...9 {
                    if record.mediaType[index] == "photo" || record.mediaType[index] == "doc"{
                        let attach_text = "\(record.mediaType[index])\(record.photoOwnerID[index])_\(record.photoID[index])"
                        attach.append(attach_text)
                        typeOf.append(record.mediaType[index])
                        isLoad.append(false)
                        startConfigureView()
                        
                        let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
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
                    
                    if record.mediaType[index] == "video" {
                        let attach_text = "video\(record.photoOwnerID[index])_\(record.photoID[index])"
                        attach.append(attach_text)
                        typeOf.append("video")
                        isLoad.append(false)
                        setAttachments()
                        startConfigureView()
                        
                        let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
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
                    
                    if record.mediaType[index] == "link" {
                        link = record.linkURL[index]
                        
                        linkImageURL = record.photoURL[index]
                        if record.photoURL[index] != "" {
                            let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                            getImage.append(getCacheImage)
                            if getImage.count > 1 {
                                getImage[getImage.count-1].addDependency(getImage[getImage.count-2])
                            }
                            getImage[getImage.count-1].completionBlock = {
                                self.linkImage = getCacheImage.outputImage!
                                OperationQueue.main.addOperation {
                                    self.collectionView.reloadData()
                                }
                            }
                            OperationQueue().addOperation(getImage[getImage.count-1])
                        }
                    }
                }
            }
            setAttachments()
        }
        
        if type == "edit_message" {
            var getImage: [Operation] = []
            for dattach in dialog.attach {
                if dattach.type == "photo" && dattach.photos.count > 0 {
                    let photo = dattach.photos[0]
                    let attach_text = "photo\(photo.ownerID)_\(photo.id)_\(photo.accessKey)"
                    print(attach_text)
                    attach.append(attach_text)
                    typeOf.append("photo")
                    isLoad.append(false)
                    startConfigureView()
                    
                    let getCacheImage = GetCacheImage(url: photo.photo604, lifeTime: .avatarImage)
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
                
                if dattach.type == "video" && dattach.videos.count > 0 {
                    let video = dattach.videos[0]
                    let attach_text = "video\(video.ownerID)_\(video.id)_\(video.accessKey)"
                    attach.append(attach_text)
                    typeOf.append("video")
                    isLoad.append(false)
                    startConfigureView()
                    
                    let getCacheImage = GetCacheImage(url: video.photo320, lifeTime: .avatarImage)
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
    
    func startConfigureView() {
        
        if attach.count > 0 || link != "" {
            textView.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 10 - tabHeight - 90 - 30 - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 80)
            setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 90, width: UIScreen.main.bounds.width-20, height: 30)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 90 + 30, width: UIScreen.main.bounds.width, height: 44)
        } else {
            textView.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 10 - tabHeight - 30 - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 0)
            setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY, width: UIScreen.main.bounds.width-20, height: 30)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 30, width: UIScreen.main.bounds.width, height: 44)
        }
        
        if type == "edit" {
            setupButton.isEnabled = false
            
            if record.postType == "postpone" {
                setupButton.isEnabled = true
                onlyFriends = record.friendsOnly
                inTime = 1
                publishDate = Date(timeIntervalSince1970: TimeInterval(record.date))
                
                if record.ownerID < 0 {
                    if "\(record.fromID)" == vkSingleton.shared.userID {
                        fromGroup = 0
                    } else {
                        fromGroup = 1
                    }
                    
                    if record.signerID != 0 {
                        signed = 1
                    }
                }
            }
        }
        
        if type == "edit_message" {
            setupButton.isEnabled = false
            addLinkButton.isHidden = true
            addMusicButton.isHidden = true
        }
        
        if type == "repost" {
            setupButton.isEnabled = false
            addLinkButton.isHidden = true
            addMusicButton.isHidden = true
            selectPhotoButton.isHidden = true
            selectVideoButton.isHidden = true
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
        
        self.view.endEditing(true)
        var readyToPost = true
        
        var title = "Ошибка при создании записи"
        if type == "edit" {
            title = "Ошибка при редактировании записи"
        } else if type == "edit_message" {
            title = "Ошибка при редактировании сообщения"
        }
        
        if type == "repost" {
            title = "Ошибка при репосте"
            if attach.count == 0 {
                readyToPost = false
                showErrorMessage(title: title, msg: "Отсутствует объект для репоста.")
            }
        } else {
            if let id = Int(ownerID) {
                if id > 0 && textView.text == "" && attach.count == 0 {
                    readyToPost = false
                    showErrorMessage(title: title, msg: "Введите сообщение или прикрепите вложение.")
                }
                
                if id < 0 && textView.text == "" {
                    readyToPost = false
                    showErrorMessage(title: title, msg: "Введите сопровождающий текст.")
                }
            } else {
                readyToPost = false
            }
        }
        
        if readyToPost {
            if type == "new" {
                createPost(controller: self, delegate: self.delegate2)
            }
            
            if type == "repost" {
                repostObject(object: attachments, message: textView.text)
            }
            
            if type == "edit" {
                self.navigationController?.popViewController(animated: true)
                
                let record = self.delegate.news[0]
                
                if record.postType != "postpone" {
                    editPost(ownerID: record.ownerID, postID: record.id, message: textView.text, attachments: attachments, friendsOnly: 0, signed: 0, publish: 0, controller: self.delegate)
                } else {
                    editPost(ownerID: record.ownerID, postID: record.id, message: textView.text, attachments: attachments, friendsOnly: onlyFriends, signed: signed, publish: Int(publishDate.timeIntervalSince1970), controller: self.delegate)
                }
            }
            
            if type == "edit_message" {
                editMessage(message: textView.text, attachment: attachments, messageID: dialog.id, controller: self.delegate2)
            }
        }
    }
    
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        if attach.count > 0 || link != "" {
            textView.frame = CGRect(x: 10, y: 70, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - kbSize.height - 70 - 90 - 30 - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 80)
            setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY + 90, width: UIScreen.main.bounds.width-20, height: 30)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 90 + 30, width: UIScreen.main.bounds.width, height: 44)
        } else {
            textView.frame = CGRect(x: 10, y: 70, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - kbSize.height - 70 - 30 - 44)
            collectionView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 0)
            setupLabel.frame = CGRect(x: 10, y: textView.frame.maxY, width: UIScreen.main.bounds.width-20, height: 30)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 30, width: UIScreen.main.bounds.width, height: 44)
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
                photosController.source = "add_photo"
                
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
            videoController.source = "add_video"
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
        usersController.source = "add_mention"
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
        groupsController.source = "add_mention"
        groupsController.title = "Упомянуть в записи"
        
        groupsController.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(groupsController.tapCancelButton(sender:)))
        groupsController.navigationItem.leftBarButtonItem = cancelButton
        groupsController.delegate = self
        
        self.navigationController?.pushViewController(groupsController, animated: true)
    }
    
    @IBAction func tapAddMusic(sender: UIButton) {
        
        if link == "" {
            let myMusicController = self.storyboard?.instantiateViewController(withIdentifier: "MyMusicController") as! MyMusicController
        
            myMusicController.ownerID = ownerID
            myMusicController.source = "add_music"
            myMusicController.delegate = self
        
            self.navigationController?.pushViewController(myMusicController, animated: true)
        } else {
            self.view.endEditing(false)
            self.showErrorMessage(title: "Внимание!", msg: "Можно добавить только одну ссылку.\nЧтобы добавить новую ссылку, удалите сначала старую.")
        }
    }
    
    @IBAction func tapAddLink(sender: UIButton) {
        
        if link == "" {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 32.0,
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false,
                showCircularIcon: true
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            let textField = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 22))
            
            textField.keyboardType = .URL
            textField.layer.borderColor = UIColor.black.cgColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
            textField.contentMode = .center
            textField.textColor = textField.tintColor
            textField.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            textField.font = UIFont(name: "Verdana", size: 12)
            textField.text = ""
            
            alert.customSubview = textField
            
            alert.addButton("Готово") {
                
                if let stringURL = textField.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: stringURL), url.host != nil {
                    self.link = textField.text
                    self.setAttachments()
                    self.startConfigureView()
                    self.collectionView.reloadData()
                } else {
                    if let text = textField.text {
                        self.showErrorMessage(title: "Ошибка", msg: "Некорректная ссылка:\n\(text)")
                    }
                }
            }
            
            alert.addButton("Отмена") {
                
            }
            
            alert.showInfo("Введите URL ссылки:", subTitle: "")
        } else {
            self.view.endEditing(true)
            self.showErrorMessage(title: "Внимание!", msg: "Можно добавить только одну ссылку.\nЧтобы добавить новую ссылку, удалите сначала старую.")
        }
    }
    
    @IBAction func tapSetup(sender: UIButton) {
        textView.endEditing(false)
        
        let setupController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordOptionsController") as! NewRecordOptionsController
        
        setupController.userID = Int(self.ownerID)!
        setupController.delegate = self
        setupController.title = "Настройки записи"
        
        self.navigationController?.pushViewController(setupController, animated: true)

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
            addLinkButton.isEnabled = false
            setupButton.isEnabled = false
            
            
            
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
                        self.setupButton.isEnabled = true
                        self.selectPhotoButton.isEnabled = true
                        self.selectVideoButton.isEnabled = true
                        self.addLinkButton.isEnabled = true
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
                        self.setupButton.isEnabled = true
                        self.selectPhotoButton.isEnabled = true
                        self.selectVideoButton.isEnabled = true
                        self.addLinkButton.isEnabled = true
                    }
                }
            }
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    func configureSetupLabel() {
        setupLabel.font = UIFont(name: "Verdana", size: 10)!
        setupLabel.isEnabled = false
        setupLabel.textAlignment = .right
        setupLabel.contentMode = .center
        setupLabel.adjustsFontSizeToFitWidth = true
        setupLabel.minimumScaleFactor = 0.5
        setupLabel.numberOfLines = 1
        
        var text = ""
        if type == "edit_message" {
            if dialog.fwdMessage.count > 0 {
                text = "Вложено \(dialog.fwdMessage.count.messageAdder())"
            }
        } else if type == "repost" {
            text = repostTitle
            setupLabel.numberOfLines = 2
        } else {
            if let id = Int(ownerID) {
                if id > 0 {
                    if onlyFriends == 1 {
                        text = "\(text)Только для друзей; "
                    }
                    if inTime == 1 {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                        dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
                        dateFormatter.timeZone = TimeZone.current
                        
                        text = "\(text)Опубликовать \(dateFormatter.string(from: publishDate));"
                    }
                } else {
                    if onlyFriends == 1 {
                        text = "\(text)Только для подписчиков; "
                    }
                    if inTime == 1 {
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                        dateFormatter.dateFormat = "dd MMMM yyyyг. в HH:mm"
                        dateFormatter.timeZone = TimeZone.current
                        
                        text = "\(text)Опубликовать \(dateFormatter.string(from: publishDate)); "
                    }
                    text = "\(text)\n"
                    if fromGroup == 1 {
                        text = "\(text)От имени группы; "
                    } else {
                        text = "\(text)От моего имени; "
                    }
                    if fromGroup == 1 && signed == 1 {
                        text = "\(text)Добавить подпись; "
                    }
                    setupLabel.numberOfLines = 2
                }
            }
        }
        setupLabel.text = text
    }
}


extension NewRecordController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if link != "" {
            return photos.count + 1
        }
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
        
        switch index {
            
        case 0...photos.count-1:
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
                    
                    if type != "repost" {
                        var titleAlert = "Удалить фотографию"
                        if typeOf[index] == "video" {
                            titleAlert = "Удалить видеозапись"
                        } else if typeOf[index] == "doc" {
                            titleAlert = "Удалить GIF"
                        } else if typeOf[index] == "wall" {
                            titleAlert = "Удалить запись на стене"
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
                    } else {
                        if typeOf[index] == "wall" {
                            let action1 = UIAlertAction(title: "Открыть запись", style: .destructive) { action in
                                
                                self.openWallRecord(ownerID: self.repostOwnerID, postID: self.repostItemID, accessKey: "", type: "post")
                                deleteView.removeFromSuperview()
                            }
                            alertController.addAction(action1)
                        } else if typeOf[index] == "photo" {
                            let action1 = UIAlertAction(title: "Открыть фотографию", style: .destructive) { action in
                                
                                self.openWallRecord(ownerID: self.repostOwnerID, postID: self.repostItemID, accessKey: self.repostAccessKey, type: "photo")
                                deleteView.removeFromSuperview()
                            }
                            alertController.addAction(action1)
                        } else if typeOf[index] == "video" {
                            let action1 = UIAlertAction(title: "Открыть видеозапись", style: .destructive) { action in
                                
                                self.openVideoController(ownerID: "\(self.repostOwnerID)", vid: "\(self.repostItemID)", accessKey: self.repostAccessKey, title: "Видеозапись")
                                deleteView.removeFromSuperview()
                            }
                            alertController.addAction(action1)
                        }
                    }
                
                    present(alertController, animated: true)
                }
            }
        case photos.count:
            self.openBrowserController(url: link)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section < photos.count {
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
            
            if type != "repost" {
                let deleteView = UIImageView()
                deleteView.image = UIImage(named: "delete-sign")
                deleteView.tintColor = UIColor.black
                deleteView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
                deleteView.contentMode = .scaleAspectFill
                deleteView.clipsToBounds = true
                deleteView.frame = CGRect(x: width-15, y: 0, width: 15, height: 15)
                
                cell.addSubview(deleteView)
            }
            
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
            
            let subviews = cell.subviews
            for subview in subviews {
                if subview is UIImageView || subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            let imageView = UIImageView()
            if linkImageURL != "" {
                imageView.image = linkImage
            } else {
                imageView.image = UIImage(named: "url")
            }
            imageView.tintColor = UIColor.darkGray
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 0.5
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            let width = cell.bounds.width
            let height = collectionView.bounds.height
            imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            cell.addSubview(imageView)
            
            let linkLabel = UILabel()
            linkLabel.text = link
            linkLabel.prepareTextForPublish2(self.delegate)
            linkLabel.textColor = UIColor.blue
            linkLabel.font = UIFont(name: "Verdana-Bold", size: 12)
            linkLabel.adjustsFontSizeToFitWidth = true
            linkLabel.minimumScaleFactor = 0.5
            linkLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
            linkLabel.numberOfLines = 3
            linkLabel.textAlignment = .center
            linkLabel.contentMode = .center
            linkLabel.lineBreakMode = .byCharWrapping
            linkLabel.frame = CGRect(x: 0, y: 0, width: width, height: height)
            cell.addSubview(linkLabel)
            
            let deleteView = UIImageView()
            deleteView.image = UIImage(named: "delete-sign")
            deleteView.tintColor = UIColor.black
            deleteView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
            deleteView.contentMode = .scaleAspectFill
            deleteView.clipsToBounds = true
            deleteView.frame = CGRect(x: width-15, y: 0, width: 15, height: 15)
            
            let tapLinkGesture = UITapGestureRecognizer()
            tapLinkGesture.numberOfTapsRequired = 1
            tapLinkGesture.addTarget(self, action: #selector(self.tapLink(sender:)))
            
            deleteView.isUserInteractionEnabled = true
            deleteView.addGestureRecognizer(tapLinkGesture)
            cell.addSubview(deleteView)
            
            return cell
        }
    }
    
    @objc func tapLink(sender: UITapGestureRecognizer) {
        let position = sender.location(in: collectionView)
        
        if let index = collectionView.indexPathForItem(at: position) {
            if let cell = collectionView.cellForItem(at: index) {
                textView.endEditing(false)
                
                let deleteView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
                deleteView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                cell.addSubview(deleteView)
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                    deleteView.removeFromSuperview()
                }
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Удалить ссылку", style: .destructive) { action in
                    
                    self.link = ""
                    self.setAttachments()
                    self.collectionView.reloadData()
                }
                alertController.addAction(action1)
                
                present(alertController, animated: true)
            }
        }
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
