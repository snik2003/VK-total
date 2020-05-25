//
//  UserInfoTableViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 16.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import CMPhotoCropEditor

struct InfoInProfile {
    var image: String
    var value: String
    var comment: String
    
    init(_ image: String, _ value: String, _ comment: String) {
        self.image = image
        self.value = value
        self.comment = comment
    }
}


class UserInfoTableViewController: InnerTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PECropViewControllerDelegate {

    var users = [UserProfileInfo]()
    var partner = [UserProfileInfo]()
    var relatives = [DialogsUsers]()
    
    var isStatusExists = true
    var countBasicInfoSection = 0
    var countContactInfoSection = 0
    var countPersonalInfoSection = 0
    var countLifePositionSection = 0
    
    var basicInfoSection = [InfoInProfile]()
    var contactInfoSection = [InfoInProfile]()
    var personalInfoSection = [InfoInProfile]()
    var lifePositionSection = [InfoInProfile]()
    var relativesSection = [InfoInProfile]()
    
    let pickerController = UIImagePickerController()
    
    var partnerName = ""
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerController.delegate = self
        self.tableView.register(RelativeCell.self, forCellReuseIdentifier: "relativeCell")
        
        if users.count > 0 {
            let user = users[0]
            
            if user.uid == vkSingleton.shared.userID {
                let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                self.navigationItem.rightBarButtonItem = barButton
            }
            
            var relUsers = ""
            for rel in user.relatives {
                if rel.id != 0 {
                    if relUsers != "" {
                        relUsers = "\(relUsers),"
                    }
                    relUsers = "\(relUsers)\(rel.id)"
                }
            }
            
            if relUsers != "" {
                let url = "/method/users.get"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_ids": relUsers,
                    "fields": "id,first_name,last_name,sex",
                    "name_case": "nom",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                self.setOfflineStatus(dependence: getServerDataOperation)
                
                let parseDialogsUsers = ParseDialogsUsers()
                parseDialogsUsers.addDependency(getServerDataOperation)
                parseDialogsUsers.completionBlock = {
                    self.relatives = parseDialogsUsers.outputData
                    self.prepareInfo()
                }
                OperationQueue().addOperation(parseDialogsUsers)
            } else {
                prepareInfo()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*if users.count > 0, users[0].uid == vkSingleton.shared.userID {
            OperationQueue.main.addOperation {
                self.prepareInfo()
                self.tableView.reloadData()
            }
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if users.count > 0 {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            let action1 = UIAlertAction(title: "Изменить личный статус профиля", style: .default) { action in
                self.changeStatus()
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Изменить информацию о профиле", style: .default) { action in
                
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangeProfileInfoController") as! ChangeProfileInfoController
                
                controller.delegate = self
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
            alertController.addAction(action2)
            
            let action3 = UIAlertAction(title: "Изменить фотографию профиля", style: .default) { action in
                
                let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController2.addAction(cancelAction)
                
                
                let action1 = UIAlertAction(title: "Выбрать из профиля", style: .default) { action in
                
                    let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
                    
                    photosController.ownerID = vkSingleton.shared.userID
                    photosController.title = "Выбрать фото"
                    
                    photosController.selectIndex = 0
                    
                    photosController.delegate = self
                    photosController.source = "change_avatar"
                    
                    self.navigationController?.pushViewController(photosController, animated: true)
                }
                alertController2.addAction(action1)
                
                let action2 = UIAlertAction(title: "Загрузить с устройства", style: .default) { action in
                    
                    self.pickerController.allowsEditing = false
                    
                    self.pickerController.sourceType = .photoLibrary
                    self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                    
                    self.present(self.pickerController, animated: true)
                }
                alertController2.addAction(action2)
                
                let action3 = UIAlertAction(title: "Сфотографировать", style: .default) { action in
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.pickerController.sourceType = .camera
                        self.pickerController.cameraCaptureMode = .photo
                        self.pickerController.modalPresentationStyle = .fullScreen
                        
                        self.present(self.pickerController, animated: true)
                    } else {
                        self.showErrorMessage(title: "Ошибка", msg: "Камера на устройстве не активна.")
                    }
                }
                alertController2.addAction(action3)
                
                self.present(alertController2, animated: true)
            }
            alertController.addAction(action3)
            
            present(alertController, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            let controller = PECropViewController()
            controller.view.backgroundColor = vkSingleton.shared.backColor
            controller.delegate = self
            controller.image = chosenImage
            controller.keepingCropAspectRatio = true
            controller.cropAspectRatio = 1.0
            controller.toolbarHidden = true
            controller.isRotationEnabled = false
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        picker.dismiss(animated:true, completion: nil)
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        controller.dismiss(animated: true)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!, transform: CGAffineTransform, cropRect: CGRect) {
        
        controller.dismiss(animated: true)
        
        let crop = "\(Int(cropRect.minX)),\(Int(cropRect.minY)),\(Int(cropRect.width))"
        self.loadOwnerPhoto(image: controller.image, filename: "photo.jpg", squareCrop: crop)
    }
    
    func changeStatus() {
        
        let user = users[0]
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        if #available(iOS 13.0, *) {
            titleColor = .label
            backColor = vkSingleton.shared.backColor
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            circleBackgroundColor: backColor,
            contentViewColor: backColor,
            titleColor: titleColor
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.mainColor
        textView.text = "\(user.status)"
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            let url = "/method/status.set"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "text": "\(textView.text!)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                let json = try! JSON(data: data)
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.users[0].status = textView.text
                        self.isStatusExists = true
                        if self.users[0].status == "" {
                            self.isStatusExists = false
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    self.showErrorMessage(title: "Статус", msg: "Ошибка #\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
        }
        
        alert.showInfo("", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func prepareInfo() {
        
        if users.count > 0 {
            let user = users[0]
            
            let url = "/method/users.get"
            let parameters = [
                "user_id": "\(user.relationPatrnerId)",
                "access_token": vkSingleton.shared.accessToken,
                "fields": "id, first_name, last_name, sex, first_name_abl, first_name_gen, first_name_acc, first_name_dat, first_name_ins, last_name_abl, last_name_gen, last_name_acc, last_name_dat, last_name_ins",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                self.partner = json["response"].compactMap { UserProfileInfo(json: $0.1) }
                
                var personal: InfoInProfile
                
                self.countBasicInfoSection = 0
                self.countContactInfoSection = 0
                self.countPersonalInfoSection = 0
                self.countLifePositionSection = 0
                
                self.basicInfoSection.removeAll(keepingCapacity: false)
                self.contactInfoSection.removeAll(keepingCapacity: false)
                self.personalInfoSection.removeAll(keepingCapacity: false)
                self.lifePositionSection.removeAll(keepingCapacity: false)
                self.relativesSection.removeAll(keepingCapacity: false)
                
                var title = "О \(user.firstNameAbl)"
                let fc = user.firstNameAbl.prefix(1)
                if fc == "А" || fc == "И" || fc == "О" || fc == "Е" || fc == "У" || fc == "Я" || fc == "Ы" || fc == "Ё" || fc == "Э" || fc == "Ю"  {
                    title = "Об \(user.firstNameAbl)"
                }
                if user.uid == vkSingleton.shared.userID {
                    title = "Обо мне"
                }
                
                OperationQueue.main.addOperation {
                    self.title = title
                }
                
                if user.status == "" {
                    self.isStatusExists = false
                }
                
                // раздел "Основная информация"
                if user.relation != 0 {
                    self.countBasicInfoSection += 1
                    personal = InfoInProfile("relation",self.relationCodeIntoString(code: user.relation, sex: user.sex, partnerId: user.relationPatrnerId),"relation")
                    self.basicInfoSection.append(personal)
                }
                
                if user.birthDate != "" {
                    self.countBasicInfoSection += 1
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                    dateFormatter.dateFormat = "dd.M.yyyy"
                    var date = dateFormatter.date(from: user.birthDate)
                    dateFormatter.dateFormat = "dd MMMM yyyy года"
                    if date == nil {
                        dateFormatter.dateFormat = "dd.M"
                        date = dateFormatter.date(from: user.birthDate)
                        dateFormatter.dateFormat = "dd MMMM"
                    }
                    personal = InfoInProfile("birthdate",dateFormatter.string(from: date!),"birthDate")
                    
                    self.basicInfoSection.append(personal)
                }
                
                if user.homeTown != "" {
                    self.countBasicInfoSection += 1
                    personal = InfoInProfile("city", user.homeTown, "city")
                    self.basicInfoSection.append(personal)
                    
                }
                
                if user.universityName != "" {
                    self.countBasicInfoSection += 1
                    var univerName = user.universityName
                    if user.universityGraduation != 0 {
                        univerName = "\(univerName) '\(user.universityGraduation)"
                    }
                    personal = InfoInProfile("university", univerName, "education")
                    self.basicInfoSection.append(personal)
                }
                
                if user.facultyName != "" {
                    self.countBasicInfoSection += 1
                    personal = InfoInProfile("faculty", user.facultyName, "education")
                    self.basicInfoSection.append(personal)
                }
                
                // раздел "Контакты"
                if user.mobilePhone != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("phone",user.mobilePhone,"phone")
                    self.contactInfoSection.append(personal)
                }
                
                if user.site != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("site",user.site,"site")
                    self.contactInfoSection.append(personal)
                }
                
                self.countContactInfoSection += 1
                personal = InfoInProfile("id","id\(user.uid)","id")
                self.contactInfoSection.append(personal)
                
                if user.domain != "" && user.domain != "id\(user.uid)"{
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("vk",user.domain,"vk")
                    self.contactInfoSection.append(personal)
                }
                
                if user.skype != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("skype",user.skype,"skype")
                    self.contactInfoSection.append(personal)
                }
                
                if user.facebook != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("facebook",user.facebook,"facebook")
                    self.contactInfoSection.append(personal)
                }
                
                if user.twitter != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("twitter",user.twitter,"twitter")
                    self.contactInfoSection.append(personal)
                }
                
                if user.instagram != "" {
                    self.countContactInfoSection += 1
                    personal = InfoInProfile("instagram",user.instagram,"instagram")
                    self.contactInfoSection.append(personal)
                }
                
                // раздел "Личная информация"
                if user.about != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("О себе",user.about,"about")
                    self.personalInfoSection.append(personal)
                }
                
                if user.activities != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Деятельность",user.activities,"activities")
                    self.personalInfoSection.append(personal)
                }
                
                if user.interests != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Интересы",user.interests,"interests")
                    self.personalInfoSection.append(personal)
                }
                
                if user.books != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимые книги",user.books,"books")
                    self.personalInfoSection.append(personal)
                }
                
                if user.games != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимые игры",user.games,"games")
                    self.personalInfoSection.append(personal)
                }
                
