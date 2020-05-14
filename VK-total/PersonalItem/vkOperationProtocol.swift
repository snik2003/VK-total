//
//  vkOperationProtocol.swift
//  VK-total
//
//  Created by Сергей Никитин on 25.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import DCCommentView

protocol VkOperationProtocol {
    
    func registerDeviceOnPush()
    
    func unregisterDeviceOnPush()
    
    func setPushSettings()
    
    func getPushSettings()
    
    func setCommentFromGroupID(id: Int, controller: UIViewController)
    
    func createRecordComment(text: String, attachments: String, replyID: Int, guid: String, stickerID: Int, controller: Record2Controller)
    
    func editRecordComment(newComment: String, attachments: String, commentID: String, controller: Record2Controller)
    
    func deleteRecordComment(commentID: String, type: String, controller: Record2Controller)
    
    func createVideoComment(text: String, attachments: String, stickerID: Int, replyID: Int, guid: String, controller: VideoController)
    
    func editVideoComment(newComment: String, attachments: String, commentID: String, controller: VideoController)
    
    func deleteVideoComment(commentID: String, controller: VideoController)
    
    func createTopicComment(text: String, attachments: String, stickerID: Int, guid: String, controller: TopicController)
    
    func deleteTopicComment(commentID: String, controller: TopicController)
    
    func fixTopic(controller: TopicController)
    
    func unfixTopic(controller: TopicController)
    
    func closeTopic(controller: TopicController)
    
    func openTopic(controller: TopicController)
    
    func editTopic(newTitle: String, controller: TopicController)
    
    func deleteTopic(controller: TopicController)
    
    func addTopic(topicTitle: String, topicText: String, attachments: String, fromGroup: Int, controller: AddTopicController, delegate: UIViewController)
    
    func addGroupToFave(group: GroupProfile)
    
    func removeGroupFromFave(group: GroupProfile)
    
    func addLinkToFave(link: String, text: String)
    
    func deleteLinkFromFave(linkID: String, controller: FavePostsController2)
    
    func hideUserFromFeed(userID: String, name: String, controller: ProfileController2)
    
    func showUserInFeed(userID: String, name: String, controller: ProfileController2)
    
    func hideGroupFromFeed(groupID: String, name: String, controller: GroupProfileController2)
    
    func showGroupInFeed(groupID: String, name: String, controller: GroupProfileController2)
    
    func copyPhotoToSaveAlbum(ownerID: String, photoID: String, accessKey: String)
    
    func deletePhotoFromSite(ownerID: String, photoID: String, delegate: UIViewController)
    
    func repostObject(object: String, message: String)
    
    func editPost(ownerID: Int, postID: Int, message: String, attachments: String, friendsOnly: Int, signed: Int, publish: Int, controller: Record2Controller)
    
    func reportUser(userID: String, type: String, comment: String)
    
    func reportObject(ownerID: String, type: String, reason: Int, itemID: String, comment: String)
    
    func editManager(groupID: String, userID: String, role: String, type: String, controller: MembersController)
    
    func postponedPost(record: Record, delegate: UIViewController)
    
    func createPost(controller: NewRecordController, delegate: UIViewController)
    
    func sendMessage(message: String, attachment: String, fwdMessages: String, stickerID: Int, controller: DialogController)
    
    func editMessage(message: String, attachment: String, messageID: Int, controller: UIViewController)
    
    func markAsReadMessages(controller: UIViewController)
    
    func inviteInGroup(groupID: String, userID: String, name: String)
    
    func deleteRequest(userID: String, controller: UsersController)
    
    func deleteAllRequests(controller: UsersController)
    
    func joinOurGroup()
    
    func createChat(userIDs: String, title: String, controller: DialogsController)
    
    func removeFromChat(chatID: String, userID: String, controller: DialogController)
    
    func loadWallPhotosToServer(ownerID: Int, image: UIImage, filename: String, completion: @escaping (String) -> Void)
    
    func loadDocsToServer(ownerID: Int, image: UIImage, filename: String, imageData: Data, completion: @escaping (String) -> Void)
}

extension UIViewController: VkOperationProtocol {
    
