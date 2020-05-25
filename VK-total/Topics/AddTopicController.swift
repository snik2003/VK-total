//
//  AddTopicController.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SCLAlertView
import Photos

class AddTopicController: InnerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var ownerID = ""
    var message = ""
    var attachments = ""
    var fromGroup = 0
    
    var delegate: UIViewController!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var selectVideoButton: UIButton!
    @IBOutlet weak var fromGroupSwitch: UISwitch!
    @IBOutlet weak var fromGroupLabel: UILabel!
    
    var postButton: UIBarButtonItem!
    let pickerController = UIImagePickerController()
    var collectionView: UICollectionView!
    var setupLabel: UILabel!
    
    let maxCountAttach = 2
    var photos: [UIImage] = []
    var attach: [String] = []
    var typeOf: [String] = []
    var isLoad: [Bool] = []
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        collectionView.backgroundColor = vkSingleton.shared.backColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = true
        self.view.addSubview(collectionView)
        
        titleView.placeholder = "Название темы для обсуждения..."
        titleView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        titleView.layer.borderWidth = 1.0
        titleView.layer.cornerRadius = 5
        titleView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        
        textView.placeholder = "Текст первого сообщения в обсуждении..."
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        
        //startConfigureView()
        
        postButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapPostButton(sender:)))
        self.navigationItem.rightBarButtonItem = postButton
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
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
    }
    
    func startConfigureView() {
        
        fromGroupSwitch.isHidden = false
        fromGroupLabel.isHidden = false
        
        if attach.count > 0 {
            titleView.frame = CGRect(x: 10, y: navHeight + 50, width: UIScreen.main.bounds.width - 20, height: 60)
            textView.frame = CGRect(x: 10, y: titleView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - titleView.frame.maxY - 10 - 100 - 44 - tabHeight)
            collectionView.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: 80)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 100, width: UIScreen.main.bounds.width, height: 44)
        } else {
            titleView.frame = CGRect(x: 10, y: navHeight + 50, width: UIScreen.main.bounds.width - 20, height: 100)
            textView.frame = CGRect(x: 10, y: titleView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - titleView.frame.maxY - 10 - 10 - 44 - tabHeight)
            collectionView.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: 0)
            toolView.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 44)
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
        
        if titleView.text == nil || titleView.text == "" {
            readyToPost = false
            showErrorMessage(title: "Ошибка!", msg: "Название темы для обсуждения не может быть пустым.")
        }
        
        if (textView.text == nil || textView.text == "") && attach.count == 0 {
            readyToPost = false
            showErrorMessage(title: "Ошибка!", msg: "Текст первого сообщения не может быть пустым. Введите текст сообщения или прикрепите вложение.")
        }
        
        if readyToPost {
            self.addTopic(topicTitle: titleView.text!, topicText: textView.text!, attachments: attachments, fromGroup: self.fromGroup, controller: self, delegate: self.delegate)
        }
    }
    
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        
        fromGroupSwitch.isHidden = true
        fromGroupLabel.isHidden = true
        
        if attach.count > 0 {
            titleView.layer.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: 30)
            textView.layer.frame = CGRect(x: 10, y: navHeight + 50, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 50 - kbSize.height - 100 - 44)
            collectionView.layer.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: 80)
            toolView.layer.frame = CGRect(x: 0, y: textView.frame.maxY + 100, width: UIScreen.main.bounds.width, height: 44)
        } else {
            titleView.layer.frame = CGRect(x: 10, y: navHeight + 10, width: UIScreen.main.bounds.width - 20, height: 60)
            textView.layer.frame = CGRect(x: 10, y: navHeight + 80, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - navHeight - 80 - kbSize.height - 10 - 44)
            collectionView.layer.frame = CGRect(x: 10, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width - 20, height: 0)
            toolView.layer.frame = CGRect(x: 0, y: textView.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 44)
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        startConfigureView()
    }
    
    @IBAction func tapSelectPhoto(sender: UIButton) {
        
        textView.endEditing(false)
        titleView.endEditing(false)
        
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
                photosController.source = "add_topic_photo"
                
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
        titleView.endEditing(false)
        
        if attach.count < maxCountAttach {
            let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
            
            videoController.ownerID = vkSingleton.shared.userID
            videoController.type = ""
            videoController.source = "add_topic_video"
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
        usersController.source = "add_topic_mention"
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
        groupsController.source = "add_topic_mention"
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
        myMusicController.source = "add_topic_music"
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
    
    @IBAction func fromGroupSwitchChangeValue(sender: UISwitch) {
        fromGroupLabel.isEnabled = fromGroupSwitch.isOn
        if fromGroupSwitch.isOn {
            fromGroup = 1
        } else {
            fromGroup = 0
        }
    }
}


extension AddTopicController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
                titleView.endEditing(false)
                
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
        imageView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
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

extension AddTopicController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Текст первого сообщения в обсуждении..." {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == self.textView {
                textView.text = "Текст первого сообщения в обсуждении..."
            } else {
                textView.text = "Placeholder"
            }
            textView.textColor = UIColor.lightGray
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
