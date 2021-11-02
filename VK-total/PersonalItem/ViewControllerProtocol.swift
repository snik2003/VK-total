//
//  ViewControllerProtocol.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON
import RealmSwift
import SCLAlertView
import Photos
import Alamofire
import SwiftMessages
import Popover
import SafariServices
import BTNavigationDropdownMenu
import Swifter

protocol NotificationCellProtocol {
    
    func openProfileController(id: Int, name: String)
    
    func openUserInfoProfile(profiles: [UserProfileInfo])
    
    func openAddAccountController()
    
    func openUsersController(uid: String, title: String, type: String)
    
    func openGroupsListController(uid: String, title: String, type: String)
    
    func openVideoController(ownerID: String, vid: String, accessKey: String, title: String, scrollToComment: Bool)
    
    func openVideoListController(ownerID: String, title: String, type: String)
    
    func openTopicsController(groupID: String, group: GroupProfile, title: String)
    
    func openTopicController(groupID: String, topicID: String, title: String, delegate: UIViewController)
    
    func openNotesController(userID: String, title: String)
    
    func openPhotosListController(ownerID: String, title: String, type: String, isAdmin: Bool)
    
    func openPhotoViewController(numPhoto: Int, photos: [Photos])
    
    func openPhotoAlbumController(ownerID: String, albumID: String, title: String, controller: PhotosListController!)
    
    func openWallRecord(ownerID: Int, postID: Int, accessKey: String, type: String, scrollToComment: Bool)
    
    func openPageController(pageID: Int, groupID: Int)
    
    func openFavePostsController()
    
    func openMembersController(groupID: Int, filters: String, title: String, isAdmin: Bool)
    
    func openNewRecordController(ownerID: String, type: String, message: String, title: String, controller: Record2Controller!, delegate: UIViewController)
    
    func openAddTopicController(ownerID: String, title: String, delegate: UIViewController)
    
    func openNewsfeedSearchController(ownerID: Int, hash: String)
    
    func openMyMusicController(ownerID: String)
    
    func openOptionsController()
    
    func openPhoto(not: Notifications)
    
    func openBrowserController(url: String)
    
    func writeReviewAppStore()
    
    func setOfflineStatus(dependence: Operation?)
    
    func showErrorMessage(title: String, msg: String)
    
    func showSuccessMessage(title: String, msg: String)
    
    func showInfoMessage(title: String, msg: String)
    
    func showSettingsMessage(title: String, msg: String)
    
    func updateAccountInRealm(account: AccountVK)
    
    func deleteAccountFromRealm(userID: Int)
    
    func getAccessTokenFromRealm(userID: Int) -> String
    
    func getNumberOfAccounts() -> Int
    
    func readAppConfig()
    
    func saveAppConfig()
    
    func commentReplyRecordController(replyName: String, replyText: String, indexPath: IndexPath, controller: Record2Controller)
    
    func commentReplyVideoController(replyName: String, replyText: String, indexPath: IndexPath, controller: VideoController)
    
    func repost(description: String, ownerID: String, itemID: String, type: String)
    
    func editRecord(description: String, record: Record, controller: Record2Controller)
    
    func getITunesInfo2(artist: String, title: String)
    
    func saveGifToDevice(url: URL)
    
    func showNotification(text: String)
    
    func showMessageNotification(title: String, text: String, userID: Int, chatID: Int, groupID: Int, startID: Int)
    
    func openDialogController(userID: String, chatID: String, startID: Int, attachment: String, messIDs: [Int], image: UIImage?)
    
    func openGroupDialogController(userID: String, groupID: String, startID: Int, attachment: String, messIDs: [Int], image: UIImage?)
    
    func openDialogsController(attachments: String, image: UIImage?, messIDs: [Int], source: String)
}

extension UIViewController: NotificationCellProtocol {
    
    var previousViewController: UIViewController? {
        guard let controllers = navigationController?.viewControllers, controllers.count > 1 else { return nil }
        switch controllers.count {
        case 2: return controllers.first
        default: return controllers.dropLast(2).first
        }
    }
    
    
    func openProfileController(id: Int, name: String) {
        if id > 0 {
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileController2") as! ProfileController2
            
            profileController.userID = "\(id)"
            profileController.title = name
            
            self.navigationController?.pushViewController(profileController, animated: true)
        }
        
        if id < 0 {
            let groupProfileController = self.storyboard?.instantiateViewController(withIdentifier: "GroupProfileController2") as! GroupProfileController2
            
            groupProfileController.groupID = abs(id)
            groupProfileController.title = name
            
            self.navigationController?.pushViewController(groupProfileController, animated: true)
        }
    }
    
    func openUserInfoProfile(profiles: [UserProfileInfo]) {
        let userInfoController = self.storyboard?.instantiateViewController(withIdentifier: "UserInfoController") as! UserInfoTableViewController
        
        userInfoController.users = profiles
        
        
        self.navigationController?.pushViewController(userInfoController, animated: true)
    }
    
