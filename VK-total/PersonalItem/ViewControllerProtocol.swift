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

protocol NotificationCellProtocol {
    
    func openProfileController(id: Int, name: String)
    
    func openUserInfoProfile(profiles: [UserProfileInfo])
    
    func openAddAccountController()
    
    func openUsersController(uid: String, title: String, type: String)
    
    func openGroupsListController(uid: String, title: String, type: String)
    
    func openVideoController(ownerID: String, vid: String, accessKey: String, title: String)
    
    func openVideoListController(ownerID: String, title: String, type: String)
    
    func openTopicsController(groupID: String, group: GroupProfile, title: String)
    
    func openTopicController(groupID: String, topicID: String, title: String, delegate: UIViewController)
    
    func openNotesController(userID: String, title: String)
    
    func openPhotosListController(ownerID: String, title: String, type: String)
    
    func openPhotoViewController(numPhoto: Int, photos: [Photos])
    
    func openPhotoAlbumController(ownerID: String, albumID: String, title: String, controller: PhotosListController!)
    
    func openWallRecord(ownerID: Int, postID: Int, accessKey: String, type: String)
    
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
    
    func getITunesInfo(searchString: String, searchType: String)
    
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
        let addAccountController = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountController") as! AddAccountController
        
        addAccountController.changeAccount = false
        
