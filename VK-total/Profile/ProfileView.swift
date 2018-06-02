//
//  ProfileView.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileView: UIView {
    
    var delegate: UIViewController!

    var avatarImage = UIImageView()
    var onlineStatusLabel = UILabel()
    var ageLabel = UILabel()
    var nameLabel = UILabel()
    var infoButton = UIButton(type: UIButtonType.detailDisclosure)
    var messageButton = UIButton()
    var friendButton = UIButton()
    var allRecordsButton = UIButton()
    var ownerButton = UIButton()
    var newRecordButton = UIButton()
    var postponedWallButton = UIButton()
    
    var collectionView1: UICollectionView!
    var collectionView2: UICollectionView!
    
    var blackImage = UIImageView()
    var favoriteImage = UIImageView()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    let infoButtonHeight: CGFloat = 22.0
    let rightInfoButton: CGFloat = 15.0
    let bottomInfoButton: CGFloat = 13.0
    let leftInsets: CGFloat = 8.0
    let bottomInsets: CGFloat = 6.0
    
    let leftInsets2: CGFloat = 10.0
    let interInsets2: CGFloat = 10.0
    let topInsets2: CGFloat = 10.0
    let statusButtonHeight: CGFloat = 30.0
    
    let leftInsets3: CGFloat = 25.0
    let topInsets3: CGFloat = 7.0
    
    func updateFriendButton(profile: UserProfileInfo) {
        
        if profile.friendStatus == 0 {
            if profile.canSendFriendRequest == 1 {
                friendButton.setTitle("Добавить в друзья", for: UIControlState.normal)
                friendButton.setTitle("Добавить в друзья", for: UIControlState.disabled)
                friendButton.isEnabled = true
                friendButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            } else {
                friendButton.setTitle("Вы не друзья", for: UIControlState.normal)
                friendButton.setTitle("Вы не друзья", for: UIControlState.disabled)
                friendButton.isEnabled = false
                friendButton.backgroundColor = UIColor.lightGray
            }
        }
        
        if profile.friendStatus == 1 {
            friendButton.setTitle("Вы подписаны", for: UIControlState.normal)
            friendButton.setTitle("Вы подписаны", for: UIControlState.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.lightGray
        }
        
        if profile.friendStatus == 2 {
            friendButton.setTitle("Подписан на вас", for: UIControlState.normal)
            friendButton.setTitle("Подписан на вас", for: UIControlState.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        }
        
        if profile.friendStatus == 3 {
            friendButton.setTitle("У Вас в друзьях", for: UIControlState.normal)
            friendButton.setTitle("У Вас в друзьях", for: UIControlState.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.lightGray
        }
    }
    
    func setStatusButtons(_ profile: UserProfileInfo, _ topY: CGFloat) -> CGFloat {
        
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.layer.borderWidth = 0.6
        messageButton.layer.cornerRadius = 15
        messageButton.clipsToBounds = true
        messageButton.setTitle("Сообщение", for: .normal)
        
        friendButton.titleLabel?.textAlignment = .center
        friendButton.layer.borderColor = UIColor.black.cgColor
        friendButton.layer.borderWidth = 0.6
        friendButton.layer.cornerRadius = 15
        friendButton.clipsToBounds = true
        
        if profile.canWritePrivateMessage == 1 {
            messageButton.isEnabled = true
            messageButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        } else {
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
        }
        
        updateFriendButton(profile: profile)
        
        messageButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        friendButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        
        let width = (UIScreen.main.bounds.width - 2 * leftInsets2 - interInsets2) / 2
        let friendButtonX = UIScreen.main.bounds.width - leftInsets2 - width
        
        messageButton.frame = CGRect(x: leftInsets2, y: topY + topInsets2, width: width, height: statusButtonHeight)
        friendButton.frame = CGRect(x: friendButtonX, y: topY + topInsets2, width: width, height: statusButtonHeight)
        
        self.addSubview(messageButton)
        self.addSubview(friendButton)
        
        return topY + statusButtonHeight + 2 * topInsets2
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets3
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func updateOwnerButtons() {
        if allRecordsButton.isSelected {
            allRecordsButton.setTitleColor(UIColor.white, for: .selected)
            allRecordsButton.layer.borderColor = UIColor.black.cgColor
            allRecordsButton.layer.cornerRadius = 5
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            allRecordsButton.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(UIColor.black, for: .normal)
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = UIColor.lightGray
            ownerButton.tintColor = UIColor.lightGray
            ownerButton.layer.cornerRadius = 5
        }
        
        if ownerButton.isSelected {
            ownerButton.setTitleColor(UIColor.white, for: .selected)
            ownerButton.layer.borderColor = UIColor.black.cgColor
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            ownerButton.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            ownerButton.layer.cornerRadius = 5
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(UIColor.black, for: .normal)
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = UIColor.lightGray
            allRecordsButton.tintColor = UIColor.lightGray
            allRecordsButton.layer.cornerRadius = 5
        }
    }
    
    func setOwnerButton(profile: UserProfileInfo, filter: String, postponed: Int, topY: CGFloat) -> CGFloat {
        
        allRecordsButton.setTitle("Все записи", for: .normal)
        allRecordsButton.setTitle("Все записи", for: .selected)
        allRecordsButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
        
        let allRecordsButtonSize = getTextSize(text: "Все записи", font: UIFont(name: "Verdana", size: 14.0)!)
        
        allRecordsButton.frame = CGRect(x: leftInsets3, y: topY + topInsets3, width: allRecordsButtonSize.width + 20, height: 40 - 2 * topInsets3)
        
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .selected)
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .normal)
        ownerButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
        
        let ownerButtonSize = getTextSize(text: "Записи \(profile.firstNameGen)", font: UIFont(name: "Verdana", size: 14.0)!)
        
        ownerButton.frame = CGRect(x: UIScreen.main.bounds.width - ownerButtonSize.width - leftInsets3 - 20, y: topY + topInsets3, width: ownerButtonSize.width + 20, height: 40 - 2 * topInsets3)
        
        if filter == "owner" {
            allRecordsButton.isSelected = false
            ownerButton.isSelected = true
        } else {
            allRecordsButton.isSelected = true
            ownerButton.isSelected = false
        }
        
        updateOwnerButtons()
        
        allRecordsButton.isHidden = false
        ownerButton.isHidden = false
        
        self.addSubview(allRecordsButton)
        self.addSubview(ownerButton)
        
        var topY = topY + 40
        if profile.canPost == 1 {
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: 5)
            separator.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            self.addSubview(separator)
            
            topY += 5
            newRecordButton.setTitle("Создать новую запись", for: .normal)
            newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
            newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
            newRecordButton.setTitleColor(UIColor.black, for: .selected)
            newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            
            newRecordButton.setImage(UIImage(named: "add-record"), for: .normal)
            newRecordButton.imageView?.tintColor = newRecordButton.tintColor
            newRecordButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 2, right: 0)
            
            newRecordButton.contentMode = .center
            
            newRecordButton.frame = CGRect(x: 2 * leftInsets3, y: topY, width: UIScreen.main.bounds.width - 4 * leftInsets3, height: 30)
            self.addSubview(newRecordButton)
            
            topY += 30
        }
        
        if postponed > 0 {
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: topY, width: UIScreen.main.bounds.width, height: 5)
            separator.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            self.addSubview(separator)
            
            topY += 5
            postponedWallButton.setTitle("Отложенные записи (\(postponed))", for: .normal)
            postponedWallButton.setTitleColor(postponedWallButton.tintColor, for: .normal)
            postponedWallButton.setTitleColor(UIColor.black, for: .highlighted)
            postponedWallButton.setTitleColor(UIColor.black, for: .selected)
            postponedWallButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            
            postponedWallButton.setImage(UIImage(named: "postponed"), for: .normal)
            postponedWallButton.imageView?.tintColor = postponedWallButton.tintColor
            postponedWallButton.imageView?.contentMode = .scaleAspectFit
            postponedWallButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 2, right: 0)
            
            postponedWallButton.contentMode = .center
            
            postponedWallButton.frame = CGRect(x: leftInsets3, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets3, height: 30)
            self.addSubview(postponedWallButton)
            
            topY += 30
            
        }
        
        return topY
    }
    
    func configureCell(profile: UserProfileInfo) -> CGFloat {
        
        nameLabel.text = "\(profile.firstName) \(profile.lastName)"
        nameLabel.textColor = UIColor.black //UIColor.white
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor(displayP3Red: 146/255, green: 146/255, blue: 146/255, alpha: 1).withAlphaComponent(0.8)
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 17)
        
        onlineStatusLabel.textAlignment = .center
        onlineStatusLabel.backgroundColor = UIColor(displayP3Red: 146/255, green: 146/255, blue: 146/255, alpha: 1).withAlphaComponent(0.8)
        onlineStatusLabel.font = UIFont(name: "Verdana", size: 12)
        
        if profile.onlineStatus == 1 {
            onlineStatusLabel.text = " онлайн"
            /*if profile.onlineMobile == 1 {
                onlineStatusLabel.text = "онлайн (моб.)"
            }*/
            onlineStatusLabel.textColor = UIColor.blue
        } else {
            onlineStatusLabel.textColor = UIColor.black //UIColor.white
            onlineStatusLabel.text = " заходил " + profile.lastSeen.toStringLastTime()
            if profile.sex == 1 {
                onlineStatusLabel.text = " заходила " + profile.lastSeen.toStringLastTime()
            }
        }
        
        if profile.platform > 0 && profile.platform != 7 {
            onlineStatusLabel.setPlatformStatus(text: "\(onlineStatusLabel.text!)", platform: profile.platform, online: profile.onlineStatus)
        }
        
        if let date = profile.birthDate.getDateFromString() {
            let age = date.age
            ageLabel.text = age.ageAdder()
            
            if profile.countryName != "" {
                ageLabel.text = ageLabel.text! + ", \(profile.countryName)"
            }
            
            if profile.cityName != "" {
                ageLabel.text = ageLabel.text! + ", \(profile.cityName)"
            }
        } else {
            if profile.countryName != "" {
                ageLabel.text = "\(profile.countryName)"
            }
            
            if profile.cityName != "" {
                if ageLabel.text != "" {
                    ageLabel.text = "\(ageLabel.text!), "
                }
                ageLabel.text = ageLabel.text! + "\(profile.cityName)"
            }
        }
        
        ageLabel.textColor = UIColor.black //UIColor.white
        ageLabel.textAlignment = .center
        ageLabel.backgroundColor = UIColor(displayP3Red: 146/255, green: 146/255, blue: 146/255, alpha: 1).withAlphaComponent(0.8)
        ageLabel.font = UIFont(name: "Verdana", size: 12)
        
        var topY: CGFloat = UIScreen.main.bounds.width * 0.9
        avatarImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topY)
        
        var hasCropPhoto = 1
        let cropWidth = (profile.cropX2 - profile.cropX1) / 100.0 * Double(profile.photoWidth)
        let cropHeight = (profile.cropY2 - profile.cropY1) / 100.0 * Double(profile.photoHeight)
        let rectWidth = (profile.rectX2 - profile.rectX1) / 100.0 * Double(cropWidth)
        let rectHeight = (profile.rectY2 - profile.rectY1) / 100.0 * Double(cropHeight)
        
        if cropWidth == 0 || cropHeight == 0 || rectWidth == 0 || rectHeight == 0 {
            hasCropPhoto = 0
        }
        
        if profile.hasPhoto == 0 {
            let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    self.avatarImage.image = getCacheImage.outputImage
                    self.avatarImage.contentMode = .center
                }
            }
            queue.addOperation(getCacheImage)
        } else if hasCropPhoto == 0 {
            let ids = profile.avatarID.components(separatedBy: "_")
            if ids.count > 0 {
                let ownerID = ids[0]
                let photoID = ids[1]
                
                let url = "/method/photos.getById"
                let parameters = [
                    "access_token":"\(vkSingleton.shared.accessToken)",
                    "photos":"\(ownerID)_\(photoID)",
                    "extended":"1",
                    "v":"\(vkSingleton.shared.version)"
                    ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    let photos = json["response"].compactMap { Photo(json: $0.1) }
                    if photos.count > 0 {
                        let getCacheImage = GetCacheImage(url: photos[0].bigPhotoURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                self.avatarImage.image = getCacheImage.outputImage
                                self.avatarImage.contentMode = .scaleAspectFill
                            }
                        }
                        self.queue.addOperation(getCacheImage)
                    } else {
                        let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                self.avatarImage.image = getCacheImage.outputImage
                                self.avatarImage.contentMode = .scaleAspectFit
                            }
                        }
                        self.queue.addOperation(getCacheImage)
                    }
                }
                queue.addOperation(getServerDataOperation)
            } else {
                let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.avatarImage.image = getCacheImage.outputImage
                        self.avatarImage.contentMode = .scaleAspectFit
                    }
                }
                queue.addOperation(getCacheImage)
            }
        } else {
            let cropX1 = profile.cropX1 / 100 * Double(profile.photoWidth)
            let cropY1 = profile.cropY1 / 100 * Double(profile.photoHeight)
            
            let rectX1 = profile.rectX1 / 100 * cropWidth
            let rectY1 = profile.rectY1 / 100 * cropHeight
            
            let getCacheImage = GetCacheImage(url: profile.cropPhotoURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    let cropRect = CGRect(x: cropX1, y: cropY1, width: cropWidth, height: cropHeight)
                    if let cropImage = getCacheImage.outputImage?.cropImage(cropRect: cropRect, viewWidth: CGFloat(profile.photoWidth), viewHeight: CGFloat(profile.photoHeight)) {
                        let rect = CGRect(x: rectX1, y: rectY1, width: rectWidth, height: rectHeight)
                        let rectImage = cropImage.cropImage(cropRect: rect, viewWidth: CGFloat(cropWidth), viewHeight: CGFloat(cropHeight))
                        self.avatarImage.image = rectImage
                        self.avatarImage.contentMode = .scaleAspectFill
                    }
                }
            }
            queue.addOperation(getCacheImage)
        }
        
        OperationQueue.main.addOperation {
            self.avatarImage.layer.borderWidth = 1
            self.avatarImage.layer.borderColor = UIColor.black.cgColor
            self.avatarImage.clipsToBounds = true
        }
        
        if profile.deactivated != "" {
            if profile.deactivated == "banned" {
                onlineStatusLabel.text = "заблокирован"
            }
            if profile.deactivated == "deleted" {
                onlineStatusLabel.text = "страница удалена"
            }
            ageLabel.text = ""
        }
        
        infoButton.tintColor = UIColor.black
        infoButton.backgroundColor = UIColor.clear
        
        if profile.hasPhoto == 0 {
            nameLabel.textColor = UIColor.black
            onlineStatusLabel.textColor = UIColor.black
            ageLabel.textColor = UIColor.black
            infoButton.tintColor = UIColor.black
        }
        
        nameLabel.isHidden = false
        onlineStatusLabel.isHidden = false
        ageLabel.isHidden = false
        infoButton.isHidden = false
        
        topY = topY - bottomInsets
        
        if ageLabel.text != "" {
            topY = topY - 15
            ageLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 15)
        } else {
            ageLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 0)
        }
        
        topY = topY - 15
        onlineStatusLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 15)
        
        topY = topY - 21
        nameLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 2 * leftInsets, height: 21)
        
        let infoButtonX = UIScreen.main.bounds.width - rightInfoButton - infoButtonHeight
        let infoButtonY = UIScreen.main.bounds.width * 0.9 - bottomInfoButton - infoButtonHeight
        infoButton.frame = CGRect(x: infoButtonX, y: infoButtonY, width: infoButtonHeight, height: infoButtonHeight)
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
        self.addSubview(onlineStatusLabel)
        self.addSubview(ageLabel)
        self.addSubview(infoButton)
        
        setCustomFields(profile: profile)
        
        topY = UIScreen.main.bounds.width * 0.9
        
        if profile.uid != vkSingleton.shared.userID {
            topY = setStatusButtons(profile, topY)
        }
        
        return topY
    }
    
    func setCustomFields(profile: UserProfileInfo) {
        blackImage.removeFromSuperview()
        favoriteImage.removeFromSuperview()
        
        if profile.blacklisted == 1 {
            blackImage.image = UIImage(named: "black-list")
            blackImage.clipsToBounds = true
            blackImage.contentMode = .scaleToFill
            blackImage.backgroundColor = UIColor(displayP3Red: 146/255, green: 146/255, blue: 146/255, alpha: 1).withAlphaComponent(0.75)
            blackImage.frame = CGRect(x: avatarImage.frame.maxX - leftInsets2 - 60, y: topInsets2, width: 60, height: 60)
            blackImage.layer.cornerRadius = 21
            avatarImage.addSubview(blackImage)
        } else if profile.isFavorite == 1 {
            favoriteImage.image = UIImage(named: "favorite")
            favoriteImage.clipsToBounds = true
            favoriteImage.contentMode = .scaleToFill
            favoriteImage.frame = CGRect(x: leftInsets2, y: topInsets2, width: 60, height: 60)
            avatarImage.addSubview(favoriteImage)
        }
    }
}