                if user.movies != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимые фильмы",user.movies,"movies")
                    self.personalInfoSection.append(personal)
                }
                
                if user.music != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимая музыка",user.music,"music")
                    self.personalInfoSection.append(personal)
                }
                
                if user.tv != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимые телешоу",user.tv,"tv")
                    self.personalInfoSection.append(personal)
                }
                
                if user.quotes != "" {
                    self.countPersonalInfoSection += 1
                    personal = InfoInProfile("Любимые цитаты",user.quotes,"quotes")
                    self.personalInfoSection.append(personal)
                }
                
                // раздел "Жизненная позиция"
                if user.persPolitical != 0 {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Политические предпочтения",self.politicalToString(code: user.persPolitical),"political")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persReligion != "" {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Мировоззрение",user.persReligion,"religion")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persInspired != "" {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Источники вдохновения",user.persInspired,"inspired")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persPeopleMain != 0 {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Главное в людях",self.peopleMainToString(code: user.persPeopleMain),"people_main")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persLifeMain != 0 {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Главное в жизни",self.lifeMainToString(code: user.persLifeMain),"life_main")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persSmoking != 0 {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Отношение к курению",self.smokingToString(code: user.persSmoking),"smoking")
                    self.lifePositionSection.append(personal)
                }
                
                if user.persAlcohol != 0 {
                    self.countLifePositionSection += 1
                    personal = InfoInProfile("Отношение к алкоголю",self.smokingToString(code: user.persAlcohol),"alcohol")
                    self.lifePositionSection.append(personal)
                }
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if isStatusExists {
                return 1
            } else {
                return 0
            }
        case 2:
            return countBasicInfoSection
        case 3:
            return countContactInfoSection
        case 4:
            if users.count > 0, users[0].relatives.count > 0 {
                return 1
            }
            return 0
        case 5:
            return countLifePositionSection
        case 6:
            return countPersonalInfoSection
        
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "relativeCell") as! RelativeCell
            
            return cell.getRowHeight(relatives: users[0].relatives, users: relatives)
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        if #available(iOS 13.0, *) {
            if section == 0 {
                view.backgroundColor = vkSingleton.shared.backColor
            } else {
                view.backgroundColor = UIColor.separator
            }
        } else {
            view.backgroundColor = UIColor(displayP3Red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()

        if #available(iOS 13.0, *) {
            if section < 2 {
                view.backgroundColor = vkSingleton.shared.backColor
            } else {
                view.backgroundColor = .separator
            }
        } else {
            view.backgroundColor = UIColor(displayP3Red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //if section == 1 && !isStatusExists { return 8 }
        if section == 2 && countBasicInfoSection == 0 { return 0 }
        if section == 4 && relatives.count == 0 { return 0 }
        if section == 5 && countLifePositionSection == 0 { return 0 }
        if section == 6 && countPersonalInfoSection == 0 { return 0 }
        
        return 8
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 6 {
            return 8
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)

            if users.count > 0 {
                let user = users[0]

                cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
                cell.backgroundColor = vkSingleton.shared.backColor
                cell.detailTextLabel?.font = UIFont(name: "Verdana", size: 11)!
                
                if #available(iOS 13.0, *) {
                    cell.detailTextLabel?.textColor = .secondaryLabel
                    cell.textLabel?.textColor = .label
                } else {
                    cell.detailTextLabel?.textColor = UIColor.gray
                    cell.textLabel?.textColor = UIColor.gray
                }
                
                if user.deactivated != "" {
                    if (user.deactivated == "banned") {
                        cell.detailTextLabel?.text = "заблокирован"
                    } else {
                        cell.detailTextLabel?.text = "страница удалена"
                    }
                }
                else {
                    if user.onlineStatus == 1 {
                        cell.detailTextLabel?.text = "онлайн"
                        if user.onlineMobile == 1 {
                            cell.detailTextLabel?.text = "онлайн (моб.)"
                        }
                        cell.detailTextLabel?.textColor = cell.detailTextLabel?.tintColor
                        cell.detailTextLabel?.isEnabled = true
                    }
                    else {
                        let date = NSDate(timeIntervalSince1970: Double(user.lastSeen))
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                        dateFormatter.dateFormat = "dd MMMM yyyy г. в HH:mm"
                        dateFormatter.timeZone = TimeZone.current
                        
                        cell.detailTextLabel?.text = "заходил " + dateFormatter.string(from: date as    Date)
                        if user.sex == 1 {
                            cell.detailTextLabel?.text = "заходила " + dateFormatter.string(from: date as Date)
                        }
                        
                        if #available(iOS 13.0, *) {
                            cell.detailTextLabel?.textColor = .secondaryLabel
                        } else {
                            cell.detailTextLabel?.textColor = .darkGray
                        }
                    }
                }
            
                let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    cell.imageView?.layer.borderColor = UIColor.black.cgColor
                    cell.imageView?.layer.cornerRadius = 27.0
                    cell.imageView?.layer.borderWidth = 0.0
                    cell.imageView?.clipsToBounds = true
                    cell.separatorInset = .zero
                }
            }
            
            return cell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath)
            
            if users.count > 0 {
                let user = users[0]
                
                cell.textLabel?.numberOfLines = 0
                //cell.textLabel?.font = UIFont(name: "System", size: 13)
                cell.textLabel?.text = "\(user.status)"
            }
            
            return cell
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCell", for: indexPath)
            
            if countBasicInfoSection > 0 {
                cell.imageView?.tintColor = vkSingleton.shared.mainColor
                cell.imageView?.image = UIImage(named: basicInfoSection[indexPath.row].image)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\(basicInfoSection[indexPath.row].value)"
                
                if (basicInfoSection[indexPath.row].comment == "relation") {
                    if let partner = self.partner.first, let user = self.users.first, user.relationPatrnerId > 0 {
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            self.openProfileController(id: user.relationPatrnerId, name: "\(partner.firstName) \(partner.lastName)")
                        }
                        cell.textLabel?.addGestureRecognizer(tap)
                        cell.textLabel?.isUserInteractionEnabled = true
                        
                        let attributedString = NSMutableAttributedString(string: "\(basicInfoSection[indexPath.row].value)")
                        attributedString.setColorForText(partnerName, with: cell.textLabel?.tintColor ?? .blue)
                        cell.textLabel?.attributedText = attributedString
                    }
                }
            }
            
            return cell
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "contactInfoCell", for: indexPath)
            
            if countContactInfoSection > 0 {
                cell.imageView?.tintColor = vkSingleton.shared.mainColor
                cell.imageView?.image = UIImage(named: contactInfoSection[indexPath.row].image)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "\(contactInfoSection[indexPath.row].value)"
                
                if contactInfoSection[indexPath.row].comment == "site" {
                    cell.textLabel?.textColor = cell.textLabel?.tintColor
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        self.openBrowserController(url: self.contactInfoSection[indexPath.row].value)
                    }
                    cell.addGestureRecognizer(tap)
                }
            }
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "relativeCell", for: indexPath) as! RelativeCell
            
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.delegate = self
            cell.configureCell(relatives: users[0].relatives, users: relatives)
            
            cell.selectionStyle = .none
            
            return cell
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell", for: indexPath)
            
            if countLifePositionSection > 0 {
                cell.textLabel?.numberOfLines = 1
                cell.textLabel?.textColor = vkSingleton.shared.mainColor
                cell.textLabel?.text = lifePositionSection[indexPath.row].image
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text = "\(lifePositionSection[indexPath.row].value)"
            }
            
            return cell
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoCell", for: indexPath)
            
            if countPersonalInfoSection > 0 {
                cell.textLabel?.numberOfLines = 1
                cell.textLabel?.textColor = vkSingleton.shared.mainColor
                cell.textLabel?.text = personalInfoSection[indexPath.row].image
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.text = "\(personalInfoSection[indexPath.row].value)"
                //print(personalInfoSection[indexPath.row].comment)
            }
            
            return cell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)

            return cell
        }
    }
}