    func openAddAccountController() {
        
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = oldObject?["token"]
                    }
                }
            }
            let realm = try Realm(configuration: config)
            let accounts = realm.objects(AccountVK.self)
            
            let accountsVK = Array(accounts)
            
            let addAccountController = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountController") as! AddAccountController
            addAccountController.changeAccount = false
            addAccountController.accounts = accountsVK
            self.navigationController?.pushViewController(addAccountController, animated: true)
        } catch {
            print(error)
        }
    }
    
    func openUsersController(uid: String, title: String, type: String) {
        let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
        
        usersController.userID = uid
        usersController.type = type
        usersController.source = ""
        usersController.title = title
        usersController.view.backgroundColor = vkSingleton.shared.backColor
        
        self.navigationController?.pushViewController(usersController, animated: true)
    }
    
    func openGroupsListController(uid: String, title: String, type: String) {
        let groupsController = self.storyboard?.instantiateViewController(withIdentifier: "GroupsListController") as! GroupsListController
        
        groupsController.userID = uid
        groupsController.type = type
        groupsController.source = ""
        groupsController.title = title
        
        self.navigationController?.pushViewController(groupsController, animated: true)
    }
    
    func openVideoController(ownerID: String, vid: String, accessKey: String, title: String, scrollToComment: Bool) {
        let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoController") as! VideoController
        
        videoController.ownerID = ownerID
        videoController.vid = vid
        videoController.accessKey = accessKey
        videoController.title = title
        
        videoController.delegate = self
        
        self.navigationController?.pushViewController(videoController, animated: true)
        self.playSoundEffect(vkSingleton.shared.dialogSound)
    }
    
    func openTopicsController(groupID: String, group: GroupProfile, title: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TopicsController") as! TopicsController
        
        controller.groupID = groupID
        controller.group.removeAll(keepingCapacity: false)
        controller.group.append(group)
        controller.title = title
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openTopicController(groupID: String, topicID: String, title: String, delegate: UIViewController) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TopicController") as! TopicController
        
        controller.groupID = groupID
        controller.topicID = topicID
        controller.title = title
        controller.delegate = delegate
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openNotesController(userID: String, title: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesController") as! NotesController
        
        controller.userID = userID
        controller.title = title
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openVideoListController(ownerID: String, title: String, type: String) {
        let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
        
        videoController.ownerID = ownerID
        videoController.type = type
        videoController.title = title
        
        self.navigationController?.pushViewController(videoController, animated: true)
    }
    
    func openPhotosListController(ownerID: String, title: String, type: String, isAdmin: Bool) {
        let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
        
        photosController.ownerID = ownerID
        photosController.isAdmin = isAdmin
        photosController.title = title
        
        if type == "photos" {
            photosController.selectIndex = 0
        } else if type == "albums" {
            photosController.selectIndex = 1
        }
        self.navigationController?.pushViewController(photosController, animated: true)
    }
    
    func openPhotoViewController(numPhoto: Int, photos: [Photos]) {
        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
        
        photoViewController.numPhoto = numPhoto
        photoViewController.photos = photos
        
        photoViewController.delegate = self
        
        self.navigationController?.pushViewController(photoViewController, animated: true)
        self.playSoundEffect(vkSingleton.shared.dialogSound)
    }
    
    func openPhotoAlbumController(ownerID: String, albumID: String, title: String, controller: PhotosListController!) {
        let photoAlbumController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumController") as! PhotoAlbumController
        
        photoAlbumController.ownerID = ownerID
        photoAlbumController.albumID = albumID
        photoAlbumController.title = title
        
        if controller != nil {
            if controller.source == "" {
                photoAlbumController.delegate = controller
            } else {
                photoAlbumController.delegate = controller.delegate
            }
            photoAlbumController.source = controller.source
        }
        
        self.navigationController?.pushViewController(photoAlbumController, animated: true)
    }
    
    func openWallRecord(ownerID: Int, postID: Int, accessKey: String, type: String, scrollToComment: Bool) {
        let recordController = self.storyboard?.instantiateViewController(withIdentifier: "Record2Controller") as! Record2Controller
        
        recordController.type = type
        recordController.ownerID = "\(ownerID)"
        recordController.itemID = "\(postID)"
        recordController.accessKey = accessKey
        recordController.scrollToComment = scrollToComment
        
        recordController.delegate = self
        
        self.navigationController?.pushViewController(recordController, animated: true)
        self.playSoundEffect(vkSingleton.shared.dialogSound)
    }
    
    func openPageController(pageID: Int, groupID: Int) {
        let pagesController = self.storyboard?.instantiateViewController(withIdentifier: "PagesController") as! PagesController
        
        pagesController.pageID = pageID
        pagesController.groupID = groupID
        pagesController.title = "Страница"
        
        self.navigationController?.pushViewController(pagesController, animated: true)
    }
    
    func openFavePostsController() {
        let favesController = self.storyboard?.instantiateViewController(withIdentifier: "FavePostsController2") as! FavePostsController2
        
        self.navigationController?.pushViewController(favesController, animated: true)
    }
    
    func openMembersController(groupID: Int, filters: String, title: String, isAdmin: Bool) {
        let membersController = self.storyboard?.instantiateViewController(withIdentifier: "MembersController") as! MembersController
        
        membersController.groupID = groupID
        membersController.filters = filters
        membersController.isAdmin = isAdmin
        membersController.title = title
        
        self.navigationController?.pushViewController(membersController, animated: true)
    }
    
    func openNewRecordController(ownerID: String, type: String, message: String, title: String, controller: Record2Controller!, delegate: UIViewController) {
        
        let newRecordController = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
        
        newRecordController.ownerID = ownerID
        newRecordController.type = type
        newRecordController.message = message
        newRecordController.title = title
        
        if controller != nil {
            newRecordController.delegate = controller
            newRecordController.record = controller.news[0]
        }
        
        newRecordController.delegate2 = delegate
        
        self.navigationController?.pushViewController(newRecordController, animated: true)
    }
    
    func openNewCommentController(ownerID: String, message: String, type: String, title: String, replyID: Int, replyName: String, comment: Comments!, controller: UIViewController) {
        
        let newCommentController = self.storyboard?.instantiateViewController(withIdentifier: "NewCommentController") as! NewCommentController
        
        newCommentController.ownerID = ownerID
        newCommentController.message = message
        newCommentController.type = type
        newCommentController.title = title
        
        newCommentController.replyID = replyID
        newCommentController.replyName = replyName
        newCommentController.delegate = controller
        
        if comment != nil {
            newCommentController.comment = comment
        }
        
        self.navigationController?.pushViewController(newCommentController, animated: true)
    }
    
    func openAddTopicController(ownerID: String, title: String, delegate: UIViewController) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddTopicController") as! AddTopicController
        
        controller.ownerID = ownerID
        controller.title = title
        controller.delegate = delegate
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openNewsfeedSearchController(ownerID: Int, hash: String) {
        
        let searchController = self.storyboard?.instantiateViewController(withIdentifier: "NewsfeedSearchController") as! NewsfeedSearchController
        
        searchController.title = "\(hash)"
        searchController.searchText = "\(hash)"
        searchController.ownerID = "\(ownerID)"
        
        self.navigationController?.pushViewController(searchController, animated: true)
    }
    
    func openOptionsController() {
        let optionsController = self.storyboard?.instantiateViewController(withIdentifier: "OptionsController") as! OptionsController
        
        
        self.navigationController?.pushViewController(optionsController, animated: true)
    }
    
    func openMyMusicController(ownerID: String) {
        let myMusicController = self.storyboard?.instantiateViewController(withIdentifier: "MyMusicController") as! MyMusicController
        
        myMusicController.ownerID = ownerID
        
        self.navigationController?.pushViewController(myMusicController, animated: true)
    }
    
    func openPhoto(not: Notifications) {
        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
        
        let photos = Photos(json: JSON.null)
        photos.ownerID = "\(not.parent[0].ownerID)"
        photos.uid = "\(not.parent[0].fromID)"
        photos.pid = "\(not.parent[0].id)"
        photos.text = not.parent[0].text
        if not.type == "reply_comment_photo" || not.type == "like_comment_photo" {
            photos.pid = "\(not.parent[0].typeID)"
        }
        photos.xxbigPhotoURL = not.parent[0].photoURL
        photos.xbigPhotoURL = not.parent[0].photoURL
        photos.bigPhotoURL = not.parent[0].photoURL
        photos.photoURL = not.parent[0].photoURL
        photos.width = not.parent[0].width
        photos.height = not.parent[0].height
        photoViewController.photos.append(photos)
        photoViewController.numPhoto = 0
        
        photoViewController.delegate = self
        
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    func checkVKLink(url: String) -> Int {
        
        if url.containsIgnoringCase(find: "vk.com") || url.containsIgnoringCase(find: "vk.cc") {
            
            var res = 1
            
            var str1 = url.replacingOccurrences(of: "https://vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "https://m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "http://vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "http://m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "vk.com/", with: "")
            let str2 = str1.components(separatedBy: "=")
            if str2.count > 1 {
                str1 = str2[1]
            }
            
            var type = str1.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: nil)
            type = type.replacingOccurrences(of: "_", with: "", options: .regularExpression, range: nil)
            type = type.replacingOccurrences(of: "-", with: "", options: .regularExpression, range: nil)
            
            if type == "id" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openProfileController(id: ownerID, name: "")
                    }
                }
                
                res = 0
            } else if type == "club" || type == "event" || type == "public" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openProfileController(id: -1 * abs(ownerID), name: "")
                    }
                }
                
                res = 0
            } else if type == "wall" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let postID = Int(accs[1]) {
                        openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post", scrollToComment: false)
                    }
                }
                
                res = 0
            } else if type == "photo" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let photoID = Int(accs[1]) {
                        openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo", scrollToComment: false)
                    }
                }
                
                res = 0
            } else if type == "video" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let videoID = Int(accs[1]) {
                        openVideoController(ownerID: "\(ownerID)", vid: "\(videoID)", accessKey: "", title: "", scrollToComment: false)
                    }
                }
                
                res = 0
            } else if type == "myownlinkchat" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 3 {
                    if let chatID = Int(accs[2]) {
                        let url = "/method/messages.getHistory"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "offset": "0",
                            "count": "1",
                            "user_id": "\(2000000000 + chatID)",
                            "start_message_id": "-1",
                            "extended": "1",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                        OperationQueue().addOperation(getServerDataOperation)
                        
                        let parseDialog = ParseDialogHistory()
                        parseDialog.completionBlock = {
                            OperationQueue.main.addOperation {
                                self.openDialogController(userID: "\(2000000000 + chatID)", chatID: "\(chatID)", startID: parseDialog.lastMessageId, attachment: "", messIDs: [], image: nil)
                            }
                        }
                        parseDialog.addDependency(getServerDataOperation)
                        OperationQueue().addOperation(parseDialog)
                    }
                }
                
                res = 0
            } else if type == "topic" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let groupID = Int(accs[0]), let topicID = Int(accs[1]) {
                        openTopicController(groupID: "\(abs(groupID))", topicID: "\(topicID)", title: "", delegate: self)
                    }
                }
                
                res = 0
            } else if type == "album" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let albumID = Int(accs[1]) {
                        openPhotoAlbumController(ownerID: "\(ownerID)", albumID: "\(albumID)", title: "", controller: nil)
                    }
                }
                
                res = 0
            } else if type == "albums" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openPhotosListController(ownerID: "\(ownerID)", title: "", type: "albums", isAdmin: false)
                    }
                }
                
                res = 0
            } else if str1.hasPrefix("@") {
                
                res = 5
            } else if str2.count == 1 {
                let url1 = "/method/utils.resolveScreenName"
                let parameters1 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "screen_name": "\(str2[0])",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url1, parameters: parameters1)
                
                res = 0
                request.completionBlock = {
                    guard let data = request.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        let typeObj = json["response"]["type"].stringValue
                        let ownerID = json["response"]["object_id"].intValue
                        
                        if typeObj == "user" {
                            OperationQueue.main.addOperation {
                                self.openProfileController(id: ownerID, name: "")
                            }
                        }
                        
                        if typeObj == "group" {
                            OperationQueue.main.addOperation {
                                self.openProfileController(id: -1 * ownerID, name: "")
                            }
                        }
                        
                        if typeObj == "application" || typeObj == "" {
                            if AppConfig.shared.setOfflineStatus {
                                res = 2
                            } else {
                                res = 1
                            }
                        }
                    }
                }
                OperationQueue().addOperation(request)
            }
            
            
            if res == 1 && AppConfig.shared.setOfflineStatus {
                res = 2
            }
            
            return res
        } else if url.containsIgnoringCase(find: "itunes.apple.com") {
            
            return 3
        }
        
        return 1
    }
    
    func openBrowserControllerNoCheck(url: String) {
        
        playSoundEffect(vkSingleton.shared.linkSound)
        if let url1 = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            guard URL(string: url1) != nil else {
                showErrorMessage(title: "Ошибка!", msg: "Некорректная ссылка:\n\(url1)")
                return
            }
            
            var validURL = url1
            if !url1.containsIgnoringCase(find: "http") && !url1.containsIgnoringCase(find: "https") {
                validURL = "http://\(url1)"
            }
            
            if #available(iOS 11.0, *) {
                if let url = URL(string: validURL) {
                    let config = SFSafariViewController.Configuration()
                    config.entersReaderIfAvailable = false

                    let browserController = SFSafariViewController(url: url, configuration: config)
                    browserController.preferredControlTintColor = .white
                    browserController.preferredBarTintColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
                    
                    let mainColor = vkSingleton.shared.mainColor
                    let backColor = vkSingleton.shared.backColor
                    
                    if #available(iOS 13.0, *) {
                        if AppConfig.shared.autoMode {
                            if self.traitCollection.userInterfaceStyle == .dark {
                                browserController.overrideUserInterfaceStyle = .dark
                                browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                                browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                            } else {
                                browserController.overrideUserInterfaceStyle = .light
                                browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                                browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                            }
                        } else if AppConfig.shared.darkMode {
                            browserController.overrideUserInterfaceStyle = .dark
                            browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                            browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                        } else {
                            browserController.overrideUserInterfaceStyle = .light
                            browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                            browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                        }
                    } else {
                        browserController.preferredBarTintColor = mainColor
                        browserController.view.backgroundColor = backColor
                    }
                    
                    self.present(browserController, animated: true)
                }
            } else {
                if let url = URL(string: validURL) {
                    let browserController = self.storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
                    browserController.path = url.absoluteString
                    self.navigationController?.pushViewController(browserController, animated: true)
                }
            }
        } else {
            showErrorMessage(title: "Ошибка!", msg: "Некорректная ссылка:\n\(url)")
        }
    }
    
    func openBrowserController(url: String) {
        
        let res = checkVKLink(url: url)
        playSoundEffect(vkSingleton.shared.linkSound)
        
        switch res {
        case 0:
            break
        case 1:
            self.openBrowserControllerNoCheck(url: url)
        case 2:
            let alertController = UIAlertController(title: "внутренняя ссылка ВКонтакте:", message: url, preferredStyle: .actionSheet)
             
             let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
             alertController.addAction(cancelAction)
             
             let action1 = UIAlertAction(title: "Открыть ссылку", style: .destructive){ action in
             
                self.openBrowserControllerNoCheck(url: url)
             }
             alertController.addAction(action1)
             
             present(alertController, animated: true)
        case 3:
            if let stringURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let validURL = URL(string: stringURL) {
                
                UIApplication.shared.open(validURL, options: [:])
            }
        default:
            self.openBrowserControllerNoCheck(url: url)
        }
    }
    
    func writeReviewAppStore() {
        if let validURL = URL(string: "https://itunes.apple.com/ru/app/id1357517067?mt=8&action=write-review") {
            
            UIApplication.shared.open(validURL, options: [:])
        }
    }
    
    func setOfflineStatus(dependence: Operation?) {
        if AppConfig.shared.setOfflineStatus {
            let url = "/method/account.setOffline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence { request.addDependency(operation) }
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("offline: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        } else {
            let url = "/method/account.setOnline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence { request.addDependency(operation) }
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("online: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func showErrorMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("OK", action: {})
            alert.showError(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func showSuccessMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("OK", action: {})
            alert.showSuccess(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.infoSound)
        }
    }
    
    func showInfoMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("OK", action: {})
            alert.showInfo(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.infoSound)
        }
    }
    
    func showInfoMessage(title: String, msg: String, completion: @escaping () -> (Void)) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("OK", action: {
                completion()
            })
            alert.showInfo(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.infoSound)
        }
    }
    
    func showSettingsMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("Перейти в настройки", action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            })
            
            alert.addButton("Отмена", action: {})
            
            alert.showError(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func createNewChat() {
        
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
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 30))
        
        textField.layer.borderColor = titleColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.backgroundColor = vkSingleton.shared.backColor
        textField.font = UIFont(name: "Verdana", size: 13)
        textField.textColor = vkSingleton.shared.secondaryLabelColor
        textField.keyboardType = .default
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.placeholder = "Название чата"
        textField.text = ""
        textField.changeKeyboardAppearanceMode()
        
        alert.customSubview = textField
        
        alert.addButton("Готово", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            self.view.endEditing(true);
            if let text = textField.text {
                if !text.isEmpty {
                    let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                    
                    usersController.userID = vkSingleton.shared.userID
                    usersController.type = "friends"
                    usersController.source = "create_chat"
                    usersController.title = "Пригласить в чат"
                    usersController.chatTitle = text
                    
                    usersController.navigationItem.hidesBackButton = true
                    let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: usersController, action: #selector(usersController.tapCancelButton(sender:)))
                    usersController.navigationItem.leftBarButtonItem = cancelButton
                    
                    usersController.chatButton = UIBarButtonItem(title: "Готово", style: .done, target: usersController, action: #selector(usersController.tapOKButton(sender:)))
                    usersController.chatButton.isEnabled = false
                    usersController.navigationItem.rightBarButtonItem = usersController.chatButton
                    
                    usersController.delegate = self
                    
                    self.navigationController?.pushViewController(usersController, animated: true)
                } else {
                    self.showErrorMessage(title: "Ошибка при создании чата", msg: "Необходимо ввести название для нового чата.")
                }
            } else {
                self.showErrorMessage(title: "Ошибка при создании чата", msg: "Необходимо ввести название для нового чата.")
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
        
        alert.showInfo("Введите название чата:", subTitle: "")
    }
    
    func editChatTitle(oldTitle: String, chatID: String) {
        
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
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 30))
        
        textField.layer.borderColor = titleColor.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.backgroundColor = vkSingleton.shared.backColor
        textField.font = UIFont(name: "Verdana", size: 13)
        textField.textColor = vkSingleton.shared.secondaryLabelColor
        textField.keyboardType = .default
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .sentences
        textField.placeholder = "Название чата"
        textField.text = oldTitle
        textField.changeKeyboardAppearanceMode()
        
        alert.customSubview = textField
        
        alert.addButton("Готово", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            self.view.endEditing(true);
            if let text = textField.text {
                if !text.isEmpty {
                    self.editChat(newTitle: text, chatID: chatID)
                } else {
                    self.showErrorMessage(title: "Ошибка редактирования чата", msg: "Необходимо ввести новое название чата.")
                }
            } else {
                self.showErrorMessage(title: "Ошибка редактирования чата", msg: "Необходимо ввести новое название чата.")
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
        
        alert.showInfo("Введите новое название чата:", subTitle: "")
    }
    
    func updateAccountInRealm(account: AccountVK) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = account.token
                    }
                }
            }
            let realm = try Realm(configuration: config)
            
            //print(realm.configuration.fileURL!)
            
            realm.beginWrite()
            realm.add(account, update: .all)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func deleteAccountFromRealm(userID: Int) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = vkSingleton.shared.accessToken
                    }
                }
            }
            let realm = try Realm(configuration: config)
            
            let account = realm.objects(AccountVK.self).filter("userID == %@", userID)
            
            realm.beginWrite()
            realm.delete(account)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func getAccessTokenFromRealm(userID: Int) -> String {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = vkSingleton.shared.accessToken
                    }
                }
            }
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(AccountVK.self).filter("userID == %@", userID)

            
            let accounts = Array(realmAccounts)
            if accounts.count > 0 {
                return accounts[0].token
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
    func getNumberOfAccounts() -> Int {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = vkSingleton.shared.accessToken
                    }
                }
            }
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(AccountVK.self)
            let accounts = Array(realmAccounts)
            return accounts.count
        } catch {
            print(error)
        }
        
        return 0
    }
    
    func readAppConfig() {
        OperationQueue().addOperation {
            
            let userDefault = UserDefaults.standard
            
            if userDefault.string(forKey: "\(vkSingleton.shared.userID)_firstAppear") == nil {
                
                AppConfig.shared.pushNotificationsOn = false
                AppConfig.shared.pushNewMessage = true
                AppConfig.shared.pushComment = true
                AppConfig.shared.pushNewFriends = true
                AppConfig.shared.pushNots = true
                AppConfig.shared.pushLikes = true
                AppConfig.shared.pushMentions = true
                AppConfig.shared.pushFromGroups = true
                AppConfig.shared.pushNewPosts = true
                
                AppConfig.shared.showStartMessage = true
                
                AppConfig.shared.setOfflineStatus = true
                AppConfig.shared.checkUnreadMessageWhileStart = false
                AppConfig.shared.readMessageInDialog = true
                AppConfig.shared.showTextEditInDialog = true
                
                AppConfig.shared.soundEffectsOn = true
            } else {
            
                AppConfig.shared.pushNotificationsOn = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
            
                AppConfig.shared.pushNewMessage = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewMessage")
            
                AppConfig.shared.pushComment = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushComment")
                
                AppConfig.shared.pushNewFriends = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewFriends")
                
                AppConfig.shared.pushNots = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNots")
             
                AppConfig.shared.pushLikes = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushLikes")
                
                AppConfig.shared.pushMentions = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushMentions")
                
                AppConfig.shared.pushFromGroups = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushFromGroups")
                
                AppConfig.shared.pushNewPosts = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewPosts")
                
                AppConfig.shared.showStartMessage = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_showStartMessage")
                
                AppConfig.shared.setOfflineStatus = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_setOfflineStatus")
                
                AppConfig.shared.checkUnreadMessageWhileStart = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_checkUnreadMessageWhileStart")
                
                AppConfig.shared.readMessageInDialog = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_readMessageInDialog")
                
                AppConfig.shared.showTextEditInDialog = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_showTextEditInDialog")
                
                AppConfig.shared.soundEffectsOn = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_soundEffectsOn")
            }
            
            AppConfig.shared.passwordOn = userDefault.bool(forKey: "passwordOn")
            AppConfig.shared.touchID = userDefault.bool(forKey: "touchID")
            
            AppConfig.shared.autoMode = userDefault.bool(forKey: "vktotal_autoMode")
            AppConfig.shared.darkMode = userDefault.bool(forKey: "vktotal_darkMode")
            
            if let digits = userDefault.string(forKey: "passDigits") {
                AppConfig.shared.passwordDigits = digits
            } else {
                AppConfig.shared.passwordDigits = "0000"
            }
        }
    }
    
    func saveAppConfig() {
        
        let userDefault = UserDefaults.standard
        
        userDefault.set(AppConfig.shared.pushNotificationsOn, forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
        
        userDefault.set(AppConfig.shared.pushNewMessage, forKey: "\(vkSingleton.shared.userID)_pushNewMessage")
        
        userDefault.set(AppConfig.shared.pushComment, forKey: "\(vkSingleton.shared.userID)_pushComment")
        
        userDefault.set(AppConfig.shared.pushNewFriends, forKey: "\(vkSingleton.shared.userID)_pushNewFriends")
        
        userDefault.set(AppConfig.shared.pushNots, forKey: "\(vkSingleton.shared.userID)_pushNots")
        
        userDefault.set(AppConfig.shared.pushLikes, forKey: "\(vkSingleton.shared.userID)_pushLikes")
        
        userDefault.set(AppConfig.shared.pushMentions, forKey: "\(vkSingleton.shared.userID)_pushMentions")
        
        userDefault.set(AppConfig.shared.pushFromGroups, forKey: "\(vkSingleton.shared.userID)_pushFromGroups")
        
        userDefault.set(AppConfig.shared.pushNewPosts, forKey: "\(vkSingleton.shared.userID)_pushNewPosts")
        
        userDefault.set(AppConfig.shared.showStartMessage, forKey: "\(vkSingleton.shared.userID)_showStartMessage")
        
        userDefault.set(AppConfig.shared.setOfflineStatus, forKey: "\(vkSingleton.shared.userID)_setOfflineStatus")
        
        userDefault.set(AppConfig.shared.checkUnreadMessageWhileStart, forKey: "\(vkSingleton.shared.userID)_checkUnreadMessageWhileStart")
        
        userDefault.set(AppConfig.shared.readMessageInDialog, forKey: "\(vkSingleton.shared.userID)_readMessageInDialog")
        
        userDefault.set(AppConfig.shared.showTextEditInDialog, forKey: "\(vkSingleton.shared.userID)_showTextEditInDialog")
        
        userDefault.set(AppConfig.shared.soundEffectsOn, forKey: "\(vkSingleton.shared.userID)_soundEffectsOn")
        
        userDefault.setValue("first", forKey: "\(vkSingleton.shared.userID)_firstAppear")
        
        userDefault.set(AppConfig.shared.passwordOn, forKey: "passwordOn")
        userDefault.set(AppConfig.shared.touchID, forKey: "touchID")
        userDefault.set(AppConfig.shared.passwordDigits, forKey: "passDigits")
        //userDefault.set("0000", forKey: "passDigits")
        
        userDefault.set(AppConfig.shared.autoMode, forKey: "vktotal_autoMode")
        userDefault.set(AppConfig.shared.darkMode, forKey: "vktotal_darkMode")
    }
    
    func commentReplyRecordController(replyName: String, replyText: String, indexPath: IndexPath, controller: Record2Controller) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
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
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = "\(replyText)"
        textView.changeKeyboardAppearanceMode()
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            controller.createRecordComment(text: textView.text, attachments: controller.attachments, replyID: controller.comments[controller.comments.count - indexPath.row].id, guid: "\(Date().timeIntervalSince1970)", stickerID: 0, controller: controller)
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Введите ваш ответ \(replyName):", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func commentReplyVideoController(replyName: String, replyText: String, indexPath: IndexPath, controller: VideoController) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
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
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = "\(replyText)"
        textView.changeKeyboardAppearanceMode()
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            controller.createVideoComment(text: textView.text, attachments: controller.attachments, stickerID: 0, replyID: controller.comments[controller.comments.count - indexPath.row].id, guid: "\(Date().timeIntervalSince1970)", controller: controller)
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Введите ваш ответ \(replyName):", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func repost(description: String, ownerID: String, itemID: String, type: String) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
        let appearance = SCLAlertView.SCLAppearance(
            //kCircleHeight: 60,
            kCircleIconHeight: 40,
            kTitleTop: 32.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: true,
            circleBackgroundColor: backColor,
            contentViewColor: backColor,
            titleColor: titleColor
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 150))
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = ""
        textView.changeKeyboardAppearanceMode()
        
        alert.customSubview = textView
        
        alert.addButton("Опубликовать на своей стене") {
            
            var object = "wall\(ownerID)_\(itemID)"
            if type == "photo" {
                object = "photo\(ownerID)_\(itemID)"
            } else if type == "video" {
                object = "video\(ownerID)_\(itemID)"
            }
            self.repostObject(object: object, message: textView.text)
        }
        alert.addButton("Отмена") {
            
        }
        
        alert.showInfo("\(description)\n\nВведите сопровождающий текст:", subTitle: "", circleIconImage: UIImage(named: "repost_big")!)
    }
    
    func editRecord(description: String, record: Record, controller: Record2Controller) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 32.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: true,
            circleBackgroundColor: backColor,
            contentViewColor: backColor,
            titleColor: titleColor
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 150))
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = record.text
        textView.changeKeyboardAppearanceMode()
        
        alert.customSubview = textView
        
        alert.addButton("Готово") {
            
            self.editPost(ownerID: record.ownerID, postID: record.id, message: textView.text, attachments: "", friendsOnly: 0, signed: 0, publish: 0, controller: controller)
        }
        alert.addButton("Отмена") {
            
        }
        
        alert.showEdit(description, subTitle: "")
    }
    
    func searchITunes(searchArtist: String, searchAlbum: String, searchSong: String, completion: @escaping ([IMusic]) -> Void) {
        
        let searchText = "\(searchSong) \(searchArtist) \(searchAlbum)"
        let escapedString = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        var lang = "us"
        if #available(iOS 11.0, *) {
            lang = NSLinguisticTagger.dominantLanguage(for: searchText)!
        }
        if (lang != "ru") { lang = "us" }
            
        let url = URL(string: "https://itunes.apple.com/search?term=\(escapedString!)&media=music&entity=song&limit=200&country=\(lang)")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data: Data!, response: URLResponse!, error: Error!) -> Void in
            if error == nil {
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                let music: [IMusic] = json["results"].compactMap { IMusic(json: $0.1) }
            
                completion(music)
            }
        })
        
        task.resume()
        
    }
    
    func refineITunesRequest(artist: String, title: String) {
        
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
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 70))
        view.backgroundColor = .clear
        
        let textField1 = UITextField(frame: CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width - 64, height: 30))
        textField1.layer.borderColor = titleColor.cgColor
        textField1.layer.borderWidth = 1
        textField1.layer.cornerRadius = 5
        textField1.backgroundColor = vkSingleton.shared.backColor
        textField1.font = UIFont(name: "Verdana", size: 13)
        textField1.textColor = vkSingleton.shared.secondaryLabelColor
        textField1.keyboardType = .default
        textField1.textAlignment = .center
        textField1.clearButtonMode = .whileEditing
        textField1.autocapitalizationType = .sentences
        textField1.placeholder = "Исполнитель песни"
        textField1.text = artist
        textField1.changeKeyboardAppearanceMode()
        view.addSubview(textField1)
        
        let textField2 = UITextField(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width - 64, height: 30))
        textField2.layer.borderColor = titleColor.cgColor
        textField2.layer.borderWidth = 1
        textField2.layer.cornerRadius = 5
        textField2.backgroundColor = vkSingleton.shared.backColor
        textField2.font = UIFont(name: "Verdana", size: 13)
        textField2.textColor = vkSingleton.shared.secondaryLabelColor
        textField2.keyboardType = .default
        textField2.textAlignment = .center
        textField2.clearButtonMode = .whileEditing
        textField2.autocapitalizationType = .sentences
        textField2.placeholder = "Название песни"
        textField2.text = title
        textField2.changeKeyboardAppearanceMode()
        view.addSubview(textField2)
        
        alert.customSubview = view
        
        alert.addButton("Искать в Apple Music", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            guard let artist1 = textField1.text, let title1 = textField2.text else { return }
            
            if artist1.isEmpty || title1.isEmpty {
                self.showInfoMessage(title: "Внимание!", msg: "\nПожалуйста, введите исполнителя и название песни. Запрос на поиск в Apple Music не может быть отправлен с пустыми значениями.\n", completion: {
                    self.refineITunesRequest(artist: artist, title: title)
                })
            } else {
                self.getITunesInfo2(artist: artist1, title: title1)
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {}
        
        alert.showInfo("При необходимости Вы можете уточнить запрос в Apple Music - для этого отредактируйте наименование исполнителя или песни:", subTitle: "")
    }
    
    func getITunesInfo2(artist: String, title: String) {
        
        if let vc = self as? Newsfeed2Controller {
            ViewControllerUtils().showActivityIndicator(uiView: vc.tableView.superview!)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let alertController = UIAlertController(title: "\(artist)\n«\(title)»", message: nil, preferredStyle: .actionSheet)
        
        let completionBlock = {
            OperationQueue.main.addOperation {
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action = UIAlertAction(title: "Скопировать название песни", style: .default) { action in
                    
                    let link = "\(artist)\n«\(title)»"
                    UIPasteboard.general.string = link
                    if let string = UIPasteboard.general.string {
                        self.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
                    }
                }
                alertController.addAction(action)
                
                let action2 = UIAlertAction(title: "Уточнить запрос в Apple Music", style: .destructive) { action in
                    
                    self.refineITunesRequest(artist: artist, title: title)
                }
                alertController.addAction(action2)
                
                ViewControllerUtils().hideActivityIndicator()
                self.present(alertController, animated: true)
            }
        }
        
        var lang = "us"
        lang = NSLinguisticTagger.dominantLanguage(for: artist)!
        if lang != "ru" { lang = "us" }
        
        
        let url = "https://itunes.apple.com/search/"
        let parameters = [
            "term": artist,
            "media": "music",
            "country": lang,
            "entity": "musicArtist"
        ]
        
        let request = GetITunesDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else {
                completionBlock()
                return
            }
            
            guard let json = try? JSON(data: data) else {
                completionBlock()
                print("json error")
                return
            }
            //print(json)
            
            let count = json["resultCount"].intValue
            if count > 0 {
                OperationQueue.main.addOperation {
                    let action = UIAlertAction(title: "Открыть исполнителя в Apple Music", style: .default) { action in
                        
                        let workURL = json["results"][0]["artistLinkUrl"].stringValue
                        self.openBrowserControllerNoCheck(url: workURL)
                    }
                    alertController.addAction(action)
                }
            }
            
            var lang = "us"
            lang = NSLinguisticTagger.dominantLanguage(for: "\(title) \(artist)")!
            if lang != "ru" { lang = "us" }
            
            
            let url2 = "https://itunes.apple.com/search/"
            let parameters2 = [
                "term": "\(title) \(artist)",
                "media": "music",
                "country": lang
            ]
            
            let request2 = GetITunesDataOperation(url: url2, parameters: parameters2)
            request2.completionBlock = {
                guard let data2 = request2.data else {
                    completionBlock()
                    return
                }
                
                guard let json2 = try? JSON(data: data2) else {
                    completionBlock()
                    print("json error")
                    return
                }
                //print(json2)
                
                let count = json2["resultCount"].intValue
                if count > 0 {
                    OperationQueue.main.addOperation {
                        let song = IMusic(json: json2["results"][0])
                        
                        let action2 = UIAlertAction(title: "Сохранить песню в «Избранное»", style: .default) { action in
                            
                            do {
                                var config = Realm.Configuration.defaultConfiguration
                                config.deleteRealmIfMigrationNeeded = false
                                config.schemaVersion = 1
                                
                                let realm = try Realm(configuration: config)
                                
                                realm.beginWrite()
                                realm.add(song, update: .all)
                                try realm.commitWrite()
                                self.showSuccessMessage(title: "Моя музыка iTunes", msg: "Песня «\(song.song)» успешно записана в «Избранное»")
                            } catch {
                                self.showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
                            }
                        }
                        alertController.addAction(action2)
                        
                        if let songURL = URL(string: song.reserv4.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            let action = UIAlertAction(title: "Прослушать отрывок из песни", style: .default) { action in
                                
                                if let vc = self as? Record2Controller {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? ProfileController2 {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? GroupProfileController2 {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? TopicController {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? Newsfeed2Controller {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? NewsfeedSearchController {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? FavePostsController2 {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? DialogController {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                } else if let vc = self as? GroupDialogController {
                                    vc.player.pause()
                                    vc.player = AVPlayer(url: songURL)
                                    vc.player.seek(to: CMTime.zero)
                                    vc.player.play()
                                    vc.showAudioPlayOnScreen(song: song, player: vc.player)
                                }
                            }
                            alertController.addAction(action)
                        }
                        
                        let action1 = UIAlertAction(title: "Открыть песню в Apple Music", style: .default) { action in
                        
                            self.openBrowserControllerNoCheck(url: song.URL)
                        }
                        alertController.addAction(action1)
                    }
                }
                
                completionBlock()
            }
            OperationQueue().addOperation(request2)
        }
        OperationQueue().addOperation(request)
    }
    
    func saveGifToDevice(url: URL) {
        if let data = try? Data(contentsOf: url) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
            })
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                self.showSuccessMessage(title: "Сохранение на устройство", msg: "GIF успешно сохранена на ваше устройство.")
            }
            
        } else {
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                self.showErrorMessage(title: "Сохранение на устройство", msg: "Возникла неизвестная ошибка при сохранении GIF на устройство")
            }
        }
    }
    
    func commentToReport(userID: String, reason: String) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
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
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = ""
        textView.changeKeyboardAppearanceMode()
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Отправить жалобу", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            self.reportUser(userID: userID, type: reason, comment: textView.text!)
        }
        
        alert.addButton("Отмена, я передумал", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Комментарий к жалобе:", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func reportOnUser(userID: String) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Порнография", style: .default) { action in
            self.commentToReport(userID: userID, reason: "porn")
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Рассылка спама", style: .default) { action in
            self.commentToReport(userID: userID, reason: "spam")
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Оскорбительное поведение", style: .default) { action in
            self.commentToReport(userID: userID, reason: "insult")
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Навязчивая рекламная страница", style: .default) { action in
            self.commentToReport(userID: userID, reason: "advertisment")
        }
        alertController.addAction(action4)
        
        present(alertController, animated: true)
    }
    
    func commentToReportOnObject(ownerID: String, itemID: String, type: String, reason: Int) {
        
        var titleColor = UIColor.black
        var backColor = UIColor.white
        
        titleColor = vkSingleton.shared.labelColor
        backColor = vkSingleton.shared.backColor
        
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
        
        textView.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = ""
        textView.changeKeyboardAppearanceMode()
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Отправить жалобу", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
            self.reportObject(ownerID: ownerID, type: type, reason: reason, itemID: itemID, comment: textView.text!)
        }
        
        alert.addButton("Отмена, я передумал", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Комментарий к жалобе:", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func reportOnObject(ownerID: String, itemID: String, type: String) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Это спам", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 0)
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Детская порнография", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 1)
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Экстремизм", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 2)
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Насилие", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 3)
        }
        alertController.addAction(action4)
        
        let action5 = UIAlertAction(title: "Пропаганда наркотиков", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 4)
        }
        alertController.addAction(action5)
        
        let action6 = UIAlertAction(title: "Материал для взрослых", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 5)
        }
        alertController.addAction(action6)
        
        let action7 = UIAlertAction(title: "Оскорбление", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 6)
        }
        alertController.addAction(action7)
        
        let action8 = UIAlertAction(title: "Призыв к суициду", style: .default) { action in
            self.commentToReportOnObject(ownerID: ownerID, itemID: itemID, type: type, reason: 8)
        }
        alertController.addAction(action8)
        
        present(alertController, animated: true)
    }
    
    func showNotification(text: String) {
        
        let view = MessageView.viewFromNib(layout: .tabView)
        view.backgroundView.backgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
        view.configureContent(title: "ВКлючайся!", body: text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "", buttonTapHandler: nil)
        
        
        view.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        view.titleLabel?.textColor = vkSingleton.shared.mainColor
        
        view.button?.isHidden = true
        view.bodyLabel?.font = UIFont(name: "Verdana", size: 13)!
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(self.tapNotificationView))
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 5)
        config.interactiveHide = true
        
        SwiftMessages.show(config: config, view: view)
    }
    
    @objc func tapNotificationView() {
        SwiftMessages.hideAll()
        if self is UITabBarController {
            if let tabbarController =  self as? UITabBarController {
                tabbarController.selectedIndex = 1
            }
        } else if self is UINavigationController {
            if let navigationController = self as? UINavigationController {
                navigationController.tabBarController?.selectedIndex = 1
            }
        } else {
            self.navigationController?.tabBarController?.selectedIndex = 1
        }
    }
    
    func showMessageNotification(title: String, text: String, userID: Int, chatID: Int, groupID: Int, startID: Int) {
        
        if userID > 0 {
            let url = "/method/users.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "user_id": "\(userID)",
                "fields": "photo_50",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                guard let json = try? JSON(data: data) else { return }
                
                let id = json["response"][0]["id"].intValue
                if id > 0 {
                    let fname = json["response"][0]["first_name"].stringValue
                    let lname = json["response"][0]["last_name"].stringValue
                    
                    let name = "\(fname) \(lname)"
                    let url = json["response"][0]["photo_50"].stringValue
                    let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            let image = getCacheImage.outputImage
                            
                            if chatID != 0 {
                                let url = "/method/messages.getChat"
                                 let parameters = [
                                    "access_token": vkSingleton.shared.accessToken,
                                    "chat_id": "\(chatID)",
                                    "v": vkSingleton.shared.version
                                ]
                                
                                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                                getServerDataOperation.completionBlock = {
                                    guard let data = getServerDataOperation.data else { return }
                                    guard let json = try? JSON(data: data) else { return }
                                    
                                    var chatTitle = json["response"]["title"].stringValue
                                    if chatTitle.length > 30 {
                                        chatTitle = "\(chatTitle.prefix(30))..."
                                    }
                                    OperationQueue.main.addOperation {
                                        self.showMessageOnScreen(title: "\(chatTitle)\n\(name)", text: text, image: image, userID: userID, chatID: chatID, groupID: groupID, startID: startID)
                                    }
                                }
                                OperationQueue().addOperation(getServerDataOperation)
                            } else {
                                self.showMessageOnScreen(title: "\(name)", text: text, image: image, userID: userID, chatID: chatID, groupID: groupID, startID: startID)
                            }
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                } else {
                    OperationQueue.main.addOperation {
                        self.showMessageOnScreen(title: title, text: text, image: nil, userID: 0, chatID: chatID, groupID: groupID, startID: startID)
                    }
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        } else {
            let url = "/method/groups.getById"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": "\(abs(userID))",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            OperationQueue().addOperation(getServerDataOperation)
            
            let parseGroupProfile = ParseGroupProfile()
            parseGroupProfile.addDependency(getServerDataOperation)
            parseGroupProfile.completionBlock = {
                if parseGroupProfile.outputData.count > 0 {
                    let group = parseGroupProfile.outputData[0]
                    let name = "\(group.name)"
                    let url = group.photo50
                    let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            let image = getCacheImage.outputImage
                            self.showMessageOnScreen(title: "\(name)", text: text, image: image, userID: userID, chatID: 0, groupID: groupID, startID: startID)
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                } else {
                    OperationQueue.main.addOperation {
                        self.showMessageOnScreen(title: title, text: text, image: nil, userID: 0, chatID: 0, groupID: 0, startID: startID)
                    }
                }
            }
            OperationQueue().addOperation(parseGroupProfile)
        }
    }
    
    func showMessageOnScreen(title: String, text: String, image: UIImage?, userID: Int, chatID: Int, groupID: Int, startID: Int) {
        let view = MessageView.viewFromNib(layout: .tabView)
        view.backgroundView.backgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
        view.configureContent(title: title, body: text, iconImage: image, iconText: nil, buttonImage: nil, buttonTitle: "", buttonTapHandler: nil)
        
        if image != nil {
            view.iconImageView?.clipsToBounds = true
            view.iconImageView?.contentMode = .scaleAspectFill
            view.iconImageView?.layer.cornerRadius = 24
            view.iconImageView?.layer.borderColor = UIColor.lightGray.cgColor
            view.iconImageView?.layer.borderWidth = 1.0
        }
        view.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        view.titleLabel?.minimumScaleFactor = 0.6
        view.titleLabel?.textColor = UIColor.black
        if chatID != 0 {
            view.titleLabel?.numberOfLines = 2
        }
        
        view.button?.isHidden = true
        view.bodyLabel?.font = UIFont(name: "Verdana", size: 11)!
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        if userID != 0 {
            tap.add {
                SwiftMessages.hideAll()
                if groupID != 0 {
                    if self.presentedViewController == nil {
                        self.openGroupDialogController(userID: "\(userID)", groupID: "\(groupID)", startID: startID, attachment: "", messIDs: [], image: nil)
                    } else {
                        self.dismiss(animated: false) { () -> Void in
                            self.openGroupDialogController(userID: "\(userID)", groupID: "\(groupID)", startID: startID, attachment: "", messIDs: [], image: nil)
                        }
                    }
                } else {
                    if chatID != 0 {
                        if self.presentedViewController == nil {
                            self.openDialogController(userID: "\(2000000000 + chatID)", chatID: "\(chatID)", startID: startID, attachment: "", messIDs: [], image: nil)
                        } else {
                            self.dismiss(animated: false) { () -> Void in
                                self.openDialogController(userID: "\(2000000000 + chatID)", chatID: "\(chatID)", startID: startID, attachment: "", messIDs: [], image: nil)
                            }
                        }
                    } else {
                        if self.presentedViewController == nil {
                            self.openDialogController(userID: "\(userID)", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                        } else {
                            self.dismiss(animated: false) { () -> Void in
                                self.openDialogController(userID: "\(userID)", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                            }
                        }
                    }
                }
            }
        } else {
            tap.add {
                SwiftMessages.hideAll()
            }
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 5)
        config.interactiveHide = false
        
        SwiftMessages.show(config: config, view: view)
    }
    
    func showAudioPlayOnScreen(song: IMusic, player: AVPlayer) {
        
        SwiftMessages.hideAll()
        
        let view = MessageView.viewFromNib(layout: .tabView)

        let mainColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
        view.backgroundView.backgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
        
        let title = song.artist
        let body = song.song
        let iImage = UIImage(named: "music")
        let bImage = UIImage(named: "stop-play")
        let tText = "00:30   "
        view.configureContent(title: title, body: body, iconImage: iImage, iconText: nil, buttonImage: bImage, buttonTitle: tText, buttonTapHandler: { _ in
            player.pause()
            view.button?.tag = 0
            SwiftMessages.hideAll()
        })
        
        view.iconImageView?.clipsToBounds = true
        view.iconImageView?.contentMode = .scaleAspectFill
        view.iconImageView?.layer.borderColor = UIColor.lightGray.cgColor
        
        view.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        view.titleLabel?.minimumScaleFactor = 0.6
        view.titleLabel?.textColor = .black
        
        view.bodyLabel?.font = UIFont(name: "Verdana", size: 11)!
        view.bodyLabel?.textColor = view.bodyLabel?.tintColor
        
        view.button?.tintColor = mainColor
        view.button?.setTitleColor(mainColor, for: .normal)
        view.button?.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        view.button?.semanticContentAttribute = .forceRightToLeft
        view.button?.tag = 3100
        
        view.tag = 31
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        
        tap.add {
            let alertController = UIAlertController(title: "\(song.artist)\n«\(song.song)»", message: nil, preferredStyle: .actionSheet)
            
            if !song.reserv6.isEmpty {
                let action1 = UIAlertAction(title: "Открыть исполнителя в Apple Music", style: .default) { action in
                    
                    self.openBrowserControllerNoCheck(url: song.reserv6)
                }
                alertController.addAction(action1)
            }
            
            let action2 = UIAlertAction(title: "Сохранить песню в «Избранное»", style: .default) { action in
                
                do {
                    var config = Realm.Configuration.defaultConfiguration
                    config.deleteRealmIfMigrationNeeded = false
                    config.schemaVersion = 1
                    
                    let realm = try Realm(configuration: config)
                    
                    realm.beginWrite()
                    realm.add(song, update: .all)
                    try realm.commitWrite()
                    self.showSuccessMessage(title: "Моя музыка iTunes", msg: "Песня «\(song.song)» успешно записана в «Избранное»")
                } catch {
                    self.showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
                }
            }
            alertController.addAction(action2)
            
            let action3 = UIAlertAction(title: "Открыть песню в Apple Music", style: .default) { action in
            
                self.openBrowserControllerNoCheck(url: song.URL)
            }
            alertController.addAction(action3)
            
            let action4 = UIAlertAction(title: "Скопировать название", style: .default) { action in
                
                let link = "\(song.artist)\n«\(song.song)»"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
                }
            }
            alertController.addAction(action4)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true)
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        let progress = UIProgressView()
        progress.tag = 500000
        progress.backgroundColor = .clear
        progress.tintColor = mainColor
        progress.progress = 0
        
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 31)
        config.interactiveHide = false
        
        SwiftMessages.show(config: config, view: view)
        
        progress.frame = CGRect(x: 30, y: 15, width: UIScreen.main.bounds.width - 60, height: 2)
        view.addSubview(progress)
        
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(timer:)), userInfo: view, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func showAudioMessageOnScreen(doc: DocAttach, users: [DialogsUsers], player: AVPlayer) {
        
        let view = MessageView.viewFromNib(layout: .tabView)
        view.backgroundView.backgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
        
        let mainColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
        
        let title = "Голосовое сообщение"
        let iImage = UIImage(named: "mic")
        
        var body = ""
        if let user = users.filter({ $0.uid == "\(doc.ownerID)" }).first {
            body = "\(user.lastName) \(user.firstName)"
        }
        
        let timeInMinutes = doc.duration / 60;
        let timeInSeconds = doc.duration % 60;
        let tText = String(format: "%02d:%02d   ", arguments: [timeInMinutes,timeInSeconds])
        
        view.configureContent(title: title, body: body, iconImage: iImage, iconText: nil, buttonImage: nil, buttonTitle: tText, buttonTapHandler: nil)
        
        view.iconImageView?.clipsToBounds = true
        view.iconImageView?.contentMode = .scaleAspectFill
        view.iconImageView?.layer.borderColor = mainColor.cgColor
        view.iconImageView?.layer.borderWidth = 0
        view.iconImageView?.layer.cornerRadius = view.iconImageView!.bounds.height/2
        view.iconImageView?.tintColor = mainColor
        
        view.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        view.titleLabel?.minimumScaleFactor = 0.6
        view.titleLabel?.textColor = .black
        
        view.bodyLabel?.font = UIFont(name: "Verdana", size: 11)!
        view.bodyLabel?.textColor = view.bodyLabel?.tintColor
        
        view.button?.tintColor = mainColor
        view.button?.setTitleColor(mainColor, for: .normal)
        view.button?.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        view.button?.tag = (doc.duration + 1) * 100
        
        view.tag = doc.duration + 1
        view.id = "\(doc.id)"
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        
        tap.add {
            player.pause()
            view.button?.tag = 0
            SwiftMessages.hide(id: view.id)
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        
        let progress = UIProgressView()
        progress.tag = 500000
        progress.backgroundColor = .clear
        progress.tintColor = mainColor
        progress.progress = 0
        
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: TimeInterval(doc.duration + 1))
        config.interactiveHide = false
        
        SwiftMessages.show(config: config, view: view)
        
        progress.frame = CGRect(x: 30, y: 15, width: UIScreen.main.bounds.width - 60, height: 2)
        view.addSubview(progress)
        
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer(timer:)), userInfo: view, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc func updateTimer(timer: Timer) {
        if let view = timer.userInfo as? MessageView, let button = view.button, let progress = view.viewWithTag(500000) as? UIProgressView {
            let duration = view.tag
            button.tag -= 1
            
            if button.tag >= 0 {
                let timeInMinutes = (button.tag) / 100 / 60;
                let timeInSeconds = (button.tag) / 100 % 60;
                OperationQueue.main.addOperation {
                    button.setTitle(String(format: "%02d:%02d   ", arguments: [timeInMinutes,timeInSeconds]), for: .normal)
                    progress.progress = Float(duration * 100 - button.tag) / Float(duration * 100)
                }
            } else if timer.isValid {
                timer.invalidate()
                if view.id != vkSingleton.shared.userID { SwiftMessages.hide(id: view.id) }
                progress.removeFromSuperview()
            }
        }
    }
    
    func recordVoiceMessage() {
        
        guard let controller = self as? DialogController else { return }
        
        controller.player.pause()
        let recordingSession = controller.session
        
        do {
            try recordingSession.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let audioFilename = path.appendingPathComponent("voice-message.m4a")
                            
                            let settings = [
                                //AVFormatIDKey : kAudioFormatOpus,
                                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                AVSampleRateKey: 16000,
                                AVNumberOfChannelsKey: 1
                                //AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                            ] as [String: Any]
                            
                            do {
                                controller.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                                controller.audioRecorder.delegate = controller
                                controller.audioRecorder.prepareToRecord()
                                controller.audioRecorder.record()

                                controller.openRecordVoiceMessageForm()
                            } catch {
                                self.showErrorMessage(title: "Внимание!", msg: "Ошибка записи голосового сообщения")
                            }
                        }
                    } else {
                        self.showSettingsMessage(title: "Внимание!", msg: "Доступ к микрофону запрещен. Перейдите в настройки приложения и предоставьте доступ к микрофону для данного приложения.")
                    }
                }
            }
        } catch {
            self.showErrorMessage(title: "Внимание!", msg: "Ошибка записи голосового сообщения")
        }
    }
    
    func openRecordVoiceMessageForm() {
        
        guard let controller = self as? DialogController else { return }
        
        SwiftMessages.hideAll()
        
        let recordView = MessageView.viewFromNib(layout: .centeredView)
        recordView.backgroundView.backgroundColor = vkSingleton.shared.backPopupColor
        let mainColor = vkSingleton.shared.mainColor
        
        if #available(iOS 13.0, *) {
            recordView.overrideUserInterfaceStyle = controller.overrideUserInterfaceStyle
        }
        
        let title = "Внимание! Идет запись!"
        let body = "После записи голосового сообщения,\nнажмите ниже кнопку «Готово»\n\nДля отмены записи сообщения\nдва раза нажмите по этой форме\n"
        let iImage = UIImage(named: "mic")
        let bText = "       Готово       "
        
        let blinkTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(blinkAction(timer:)), userInfo: recordView, repeats: true)
        
        recordView.configureContent(title: title, body: body, iconImage: iImage, iconText: nil, buttonImage: nil, buttonTitle: bText, buttonTapHandler: { button in
            
            controller.audioRecorder.stop()
            
            if blinkTimer.isValid { blinkTimer.invalidate() }
            
            var durationText = "00:00"
            var duration = 0
            let player = try? AVAudioPlayer(contentsOf: controller.audioRecorder.url)
            if let dur = player?.duration {
                duration = Int(dur + 0.5)
                let minutes = duration / 60
                let seconds = duration % 60
                durationText = "\(minutes.minutesAdder()) \(seconds.secondsAdder())".trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            recordView.titleLabel?.text = "Сообщение успешно записано!"
            recordView.bodyLabel?.text = "Длительность сообщения:\n\(durationText)\n\nДля отмены отправки сообщения\nдва раза нажмите по этой форме\n"
            
            recordView.titleLabel?.alpha = 1.0
            recordView.iconImageView?.alpha = 1.0
            
            button.setTitle("Прослушать", for: .normal)
            
            let midX = recordView.frame.midX
            let minY = button.frame.maxY
            let bHeight = button.frame.height
            
            let playButton = UIButton()
            playButton.tintColor = mainColor
            playButton.backgroundColor = mainColor
            playButton.setTitleColor(.white, for: .normal)
            playButton.setTitle("Прослушать", for: .normal)
            playButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
            playButton.layer.cornerRadius = 4
            playButton.frame = CGRect(x: midX - 125, y: minY, width: 110, height: bHeight)
            recordView.addSubview(playButton)
            playButton.add(for: .touchUpInside) {
                recordView.tag = duration
                recordView.button?.tag = (duration) * 100
                
                let progress = UIProgressView()
                progress.tag = 500000
                progress.backgroundColor = .clear
                progress.tintColor = mainColor
                progress.progress = 0
                progress.frame = CGRect(x: 50, y: 25, width: UIScreen.main.bounds.width - 100, height: 2)
                recordView.addSubview(progress)
                
                controller.player = AVPlayer(url: controller.audioRecorder.url)
                controller.player.seek(to: CMTime.zero)
                controller.player.play()
                
                UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTimer(timer:)), userInfo: recordView, repeats: true)
                RunLoop.current.add(timer, forMode: .common)
            }
            
            let sendButton = UIButton()
            sendButton.tintColor = mainColor
            sendButton.backgroundColor = mainColor
            sendButton.setTitleColor(.white, for: .normal)
            sendButton.setTitle("Отправить", for: .normal)
            sendButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
            sendButton.layer.cornerRadius = 4
            sendButton.frame = CGRect(x: midX + 15, y: minY, width: 110, height: bHeight)
            recordView.addSubview(sendButton)
            sendButton.add(for: .touchUpInside) {
                controller.player.pause()
                
                if duration <= 300 {
                    do {
                        let url = controller.audioRecorder.url
                        let data = try Data(contentsOf: url)
                        
                        SwiftMessages.hide(id: recordView.id)
                        ViewControllerUtils().showActivityIndicator(uiView: controller.commentView)
                        self.loadVoiceMessageToServer(fileData: data, fileName: url.absoluteString, completion: { attach in
                            print("attach = \(attach)")
                            
                            if !attach.isEmpty {
                                
                            }
                            
                            OperationQueue.main.addOperation {
                                controller.audioRecorder.deleteRecording()
                                controller.audioRecorder = nil
                                ViewControllerUtils().hideActivityIndicator()
                            }
                        })
                    } catch {
                        self.showErrorMessage(title: "Внимание!", msg: "\nОшибка загрузки файла\nголосового сообщения на сервер\n")
                    }
                } else {
                    self.showErrorMessage(title: "Внимание!", msg: "\nДлительность голосового сообщения\nне может превышать 5 минут\n")
                }
            }
            
            button.isEnabled = false
            button.setTitle("", for: .normal)
            button.setTitleColor(.clear, for: .normal)
            button.backgroundColor = .clear
        })
        
        recordView.iconImageView?.clipsToBounds = true
        recordView.iconImageView?.contentMode = .scaleAspectFill
        recordView.iconImageView?.tintColor = mainColor
        
        recordView.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
        recordView.titleLabel?.adjustsFontSizeToFitWidth = true
        recordView.titleLabel?.minimumScaleFactor = 0.6
        recordView.titleLabel?.textColor = .black
        
        recordView.bodyLabel?.font = UIFont(name: "Verdana", size: 13)!
        recordView.bodyLabel?.textColor = mainColor
        
        recordView.button?.tintColor = mainColor
        recordView.button?.backgroundColor = mainColor
        recordView.button?.setTitleColor(.white, for: .normal)
        recordView.button?.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 10)!
        recordView.button?.layer.cornerRadius = 4
        
        recordView.id = vkSingleton.shared.userID
        
        recordView.titleLabel?.textColor = vkSingleton.shared.labelPopupColor
        recordView.bodyLabel?.textColor = vkSingleton.shared.secondaryLabelPopupColor
        recordView.iconImageView?.tintColor = vkSingleton.shared.labelPopupColor
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        
        tap.add {
            controller.player.pause()
            controller.audioRecorder.stop()
            controller.audioRecorder.deleteRecording()
            controller.audioRecorder = nil
            SwiftMessages.hide(id: recordView.id)
        }
        recordView.addGestureRecognizer(tap)
        recordView.isUserInteractionEnabled = true
        
        recordView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .forever
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        
        SwiftMessages.show(config: config, view: recordView)
    }
    
    @objc func blinkAction(timer: Timer) {
        if let view = timer.userInfo as? MessageView, let imageView = view.iconImageView, let label = view.titleLabel {
            UIView.animate(withDuration: 0.5) {
                imageView.alpha = imageView.alpha == 1.0 ? 0.0 : 1.0
                label.alpha = label.alpha == 1.0 ? 0.0 : 1.0
            }
        }
    }
    
    func openDialogController(userID: String, chatID: String, startID: Int, attachment: String, messIDs: [Int], image: UIImage?) {
        
        var found = false
        if let controllers = self.navigationController?.viewControllers {
            for vc in controllers {
                if let controller = vc as? DialogController,
                    controller.userID == userID,
                    controller.mode == .dialog {
                    
                    found = true
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
        
        if !found {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogController") as! DialogController
            
            controller.userID = userID
            controller.chatID = chatID
            controller.startMessageID = startID
            controller.attachments = attachment
            controller.fwdMessagesID = messIDs
            controller.attachImage = image
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openGroupDialogController(userID: String, groupID: String, startID: Int, attachment: String, messIDs: [Int], image: UIImage?) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GroupDialogController") as! GroupDialogController
        
        controller.userID = userID
        controller.groupID = groupID
        controller.startMessageID = startID
        controller.attachments = attachment
        controller.fwdMessagesID = messIDs
        controller.attachImage = image
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openDialogsController(attachments: String, image: UIImage?, messIDs: [Int], source: String) {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogsController") as? DialogsController {
        
            controller.attachment = attachments
            controller.attachImage = image
            controller.source = source
            controller.fwdMessagesID = messIDs
        
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func actionFromGroupButton(fromView: UIView) {
        var popover: Popover!
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
            .color(vkSingleton.shared.backPopupColor)
        ]
        
        let view = UIView()
        
        let width = UIScreen.main.bounds.width - 40
        var height: CGFloat = 10
        
        let titleLabel = UILabel()
        titleLabel.text = "Отправлять комментарии:"
        titleLabel.textColor = vkSingleton.shared.labelPopupColor
        titleLabel.font = UIFont(name: "Verdana", size: 13)!
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 10, y: height, width: width - 20, height: 20)
        view.addSubview(titleLabel)
        
        height += 25
        
        let ownLabel = UILabel()
        ownLabel.text = "от своего имени"
        ownLabel.textColor = vkSingleton.shared.labelPopupColor
        
        let fullString = "от своего имени"
        let rangeOfColoredString = (fullString as NSString).range(of: "своего имени")
        let attributedString = NSMutableAttributedString(string: fullString)
        
        if vkSingleton.shared.commentFromGroup == 0 {
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemRed], range: rangeOfColoredString)
        } else {
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: ownLabel.tintColor], range: rangeOfColoredString)
        }
        
        ownLabel.attributedText = attributedString
        
        if vkSingleton.shared.commentFromGroup != 0 {
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            tap.add {
                popover.dismiss()
                self.setCommentFromGroupID(id: 0, controller: self)
                vkSingleton.shared.commentFromGroup = 0
            }
            ownLabel.isUserInteractionEnabled = true
            ownLabel.addGestureRecognizer(tap)
        }
        
        ownLabel.font = UIFont(name: "Verdana", size: 12)!
        ownLabel.textAlignment = .left
        ownLabel.clipsToBounds = true
        ownLabel.frame = CGRect(x: 10, y: height, width: width - 60, height: 30)
        view.addSubview(ownLabel)
        
        let avatar = UIImageView()
        let getCacheImage = GetCacheImage(url: vkSingleton.shared.avatarURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            if let avatarImage = getCacheImage.outputImage {
                OperationQueue.main.addOperation {
                    avatar.image = avatarImage
                }
            }
        }
        OperationQueue().addOperation(getCacheImage)
        avatar.layer.cornerRadius = 15
        avatar.layer.borderColor = vkSingleton.shared.secondaryLabelPopupColor.cgColor
        avatar.layer.borderWidth = 0.6
        avatar.clipsToBounds = true
        avatar.frame = CGRect(x: width - 40, y: height, width: 30, height: 30)
        view.addSubview(avatar)
        
        height += 35
        
        let url = "/method/groups.get"
        let parameters = [
            "user_id": vkSingleton.shared.userID,
            "access_token": vkSingleton.shared.accessToken,
            "filter": "admin",
            "extended": "1",
            "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseGroups = ParseGroupList()
        parseGroups.completionBlock = {
            var groups = parseGroups.outputData
            
            if let vc = self as? VideoController {
                groups.removeAll(keepingCapacity: false)
                if let ownerID = Int(vc.ownerID), ownerID < 0 {
                    for group in parseGroups.outputData {
                        if "\(abs(ownerID))" == group.gid {
                            groups.append(group)
                        }
                    }
                }
            }
            
            if let vc = self as? TopicController {
                groups.removeAll(keepingCapacity: false)
                if let ownerID = Int(vc.groupID) {
                    for group in parseGroups.outputData {
                        if "\(ownerID)" == group.gid {
                            groups.append(group)
                        }
                    }
                }
            }
            
            if groups.count > 0 {
                OperationQueue.main.addOperation {
                    for group in groups {
                        let ownLabel = UILabel()
                        ownLabel.text = "от \(group.name)"
                        ownLabel.textColor = vkSingleton.shared.labelPopupColor
                        
                        if let gid = Int(group.gid) {
                            let fullString = "от \(group.name)"
                            let rangeOfColoredString = (fullString as NSString).range(of: "\(group.name)")
                            let attributedString = NSMutableAttributedString(string: fullString)
                            
                            if vkSingleton.shared.commentFromGroup == gid {
                                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemRed], range: rangeOfColoredString)
                            } else {
                                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: ownLabel.tintColor], range: rangeOfColoredString)
                            }
                            
                            ownLabel.attributedText = attributedString
                            
                            if vkSingleton.shared.commentFromGroup != gid {
                                let tap = UITapGestureRecognizer()
                                tap.numberOfTapsRequired = 1
                                tap.add {
                                    popover.dismiss()
                                    self.setCommentFromGroupID(id: gid, controller: self)
                                    vkSingleton.shared.commentFromGroup = gid
                                }
                                ownLabel.isUserInteractionEnabled = true
                                ownLabel.addGestureRecognizer(tap)
                            }
                        }
                        
                        ownLabel.font = UIFont(name: "Verdana", size: 12)!
                        ownLabel.textAlignment = .left
                        ownLabel.clipsToBounds = true
                        ownLabel.frame = CGRect(x: 10, y: height, width: width - 60, height: 30)
                        view.addSubview(ownLabel)
                        
                        let avatar2 = UIImageView()
                        let getCacheImage = GetCacheImage(url: group.coverURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                avatar2.image = getCacheImage.outputImage
                            }
                        }
                        OperationQueue().addOperation(getCacheImage)
                        avatar2.layer.cornerRadius = 15
                        avatar2.layer.borderColor = vkSingleton.shared.secondaryLabelPopupColor.cgColor
                        avatar2.layer.borderWidth = 0.6
                        avatar2.clipsToBounds = true
                        avatar2.frame = CGRect(x: width - 40, y: height, width: 30, height: 30)
                        view.addSubview(avatar2)
                        
                        height += 35
                    }
                
                    height += 5
                    view.frame = CGRect(x: 0, y: 0, width: width, height: height)
                
                
                    popover = Popover(options: popoverOptions)
                    popover.show(view, fromView: fromView)
                }
            }
        }
        parseGroups.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseGroups)
    }
    
    func playSoundEffect(_ code: SystemSoundID) {
        if AppConfig.shared.soundEffectsOn {
            AudioServicesPlaySystemSound(code)
        }
    }
    
    func showSetOnlineAlert(title: String, body: String, doneCompletion: @escaping ()->(Void)) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("Хорошо, я согласен", action: {
                doneCompletion()
            })
            
            alert.addButton("Отмена", action: {})
            
            alert.showError(title, subTitle: body)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func showSetOnlineAlert(title: String, body: String, doneCompletion: @escaping ()->(Void), cancelCompletion: @escaping ()->(Void)) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
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
            
            alert.addButton("Хорошо, я согласен", action: {
                doneCompletion()
            })
            
            alert.addButton("Нет, хочу остаться офлайн", action: {
                cancelCompletion()
            })
            
            alert.showError(title, subTitle: body)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func addBookmarkOnHomeScreen(name: String, screenName: String, image: UIImage) {
        
        var html = ""
        
        html = "\(html)<!DOCTYPE html>\n"
        html = "\(html)<html>\n"
        html = "\(html)<div id=\"html\">\n"
        html = "\(html)    <!DOCTYPE html>\n"
        html = "\(html)        <html>\n"
        html = "\(html)            <head>\n"
        html = "\(html)                <title>Добавить закладку на экран «Домой»</title>\n"
        html = "\(html)                <meta content=\"text/html; charset=UTF-8\" http-equiv=\"Content-Type\"/>\n"
        html = "\(html)                <meta content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=no;\" name=\"viewport\"/>\n"
        html = "\(html)                <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\n"
        html = "\(html)                <meta name=\"apple-mobile-web-app-status-bar-style\" content=\"black\" />\n"
        html = "\(html)                <meta content=\"SHORTCUT-NAME-HERE\" name=\"apple-mobile-web-app-title\"/>\n"
        html = "\(html)                <link rel=\"icon\" type=\"image/png\" href=\"data:image/png;base64, ICON-IMAGE-DATA\"/>\n"
        html = "\(html)                <link rel=\"apple-touch-icon\" href=\"data:image/png;base64, ICON-IMAGE-DATA\"/>\n"
        html = "\(html)                <link rel=\"apple-touch-startup-image\" href=\"data:image/png;base64, ICON-IMAGE-DATA\"/>\n"
        html = "\(html)            </head>\n"
        html = "\(html)            <body>\n"
        html = "\(html)                <a id=\"redirectURL\" href=\"YOUR-CUSTOM-URL\" name = \"redirectURL\"></a>\n"
        html = "\(html)                <script>\n"
        html = "\(html)                    if (window.navigator.standalone) {\n"
        html = "\(html)                        var e = document.getElementById('redirectURL');\n"
        html = "\(html)                        var ev = document.createEvent('MouseEvents');\n"
        html = "\(html)                        ev.initEvent('click', true, true);\n"
        html = "\(html)                        e.dispatchEvent(ev);\n"
        html = "\(html)                        window.close();\n"
        html = "\(html)                    } else {\n"
        html = "\(html)                        document.write(\"<center><h1>Valet</h1><img id=\"imageIcon\" src=\"data:image/png;base64, IMAGE-ICON-DATA\"></img><h2> Добавьте закладку на экран «Домой» </h2></center>\")\n"
        html = "\(html)                    }\n"
        html = "\(html)                </script>\n"
        html = "\(html)            </body>\n"
        html = "\(html)        </html>\n"
        html = "\(html)    </div>\n"
        html = "\(html)    <script type=\"text/javascript\">\n"
        html = "\(html)        var html = document.getElementById(\"html\").innerHTML;\n"
        html = "\(html)        html = html.replace(/s{2,}/g, '')\n"
        html = "\(html)           .replace(/%/g, '%25')\n"
        html = "\(html)           .replace(/&/g, '%26')\n"
        html = "\(html)           .replace(/#/g, '%23')\n"
        html = "\(html)           .replace(/\"/g, '%22')\n"
        html = "\(html)           .replace(/'/g, '%27');\n"
        html = "\(html)        var dataURI = 'data:text/html;charset=UTF-8,' + html;\n"
        html = "\(html)        window.location.href = dataURI\n"
        html = "\(html)    </script>\n"
        html = "\(html)</html>\n"

        html = html.replacingOccurrences(of: "SHORTCUT-NAME-HERE", with: name)
        html = html.replacingOccurrences(of: "YOUR-CUSTOM-URL", with: "vktotal://vk.com/\(screenName)")
        html = html.replacingOccurrences(of: "ICON-IMAGE-DATA", with: image.convertToBase64())
        //print(html)
        
        do {
            let server = HttpServer()
            server.stop()
            server["/bookmark"] = { request in
                return HttpResponse.ok(.text(html))
            }
            try server.start(9080, forceIPv4: true)
            
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            if let url = URL(string: "http://localhost:9080/bookmark") {
                let browserController = SFSafariViewController(url: url, configuration: config)
                browserController.preferredControlTintColor = .white
                browserController.preferredBarTintColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
                
                let mainColor = vkSingleton.shared.mainColor
                let backColor = vkSingleton.shared.backColor
                
                if #available(iOS 13.0, *) {
                    if AppConfig.shared.autoMode {
                        if self.traitCollection.userInterfaceStyle == .dark {
                            browserController.overrideUserInterfaceStyle = .dark
                            browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                            browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                        } else {
                            browserController.overrideUserInterfaceStyle = .light
                            browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                            browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                        }
                    } else if AppConfig.shared.darkMode {
                        browserController.overrideUserInterfaceStyle = .dark
                        browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                        browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    } else {
                        browserController.overrideUserInterfaceStyle = .light
                        browserController.preferredBarTintColor = mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                        browserController.view.backgroundColor = backColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                    }
                } else {
                    browserController.preferredBarTintColor = mainColor
                    browserController.view.backgroundColor = backColor
                }
                
                self.present(browserController, animated: true)
            }
        } catch let error {
            print("Ошибка: \(error.localizedDescription)")
        }
    }
    
    @objc func pollVote(sender: UITapGestureRecognizer) {
        
        var tableView: UITableView!
        
        if let controller = self as? Record2Controller {
            tableView = controller.tableView
        } else if let controller = self as? FavePostsController2 {
            tableView = controller.tableView
        } else if let controller = self as? Newsfeed2Controller {
            tableView = controller.tableView
        } else if let controller = self as? NewsfeedSearchController {
            tableView = controller.tableView
        } else if let controller = self as? ProfileController2 {
            tableView = controller.tableView
        } else if let controller = self as? GroupProfileController2 {
            tableView = controller.tableView
        }
        
        if tableView != nil {
            let position: CGPoint = sender.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: position)
            
            if let cell = tableView.cellForRow(at: indexPath!) as? Record2Cell, let label = sender.view as? UILabel {
                cell.delegate = self
                
                let num = label.tag
                
                if cell.poll.answerIDs.count == 0 && !cell.poll.multiple {
                    
                    if cell.poll.closed || !cell.poll.canVote { return }
                    
                    cell.poll.answers[num].isSelect = !cell.poll.answers[num].isSelect
                    cell.updatePoll()
                    
                    var message: String? = "Вы выбрали следующий вариант: \n«\(cell.poll.answers[num].text)»"
                    var title: String? = nil
                    if cell.poll.disableUnvote { title = "Внимание!\nОтменить голосование по этому опросу\n будет впоследствии невозможно\n\n"}
                    else { title = message; message = nil }
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.poll.answers[num].isSelect = false
                        cell.updatePoll()
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Проголосовать", style: .default) { action in
                        let url = "/method/polls.addVote"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": "\(cell.poll.ownerID)",
                            "poll_id": "\(cell.poll.id)",
                            "answer_ids": "\(cell.poll.answers[num].id)",
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
                                OperationQueue.main.addOperation {
                                    cell.poll.votes += 1
                                    cell.poll.answers[num].votes += 1
                                    cell.poll.answers[num].isSelect = false
                                    for answer in cell.poll.answers {
                                        answer.rate = Double(answer.votes) / Double(cell.poll.votes) * 100
                                    }
                                    cell.poll.answerIDs = [cell.poll.answers[num].id]
                                    cell.updatePoll()
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                    
                    present(alertController, animated: true)
                } else if cell.poll.answerIDs.contains(cell.poll.answers[num].id) {
                    
                    if cell.poll.closed || !cell.poll.canVote || cell.poll.disableUnvote { return }
                    
                    let title = "Вы проголосовали за вариант: \n«\(cell.poll.answers[num].text)»"
                    
                    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.poll.answers[num].isSelect = false
                        cell.updatePoll()
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Отозвать свой голос", style: .destructive) { action in
                        let url = "/method/polls.deleteVote"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": "\(cell.poll.ownerID)",
                            "poll_id": "\(cell.poll.id)",
                            "answer_id": "\(cell.poll.answers[num].id)",
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
                                OperationQueue.main.addOperation {
                                    cell.poll.answerIDs.remove(object: cell.poll.answers[num].id)
                                    if cell.poll.answerIDs.count == 0 { cell.poll.votes -= 1 }
                                    cell.poll.answers[num].votes -= 1
                                    cell.poll.answers[num].isSelect = false
                                    for answer in cell.poll.answers {
                                        answer.rate = Double(answer.votes) / Double(cell.poll.votes) * 100
                                    }
                                    cell.updatePoll()
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                    
                    present(alertController, animated: true)
                } else if cell.poll.multiple {
                    
                    if cell.poll.closed || !cell.poll.canVote || cell.poll.answerIDs.count > 0 { return }
                    
                    cell.poll.answers[num].isSelect = !cell.poll.answers[num].isSelect
                    cell.updatePoll()
                }
            } else if let cell = tableView.cellForRow(at: indexPath!) as? WallRecordCell2, let label = sender.view as? UILabel {
                cell.delegate = self
                
                let num = label.tag
                
                if cell.poll.answerIDs.count == 0 && !cell.poll.multiple {
                    
                    if cell.poll.closed || !cell.poll.canVote { return }
                    
                    cell.poll.answers[num].isSelect = !cell.poll.answers[num].isSelect
                    cell.updatePoll()
                    
                    var message: String? = "Вы выбрали следующий вариант: \n«\(cell.poll.answers[num].text)»"
                    var title: String? = nil
                    if cell.poll.disableUnvote { title = "Внимание!\nОтменить голосование по этому опросу\n будет впоследствии невозможно\n\n"}
                    else { title = message; message = nil }
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.poll.answers[num].isSelect = false
                        cell.updatePoll()
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Проголосовать", style: .default) { action in
                        let url = "/method/polls.addVote"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": "\(cell.poll.ownerID)",
                            "poll_id": "\(cell.poll.id)",
                            "answer_ids": "\(cell.poll.answers[num].id)",
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
                                OperationQueue.main.addOperation {
                                    cell.poll.votes += 1
                                    cell.poll.answers[num].votes += 1
                                    cell.poll.answers[num].isSelect = false
                                    for answer in cell.poll.answers {
                                        answer.rate = Double(answer.votes) / Double(cell.poll.votes) * 100
                                    }
                                    cell.poll.answerIDs = [cell.poll.answers[num].id]
                                    cell.updatePoll()
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                    
                    present(alertController, animated: true)
                } else if cell.poll.answerIDs.contains(cell.poll.answers[num].id) {
                    
                    if cell.poll.closed || !cell.poll.canVote || cell.poll.disableUnvote { return }
                    
                    let title = "Вы проголосовали за вариант: \n«\(cell.poll.answers[num].text)»"
                    
                    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.poll.answers[num].isSelect = false
                        cell.updatePoll()
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Отозвать свой голос", style: .destructive) { action in
                        let url = "/method/polls.deleteVote"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "owner_id": "\(cell.poll.ownerID)",
                            "poll_id": "\(cell.poll.id)",
                            "answer_id": "\(cell.poll.answers[num].id)",
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
                                OperationQueue.main.addOperation {
                                    cell.poll.answerIDs.remove(object: cell.poll.answers[num].id)
                                    if cell.poll.answerIDs.count == 0 { cell.poll.votes -= 1 }
                                    cell.poll.answers[num].votes -= 1
                                    cell.poll.answers[num].isSelect = false
                                    for answer in cell.poll.answers {
                                        answer.rate = Double(answer.votes) / Double(cell.poll.votes) * 100
                                    }
                                    cell.updatePoll()
                                }
                            } else {
                                error.showErrorMessage(controller: self)
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                    
                    present(alertController, animated: true)
                } else if cell.poll.multiple {
                    
                    if cell.poll.closed || !cell.poll.canVote || cell.poll.answerIDs.count > 0 { return }
                    
                    cell.poll.answers[num].isSelect = !cell.poll.answers[num].isSelect
                    cell.updatePoll()
                }
            }
        }
    }
    
    func getPollVoters(poll: Poll, index: Int) {
        let alertController = UIAlertController(title: "Узнайте, кто из пользователей\nпроголосовал за вариант ответа", message: "«\(poll.answers[index].text)»", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Все пользователи", style: .default) { action in
            let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
            
            usersController.userID = vkSingleton.shared.userID
            usersController.type = "voters"
            usersController.source = ""
            usersController.title = "Проголосовавшие пользователи"
            usersController.delegate = self
            usersController.poll = poll
            usersController.pollIndex = index
            
            self.navigationController?.pushViewController(usersController, animated: true)
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Мои друзья", style: .default) { action in
            let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
            
            usersController.userID = vkSingleton.shared.userID
            usersController.type = "voters"
            usersController.source = "friends"
            usersController.title = "Проголосовавшие друзья"
            usersController.delegate = self
            usersController.poll = poll
            usersController.pollIndex = index
            
            self.navigationController?.pushViewController(usersController, animated: true)
        }
        alertController.addAction(action2)
        
        present(alertController, animated: true)
    }
}

extension UIViewController {
    
    var visibleViewController2: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController2
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController2
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController2
        } else {
            return self
        }
    }
    
    func popoverHideAll() {
        if let vc = self as? GroupProfileController2, let popover = vc.popover {
            popover.dismiss()
        }
        if let vc = self as? Record2Controller, let popover = vc.popover {
            popover.dismiss()
        }
    }
}

extension SCLAlertView {
    open override func viewDidLayoutSubviews() {
        if #available(iOS 13.0, *) {
            if !AppConfig.shared.autoMode {
                if AppConfig.shared.darkMode {
                    self.overrideUserInterfaceStyle = .dark
                } else {
                    self.overrideUserInterfaceStyle = .light
                }
            }
        }
        
        super.viewDidLayoutSubviews()
    }
}

extension Popover {
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.layoutSubviews()
    }
    
    open override func layoutSubviews() {
        if #available(iOS 13.0, *) {
            if !AppConfig.shared.autoMode {
                if AppConfig.shared.darkMode {
                    self.overrideUserInterfaceStyle = .dark
                } else {
                    self.overrideUserInterfaceStyle = .light
                }
            }
        }
        
        super.layoutSubviews()
    }
}