    func unregisterDeviceOnPush() {
        
        let userDefaults = UserDefaults.standard
        
        let url = "/method/account.unregisterDevice"
        let parameters = [
            //"token": vkSingleton.shared.deviceToken,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "sandbox": "\(vkSingleton.shared.sandbox)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                userDefaults.setValue(false, forKey: "\(vkSingleton.shared.userID)_registerPush")
                print("Device successfully unregistered on Push")
            }  else {
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode != 0 {
                    self.showErrorMessage(title: "Настройка пуш!", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func registerDeviceOnPush() {
        
        var jsonParam: [String: [String]] = ["":[""]]
        
        if AppConfig.shared.pushNewMessage {
            if AppConfig.shared.showStartMessage {
                jsonParam["msg"] = ["on"]
                jsonParam["chat"] = ["on"]
            } else {
                jsonParam["msg"] = ["on", "no_text"]
                jsonParam["chat"] = ["on", "no_text"]
            }
        } else {
            jsonParam["msg"] = ["off"]
            jsonParam["chat"] = ["off"]
        }
        
        if AppConfig.shared.pushComment {
            jsonParam["comment"] = ["on"]
            jsonParam["comment_commented"] = ["on"]
        } else {
            jsonParam["comment"] = ["off"]
            jsonParam["comment_commented"] = ["off"]
        }
        
        if AppConfig.shared.pushNewFriends {
            jsonParam["friend"] = ["on"]
            jsonParam["friend_accepted"] = ["on"]
            jsonParam["friend_found"] =  ["on"]
            
        } else {
            jsonParam["friend"] = ["off"]
            jsonParam["friend_accepted"] = ["off"]
            jsonParam["friend_found"] =  ["off"]
        }
        
        if AppConfig.shared.pushNots {
            jsonParam["reply"] = ["on"]
            jsonParam["repost"] = ["on"]
            jsonParam["reminder"] = ["on"]
            jsonParam["new_post"] = ["on"]
            jsonParam["birthday"] = ["on"]
            jsonParam["gift"] = ["on"]
            jsonParam["live"] = ["on"]
            jsonParam["tag_photo"] = ["on"]
            jsonParam["content_achievements"] = ["on"]
        } else {
            jsonParam["reply"] = ["off"]
            jsonParam["repost"] = ["off"]
            jsonParam["reminder"] = ["off"]
            jsonParam["new_post"] = ["off"]
            jsonParam["birthday"] = ["off"]
            jsonParam["gift"] = ["off"]
            jsonParam["live"] = ["off"]
            jsonParam["tag_photo"] = ["off"]
            jsonParam["content_achievements"] = ["off"]
        }
        
        if AppConfig.shared.pushLikes {
            jsonParam["like"] = ["on"]
        } else {
            jsonParam["like"] = ["off"]
        }
        
        if AppConfig.shared.pushMentions {
            jsonParam["mention"] = ["on"]
            jsonParam["chat_mention"] = ["on"]
        } else {
            jsonParam["mention"] = ["off"]
            jsonParam["chat_mention"] = ["off"]
        }
        
        if AppConfig.shared.pushFromGroups {
            jsonParam["group_invite"] = ["on"]
            jsonParam["group_accepted"] = ["on"]
            jsonParam["event_soon"] = ["on"]
            jsonParam["private_group_post"] = ["on"]
            jsonParam["associated_events"] = ["on"]
        } else {
            jsonParam["group_invite"] = ["off"]
            jsonParam["group_accepted"] = ["off"]
            jsonParam["event_soon"] = ["off"]
            jsonParam["private_group_post"] = ["off"]
            jsonParam["associated_events"] = ["off"]
        }
        
        if AppConfig.shared.pushNewPosts {
            jsonParam["wall_post"] = ["on"]
            jsonParam["wall_publish"] = ["on"]
            jsonParam["story_reply"] = ["on"]
            jsonParam["interest_post"] = ["on"]
        } else {
            jsonParam["wall_post"] = ["off"]
            jsonParam["wall_publish"] = ["off"]
            jsonParam["story_reply"] = ["off"]
            jsonParam["interest_post"] = ["off"]
        }
        
        jsonParam["sdk_open"] = ["on"]
        jsonParam["app_request"] = ["on"]
        jsonParam["call"] = ["on"]
        jsonParam["missed_call"] = ["on"]
        jsonParam["money"] = ["on"]
        
        let url = "/method/account.registerDevice"
        let parameters = [
            "token": vkSingleton.shared.deviceToken,
            "device_model": UIDevice.current.localizedModel,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "system_version": UIDevice.current.systemVersion,
            "sandbox": "\(vkSingleton.shared.sandbox)",
            "settings": JSON(jsonParam),
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        print(parameters)
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                print("Device successfully registered on Push")
                self.getPushSettings()
            }  else {
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode != 0 {
                    self.showErrorMessage(title: "Настройка пуш!", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func setPushSettings() {
        if AppConfig.shared.pushNotificationsOn {
            let userDefaults = UserDefaults.standard
            let opq = OperationQueue()
            
            var jsonParam: [String: [String]] = ["":[""]]
            
            if AppConfig.shared.pushNewMessage {
                if AppConfig.shared.showStartMessage {
                    jsonParam["msg"] = ["on"]
                    jsonParam["chat"] = ["on"]
                } else {
                    jsonParam["msg"] = ["on", "no_text"]
                    jsonParam["chat"] = ["on", "no_text"]
                }
            } else {
                jsonParam["msg"] = ["off"]
                jsonParam["chat"] = ["off"]
            }
            
            if AppConfig.shared.pushComment {
                jsonParam["comment"] = ["on"]
            } else {
                jsonParam["comment"] = ["off"]
            }
            
            if AppConfig.shared.pushNewFriends {
                jsonParam["friend"] = ["on"]
                jsonParam["friend_accepted"] = ["on"]
                jsonParam["friend_found"] =  ["on"]
                
            } else {
                jsonParam["friend"] = ["off"]
                jsonParam["friend_accepted"] = ["off"]
                jsonParam["friend_found"] =  ["off"]
            }
            
            if AppConfig.shared.pushNots {
                jsonParam["reply"] = ["on"]
                jsonParam["repost"] = ["on"]
                jsonParam["new_post"] = ["on"]
                jsonParam["birthday"] = ["on"]
                jsonParam["gift"] = ["on"]
                jsonParam["live"] = ["on"]
                jsonParam["tag_photo"] = ["on"]
                jsonParam["wall_post"] = ["on"]
                jsonParam["wall_publish"] = ["on"]
                jsonParam["story_reply"] = ["on"]
                jsonParam["interest_post"] = ["on"]
            } else {
                jsonParam["reply"] = ["off"]
                jsonParam["repost"] = ["off"]
                jsonParam["new_post"] = ["off"]
                jsonParam["birthday"] = ["off"]
                jsonParam["gift"] = ["off"]
                jsonParam["live"] = ["off"]
                jsonParam["tag_photo"] = ["off"]
                jsonParam["wall_post"] = ["off"]
                jsonParam["wall_publish"] = ["off"]
                jsonParam["story_reply"] = ["off"]
                jsonParam["interest_post"] = ["off"]
            }
            
            if AppConfig.shared.pushLikes {
                jsonParam["like"] = ["on"]
            } else {
                jsonParam["like"] = ["off"]
            }
            
            if AppConfig.shared.pushMentions {
                jsonParam["mention"] = ["on"]
                jsonParam["chat_mention"] = ["on"]
            } else {
                jsonParam["mention"] = ["off"]
                jsonParam["chat_mention"] = ["off"]
            }
            
            if AppConfig.shared.pushFromGroups {
                jsonParam["group_invite"] = ["on"]
                jsonParam["group_accepted"] = ["on"]
                jsonParam["event_soon"] = ["on"]
                jsonParam["private_group_post"] = ["on"]
                jsonParam["associated_events"] = ["on"]
            } else {
                jsonParam["group_invite"] = ["off"]
                jsonParam["group_accepted"] = ["off"]
                jsonParam["event_soon"] = ["off"]
                jsonParam["private_group_post"] = ["off"]
                jsonParam["associated_events"] = ["off"]
            }
            
            jsonParam["sdk_open"] = ["off"]
            jsonParam["app_request"] = ["off"]
            jsonParam["call"] = ["off"]
            jsonParam["money"] = ["off"]
            
            
            let url = "/method/account.setPushSettings"
            let parameters = [
                "device_id": "\(UIDevice.current.identifierForVendor!)",
                "token": vkSingleton.shared.deviceToken,
                "access_token": vkSingleton.shared.accessToken,
                "settings": JSON(jsonParam),
                "v": vkSingleton.shared.version
            ] as [String : Any]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                //print(json)
                let result = json["response"].intValue
                
                if result == 1 {
                    print("setPushSettings: success")
                    self.getPushSettings()
                } else {
                    vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                    vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if vkSingleton.shared.errorCode != 0 {
                        if vkSingleton.shared.errorCode == 100 {
                            userDefaults.setValue(false, forKey: "\(vkSingleton.shared.userID)_registerPush")
                        } else {
                            self.showErrorMessage(title: "Настройка пуш!", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                        }
                    }
                }
            }
            opq.addOperation(request)
        }
    }
    
    func getPushSettings() {
        let opq = OperationQueue()
        
        let url = "/method/account.getPushSettings"
        let parameters = [
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ]  as [String : Any]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(request)
        
        let parsePush = ParsePushSettings()
        parsePush.addDependency(request)
        parsePush.completionBlock = {
            if vkSingleton.shared.errorCode == 0 {
                if parsePush.settings.disabled == 1 {
                    print("Пуш-уведомления отключены")
                    //AppConfig.shared.pushNotificationsOn = false
                    //UserDefaults.standard.set(false, forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
                } else {
                    print("message: \"\(parsePush.settings.msg)\"")
                    print("comment: \"\(parsePush.settings.comment)\"")
                    print("friend: \"\(parsePush.settings.friend)\"")
                    print("reply: \"\(parsePush.settings.reply)\"")
                    print("like: \"\(parsePush.settings.like)\"")
                    print("mention: \"\(parsePush.settings.mention)\"")
                    print("group_accepted: \"\(parsePush.settings.groupAccepted)\"")
                    print("new_posts: \"\(parsePush.settings.wallPost)\"")
                }
            } else {
                self.showErrorMessage(title: "Получение настроек Push", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
            }
        }
        opq.addOperation(parsePush)
    }
    
    func setCommentFromGroupID(id: Int, controller: UIViewController) {
        
        if id == 0 {
            let getCacheImage = GetCacheImage(url: vkSingleton.shared.avatarURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                if let avatarImage = getCacheImage.outputImage {
                    OperationQueue.main.addOperation {
                        if let vc = controller as? Record2Controller {
                            vc.commentView.fromGroupImage = avatarImage
                            vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                        } else if let vc = controller as? VideoController {
                            vc.commentView.fromGroupImage = avatarImage
                            vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                        } else if let vc = controller as? TopicController {
                            vc.commentView.fromGroupImage = avatarImage
                            vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                        } else if let vc = controller as? DialogController {
                            vc.commentView.fromGroupImage = avatarImage
                        }
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
        } else {
            let url = "/method/groups.getById"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": "\(abs(id))",
                "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,can_message,contacts",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            OperationQueue().addOperation(getServerDataOperation)
            
            let parseGroupProfile = ParseGroupProfile()
            parseGroupProfile.completionBlock = {
                if parseGroupProfile.outputData.count > 0 {
                    let group = parseGroupProfile.outputData[0]
                    
                    let getCacheImage = GetCacheImage(url: group.photo50, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            
                            if let vc = controller as? Record2Controller {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? VideoController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? TopicController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? GroupDialogController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                            }
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                }
            }
            parseGroupProfile.addDependency(getServerDataOperation)
            OperationQueue().addOperation(parseGroupProfile)
        }
    }
    
    func createRecordComment(text: String, attachments: String, replyID: Int, guid: String, stickerID: Int, controller: Record2Controller) {
        
        var url: String = ""
        var parameters: Parameters = [:]
        
        if controller.type == "post" {
            url = "/method/wall.createComment"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": controller.ownerID,
                "post_id": controller.itemID,
                "message": text,
                "attachments": attachments,
                "guid": guid,
                "v": vkSingleton.shared.version
            ]
            
        } else if controller.type == "photo" {
            url = "/method/photos.createComment"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": controller.ownerID,
                "photo_id": controller.itemID,
                "message": text,
                "attachments": attachments,
                "guid": guid,
                "v": vkSingleton.shared.version
            ]
        }
     
        if vkSingleton.shared.commentFromGroup > 0 {
            parameters["from_group"] = "\(vkSingleton.shared.commentFromGroup)"
        }
        
        if replyID > 0 {
            parameters["reply_to_comment"] = "\(replyID)"
        }
        
        if stickerID > 0 {
            parameters["sticker_id"] = "\(stickerID)"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                
                if controller.type == "post" {
                    url = "/method/wall.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": controller.ownerID,
                        "post_id": controller.itemID,
                        "need_likes": "1",
                        "offset": "0",
                        "count": "\(controller.count)",
                        "sort": "desc",
                        "preview_length": "0",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                        "v": vkSingleton.shared.version
                    ]
                } else if controller.type == "photo" {
                    url = "/method/photos.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": controller.ownerID,
                        "photo_id": controller.itemID,
                        "need_likes": "1",
                        "offset": "0",
                        "count": "\(controller.count)",
                        "sort": "desc",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                        "v": vkSingleton.shared.version
                    ]
                }
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                
                let parseComments = ParseComments2()
                parseComments.addDependency(getServerDataOperation)
                parseComments.completionBlock = {
                    controller.rowHeightCache.removeAll(keepingCapacity: false)
                    controller.offset = controller.count
                    controller.totalComments = parseComments.count
                    controller.comments = parseComments.comments
                    controller.commentsProfiles = parseComments.profiles
                    controller.commentsGroups = parseComments.groups
                    if controller.news.count > 0 {
                        controller.news[0].countComments += 1
                    }
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        if controller.comments.count > 0 {
                            controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 1), at: .bottom, animated: false)
                        } else {
                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                OperationQueue().addOperation(parseComments)
                
            } else if error.errorCode == 15 && vkSingleton.shared.commentFromGroup > 0 {
                self.showErrorMessage(title: "Ошибка", msg: "ВКонтакте закрыл доступ для отправки комментариев от имени малочисленных и недавно созданных групп. Попробуйте отправить комментарий от имени данного сообщества позднее.")
            } else if error.errorCode == 213 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментированию записи.\n")
            } else if error.errorCode == 223 {
                self.showErrorMessage(title: "Ошибка", msg: "\nПревышен лимит комментариев на стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteRecordComment(commentID: String, type: String, controller: Record2Controller) {
        
        var url: String = ""
        var parameters: Parameters = [:]
        
        if type == "post" {
            url = "/method/wall.deleteComment"
        } else if type == "photo" {
            url = "/method/photos.deleteComment"
        }
            
        parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "comment_id": commentID,
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
                
                if type == "post" {
                    url = "/method/wall.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": controller.ownerID,
                        "post_id": controller.itemID,
                        "need_likes": "1",
                        "offset": "0",
                        "count": "\(controller.count)",
                        "sort": "desc",
                        "preview_length": "0",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                        "v": vkSingleton.shared.version
                    ]
                } else if type == "photo" {
                    url = "/method/photos.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": controller.ownerID,
                        "photo_id": controller.itemID,
                        "need_likes": "1",
                        "offset": "0",
                        "count": "\(controller.count)",
                        "sort": "desc",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                        "v": vkSingleton.shared.version
                    ]
                }
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                
                let parseComments = ParseComments2()
                parseComments.addDependency(getServerDataOperation)
                parseComments.completionBlock = {
                    controller.rowHeightCache.removeAll(keepingCapacity: false)
                    controller.totalComments = parseComments.count
                    controller.comments = parseComments.comments
                    controller.commentsProfiles = parseComments.profiles
                    controller.commentsGroups = parseComments.groups
                    if controller.news.count > 0 {
                        controller.news[0].countComments -= 1
                    }
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        if controller.comments.count > 0 {
                            controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 1), at: .bottom, animated: false)
                        } else {
                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                OperationQueue().addOperation(parseComments)
                
            } else if error.errorCode == 211 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментариям на этой стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func editRecordComment(newComment: String, attachments: String, commentID: String, controller: Record2Controller) {
        
        var url: String = ""
        var parameters: Parameters = [:]
        
        if controller.type == "post" {
            url = "/method/wall.editComment"
        } else if controller.type == "photo" {
            url = "/method/photos.editComment"
        }
        
        parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "comment_id": commentID,
            "message": newComment,
            "attachments": attachments,
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
                controller.offset -= controller.count
                for index in stride(from: controller.comments.count-1, through: 0, by: -1) {
                    if index >= controller.offset {
                        controller.comments.remove(at: index)
                    }
                }
                controller.loadMoreComments()
            } else if error.errorCode == 211 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментариям на этой стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func createVideoComment(text: String, attachments: String, stickerID: Int, replyID: Int, guid: String, controller: VideoController) {
        
        
        let url = "/method/video.createComment"
        var  parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "video_id": controller.vid,
            "message": text,
            "attachments": attachments,
            "guid": guid,
            "v": vkSingleton.shared.version
        ]
        
        if replyID > 0 {
            parameters["reply_to_comment"] = "\(replyID)"
        }
        
        if stickerID > 0 {
            parameters["sticker_id"] = "\(stickerID)"
        }
        
        if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(controller.ownerID)!) {
            parameters["from_group"] = "1"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                
                let url = "/method/video.getComments"
                let parameters: Parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": controller.ownerID,
                    "video_id": controller.vid,
                    "need_likes": "1",
                    "offset": "0",
                    "count": "\(controller.count)",
                    "sort": "desc",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                
                let parseComments = ParseComments2()
                parseComments.addDependency(getServerDataOperation)
                parseComments.completionBlock = {
                    controller.rowHeightCache.removeAll(keepingCapacity: false)
                    controller.offset = controller.count
                    controller.totalComments = parseComments.count
                    controller.comments = parseComments.comments
                    controller.commentsProfiles = parseComments.profiles
                    controller.commentsGroups = parseComments.groups
                    if controller.video.count > 0 {
                        controller.video[0].countComments += 1
                    }
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        if controller.comments.count > 0 {
                            controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 1), at: .bottom, animated: false)
                        } else {
                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                OperationQueue().addOperation(parseComments)
                
            } else if error.errorCode == 213 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментированию записи.\n")
            } else if error.errorCode == 223 {
                self.showErrorMessage(title: "Ошибка", msg: "\nПревышен лимит комментариев на стене.\n")
            } else if error.errorCode == 801 {
                self.showErrorMessage(title: "Ошибка", msg: "\nКомментарии этой видеозаписи закрыты его владельцем.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteVideoComment(commentID: String, controller: VideoController) {
        
        var url = "/method/video.deleteComment"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "comment_id": commentID,
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
                
                url = "/method/video.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": controller.ownerID,
                        "video_id": controller.vid,
                        "need_likes": "1",
                        "offset": "0",
                        "count": "100",
                        "sort": "desc",
                        "preview_length": "0",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                        "v": vkSingleton.shared.version
                    ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                OperationQueue().addOperation(getServerDataOperation)
                
                
                let parseComments = ParseComments2()
                parseComments.addDependency(getServerDataOperation)
                parseComments.completionBlock = {
                    controller.rowHeightCache.removeAll(keepingCapacity: false)
                    controller.totalComments = parseComments.count
                    controller.comments = parseComments.comments
                    controller.commentsProfiles = parseComments.profiles
                    controller.commentsGroups = parseComments.groups
                    if controller.video.count > 0 {
                        controller.video[0].countComments -= 1
                    }
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        if controller.comments.count > 0 {
                            controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 1), at: .bottom, animated: false)
                        } else {
                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                        }
                    }
                }
                OperationQueue().addOperation(parseComments)
                
            } else if error.errorCode == 211 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментариям на этой стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func editVideoComment(newComment: String, attachments: String, commentID: String, controller: VideoController) {
        
        let url = "/method/video.editComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "comment_id": commentID,
            "message": newComment,
            "attachments": attachments,
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
                controller.offset -= controller.count
                for index in stride(from: controller.comments.count-1, through: 0, by: -1) {
                    if index >= controller.offset {
                        controller.comments.remove(at: index)
                    }
                }
                controller.loadMoreComments()
            } else if error.errorCode == 211 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментариям на этой стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func createTopicComment(text: String, attachments: String, stickerID: Int, guid: String, controller: TopicController) {
    
        let url = "/method/board.createComment"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
            "message": text,
            "attachments": attachments,
            "guid": guid,
            "v": vkSingleton.shared.version
        ]
        
        if stickerID > 0 {
            parameters["sticker_id"] = "\(stickerID)"
        }
        
        if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(controller.groupID)!) {
            parameters["from_group"] = "1"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                controller.offset = 0
                controller.getTopicComments()
                OperationQueue.main.addOperation {
                    if controller.comments.count > 0 {
                        controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 2), at: .bottom, animated: true)
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func editTopicComment(newComment: String, attachments: String, commentID: String, controller: TopicController) {
        
        let url = "/method/board.editComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
            "comment_id": commentID,
            "message": newComment,
            "attachments": attachments,
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
                controller.offset = 0
                controller.getTopicComments()
                OperationQueue.main.addOperation {
                    if controller.comments.count > 0 {
                        controller.tableView.scrollToRow(at: IndexPath(row: controller.comments.count, section: 2), at: .bottom, animated: true)
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteTopicComment(commentID: String, controller: TopicController) {
        
        let url = "/method/board.deleteComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
            "comment_id": commentID,
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
                controller.offset = 0
                controller.getTopicComments()
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func fixTopic(controller: TopicController) {
        
        let url = "/method/board.fixTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
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
                controller.topics[0].isFixed = 1
                OperationQueue.main.addOperation {
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func unfixTopic(controller: TopicController) {
        
        let url = "/method/board.unfixTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
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
                controller.topics[0].isFixed = 0
                OperationQueue.main.addOperation {
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func closeTopic(controller: TopicController) {
        
        let url = "/method/board.closeTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
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
                controller.topics[0].isClosed = 1
                OperationQueue.main.addOperation {
                    controller.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44)
                    controller.view.addSubview(controller.tableView)
                    controller.commentView.removeFromSuperview()
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func openTopic(controller: TopicController) {
        
        let url = "/method/board.openTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
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
                controller.topics[0].isClosed = 0
                OperationQueue.main.addOperation {
                    controller.commentView = DCCommentView.init(scrollView: controller.tableView, frame: controller.view.bounds)
                    controller.commentView.delegate = controller
                    controller.commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                    controller.commentView.accessoryImage = UIImage(named: "attachment")
                    controller.commentView.accessoryButton.addTarget(controller, action: #selector(controller.tapAccessoryButton(sender:)), for: .touchUpInside)
                    
                    controller.view.addSubview(controller.commentView)
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func editTopic(newTitle: String, controller: TopicController) {
        
        let url = "/method/board.editTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
            "title": newTitle,
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
                controller.topics[0].title = newTitle
                OperationQueue.main.addOperation {
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteTopic(controller: TopicController) {
        
        let url = "/method/board.deleteTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.groupID,
            "topic_id": controller.topicID,
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
                    if let vc = controller.delegate as? TopicsController {
                        vc.offset = 0
                        vc.getTopics()
                        controller.navigationController?.popViewController(animated: true)
                    } else if let vc = controller.delegate as? GroupProfileController2 {
                        vc.groupProfile[0].topicsCounter -= 1
                        vc.collectionView.reloadData()
                        controller.navigationController?.popViewController(animated: true)
                    } else {
                        self.showSuccessMessage(title: "Удаление обсуждения", msg: "Удаление темы в обсуждения успешно выполнено")
                        controller.navigationController?.popViewController(animated: true)
                    }
                    
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func addTopic(topicTitle: String, topicText: String, attachments: String, fromGroup: Int, controller: AddTopicController, delegate: UIViewController) {
        
        let url = "/method/board.addTopic"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": controller.ownerID,
            "title": topicTitle,
            "text": topicText,
            "from_group": "\(fromGroup)",
            "attachments": attachments,
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
                let groupID = controller.ownerID
                let topicID = json["response"].stringValue
                OperationQueue.main.addOperation {
                    controller.navigationController?.popViewController(animated: true)
                
                    if let vc = delegate as? TopicsController {
                        vc.offset = 0
                        vc.getTopics()
                        vc.openTopicController(groupID: groupID, topicID: topicID, title: "", delegate: vc)
                    } else if let vc = delegate as? GroupProfileController2 {
                        vc.groupProfile[0].topicsCounter += 1
                        vc.collectionView.reloadData()
                        vc.openTopicController(groupID: groupID, topicID: topicID, title: "", delegate: vc)
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    
    func addGroupToFave(group: GroupProfile) {
        
        let url = "/method/fave.addGroup"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(group.gid)",
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
               self.showSuccessMessage(title: "Избранные ссылки", msg: "\nСообщество «\(group.name)» успешно добавлено в «Избранное»\n")
                
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func removeGroupFromFave(group: GroupProfile) {
        
        let url = "/method/fave.removeGroup"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(group.gid)",
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
                self.showSuccessMessage(title: "Избранные ссылки", msg: "\nСообщество «\(group.name)» успешно удалено из «Избранное»\n")
                
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func addLinkToFave(link: String, text: String) {
        
        let url = "/method/fave.addLink"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "link": link,
            "text": text,
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
                self.showSuccessMessage(title: "Избранные ссылки", msg: "Ссылка \n«\(link)»\n успешно добавлена в «Избранное»")
                
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteLinkFromFave(linkID: String, controller: FavePostsController2) {
        
        let url = "/method/fave.removeLink"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "link_id": linkID,
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
                    controller.offset = 0
                    controller.estimatedHeightCache.removeAll(keepingCapacity: false)
                    controller.refresh()
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func hideUserFromFeed(userID: String, name: String, controller: ProfileController2) {
        
        let url = "/method/newsfeed.addBan"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_ids": userID,
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
                controller.userProfile[0].isHiddenFromFeed = 1
                self.showSuccessMessage(title: "Лента новостей", msg: "Новости от пользователя «\(name)» больше не будут показываться в вашей ленте новостей.")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func showUserInFeed(userID: String, name: String, controller: ProfileController2) {
        
        let url = "/method/newsfeed.deleteBan"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_ids": userID,
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
                controller.userProfile[0].isHiddenFromFeed = 0
                self.showSuccessMessage(title: "Лента новостей", msg: "Новости от пользователя «\(name)» теперь будут показываться в вашей ленте новостей.")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func hideGroupFromFeed(groupID: String, name: String, controller: GroupProfileController2) {
        
        let url = "/method/newsfeed.addBan"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_ids": groupID,
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
                controller.groupProfile[0].isHiddenFromFeed = 1
                self.showSuccessMessage(title: "Лента новостей", msg: "Новости от сообщества «\(name)» больше не будут показываться в вашей ленте новостей.")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func showGroupInFeed(groupID: String, name: String, controller: GroupProfileController2) {
        
        let url = "/method/newsfeed.deleteBan"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_ids": groupID,
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
                controller.groupProfile[0].isHiddenFromFeed = 0
                self.showSuccessMessage(title: "Лента новостей", msg: "Новости от сообщества «\(name)» теперь будут показываться в вашей ленте новостей.")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func copyPhotoToSaveAlbum(ownerID: String, photoID: String, accessKey: String) {
        
        let url = "/method/photos.copy"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "photo_id": photoID,
            "access_key": accessKey,
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
                self.showSuccessMessage(title: "Фотографии", msg: "Фотография успешно скопирована в альбом «Сохраненные фотографии»")
                
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deletePhotoFromSite(ownerID: String, photoID: String, delegate: UIViewController) {
        
        let url = "/method/photos.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "photo_id": photoID,
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
                var prevContr = delegate
                
                if let delegateController = delegate as? PhotoViewController {
                    prevContr = delegateController.previousViewController!
                }
                
                OperationQueue.main.addOperation {
                    self.navigationController?.popToViewController(prevContr, animated: true)
                }
                
                if prevContr is ProfileController2 {
                    (prevContr as? ProfileController2)?.offset = 0
                    (prevContr as? ProfileController2)?.refresh()
                }
                    
                if prevContr is GroupProfileController2 {
                    (prevContr as? GroupProfileController2)?.offset = 0
                    (prevContr as? GroupProfileController2)?.refresh()
                }
                
                if prevContr is PhotosListController {
                    (prevContr as? PhotosListController)?.offset = 0
                    (prevContr as? PhotosListController)?.getPhotos()
                }
                
                if prevContr is PhotoAlbumController {
                    (prevContr as? PhotoAlbumController)?.offset = 0
                    (prevContr as? PhotoAlbumController)?.getPhotos()
                }
                //self.showSuccessMessage(title: "Удаление фотографии", msg: "Удаление фотографии успешно завершено")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func repostObject(object: String, message: String) {
        let url = "/method/wall.repost"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "object": object,
            "message": message,
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
                let success = json["response"]["success"].intValue
                let postID = json["response"]["post_id"].intValue
                if success == 1 {
                    OperationQueue.main.addOperation {
                        self.openWallRecord(ownerID: Int(vkSingleton.shared.userID)!, postID: postID, accessKey: "", type: "post")
                    }
                }
                self.setOfflineStatus(dependence: request)
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func postponedPost(record: Record, delegate: UIViewController) {
        
        var attachments = ""
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                if attachments != "" {
                    attachments = "\(attachments),"
                }
                attachments = "\(attachments)photo\(record.photoOwnerID[index])_\(record.photoID[index])"
            }
            
            if record.mediaType[index] == "video" {
                if attachments != "" {
                    attachments = "\(attachments),"
                }
                attachments = "\(attachments)video\(record.photoOwnerID[index])_\(record.photoID[index])"
            }
            
            if record.mediaType[index] == "link" {
                if attachments != "" {
                    attachments = "\(attachments),"
                }
                attachments = "\(attachments)\(record.linkURL[index])"
            }
        }
        
        let url = "/method/wall.post"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": record.ownerID,
            "friends_only": "\(record.friendsOnly)",
            "message": record.text,
            "attachments": attachments,
            "post_id": "\(record.id)",
            "v": vkSingleton.shared.version
            ] as [String : Any]
        
        if record.ownerID < 0 {
            if record.fromID < 0 {
                parameters["from_group"] = "1"
                if record.signerID != 0 {
                    parameters["signed"] = "1"
                }
            }
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            self.setOfflineStatus(dependence: request)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    let prevController = delegate.previousViewController
                    self.navigationController?.popToViewController(prevController!, animated: true)
                    if let vc = prevController as? ProfileController2 {
                        vc.offset = 0
                        vc.refresh()
                    } else if let vc = prevController as? GroupProfileController2 {
                        vc.offset = 0
                        vc.refresh()
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func createPost(controller: NewRecordController, delegate: UIViewController) {
        let url = "/method/wall.post"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": controller.ownerID,
            "friends_only": "\(controller.onlyFriends)",
            "message": controller.textView.text!,
            "attachments": controller.attachments,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        
        if let id = Int(controller.ownerID), id < 0 {
            parameters["from_group"] = "\(controller.fromGroup)"
            if controller.fromGroup == 1 {
                parameters["signed"] = "\(controller.signed)"
            }
        }
        
        if controller.publishDate != nil {
            parameters["publish_date"] = controller.publishDate.timeIntervalSince1970
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            self.setOfflineStatus(dependence: request)
            
            if error.errorCode == 0 {
                let postID = json["response"]["post_id"].intValue
                let ownerID = controller.ownerID
                
                OperationQueue.main.addOperation {
                    controller.navigationController?.popViewController(animated: true)
                    if let delegateController = delegate as? ProfileController2 {
                        delegateController.refresh()
                    } else if let delegateController = delegate as? GroupProfileController2 {
                        delegateController.refresh()
                    }
                    delegate.openWallRecord(ownerID: Int(ownerID)!, postID: postID, accessKey: "", type: "post")
                }
            } else {
                delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func editPost(ownerID: Int, postID: Int, message: String, attachments: String, friendsOnly: Int, signed: Int, publish: Int, controller: Record2Controller) {
        
        let url = "/method/wall.edit"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(ownerID)",
            "post_id": "\(postID)",
            "message": message,
            "attachments": attachments,
            "v": vkSingleton.shared.version
        ]
        
        if publish != 0 {
            parameters["friends_only"] = "\(friendsOnly)"
            parameters["signed"] = "\(signed)"
            parameters["publish_date"] = "\(publish)"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                controller.getRecord()
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func reportUser(userID: String, type: String, comment: String) {
        
        let url = "/method/users.report"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_id": userID,
            "type": type,
            "comment": comment,
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
                self.showSuccessMessage(title: "Жалоба на пользователя", msg: "Ваша жалоба на пользователя успешно отправлена.")
            } else {
                self.showErrorMessage(title: "Жалоба на пользователя", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func reportObject(ownerID: String, type: String, reason: Int, itemID: String, comment: String) {
        
        var url = ""
        var title = ""
        var text = ""
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "reason": "\(reason)",
            "comment": comment,
            "v": vkSingleton.shared.version
        ]
        
        if type == "post" {
            url = "/method/wall.reportPost"
            parameters["post_id"] = itemID
            title = "Жалоба на запись"
            text = "Ваша жалоба на запись успешно отправлена."
        } else if type == "group" {
            url = "/method/wall.reportPost"
            parameters["post_id"] = itemID
            title = "Жалоба на сообщество"
            text = "Ваша жалоба на сообщество успешно отправлена."
        } else if type == "post_comment" {
            url = "/method/wall.reportComment"
            parameters["comment_id"] = itemID
            title = "Жалоба на комментарий"
            text = "Ваша жалоба на комментарий к записи успешно отправлена."
        } else if type == "photo" {
            url = "/method/photos.report"
            parameters["photo_id"] = itemID
            title = "Жалоба на фотографию"
            text = "Ваша жалоба на фотографию успешно отправлена."
        } else if type == "photo_comment" {
            url = "/method/photos.reportComment"
            parameters["comment_id"] = itemID
            title = "Жалоба на комментарий"
            text = "Ваша жалоба на комментарий к фотографии успешно отправлена."
        } else if type == "video_comment" {
            url = "/method/video.reportComment"
            parameters["comment_id"] = itemID
            title = "Жалоба на комментарий"
            text = "Ваша жалоба на комментарий к видеозаписи успешно отправлена."
        } else if type == "video" {
            url = "/method/video.report"
            parameters["video_id"] = itemID
            title = "Жалоба на видеозапись"
            text = "Ваша жалоба на видеозапись успешно отправлена."
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                self.showSuccessMessage(title: title, msg: text)
            } else {
                self.showErrorMessage(title: title, msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func editManager(groupID: String, userID: String, role: String, type: String, controller: MembersController) {
        
        let url = "/method/groups.editManager"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": groupID,
            "user_id": userID,
            "v": vkSingleton.shared.version
        ]
        
        if role != "" {
            parameters["role"] = role
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                if let gid = Int(groupID), userID == vkSingleton.shared.userID {
                    if role == "" {
                        vkSingleton.shared.adminGroupID.remove(object: gid)
                    } else {
                        if !vkSingleton.shared.adminGroupID.contains(gid) {
                            vkSingleton.shared.adminGroupID.append(gid)
                        }
                    }
                }
                
                if type == "change" {
                    OperationQueue.main.addOperation {
                        controller.offset = 0
                        controller.refresh()
                    }
                } else {
                    self.showSuccessMessage(title: "Изменение полномочий", msg: "Изменение полномочий пользователя в сообществе успешно проведены.")
                }
            } else if error.errorCode == 700 {
                self.showErrorMessage(title: "Изменение полномочий", msg: "#700: Невозможно изменить полномочия создателя.")
            } else if error.errorCode == 701 {
                self.showErrorMessage(title: "Изменение полномочий", msg: "#701: Пользователь должен состоять в сообществе.")
            } else if error.errorCode == 702 {
                self.showErrorMessage(title: "Изменение полномочий", msg: "#702: Достигнут лимит на количество руководителей в сообществе.")
            } else {
                self.showErrorMessage(title: "Изменение полномочий", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteMessage(messIDs: String, forAll: Bool, spam: Bool, controller: DialogController) {
        
        let url = "/method/messages.delete"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "message_ids": messIDs,
            "v": vkSingleton.shared.version
        ]
        
        if spam {
            parameters["spam"] = "1"
        }
        
        if forAll {
            parameters["delete_for_all"] = "1"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                
            } else {
                self.showErrorMessage(title: "Отправка сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
            controller.markMessages.removeAll(keepingCapacity: false)
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteMessageGroupDialog(messIDs: String, forAll: Bool, spam: Bool, controller: GroupDialogController) {
        
        let url = "/method/messages.delete"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "message_ids": messIDs,
            "group_id": controller.groupID,
            "v": vkSingleton.shared.version
        ]
        
        if spam {
            parameters["spam"] = "1"
        }
        
        if forAll {
            parameters["delete_for_all"] = "1"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                
            } else {
                self.showErrorMessage(title: "Отправка сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
            controller.markMessages.removeAll(keepingCapacity: false)
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func sendMessage(message: String, attachment: String, fwdMessages: String, stickerID: Int, controller: DialogController) {
        
        let url = "/method/messages.send"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "random_id": "",
            "peer_id": controller.userID,
            "message": message,
            "v": vkSingleton.shared.version
        ]
        
        if attachment != "" {
            parameters["attachment"] = attachment
        }
        
        if fwdMessages != "" {
            parameters["forward_messages"] = fwdMessages
        }
        
        if stickerID != 0 {
            parameters["sticker_id"] = stickerID
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                //let messID = json["response"]["upload_url"].stringValue
                OperationQueue.main.addOperation {
                    controller.attachments = ""
                    controller.fwdMessages = ""
                    controller.commentView.textView.text = ""
                    
                    controller.fwdMessagesID.removeAll(keepingCapacity: false)
                    controller.attach.removeAll(keepingCapacity: false)
                    controller.photos.removeAll(keepingCapacity: false)
                    controller.isLoad.removeAll(keepingCapacity: false)
                    controller.typeOf.removeAll(keepingCapacity: false)
                    
                    controller.setAttachments()
                    controller.collectionView.reloadData()
                }
            } else {
                if stickerID > 0 {
                    self.showErrorMessage(title: "Ошибка при отправке стикера", msg: "Данный набор стикеров необходимо активировать в полной версии сайта (https://vk.com/stickers?tab=free).")
                } else {
                    self.showErrorMessage(title: "Отправка сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func sendMessageGroupDialog(message: String, attachment: String, fwdMessages: String, stickerID: Int, controller: GroupDialogController) {
        
        let url = "/method/messages.send"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "random_id": "",
            "peer_id": controller.userID,
            "message": message,
            "group_id": controller.groupID,
            "v": vkSingleton.shared.version
        ]
        
        if attachment != "" {
            parameters["attachment"] = attachment
        }
        
        if fwdMessages != "" {
            parameters["forward_messages"] = fwdMessages
        }
        
        if stickerID != 0 {
            parameters["sticker_id"] = stickerID
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                //let messID = json["response"]["upload_url"].stringValue
                OperationQueue.main.addOperation {
                    controller.attachments = ""
                    controller.fwdMessages = ""
                    controller.commentView.textView.text = ""
                    
                    controller.fwdMessagesID.removeAll(keepingCapacity: false)
                    controller.attach.removeAll(keepingCapacity: false)
                    controller.photos.removeAll(keepingCapacity: false)
                    controller.isLoad.removeAll(keepingCapacity: false)
                    controller.typeOf.removeAll(keepingCapacity: false)
                    
                    controller.setAttachments()
                    controller.collectionView.reloadData()
                }
            } else {
                if stickerID > 0 {
                    self.showErrorMessage(title: "Ошибка при отправке стикера", msg: "Данный набор стикеров необходимо активировать в полной версии сайта (https://vk.com/stickers?tab=free).")
                } else {
                    self.showErrorMessage(title: "Отправка сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func editMessage(message: String, attachment: String, messageID: Int, controller: UIViewController) {
        
        if let delegate = controller as? DialogController {
            let url = "/method/messages.edit"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "peer_id": delegate.userID,
                "message": message,
                "message_id": "\(messageID)",
                "attachment": attachment,
                "keep_forward_messages": "1",
                "keep_snippets": "1",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                //print(json)
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if error.errorCode == 909 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#909: Невозможно отредактировать сообщение после 24 часов.")
                } else if error.errorCode == 910 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#910: Невозможно отредактировать сообщение, поскольку оно слишком большое.")
                } else if error.errorCode == 914 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#914: Сообщение слишком длинное.")
                } else if error.errorCode == 917 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#917: У вас нет доступа в эту беседу.")
                } else if error.errorCode == 920 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#920: Невозможно отредактировать сообщение такого типа.")
                } else {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
                self.setOfflineStatus(dependence: request)
            }
            
            OperationQueue().addOperation(request)
        } else if let delegate = controller as? GroupDialogController {
            
            let url = "/method/messages.edit"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "peer_id": delegate.userID,
                "message": message,
                "message_id": "\(messageID)",
                "attachment": attachment,
                "keep_forward_messages": "1",
                "keep_snippets": "1",
                "group_id": delegate.groupID,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                //print(json)
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if error.errorCode == 909 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#909: Невозможно отредактировать сообщение после 24 часов.")
                } else if error.errorCode == 910 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#910: Невозможно отредактировать сообщение, поскольку оно слишком большое.")
                } else if error.errorCode == 914 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#914: Сообщение слишком длинное.")
                } else if error.errorCode == 917 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#917: У вас нет доступа в эту беседу.")
                } else if error.errorCode == 920 {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#920: Невозможно отредактировать сообщение такого типа.")
                } else {
                    self.showErrorMessage(title: "Ошибка редактирования", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
                self.setOfflineStatus(dependence: request)
            }
            
            OperationQueue().addOperation(request)
        }
    }
    
    func markAsReadMessages(controller: UIViewController) {
        
        if AppConfig.shared.readMessageInDialog {
            
            if let delegate = controller as? DialogController {
                let url = "/method/messages.markAsRead"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "peer_id": delegate.userID,
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode != 0 {
                        print(json)
                    }
                }
                
                OperationQueue().addOperation(request)
            }
            
            if let delegate = controller as? GroupDialogController {
                
                let url = "/method/messages.markAsRead"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "peer_id": delegate.userID,
                    "group_id": delegate.groupID,
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode != 0 {
                        print(json)
                    }
                }
                
                OperationQueue().addOperation(request)
            }
        }
    }
    
    func startTyping(controller: DialogController) {
        
        if AppConfig.shared.showTextEditInDialog {
            
            let url = "/method/messages.setActivity"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "user_id": controller.userID,
                "type": "typing",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode != 0 {
                    //print(json)
                }
            }
            
            OperationQueue().addOperation(request)
        }
    }
    
    func inviteInGroup(groupID: String, userID: String, name: String) {
        
        let url = "/method/groups.invite"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": groupID,
            "user_id": userID,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                self.showSuccessMessage(title: "Приглашение в сообщество", msg: "Приглашение успешно выслано пользователю «\(name)».")
            } else if error.errorCode == 15 {
                self.showErrorMessage(title: "Ошибка приглашения", msg: "#15: Пользователь запретил приглашать себя в сообщества.")
            } else if error.errorCode == 103 {
                self.showErrorMessage(title: "Ошибка приглашения", msg: "#103: Превышен лимит!")
            } else {
                self.showErrorMessage(title: "Ошибка приглашения", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func getCounters() {
        
        let url = "/method/account.getCounters"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "filter": "friends,messages",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                let friends = json["response"]["friends"].intValue
                let messages = json["response"]["messages"].intValue
                
                OperationQueue.main.addOperation {
                    if let item = self.tabBarController?.tabBar.items?[0] {
                        if friends > 0 {
                            item.badgeValue = "\(friends)"
                        } else {
                            item.badgeValue = nil
                        }
                    }
                    
                    if let item = self.tabBarController?.tabBar.items?[3] {
                        if messages > 0 {
                            item.badgeValue = "\(messages)"
                        } else {
                            item.badgeValue = nil
                        }
                    }
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteRequest(userID: String, controller: UsersController) {
        
        let url = "/method/friends.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_id": userID,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    controller.getCounters()
                    for friend in controller.friends {
                        if friend.userID == userID {
                            controller.friends.remove(object: friend)
                        }
                    }
                    controller.sortedFriends = controller.friends
                    controller.users = controller.sortedFriends
                    controller.tableView.reloadData()
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteAllRequests(controller: UsersController) {
        
        let url = "/method/friends.deleteAllRequests"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    controller.getCounters()
                    controller.friends.removeAll(keepingCapacity: false)
                    controller.sortedFriends.removeAll(keepingCapacity: false)
                    controller.users.removeAll(keepingCapacity: false)
                    controller.tableView.reloadData()
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func joinOurGroup() {
        let url = "/method/groups.join"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "166099539",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        /*request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            print(json)
        }*/
        OperationQueue().addOperation(request)
    }
    
    func createChat(userIDs: String, title: String, controller: DialogsController) {
        
        let url = "/method/messages.createChat"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_ids": userIDs,
            "title": title,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    controller.pullToRefresh()
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func editChat(newTitle: String, chatID: String) {
        
        let url = "/method/messages.editChat"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "chat_id": chatID,
            "title": newTitle,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if let vc = self as? DialogController {
                        vc.getDialog()
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteChatPhoto(chatID: String) {
        
        let url = "/method/messages.deleteChatPhoto"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "chat_id": chatID,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if let vc = self as? DialogController {
                        vc.getDialog()
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func removeFromChat(chatID: String, userID: String, controller: DialogController) {
        
        let url = "/method/messages.removeChatUser"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "chat_id": chatID,
            "user_id": userID,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if userID == vkSingleton.shared.userID {
                        controller.navigationController?.popViewController(animated: true)
                    } else {
                        controller.getDialog()
                    }
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func addUserToChat(chatID: String, userID: String, controller: DialogController) {
        
        let url = "/method/messages.addChatUser"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "chat_id": chatID,
            "user_id": userID,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    controller.getDialog()
                }
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func getLinkToChat(reset: String, controller: DialogController) {
        
        let url = "/method/messages.getInviteLink"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "peer_id": controller.userID,
            "reset": reset,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            //print(json)
            
            if error.errorCode == 0 {
                let link = json["response"]["link"].stringValue
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка для приглашения в чат", msg: "Ссылка скопирована в буфер обмена:\n\n\(string)")
                }
            } else {
                if error.errorCode == 919 {
                    self.showErrorMessage(title: "Ошибка получения ссылки", msg: "Вам недоступны ссылки для приглашения в этот чат.")
                } else {
                    self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func getAppVkStat() {
        
        if vkSingleton.shared.vkAppID.count > 0 {
            let url = "/method/stats.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "app_id": vkSingleton.shared.vkAppID[0],
                "date_from": "2018-01-01",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                print(json)
                
                if error.errorCode == 0 {
                    
                } else {
                    self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func changeAvatar(newID: String, oldID: String) {
        
        let url = "/method/photos.reorderPhotos"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": vkSingleton.shared.userID,
            "photo_id": "\(newID)",
            "after": "\(oldID)",
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
                self.showSuccessMessage(title: "Изменение фото профиля", msg: "Изменение главной фотографии профиля завершено. Обновите экран.")
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func putNewAvatar(newID: String) {
        
        let url = "/method/photos.move"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": vkSingleton.shared.userID,
            "target_album_id": "-6",
            "photo_id": "\(newID)",
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
                self.showSuccessMessage(title: "Изменение фото профиля", msg: "Изменение главной фотографии профиля завершено. Обновите экран.")
            } else {
                self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadOwnerPhoto(image: UIImage, filename: String, squareCrop: String) {
        let url = "/method/photos.getOwnerPhotoUploadServer"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
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
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myImageUploadRequest(url: uploadURL, image: image, filename: filename, squareCrop: squareCrop) { json2 in
                    let photo = json2["photo"].stringValue
                    let server = json2["server"].intValue
                    let hash = json2["hash"].stringValue
                    
                    let url2 = "/method/photos.saveOwnerPhoto"
                    let parameters2 = [
                        "access_token": vkSingleton.shared.accessToken,
                        "photo": photo,
                        "server": "\(server)",
                        "hash": hash,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url2, parameters: parameters2)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        let json3 = try! JSON(data: data)
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json3["error"]["error_code"].intValue
                        error.errorMsg = json3["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.setOfflineStatus(dependence: request)
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().hideActivityIndicator()
                                self.showSuccessMessage(title: "Изменение фото профиля", msg: "Изменение главной фотографии профиля завершено. Обновите экран.")
                            }
                        } else {
                            OperationQueue.main.addOperation {
                                ViewControllerUtils().hideActivityIndicator()
                                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                            }
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                    self.showErrorMessage(title: "Ошибка", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadWallPhotosToServer(ownerID: Int, image: UIImage, filename: String, completion: @escaping (String) -> Void) {
        
        var url = "/method/photos.getWallUploadServer"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        if ownerID < 0 {
            parameters["group_id"] = "\(abs(ownerID))"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myImageUploadRequest(url: uploadURL, image: image, filename: filename, squareCrop: "") { json2 in
                    let photo = json2["photo"].stringValue
                    let server = json2["server"].intValue
                    let hash = json2["hash"].stringValue
                    
                    url = "/method/photos.saveWallPhoto"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "photo": photo,
                        "server": server,
                        "hash": hash,
                        "v": vkSingleton.shared.version
                        ]
                    
                    if ownerID > 0 {
                        parameters["user_id"] = "\(ownerID)"
                    } else {
                        parameters["group_id"] = "\(abs(ownerID))"
                    }
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        let json3 = try! JSON(data: data)
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json3["error"]["error_code"].intValue
                        error.errorMsg = json3["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            let id = json3["response"][0]["id"].intValue
                            let owner = json3["response"][0]["owner_id"].intValue
                            let attach = "photo\(owner)_\(id)"
                            
                            completion(attach)
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadDocsToServer(ownerID: Int, image: UIImage, filename: String, imageData: Data, completion: @escaping (String) -> Void) {
        
        var url = "/method/docs.getWallUploadServer"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        if ownerID < 0 {
            parameters["group_id"] = "\(abs(ownerID))"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myGifUploadRequest(url: uploadURL, imageData: imageData, filename: filename) { json2 in
                    let file = json2["file"].stringValue
                    
                    url = "/method/docs.save"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "file": file,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        let json3 = try! JSON(data: data)
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json3["error"]["error_code"].intValue
                        error.errorMsg = json3["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            let id = json3["response"][0]["id"].intValue
                            let owner = json3["response"][0]["owner_id"].intValue
                            let attach = "doc\(owner)_\(id)"
                            
                            completion(attach)
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadChatPhotoToServer(chatID: String, image: UIImage, filename: String) {
        
        var url = "/method/photos.getChatUploadServer"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "chat_id": chatID,
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
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myImageUploadRequest(url: uploadURL, image: image, filename: filename, squareCrop: "") { json2 in
                    let response = json2["response"].stringValue
                    
                    url = "/method/messages.setChatPhoto"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "file": response,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        let json3 = try! JSON(data: data)
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json3["error"]["error_code"].intValue
                        error.errorMsg = json3["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            if let vc = self as? DialogController {
                                vc.getDialog()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
}

extension UIViewController {
    func myImageUploadRequest(url: String, image: UIImage, filename: String, squareCrop: String, completion: @escaping (JSON) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.jpegData(compressionQuality: 1)
            
        if imageData == nil { return }
            
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, filepath: filename, squareCrop: squareCrop) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode != 0 {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
            completion(json)
        }
        
        task.resume()
    }
    
    func myGifUploadRequest(url: String, imageData: Data, filename: String, completion: @escaping (JSON) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData as NSData, boundary: boundary, filepath: filename, squareCrop: "") as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode != 0 {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
            completion(json)
        }
        
        task.resume()
    }
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String, filepath: String, squareCrop: String) -> NSData {
        
        let body = NSMutableData();
        
        if squareCrop != "" {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"_square_crop\"\r\n\r\n")
            body.appendString(string: "\(squareCrop)\r\n")
        }
        
        var filename = "photo.jpg"
        var mimetype = "image/jpg"
        
        if filepath.hasSuffix("gif") {
            filename = "photo.gif"
            mimetype = "image/gif"
        }
        
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