extension UserInfoTableViewController {
    func relationCodeIntoString(code: Int, sex: Int, partnerId: Int) -> String {
        
        if (partnerId == 0) {
            if code == 1 {
                if sex == 1 {
                    return "не замужем"
                } else {
                    return "не женат"
                }
            }
            if code == 2 {
                if sex == 1 {
                    return "есть друг"
                } else {
                    return "есть подруга"
                }
            }
            if code == 3 {
                if sex == 1 {
                    return "помолвлена"
                } else {
                    return "помолвлен"
                }
            }
            if code == 4 {
                if sex == 1 {
                    return "замужем"
                } else {
                    return "женат"
                }
            }
            if code == 5 {
                return "всё сложно"
            }
            if code == 6 {
                return "в активном поиске"
            }
            if code == 7 {
                if sex == 1 {
                    return "влюблена"
                } else {
                    return "влюблен"
                }
            }
            if code == 8 {
                return "в гражданском браке"
            }
        } else if let partner = self.partner.first {
            
            if code == 1 {
                if sex == 1 {
                    return "не замужем"
                } else {
                    return "не женат"
                }
            }
            if code == 2 {
                if sex == 1 {
                    return "есть друг"
                } else {
                    return "есть подруга"
                }
            }
            if code == 3 {
                if sex == 1 {
                    partnerName = "\(partner.firstNameIns) \(partner.lastNameIns)"
                    return "помолвлена c \(partner.firstNameIns) \(partner.lastNameIns)"
                } else {
                    partnerName = "\(partner.firstNameIns) \(partner.lastNameIns)"
                    return "помолвлен c \(partner.firstNameIns) \(partner.lastNameIns)"
                }
            }
            if code == 4 {
                if sex == 1 {
                    partnerName = "\(partner.firstNameIns) \(partner.lastNameIns)"
                    return "замужем за \(partner.firstNameIns) \(partner.lastNameIns)"
                } else {
                    partnerName = "\(partner.firstNameDat) \(partner.lastNameDat)"
                    return "женат на \(partner.firstNameDat) \(partner.lastNameDat)"
                }
            }
            if code == 5 {
                return "всё сложно"
            }
            if code == 6 {
                return "в активном поиске"
            }
            if code == 7 {
                if sex == 1 {
                    partnerName = "\(partner.firstNameAcc) \(partner.lastNameAcc)"
                    return "влюблена в \(partner.firstNameAcc) \(partner.lastNameAcc)"
                } else {
                    partnerName = "\(partner.firstNameAcc) \(partner.lastNameAcc)"
                    return "влюблен в \(partner.firstNameAcc) \(partner.lastNameAcc)"
                }
            }
            if code == 8 {
                partnerName = "\(partner.firstNameIns) \(partner.lastNameIns)"
                return "в гражданском браке c \(partner.firstNameIns) \(partner.lastNameIns)"
            }
        }
        
        return ""
    }
    
