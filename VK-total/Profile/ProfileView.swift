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
    
    var delegate: ProfileController2!

    var avatarImage = UIImageView()
    var onlineStatusLabel = UILabel()
    var ageLabel = UILabel()
    var nameLabel = UILabel()
    var infoButton = UIButton(type: UIButton.ButtonType.infoLight)
    var messageButton = UIButton()
    var friendButton = UIButton()
    var allRecordsButton = UIButton()
    var ownerButton = UIButton()
    var newRecordButton = UIButton()
    var postponedWallButton = UIButton()
    
    var collectionView1: UICollectionView!
    var collectionView2: UICollectionView!
    
    var blackImage = UIImageView()
    var loveImage = UIImageView()
    var favoriteImage = UIImageView()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    let infoButtonHeight: CGFloat = 21.0
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
                friendButton.setTitle("Добавить в друзья", for: UIControl.State.normal)
                friendButton.setTitle("Добавить в друзья", for: UIControl.State.disabled)
                friendButton.isEnabled = true
                friendButton.backgroundColor = vkSingleton.shared.mainColor
            } else {
                friendButton.setTitle("Вы не друзья", for: UIControl.State.normal)
                friendButton.setTitle("Вы не друзья", for: UIControl.State.disabled)
                friendButton.isEnabled = false
                friendButton.backgroundColor = vkSingleton.shared.separatorColor
            }
        }
        
        if profile.friendStatus == 1 {
            friendButton.setTitle("Вы подписаны", for: UIControl.State.normal)
            friendButton.setTitle("Вы подписаны", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = vkSingleton.shared.separatorColor
        }
        
        if profile.friendStatus == 2 {
            friendButton.setTitle("Подписан на вас", for: UIControl.State.normal)
            friendButton.setTitle("Подписан на вас", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = vkSingleton.shared.mainColor
        }
        
        if profile.friendStatus == 3 {
            friendButton.setTitle("У Вас в друзьях", for: UIControl.State.normal)
            friendButton.setTitle("У Вас в друзьях", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = vkSingleton.shared.separatorColor
        }
    }
    
    func setStatusButtons(_ profile: UserProfileInfo, _ topY: CGFloat) -> CGFloat {
        
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.layer.borderWidth = 0.5
        messageButton.layer.cornerRadius = statusButtonHeight/3
        messageButton.clipsToBounds = true
        messageButton.setTitle("Сообщение", for: .normal)
        
        messageButton.isEnabled = true
        messageButton.backgroundColor = vkSingleton.shared.mainColor
        
        messageButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        friendButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        
        friendButton.titleLabel?.textAlignment = .center
        friendButton.layer.borderColor = UIColor.black.cgColor
        friendButton.layer.borderWidth = 0.5
        friendButton.layer.cornerRadius = statusButtonHeight/3
        friendButton.clipsToBounds = true
        
        if profile.canWritePrivateMessage == 0 {
            messageButton.isEnabled = false
            messageButton.backgroundColor = vkSingleton.shared.separatorColor
        }
        
        messageButton.add(for: .touchUpInside) {
            self.delegate.tapMessageButton(sender: self.messageButton)
        }
        
        if profile.uid == vkSingleton.shared.userID {
            friendButton.setTitle("Настройки", for: UIControl.State.normal)
            friendButton.isEnabled = true
            friendButton.backgroundColor = vkSingleton.shared.mainColor
            
            friendButton.add(for: .touchUpInside) {
                self.friendButton.buttonTouched(controller: self.delegate)
                self.delegate.openOptionsController()
            }
        } else {
            updateFriendButton(profile: profile)
            
            friendButton.add(for: .touchUpInside) {
                self.delegate.addFriendButton(sender: self.friendButton)
            }
        }
        
        let width = (UIScreen.main.bounds.width - 2 * leftInsets2 - interInsets2) / 2
        let friendButtonX = UIScreen.main.bounds.width - leftInsets2 - width
        
        messageButton.frame = CGRect(x: leftInsets2, y: topY + topInsets2, width: width, height: statusButtonHeight)
        friendButton.frame = CGRect(x: friendButtonX, y: topY + topInsets2, width: width, height: statusButtonHeight)
        
        self.addSubview(friendButton)
        self.addSubview(messageButton)
        
        return topY + statusButtonHeight + 2 * topInsets2
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets3
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func updateOwnerButtons() {
        if allRecordsButton.isSelected {
            allRecordsButton.setTitleColor(vkSingleton.shared.labelColor, for: .selected)
            allRecordsButton.layer.borderColor = vkSingleton.shared.labelColor.cgColor
            
            allRecordsButton.layer.cornerRadius = 5
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = vkSingleton.shared.mainColor
            allRecordsButton.tintColor = vkSingleton.shared.mainColor
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(vkSingleton.shared.secondaryLabelColor, for: .normal)
            
            ownerButton.layer.cornerRadius = 5
            ownerButton.clipsToBounds = true
            
            ownerButton.backgroundColor = vkSingleton.shared.separatorColor
            ownerButton.tintColor = vkSingleton.shared.separatorColor
        }
        
        if ownerButton.isSelected {
            ownerButton.setTitleColor(vkSingleton.shared.labelColor, for: .selected)
            ownerButton.layer.borderColor = vkSingleton.shared.labelColor.cgColor
            
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = vkSingleton.shared.mainColor
            ownerButton.tintColor = vkSingleton.shared.mainColor
            ownerButton.layer.cornerRadius = 5
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(vkSingleton.shared.secondaryLabelColor, for: .normal)
            
            allRecordsButton.clipsToBounds = true
            allRecordsButton.layer.cornerRadius = 5
            
            allRecordsButton.backgroundColor = vkSingleton.shared.separatorColor
            allRecordsButton.tintColor = vkSingleton.shared.separatorColor
        }
    }
    
    func setOwnerButton(profile: UserProfileInfo, filter: String, postponed: Int, topY: CGFloat) -> CGFloat {
        
        allRecordsButton.setTitle("Все записи", for: .normal)
        allRecordsButton.setTitle("Все записи", for: .selected)
        allRecordsButton.setTitleColor(vkSingleton.shared.labelColor, for: .normal)
        allRecordsButton.setTitleColor(vkSingleton.shared.labelColor, for: .selected)
        allRecordsButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
        
        let allRecordsButtonSize = getTextSize(text: "Все записи", font: UIFont(name: "Verdana", size: 14.0)!)
        
        allRecordsButton.frame = CGRect(x: leftInsets3, y: topY + topInsets3, width: allRecordsButtonSize.width + 20, height: 40 - 2 * topInsets3)
        
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .selected)
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .normal)
        ownerButton.setTitleColor(vkSingleton.shared.labelColor, for: .normal)
        ownerButton.setTitleColor(vkSingleton.shared.labelColor, for: .selected)
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
            separator.backgroundColor = vkSingleton.shared.separatorColor
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
            separator.backgroundColor = vkSingleton.shared.separatorColor
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
    
    func configureCell2(profile: UserProfileInfo) -> CGFloat {
        var topY = createInfoView(profile: profile, topY: delegate.navHeight + 20, radius: 12)
        topY = setStatusButtons(profile, topY + 20)
        
        return topY
    }
    
    func configureCell(profile: UserProfileInfo) -> CGFloat {
        
        var topY: CGFloat = UIScreen.main.bounds.width
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
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            queue.addOperation(getCacheImage)
        } else if hasCropPhoto == 0 {
            let ids = profile.avatarID.components(separatedBy: "_")
            if ids.count > 1 {
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
                    guard let data = getServerDataOperation.data else {
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    guard let json = try? JSON(data: data) else {
                        print("json error");
                        ViewControllerUtils().hideActivityIndicator()
                        return
                    }
                    
                    let photos = json["response"].compactMap { Photo(json: $0.1) }
                    if photos.count > 0 {
                        let getCacheImage = GetCacheImage(url: photos[0].bigPhotoURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                self.avatarImage.image = getCacheImage.outputImage
                                self.avatarImage.contentMode = .scaleAspectFill
                                ViewControllerUtils().hideActivityIndicator()
                            }
                        }
                        self.queue.addOperation(getCacheImage)
                    } else {
                        let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                self.avatarImage.image = getCacheImage.outputImage
                                self.avatarImage.contentMode = .scaleAspectFit
                                ViewControllerUtils().hideActivityIndicator()
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
                        ViewControllerUtils().hideActivityIndicator()
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
                        ViewControllerUtils().hideActivityIndicator()
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
        
        self.addSubview(avatarImage)
        
        topY = UIScreen.main.bounds.width
        let _ = createInfoView(profile: profile, topY: topY, radius: 12)
        setCustomFields(profile: profile)
        topY = setStatusButtons(profile, topY)
        
        return topY
    }
    
    func createInfoView(profile: UserProfileInfo, topY: CGFloat, radius: CGFloat) -> CGFloat {
        let view = UIView()
        
        var color = UIColor(red: 255/255, green: 252/255, blue: 121/255, alpha: 1)
        if profile.deactivated != "" || profile.blacklisted == 1 || profile.blacklistedByMe == 1 || (profile.isClosed == 1 && profile.canAccessClosed == 0) {
            color = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1)
        } else if profile.uid == vkSingleton.shared.userID {
            color = UIColor(red: 207/255, green: 244/255, blue: 207/255, alpha: 1)
        } else if profile.friendStatus == 3 {
            color = UIColor(red: 207/255, green: 244/255, blue: 207/255, alpha: 1)
        }
        
        view.layer.cornerRadius = radius
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 0.6
        view.backgroundColor = .clear
    
        nameLabel.text = "\(profile.firstName) \(profile.lastName)"
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .clear
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 17)
        
        onlineStatusLabel.textAlignment = .center
        onlineStatusLabel.backgroundColor = .clear
        onlineStatusLabel.adjustsFontSizeToFitWidth = true
        onlineStatusLabel.minimumScaleFactor = 0.8
        onlineStatusLabel.font = UIFont(name: "Verdana", size: 12)
        
        if profile.onlineStatus == 1 {
            onlineStatusLabel.text = " онлайн"
            onlineStatusLabel.textColor = onlineStatusLabel.tintColor
        } else {
            onlineStatusLabel.textColor = UIColor.black
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
        
        ageLabel.textColor = UIColor.black
        ageLabel.textAlignment = .center
        ageLabel.backgroundColor = .clear
        ageLabel.font = UIFont(name: "Verdana", size: 12)
        
        
        if profile.deactivated != "" {
            if profile.deactivated == "banned" {
                onlineStatusLabel.text = "страница заблокирована"
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
        
        let width = UIScreen.main.bounds.width - 2 * leftInsets
        var height: CGFloat = 5
        
        nameLabel.frame = CGRect(x: leftInsets, y: height, width: width - 2 * leftInsets, height: 21)
        view.addSubview(nameLabel)
        height += 21
        
        onlineStatusLabel.frame = CGRect(x: leftInsets + infoButtonHeight, y: height, width: width - 2 * (leftInsets + infoButtonHeight), height: 18)
        view.addSubview(onlineStatusLabel)
        height += 18
        
        if let text = ageLabel.text, text != "" {
            ageLabel.frame = CGRect(x: leftInsets, y: height, width: width - 2 * leftInsets, height: 15)
            view.addSubview(ageLabel)
            height += 15
        }
        
        height += 5
        let infoX = width - leftInsets - infoButtonHeight
        let infoY = height/2 - infoButtonHeight/2
        infoButton.frame = CGRect(x: infoX, y: infoY, width: infoButtonHeight, height: infoButtonHeight)
        view.addSubview(infoButton)
        
        let topY = topY - leftInsets - height
        view.frame = CGRect(x: leftInsets, y: topY, width: width, height: height)
        view.dropShadow(color: color, opacity: 1, offSet: CGSize(width: 0, height: 0), radius: radius)
        self.addSubview(view)
        
        return height
    }
    
    func setCustomFields(profile: UserProfileInfo) {
        blackImage.removeFromSuperview()
        favoriteImage.removeFromSuperview()
        
        if profile.blacklisted == 1 || (profile.isClosed == 1 && profile.canAccessClosed == 0){
            
            blackImage.image = UIImage(named: "black-list")
            blackImage.clipsToBounds = true
            blackImage.contentMode = .scaleToFill
            //blackImage.backgroundColor = UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 0.75)
            blackImage.frame = CGRect(x: avatarImage.frame.maxX - leftInsets2 - 60, y: topInsets2, width: 60, height: 60)
            
            avatarImage.addSubview(blackImage)
        }
            
        if profile.inLove {
            loveImage.image = UIImage(named: "heart")
            loveImage.clipsToBounds = true
            loveImage.contentMode = .scaleAspectFit
            
            loveImage.frame = CGRect(x: 15, y: 15, width: 60, height: 60)
            avatarImage.addSubview(loveImage)
        } else if profile.isFavorite == 1 {
            favoriteImage.image = UIImage(named: "favorite")
            favoriteImage.clipsToBounds = true
            favoriteImage.contentMode = .scaleToFill
            
            favoriteImage.frame = CGRect(x: leftInsets2, y: topInsets2, width: 60, height: 60)
            avatarImage.addSubview(favoriteImage)
        }
    }
}

extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = false
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
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
    
    func dialogAdder() -> String {
        
        let mess = self
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) диалог"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) диалога"
        }
        
        return "\(mess) диалогов"
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
    
    func minutesAdder() -> String {
        
        let mess = self
        
        if mess == 0 { return "" }
        
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) минута и"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) минуты и"
        }
        
        return "\(mess) минут и"
    }
    
    func secondsAdder() -> String {
        
        let mess = self
        
        if (mess % 10 == 1 && (mess % 100 != 11)) {
            return "\(mess) секунда"
        } else if ((mess % 10 >= 2 && mess % 10 < 5) && !(mess % 100 >= 12 && mess % 100 < 15)) {
            return "\(mess) секунды"
        }
        
        return "\(mess) секунд"
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
    
    func convertToBase64() -> String {
        if let data = self.pngData() {
            return data.base64EncodedString(options: .lineLength64Characters)
        }
        
        return ""
    }
}

extension UIButton {
    func buttonTouched(controller: UIViewController) {
        controller.playSoundEffect(vkSingleton.shared.buttonSound)
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.92)
        },
                         completion: { finish in
                            usleep(100000)
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.transform = CGAffineTransform.identity
                            })
        })
    }
}

extension UIView {
    func viewTouched(controller: UIViewController) {
        controller.playSoundEffect(vkSingleton.shared.buttonSound)
        UIView.animate(withDuration: 0.3,
                         animations: {
                            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.94)
        },
                         completion: { finish in
                            usleep(100000)
                            UIView.animate(withDuration: 0.3, animations: {
                                self.transform = CGAffineTransform.identity
                            })
        })
    }
}