extension Int {
    func ageAdder() -> String {
        
        let age = self
        if (age % 10 == 1 && (age % 100 != 11)) {
            return "\(age) год"
        } else if ((age % 10 >= 2 && age % 10 < 5) && !(age % 100 >= 12 && age % 100 < 15)) {
            return "\(age) года"
        }
    
        return "\(age) лет"
    }
    
    func membersAdder() -> String {
        
        let members = self
        if (members % 10 == 1 && (members % 100 != 11)) {
            return "\(members) участник"
        } else if ((members % 10 >= 2 && members % 10 < 5) && !(members % 100 >= 12 && members % 100 < 15)) {
            return "\(members) участника"
        }
        
        return "\(members) участников"
    }
    
    func subscribersAdder() -> String {
        
        let members = self
        if (members % 10 == 1 && (members % 100 != 11)) {
            return "\(members) подписчик"
        } else if ((members % 10 >= 2 && members % 10 < 5) && !(members % 100 >= 12 && members % 100 < 15)) {
            return "\(members) подписчика"
        }
        
        return "\(members) подписчиков"
    }
    
    func rateAdder() -> String {
        
        let rate = self
        if (rate % 10 == 1 && (rate % 100 != 11)) {
            return "\(rate) голос"
        } else if ((rate % 10 >= 2 && rate % 10 < 5) && !(rate % 100 >= 12 && rate % 100 < 15)) {
            return "\(rate) голоса"
        }
        
        return "\(rate) голосов"
    }
    
    func messageAdder() -> String {
        
        let mess = self
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) сообщение"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) сообщения"
        }
        
        return "\(mess) сообщений"
    }
    
    func attachAdder() -> String {
        
        let mess = self
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) вложение"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) вложения"
        }
        
        return "\(mess) вложений"
    }
}

extension String {
    func getDateFromString() -> Date? {
        let dateStr = self
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let dateArray = dateStr.components(separatedBy: ".")
        let components = NSDateComponents()
        
        if dateArray.count > 2, let year = Int(dateArray[2]), let month =  Int(dateArray[1]), let day =  Int(dateArray[0]) {
            components.year = year
            components.month = month
            components.day = day
            components.timeZone = TimeZone(abbreviation: "GMT+0:00")
            let date = calendar?.date(from: components as DateComponents)
            
            return date
        }
        
        return nil
    }
}

extension UIImage {
    func cropImage(cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        
        let inputImage = self
        
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        guard let cutImageRef = inputImage.cgImage?.cropping(to:cropZone) else { return nil }
        
        return UIImage(cgImage: cutImageRef)
    }
}