    func politicalToString(code: Int) -> String {
        switch code {
        case 1:
            return "коммунистические"
        case 2:
            return "социалистические"
        case 3:
            return "умеренные"
        case 4:
            return "либеральные"
        case 5:
            return "консервативные"
        case 6:
            return "монархические"
        case 7:
            return "ультраконсервативные"
        case 8:
            return "индифферентные"
        case 9:
            return "либертарианские"
        default:
            return ""
        }
    }
    
    func peopleMainToString(code: Int) -> String {
        switch code {
        case 1:
            return "ум и креативность"
        case 2:
            return "доброта и честность"
        case 3:
            return "красота и здоровье"
        case 4:
            return "власть и богатство"
        case 5:
            return "смелость и упорство"
        case 6:
            return "юмор и жизнелюбие"
        default:
            return ""
        }
    }
    
    func lifeMainToString(code: Int) -> String {
        switch code {
        case 1:
            return "семья и дети"
        case 2:
            return "карьера и деньги"
        case 3:
            return "развлечения и отдых"
        case 4:
            return "наука и исследования"
        case 5:
            return "совершенствование мира"
        case 6:
            return "саморазвитие"
        case 7:
            return "красота и искусство"
        case 8:
            return "слава и влияние"
        default:
            return ""
        }
    }
    