        self.navigationController?.pushViewController(addAccountController, animated: true)
    }
    
    func openUsersController(uid: String, title: String, type: String) {
        let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
        
        usersController.userID = uid
        usersController.type = type
        usersController.source = ""
        usersController.title = title
        
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
    
    func openVideoController(ownerID: String, vid: String, accessKey: String, title: String) {
        let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoController") as! VideoController
        
        videoController.ownerID = ownerID
        videoController.vid = vid
        videoController.accessKey = accessKey
        videoController.title = title
        
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
    
    func openPhotosListController(ownerID: String, title: String, type: String) {
        let photosController = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
        
        photosController.ownerID = ownerID
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
            photoAlbumController.delegate = controller.delegate
            photoAlbumController.source = controller.source
        }
        
        self.navigationController?.pushViewController(photoAlbumController, animated: true)

    }
    
    func openWallRecord(ownerID: Int, postID: Int, accessKey: String, type: String) {
        let recordController = self.storyboard?.instantiateViewController(withIdentifier: "Record2Controller") as! Record2Controller
        
        recordController.type = type
        recordController.ownerID = "\(ownerID)"
        recordController.itemID = "\(postID)"
        recordController.accessKey = accessKey
        
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
        photos.uid = "\(not.parent[0].ownerID)"
        photos.pid = "\(not.parent[0].id)"
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
                        openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
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
                        openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo")
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
                        openVideoController(ownerID: "\(ownerID)", vid: "\(videoID)", accessKey: "", title: "")
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
                            "v": vkSingleton.shared.version
                        ]
                        
                        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                        OperationQueue().addOperation(getServerDataOperation)
                        
                        let parseDialog = ParseDialogHistory()
                        parseDialog.completionBlock = {
                            var startID = parseDialog.inRead
                            if parseDialog.outRead > startID {
                                startID = parseDialog.outRead
                            }
                            OperationQueue.main.addOperation {
                                self.openDialogController(userID: "\(2000000000 + chatID)", chatID: "\(chatID)", startID: startID, attachment: "", messIDs: [], image: nil)
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
                        openPhotosListController(ownerID: "\(ownerID)", title: "", type: "albums")
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
                    
                    let json = try! JSON(data: data)
                    
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
            
            let browserController = self.storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
            
            browserController.path = "\(validURL)"
            
            self.navigationController?.pushViewController(browserController, animated: true)
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
            if let operation = dependence {
                request.addDependency(operation)
            }
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
            if let operation = dependence {
                request.addDependency(operation)
            }
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
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showError(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func showSuccessMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showSuccess(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.infoSound)
        }
    }
    
    func showInfoMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showInfo(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.infoSound)
        }
    }
    
    func createNewChat() {
        let alert = UIAlertController(title: "Создание группового чата", message: "Введите название чата:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Готово", style: .default) { [weak alert] (_) in
            if let text = alert?.textFields?[0].text {
                if text != "" {
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
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func editChatTitle(oldTitle: String, chatID: String) {
        let alert = UIAlertController(title: " Редактирование чата", message: "Введите новое название чата:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = oldTitle
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Готово", style: .default) { [weak alert] (_) in
            if let text = alert?.textFields?[0].text {
                if text != "" {
                    self.editChat(newTitle: text, chatID: chatID)
                } else {
                    self.showErrorMessage(title: "Ошибка редактирования чата", msg: "Необходимо ввести новое название чата.")
                }
            } else {
                self.showErrorMessage(title: "Ошибка редактирования чата", msg: "Необходимо ввести новое название чата.")
            }
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
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
            realm.add(account, update: true)
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
    }
    
    func commentReplyRecordController(replyName: String, replyText: String, indexPath: IndexPath, controller: Record2Controller) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = "\(replyText)"
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            controller.createRecordComment(text: textView.text, attachments: controller.attachments, replyID: controller.comments[controller.comments.count - indexPath.row].id, guid: "\(Date().timeIntervalSince1970)", stickerID: 0, controller: controller)
        }
        
        alert.addButton("Отмена", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Введите ваш ответ \(replyName):", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func commentReplyVideoController(replyName: String, replyText: String, indexPath: IndexPath, controller: VideoController) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = "\(replyText)"
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Готово", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            controller.createVideoComment(text: textView.text, attachments: controller.attachments, stickerID: 0, replyID: controller.comments[controller.comments.count - indexPath.row].id, guid: "\(Date().timeIntervalSince1970)", controller: controller)
        }
        
        alert.addButton("Отмена", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
        }
        
        alert.showSuccess("Введите ваш ответ \(replyName):", subTitle: "", closeButtonTitle: "Готово")
    }
    
    func repost(description: String, ownerID: String, itemID: String, type: String) {
        
        let appearance = SCLAlertView.SCLAppearance(
            //kCircleHeight: 60,
            kCircleIconHeight: 40,
            kTitleTop: 32.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 150))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = ""
        
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
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 150))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = record.text
        
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
    
    func getITunesInfo(searchString: String, searchType: String) {
        
        var lang = "us"
        if #available(iOS 11.0, *) {
            lang = NSLinguisticTagger.dominantLanguage(for: searchString)!
        }
        if lang != "ru" { lang = "us" }
        
        
        let url = "https://itunes.apple.com/search/"
        var parameters = [
            "term": searchString,
            "media": "music",
            "country": lang
        ]
    
        if searchType == "artist" {
            parameters["entity"] = "musicArtist"
        }
        
        let request = GetITunesDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let count = json["resultCount"].intValue
            if count > 0 {
                if searchType == "artist" {
                    
                    let workURL = json["results"][0]["artistLinkUrl"].stringValue
                    let previewURL = json["results"][0]["artistLinkUrl"].stringValue
                    let artistID = json["results"][0]["artistId"].intValue
                    let artist = json["results"][0]["artistName"].stringValue
                    
                    OperationQueue.main.addOperation {
                        ViewControllerUtils().hideActivityIndicator()
                        
                        let browserController = self.storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
                        
                        browserController.path = "\(workURL)"
                        
                        browserController.type = searchType
                        browserController.artistID = artistID
                        browserController.artist = artist
                        browserController.workURL = workURL
                        browserController.previewURL = previewURL
                        
                        self.navigationController?.pushViewController(browserController, animated: true)
                    }
                } else if searchType == "song" {
                    let workURL = json["results"][0]["trackViewUrl"].stringValue
                    let previewURL = json["results"][0]["previewUrl"].stringValue
                    let songID = json["results"][0]["trackId"].intValue
                    let artistID = json["results"][0]["artistId"].intValue
                    let song = json["results"][0]["trackName"].stringValue
                    let artist = json["results"][0]["artistName"].stringValue
                    let album = json["results"][0]["collectionName"].stringValue
                    let avatarURL = json["results"][0]["artworkUrl100"].stringValue
                    
                    OperationQueue.main.addOperation {
                        ViewControllerUtils().hideActivityIndicator()
                        
                        let browserController = self.storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
                        
                        browserController.path = "\(workURL)"
                        
                        browserController.type = searchType
                        browserController.songID = songID
                        browserController.artistID = artistID
                        browserController.artist = artist
                        browserController.album = album
                        browserController.song = song
                        browserController.previewURL = previewURL
                        browserController.workURL = workURL
                        browserController.avatarURL = avatarURL
                        
                        self.navigationController?.pushViewController(browserController, animated: true)
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                    if searchType == "song" {
                        self.showErrorMessage(title: "Поиск в iTunes", msg: "В iTunes не найдена песня «\(searchString)»")
                    } else if searchType == "artist" {
                        self.showErrorMessage(title: "Поиск в iTunes", msg: "В iTunes не найден исполнитель «\(searchString)»")
                    } else {
                        self.showErrorMessage(title: "Поиск в iTunes", msg: "Ошибка поиска в iTunes по  параметрам «\(searchString)»")
                    }
                }
            }
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
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = ""
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Отправить жалобу", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            self.reportUser(userID: userID, type: reason, comment: textView.text!)
        }
        
        alert.addButton("Отмена, я передумал", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
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
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 12.0,
            kWindowWidth: UIScreen.main.bounds.width - 40,
            kTitleFont: UIFont(name: "Verdana", size: 13)!,
            kTextFont: UIFont(name: "Verdana", size: 12)!,
            kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
            showCloseButton: false,
            showCircularIcon: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = ""
        //textView.becomeFirstResponder()
        
        alert.customSubview = textView
        
        alert.addButton("Отправить жалобу", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            self.reportObject(ownerID: ownerID, type: type, reason: reason, itemID: itemID, comment: textView.text!)
        }
        
        alert.addButton("Отмена, я передумал", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
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
        
        //var text1 = text.components(separatedBy: [".","!","?"])
        //let iconImage = UIImage(named: "AppIcon")
        let view = MessageView.viewFromNib(layout: .tabView)
        view.configureContent(title: "ВКлючайся!", body: text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "", buttonTapHandler: nil)
        
        
        view.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        view.titleLabel?.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
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
        config.presentationContext1 = .viewController(self)
        config.duration = .seconds(seconds: 4)
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
        config.presentationContext1 = .viewController(self)
        config.duration = .seconds(seconds: 4)
        config.interactiveHide = true
        
        SwiftMessages.show(config: config, view: view)
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
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogsController") as! DialogsController
        
        controller.attachment = attachments
        controller.attachImage = image
        controller.source = source
        controller.fwdMessagesID = messIDs
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func actionFromGroupButton(fromView: UIView) {
        var popover: Popover!
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
        ]
        
        let view = UIView()
        
        let width = UIScreen.main.bounds.width - 2 * 10
        var height: CGFloat = 10
        
        let titleLabel = UILabel()
        titleLabel.text = "Отправлять комментарии:"
        titleLabel.font = UIFont(name: "Verdana", size: 14)!
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 10, y: height, width: width - 20, height: 20)
        view.addSubview(titleLabel)
        
        height += 25
        
        let ownLabel = UILabel()
        ownLabel.text = "от своего имени"
        
        let fullString = "от своего имени"
        let rangeOfColoredString = (fullString as NSString).range(of: "своего имени")
        let attributedString = NSMutableAttributedString(string: fullString)
        
        if vkSingleton.shared.commentFromGroup == 0 {
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: rangeOfColoredString)
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
        avatar.layer.borderColor = UIColor.gray.cgColor
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
                        
                        if let gid = Int(group.gid) {
                            let fullString = "от \(group.name)"
                            let rangeOfColoredString = (fullString as NSString).range(of: "\(group.name)")
                            let attributedString = NSMutableAttributedString(string: fullString)
                            
                            if vkSingleton.shared.commentFromGroup == gid {
                                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: rangeOfColoredString)
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
                        avatar2.layer.borderColor = UIColor.gray.cgColor
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