    func smokingToString(code: Int) -> String {
        switch code {
        case 1:
            return "резко негативное"
        case 2:
            return "негативное"
        case 3:
            return "компромиссное"
        case 4:
            return "нейтральное"
        case 5:
            return "положительное"
        default:
            return ""
        }
    }
    
    func relativesToString(type: String, sex: Int) -> String {
        switch type {
        case "child":
            if sex == 1 {
                return "дочь"
            }
            return "сын"
        case "sibling":
            if sex == 1 {
                return "сестра"
            }
            return "брат"
        case "parent":
            if sex == 1 {
                return "мама"
            }
            return "папа"
        case "grandparent":
            if sex == 1 {
                return "бабушка"
            }
            return "дедушка"
        case "grandchild":
            if sex == 1 {
                return "внучка"
            }
            return "внук"
        default:
            return ""
        }
    }
}

extension String {
    var nsString: NSString { return self as NSString }
    var length: Int { return nsString.length }
    var nsRange: NSRange { return NSRange(location: 0, length: length) }
    var detectDates: [Date]? {
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            .matches(in: self, range: nsRange)
            .compactMap{$0.date}
    }
}

extension Collection where Iterator.Element == String {
    var dates: [Date] {
        return compactMap{$0.detectDates}.flatMap{$0}
    }
}

extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
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
