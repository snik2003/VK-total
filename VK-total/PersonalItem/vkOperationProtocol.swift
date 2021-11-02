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
import SCLAlertView
import DropDown
import SmileLock

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
    
    func deleteVideoFromSite(ownerID: Int, videoID: Int, delegate: UIViewController?)
    
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
    
    func loadPhotosAlbumToServer(ownerID: Int, albumID: Int, image: UIImage, caption: String, filename: String, completion: @escaping (Int, ErrorJson) -> Void)
    
    func loadWallPhotosToServer(ownerID: Int, image: UIImage, filename: String, completion: @escaping (String) -> Void)
    
    func loadDocsToServer(ownerID: Int, image: UIImage, filename: String, imageData: Data, completion: @escaping (String) -> Void)
    
    func getUploadVideoURL(isLink: Bool, groupID: Int, isPrivate: Int, wallpost: Int, completion: @escaping (String, String) -> Void)
    
    func getImportantConversations() -> [Int]
    
    func saveImportantConversations(importantIds: [Int])
    
    func addImportantConversation(importantID: Int)
    
    func deleteImportantConversation(importantID: Int)
    
    func actualConversationArray(conversations: [Conversation]) -> [Conversation]
    
    func convertMenuDialogs()
    
    func splitMenuDialogsArrayOn100(dialogsIDs: [Int]) -> [[Int]]
    
    func readMenuDialogs() -> [Int]
    
    func saveMenuDialogs(dialogsIds: [Int])
    
    func removeConversationWith(peerID: Int)
    
    func addPeerIdToMenuDialogs(peerID: Int)
    
    func removePeerIdFromMenuDialogs(peerID: Int)
    
    func addNewConversations(conversations: [Conversation]) -> [Int]
    
    func addStickersToFavorite(stickerID: Int, success: @escaping ()->())
    
    func removeStickersFromFavorite(stickerID: Int, success: @escaping ()->())
    
    func checkAndAddStickersToFavorite(stickerID: Int, success: @escaping ()->())
}

extension UIViewController: VkOperationProtocol {
    
    func checkAndAddStickersToFavorite(stickerID: Int, success: @escaping ()->()) {
        if vkSingleton.shared.favoriteStickers.stickers.contains(where: {$0.stickerID == stickerID }) {
            self.removeStickersFromFavorite(stickerID: stickerID, success: {
                self.addStickersToFavorite(stickerID: stickerID, success: success)
            })
        } else if vkSingleton.shared.favoriteStickers.stickers.count < vkSingleton.shared.maxFavoriteStickersCount {
            self.addStickersToFavorite(stickerID: stickerID, success: success)
        } else if let lastSticker = vkSingleton.shared.favoriteStickers.stickers.last {
            self.removeStickersFromFavorite(stickerID: lastSticker.stickerID, success: {
                self.addStickersToFavorite(stickerID: stickerID, success: success)
            })
        }
    }
    
    func addStickersToFavorite(stickerID: Int, success: @escaping ()->()) {
        let url = "/method/store.addStickersToFavorite"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "sticker_ids": "\(stickerID)",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                let url2 = "/method/store.getFavoriteStickers"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                request2.completionBlock = {
                    guard let data = request2.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    vkSingleton.shared.getFavoriteStickers(json: json["response"]["items"])
                    success()
                }
                OperationQueue().addOperation(request2)
            } else {
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                self.showErrorMessage(title: "Внимание!", msg: "\(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func removeStickersFromFavorite(stickerID: Int, success: @escaping ()->()) {
        let url = "/method/store.removeStickersFromFavorite"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "sticker_ids": "\(stickerID)",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                let url2 = "/method/store.getFavoriteStickers"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                request2.completionBlock = {
                    guard let data = request2.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    vkSingleton.shared.getFavoriteStickers(json: json["response"]["items"])
                    success()
                }
                OperationQueue().addOperation(request2)
            } else {
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                self.showErrorMessage(title: "Внимание!", msg: "\(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func convertMenuDialogs() {
        
        let key = "\(vkSingleton.shared.userID)_all-dialogs"
        if let dialogs = UserDefaults.standard.object(forKey: key) as? [Message] {
        
            var dialogsIDs = readMenuDialogs()
            for dialog in dialogs {
                if !dialogsIDs.contains(dialog.peerID) { dialogsIDs.append(dialog.peerID) }
                saveMenuDialogs(dialogsIds: dialogsIDs)
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    func splitMenuDialogsArrayOn100(dialogsIDs: [Int]) -> [[Int]] {
        
        var peer100: [[Int]] = []
        let count = dialogsIDs.count % 100 == 0 ? dialogsIDs.count / 100 : dialogsIDs.count / 100 + 1
        
        if (count == 1) {
            peer100.append(dialogsIDs)
        } else {
            for index in 0 ..< count {
                let index0 = 100 * index
                let index1 = min(99 + 100 * index,dialogsIDs.count - 1)
                
                let element = Array(dialogsIDs[index0 ... index1])
                peer100.append(element)
            }
        }
        
        return peer100
    }
    
    func readMenuDialogs() -> [Int] {
    
        let key = "\(vkSingleton.shared.userID)_menu-all-dialogs"
        if let dialogsIds = UserDefaults.standard.object(forKey: key) as? [Int] { return dialogsIds }
        
        return []
    }
    
    func saveMenuDialogs(dialogsIds: [Int]) {
        
        let key = "\(vkSingleton.shared.userID)_menu-all-dialogs"
        UserDefaults.standard.set(dialogsIds, forKey: key)
    }
    
    func removeConversationWith(peerID: Int) {
        
        let dialogsIDs = readMenuDialogs().filter({ $0 != peerID })
        saveMenuDialogs(dialogsIds: dialogsIDs)
    }
    
    func addPeerIdToMenuDialogs(peerID: Int) {
        
        var dialogsIDs = readMenuDialogs()
        if !dialogsIDs.contains(peerID) {
            dialogsIDs.append(peerID)
            saveMenuDialogs(dialogsIds: dialogsIDs)
            
            print("add peerId \(peerID) to menu dialogs")
        }
    }
    
    func removePeerIdFromMenuDialogs(peerID: Int) {
        
        var dialogsIDs = readMenuDialogs()
        if dialogsIDs.contains(peerID) {
            dialogsIDs.remove(object: peerID)
            saveMenuDialogs(dialogsIds: dialogsIDs)
            
            print("remove peerId \(peerID) from menu dialogs")
        }
    }
    
    func addNewConversations(conversations: [Conversation]) -> [Int] {
        
        var dialogsIDs = readMenuDialogs()
        
        for conversation in conversations {
            if !dialogsIDs.contains(conversation.peerID) { dialogsIDs.append(conversation.peerID) }
        }
        
        saveMenuDialogs(dialogsIds: dialogsIDs)
        
        return dialogsIDs
    }
    
    func getImportantConversations() -> [Int] {
    
        let key = "\(vkSingleton.shared.userID)_important_conversation"
        if let importantIds = UserDefaults.standard.object(forKey: key) as? [Int] { return importantIds }
        
        return []
    }
    
    func saveImportantConversations(importantIds: [Int]) {
        
        let key = "\(vkSingleton.shared.userID)_important_conversation"
        UserDefaults.standard.set(importantIds, forKey: key)
    }
    
    func addImportantConversation(importantID: Int) {
        
        var importantIDs = getImportantConversations()
        
        if !importantIDs.contains(importantID) {
            importantIDs.append(importantID)
            saveImportantConversations(importantIds: importantIDs)
        }
    }
    
    func deleteImportantConversation(importantID: Int) {
        
        var importantIDs = getImportantConversations()
        
        if importantIDs.contains(importantID) {
            importantIDs.remove(object: importantID)
            saveImportantConversations(importantIds: importantIDs)
        }
    }
    
    func actualConversationArray(conversations: [Conversation]) -> [Conversation] {
        
        let importantIDs = getImportantConversations()
        
        for conversation in conversations {
            conversation.important = importantIDs.contains(conversation.peerID) ? true : false
        }
        
        return conversations
    }
    
    func unregisterDeviceOnPush() {
        
        let userDefaults = UserDefaults.standard
        
        var sandbox = 0
        #if DEBUG
            sandbox = 1
        #endif
        
        let url = "/method/account.unregisterDevice"
        let parameters = [
            //"token": vkSingleton.shared.deviceToken,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "sandbox": "\(sandbox)",
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
        
        var sandbox = 0
        #if DEBUG
            sandbox = 1
        #endif
        
        let url = "/method/account.registerDevice"
        let parameters = [
            "token": vkSingleton.shared.deviceToken,
            "device_model": UIDevice.current.localizedModel,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "system_version": UIDevice.current.systemVersion,
            "sandbox": "\(sandbox)",
            "settings": JSON(jsonParam),
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        //print(parameters)
        
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
                "guid": guid,
                "v": vkSingleton.shared.version
            ]
            
        } else if controller.type == "photo" {
            url = "/method/photos.createComment"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": controller.ownerID,
                "photo_id": controller.itemID,
                "guid": guid,
                "v": vkSingleton.shared.version
            ]
        }
     
        if !text.isEmpty {
            parameters["message"] = text
        }
        
        if !attachments.isEmpty {
            parameters["attachments"] = attachments
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
            
            //print(json)
            
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
               error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                    controller.tableView.frame = CGRect(x: 0, y: controller.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - controller.navHeight - controller.tabHeight)
                    controller.view.addSubview(controller.tableView)
                    controller.commentView.removeFromSuperview()
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                error.showErrorMessage(controller: self)
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
                    controller.commentView = DCCommentView.init(scrollView: controller.tableView, frame: controller.view.bounds, color: vkSingleton.shared.backColor)
                    controller.commentView.delegate = controller
                    controller.commentView.textView.backgroundColor = .clear
                    controller.commentView.textView.textColor = vkSingleton.shared.labelColor
                    controller.commentView.textView.tintColor = vkSingleton.shared.secondaryLabelColor
                    controller.commentView.textView.changeKeyboardAppearanceMode()
                    controller.commentView.tintColor = vkSingleton.shared.labelColor
                    
                    controller.commentView.sendImage = UIImage(named: "send")
                    
                    if (vkSingleton.shared.stickers.count > 0) {
                        controller.commentView.stickerImage = UIImage(named: "sticker")
                        controller.commentView.stickerButton.addTarget(controller, action: #selector(controller.tapStickerButton(sender:)), for: .touchUpInside)
                    }
                    
                    controller.commentView.tabHeight = 0
                    if #available(iOS 13.0, *) {
                        if !AppConfig.shared.autoMode {
                            if vkSingleton.shared.deviceInterfaceStyle == .dark && !AppConfig.shared.darkMode {
                                controller.commentView.tabHeight = controller.tabHeight
                            } else if vkSingleton.shared.deviceInterfaceStyle == .light && AppConfig.shared.darkMode {
                                controller.commentView.tabHeight = controller.tabHeight
                            }
                        }
                    }
                    
                    if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(controller.groupID)!) {
                        controller.setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: controller)
                    } else {
                        controller.setCommentFromGroupID(id: 0, controller: controller)
                    }
                    
                    controller.commentView.accessoryImage = UIImage(named: "attachment")
                    controller.commentView.accessoryButton.addTarget(controller, action: #selector(controller.tapAccessoryButton(sender:)), for: .touchUpInside)
                    
                    controller.view.addSubview(controller.commentView)
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                }
            } else {
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func deleteVideoFromSite(ownerID: Int, videoID: Int, delegate: UIViewController?) {
        
        let url = "/method/video.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "target_id": "\(ownerID)",
            "owner_id": "\(ownerID)",
            "video_id": "\(videoID)",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { ViewControllerUtils().hideActivityIndicator(); print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            ViewControllerUtils().hideActivityIndicator()
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if let controller = delegate as? VideoListController {
                        self.navigationController?.popViewController(animated: true)
                        
                        controller.videos = controller.videos.filter({ !($0.ownerID == ownerID && $0.id == videoID) })
                        controller.tableView.reloadData()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    
                        if ownerID > 0 {
                            self.showSuccessMessage(title: "Видео успешно удалено!", msg: "Видеозапись была успешно удалена с Вашей страницы.")
                        } else if ownerID < 0 {
                            self.showSuccessMessage(title: "Видео успешно удалено!", msg: "Видеозапись была успешно удалена со страницы сообщества.")
                        }
                    }
                }
            } else {
                error.showErrorMessage(controller: self)
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
                        self.openWallRecord(ownerID: Int(vkSingleton.shared.userID)!, postID: postID, accessKey: "", type: "post", scrollToComment: false)
                    }
                }
                self.setOfflineStatus(dependence: request)
            } else {
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                    delegate.openWallRecord(ownerID: Int(ownerID)!, postID: postID, accessKey: "", type: "post", scrollToComment: false)
                }
            } else {
                error.showErrorMessage(controller: delegate)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
            
            if error.errorCode != 0 {
                error.showErrorMessage(controller: self)
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
            
            if error.errorCode != 0 {
                error.showErrorMessage(controller: self)
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
            "v": vkSingleton.shared.version
        ]
        
        if !message.isEmpty {
            parameters["message"] = message
        }
        
        if !attachment.isEmpty {
            parameters["attachment"] = attachment
        }
        
        if !fwdMessages.isEmpty {
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
                    error.showErrorMessage(controller: self)
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
            "group_id": controller.groupID,
            "v": vkSingleton.shared.version
        ]
        
        if !message.isEmpty {
            parameters["message"] = message
        }
        
        if !attachment.isEmpty {
            parameters["attachment"] = attachment
        }
        
        if !fwdMessages.isEmpty {
            parameters["forward_messages"] = fwdMessages
        }
        
        if stickerID != 0 {
            parameters["sticker_id"] = stickerID
        }
        
        //print(parameters)
        
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
                    error.showErrorMessage(controller: self)
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
                    error.showErrorMessage(controller: self)
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
                   error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func getAccountCounters(account: AccountVK, counters: @escaping (String,Int,Int,Int)->()) {
        
        var code = "var a = API.account.getCounters({\"access_token\":\"\(account.token)\",\"filter\":\"friends,messages\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var b = API.notifications.get({\"count\":\"100\",\"start_time\":\"\(Date().timeIntervalSince1970 - 15552000)\",\"access_token\":\"\(account.token)\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.groups.getInvites({\"count\":\"100\",\"extended\":\"0\",\"access_token\":\"\(account.token)\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) return [a,b,c];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": account.token,
            "code": code,
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
                    let counter1 = json["response"][0]["friends"].intValue
                    let counter2 = json["response"][0]["messages"].intValue
                    
                    var counter3 = 0
                    
                    let notData = json["response"][1]["items"].compactMap { Notifications(json: $0.1) }
                    let lastViewed = json["response"][1]["last_viewed"].intValue
                    for not in notData {
                        if not.date > lastViewed {
                            counter3 += not.feedback.count
                        }
                    }
                    
                    let groups = json["response"][2]["items"].compactMap { Groups(json: $0.1) }
                    counter3 += groups.count
                    
                    counters(account.token,counter1,counter2,counter3)
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                    print("errorCode = \(error.errorCode), errorMsg = \(error.errorMsg)")
                }
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    controller.pullToRefresh()
                }
            } else {
                error.showErrorMessage(controller: self)
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
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if let vc = self as? DialogController {
                        vc.getDialog()
                    }
                }
            } else {
                error.showErrorMessage(controller: self)
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
            //print(json)
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    if let vc = self as? DialogController {
                        vc.getDialog()
                    }
                }
            } else {
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                    error.showErrorMessage(controller: self)
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
                //print(json)
                
                if error.errorCode != 0 {
                    error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                error.showErrorMessage(controller: self)
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
                                error.showErrorMessage(controller: self)
                            }
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                    error.showErrorMessage(controller: self)
                }
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadPhotosAlbumToServer(ownerID: Int, albumID: Int, image: UIImage, caption: String, filename: String, completion: @escaping (Int, ErrorJson) -> Void) {
        let url = "/method/photos.getUploadServer"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "album_id": albumID,
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
                    //print("json2 = \(json2)")
                    
                    let error2 = ErrorJson(json: JSON.null)
                    error2.errorCode = json2["error"]["error_code"].intValue
                    error2.errorMsg = json2["error"]["error_msg"].stringValue
                    
                    if error2.errorCode == 0 {
                        let photos = json2["photos_list"].stringValue
                        let server = json2["server"].intValue
                        let hash = json2["hash"].stringValue
                        
                        let url2 = "/method/photos.save"
                        var parameters2: [String : Any] = [
                            "access_token": vkSingleton.shared.accessToken,
                            "album_id": albumID,
                            "photos_list": photos,
                            "server": server,
                            "hash": hash,
                            "caption": caption,
                            "v": vkSingleton.shared.version
                            ]
                        
                        if ownerID < 0 {
                            parameters2["group_id"] = "\(abs(ownerID))"
                        }
                        
                        let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                        request2.completionBlock = {
                            guard let data = request2.data else { return }
                            guard let json3 = try? JSON(data: data) else { print("json error"); return }
                            
                            let error3 = ErrorJson(json: JSON.null)
                            error3.errorCode = json3["error"]["error_code"].intValue
                            error3.errorMsg = json3["error"]["error_msg"].stringValue
                            
                            completion(error3.errorCode, error3)
                        }
                        OperationQueue().addOperation(request2)
                    }
                    
                    completion(error2.errorCode, error2)
                }
            } else {
                completion(error.errorCode, error)
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
                        //print(json3)
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json3["error"]["error_code"].intValue
                        error.errorMsg = json3["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            let id = json3["response"][0]["id"].intValue
                            let owner = json3["response"][0]["owner_id"].intValue
                            let accessKey = json3["response"][0]["access_key"].stringValue
                            let attach = "photo\(owner)_\(id)_\(accessKey)"
                            
                            completion(attach)
                        } else {
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                error.showErrorMessage(controller: self)
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func loadVoiceMessageToServer(fileData: Data, fileName: String, completion: @escaping (String) -> Void) {
        let url = "/method/docs.getMessagesUploadServer"
        let parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "peer_id": vkSingleton.shared.userID,
            "type": "audio_message",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            print("json1 = \(json)")
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myGifUploadRequest(url: uploadURL, imageData: data, filename: fileName) { json2 in
                    
                    print("json2 = \(json2)")
                    
                    let error = json2["error_descr"].stringValue
                    if error.isEmpty {
                        let file = json2["file"].stringValue
                    
                        let url2 = "/method/docs.save"
                        let parameters2 = [
                            "access_token": vkSingleton.shared.accessToken,
                            "file": file,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                        request2.completionBlock = {
                            guard let data = request2.data else { return }
                            
                            let json3 = try! JSON(data: data)
                            print("json3 = \(json3)")
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json3["error"]["error_code"].intValue
                            error.errorMsg = json3["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                let id = json3["response"][0]["id"].intValue
                                let owner = json3["response"][0]["owner_id"].intValue
                                let attach = "doc\(owner)_\(id)"
                                
                                completion(attach)
                            } else {
                                completion("")
                                self.showErrorMessage(title: "Внимание!", msg: "Ошибка загрузки файла\nголосового сообщения на сервер:\n\n\(error.errorMsg)")
                            }
                        }
                        OperationQueue().addOperation(request2)
                    } else {
                        completion("")
                        self.showErrorMessage(title: "Внимание!", msg: "Ошибка загрузки файла\nголосового сообщения на сервер:\n\n\(error)")
                    }
                }
            } else {
                completion("")
                self.showErrorMessage(title: "Внимание!", msg: "Ошибка загрузки файла\nголосового сообщения на сервер:\n\n\(error.errorMsg)")
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
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                error.showErrorMessage(controller: self)
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
                            error.showErrorMessage(controller: self)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
            } else {
                error.showErrorMessage(controller: self)
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    func getUploadVideoURL(isLink: Bool, groupID: Int, isPrivate: Int, wallpost: Int, completion: @escaping (String, String) -> Void) {
        
        var name = ""
        var descriptionText = ""
        
        var privacyView: [String] = ["only_me"]
        var privacyComment: [String] = ["only_me"]

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
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 100))
        
        textView.layer.borderColor = titleColor.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = backColor
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = vkSingleton.shared.secondaryLabelColor
        textView.text = ""
        textView.changeKeyboardAppearanceMode()
        
        if isLink {
            var link = ""
            
            let alert = SCLAlertView(appearance: appearance)
            textView.text = ""
            alert.customSubview = textView
            
            alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                textView.resignFirstResponder()
                link = textView.text
                
                if link.isEmpty {
                    var titleColor = UIColor.black
                    var backColor = UIColor.white
                    
                    titleColor = vkSingleton.shared.labelColor
                    backColor = vkSingleton.shared.backColor
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleTop: 32.0,
                        kWindowWidth: UIScreen.main.bounds.width - 40,
                        kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                        kTextFont: UIFont(name: "Verdana", size: 13)!,
                        kButtonFont: UIFont(name: "Verdana", size: 14)!,
                        showCloseButton: false,
                        showCircularIcon: true,
                        circleBackgroundColor: backColor,
                        contentViewColor: backColor,
                        titleColor: titleColor
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    
                    alertView.addButton("Хорошо") {
                        completion("","")
                    }
                    
                    alertView.showWarning("Внимание!", subTitle: "URL видео является обязательным для заполнения. Повторите процедуру.")
                } else {
                    let alert = SCLAlertView(appearance: appearance)
                    textView.text = ""
                    alert.customSubview = textView
                    
                    alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                        textView.resignFirstResponder()
                        name = textView.text
                        
                        let alert = SCLAlertView(appearance: appearance)
                        textView.text = ""
                        alert.customSubview = textView
                        
                        alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                            textView.resignFirstResponder()
                            descriptionText = textView.text
                            
                            if groupID == 0 {
                                self.getPrivacySetting(titleText: "Кто сможет просматривать данное видео?", completion: { privacy in
                                    if privacy.count > 0 {
                                        privacyView = privacy
                                        
                                        self.getPrivacySetting(titleText: "Кто сможет комментировать данное видеозапись?", completion: { privacy in
                                            if privacy.count > 0 {
                                                privacyComment = privacy
                                                
                                                var parameters: [String: Any] = [
                                                    "access_token": vkSingleton.shared.accessToken,
                                                    "is_private": isPrivate,
                                                    "wallpost": wallpost,
                                                    "link": link,
                                                    "repeat": 0,
                                                    "compression": 0,
                                                    "privacy_view": JSON(privacyView),
                                                    "privacy_comment": JSON(privacyComment),
                                                    "v": vkSingleton.shared.version
                                                ]
                                                
                                                if !name.isEmpty { parameters["name"] = name }
                                                if !descriptionText.isEmpty { parameters["description"] = descriptionText }
                                                
                                                self.methodVideoSave(parameters: parameters, completion: { uploadURL, attach in
                                                    completion(uploadURL,attach)
                                                })
                                            } else {
                                                completion("","")
                                            }
                                        })
                                    } else {
                                        completion("","")
                                    }
                                })
                            } else {
                                var parameters: [String: Any] = [
                                    "access_token": vkSingleton.shared.accessToken,
                                    "is_private": isPrivate,
                                    "wallpost": wallpost,
                                    "link": link,
                                    "group_id": abs(groupID),
                                    "no_comments": 0,
                                    "repeat": 0,
                                    "compression": 0,
                                    "v": vkSingleton.shared.version
                                ]
                                
                                if !name.isEmpty { parameters["name"] = name }
                                if !descriptionText.isEmpty { parameters["description"] = descriptionText }
                                
                                self.methodVideoSave(parameters: parameters, completion: { uploadURL, attach in
                                    completion(uploadURL,attach)
                                })
                            }
                        }
                        
                        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                            completion("","")
                        }
                        
                        alert.showInfo("Введите описание видео\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
                    }
                    
                    alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                        completion("","")
                    }
                    
                    alert.showInfo("Введите наименование видео\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
                }
            }
            
            alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                completion("","")
            }
            
            alert.showInfo("Введите URL видео с внешнего сайта:\n(обязательно)", subTitle: "", closeButtonTitle: "Готово")
        } else {
            let alert = SCLAlertView(appearance: appearance)
            textView.text = ""
            alert.customSubview = textView
            
            alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                textView.resignFirstResponder()
                name = textView.text
                
                let alert = SCLAlertView(appearance: appearance)
                textView.text = ""
                alert.customSubview = textView
                
                alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                    textView.resignFirstResponder()
                    descriptionText = textView.text
                    
                    if groupID == 0 && isPrivate == 0 && wallpost == 0 {
                        self.getPrivacySetting(titleText: "Кто сможет просматривать данное видео?", completion: { privacy in
                            if privacy.count > 0 {
                                privacyView = privacy
                                
                                self.getPrivacySetting(titleText: "Кто сможет комментировать данное видеозапись?", completion: { privacy in
                                    if privacy.count > 0 {
                                        privacyComment = privacy
                                        
                                        var parameters: [String: Any] = [
                                            "access_token": vkSingleton.shared.accessToken,
                                            "is_private": isPrivate,
                                            "wallpost": wallpost,
                                            "repeat": 0,
                                            "compression": 0,
                                            "privacy_view": JSON(privacyView),
                                            "privacy_comment": JSON(privacyComment),
                                            "v": vkSingleton.shared.version
                                        ]
                                        
                                        if !name.isEmpty { parameters["name"] = name }
                                        if !descriptionText.isEmpty { parameters["description"] = descriptionText }
                                        
                                        self.methodVideoSave(parameters: parameters, completion: { uploadURL, attach in
                                            completion(uploadURL,attach)
                                        })
                                    } else {
                                        completion("","")
                                    }
                                })
                            } else {
                                completion("","")
                            }
                        })
                    } else {
                        var parameters: [String: Any] = [
                            "access_token": vkSingleton.shared.accessToken,
                            "is_private": isPrivate,
                            "wallpost": wallpost,
                            "group_id": abs(groupID),
                            "no_comments": 0,
                            "repeat": 0,
                            "compression": 0,
                            "v": vkSingleton.shared.version
                        ]
                        
                        if !name.isEmpty { parameters["name"] = name }
                        if !descriptionText.isEmpty { parameters["description"] = descriptionText }
                        
                        self.methodVideoSave(parameters: parameters, completion: { uploadURL, attach in
                            completion(uploadURL,attach)
                        })
                    }
                }
                
                alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                    completion("","")
                }
                
                alert.showInfo("Введите описание видео\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
            }
            
            alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
                completion("","")
            }
            
            alert.showInfo("Введите наименование видео\n(необязательно):", subTitle: "", closeButtonTitle: "Готово")
        }
    }
    
    func methodVideoSave(parameters: [String: Any], completion: @escaping (String, String) -> Void) {
        
        let url = "/method/video.save"
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error_code"].intValue
            error.errorMsg = json["error_msg"].stringValue
            
            //print(json)
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                let ownerID = json["response"]["owner_id"].intValue
                let videoID = json["response"]["video_id"].intValue
                
                completion(uploadURL,"video\(ownerID)_\(videoID)")
            } else {
                self.showErrorMessage(title: "\nОшибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                completion("","")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func getPrivacySetting(titleText: String, completion: @escaping ([String]) -> Void) {
        
        let titleColor = vkSingleton.shared.labelColor
        let backColor = vkSingleton.shared.backColor
        
        var selectedBackgroundColor = vkSingleton.shared.mainColor
        var dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
        var shadowColor = UIColor.darkGray
        var textColor = UIColor.black
        
        var selectedIndex = 2
        
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
        }
        
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
        let picker: [String] = ["все пользователи", "друзья и друзья друзей", "друзья", "никто, кроме меня"]
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 64, height: 22))
        label.text = picker[selectedIndex]
        label.textColor = titleColor
        label.font = UIFont(name: "Verdana", size: 13)!
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.backgroundColor = backColor
        label.layer.cornerRadius = 4
        label.layer.borderColor = titleColor.cgColor
        label.layer.borderWidth = 0.8
        
        let downDrop = DropDown()
        downDrop.anchorView = label
        downDrop.dataSource = picker
        
        downDrop.textColor = textColor
        downDrop.textFont = UIFont(name: "Verdana", size: 12)!
        downDrop.selectedTextColor = textColor
        downDrop.backgroundColor = dropBackgroundColor
        downDrop.selectionBackgroundColor = selectedBackgroundColor
        downDrop.cellHeight = 30
        downDrop.shadowColor = shadowColor
        
        downDrop.selectionAction = { (index: Int, item: String) in
            selectedIndex = index
            label.tag = index
            label.text = item
            downDrop.hide()
        }
        
        let tap = UITapGestureRecognizer()
        tap.add {
            self.view.endEditing(true)
            downDrop.selectRow(selectedIndex)
            downDrop.show()
        }
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        alert.customSubview = label
        
        alert.addButton("Продолжить", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            switch label.tag {
            case 0:
                completion(["all"])
            case 1:
                completion(["friends_of_friends"])
            case 2:
                completion(["friends"])
            case 3:
                completion(["only_me"])
            default:
                completion([])
            }
        }
        
        alert.addButton("Отмена", backgroundColor: vkSingleton.shared.mainColor, textColor: UIColor.white) {
            completion([])
        }
        
        alert.showInfo(titleText, subTitle: "", closeButtonTitle: "Готово")
    }
}

extension UIViewController {
    func myVideoUploadLinkRequest(url: String, completion: @escaping (Int) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error_code"].intValue
            error.errorMsg = json["error_msg"].stringValue
            
            //print(json)
            
            if error.errorCode == 0 {
                let result = json["response"].intValue
                completion(result)
            } else {
                self.showErrorMessage(title: "\nОшибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                completion(0)
            }
        }
        
        task.resume()
    }
    
    func myVideoUploadRequest(url: String, videoData: Data, filename: String, completion: @escaping (String, String, Int) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(filePathKey: "file", dataKey: videoData as NSData, boundary: boundary, filepath: filename, squareCrop: "") as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error_code"].intValue
            error.errorMsg = json["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let ownerID = json["owner_id"].intValue
                let videoID = json["video_id"].intValue
                let videoSize = json["size"].intValue
                let videoHash = json["video_hash"].stringValue
                
                completion("video\(ownerID)_\(videoID)",videoHash,videoSize)
            } else {
                self.showErrorMessage(title: "\nОшибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                completion("","",0)
            }
        }
        
        task.resume()
    }
    
    func myImageUploadRequest(url: String, image: UIImage, filename: String, squareCrop: String, completion: @escaping (JSON) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = image.jpegData(compressionQuality: 1)
            
        if imageData == nil { return }
            
        request.httpBody = createBodyWithParameters(filePathKey: "file", dataKey: imageData! as NSData, boundary: boundary, filepath: filename, squareCrop: squareCrop) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode != 0 {
                error.showErrorMessage(controller: self)
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
        
        request.httpBody = createBodyWithParameters(filePathKey: "file", dataKey: imageData as NSData, boundary: boundary, filepath: filename, squareCrop: "") as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode != 0 {
                ViewControllerUtils().hideActivityIndicator()
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
            completion(json)
        }
        
        task.resume()
    }
    
    func createBodyWithParameters(filePathKey: String?, dataKey: NSData, boundary: String, filepath: String, squareCrop: String) -> NSData {
        
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
        
        if filepath.hasSuffix("m4a") {
            filename = filepath
            mimetype = "audio/mpeg"
        }
        
        if filepath.hasSuffix("ogg") {
            filename = filepath
            mimetype = "audio/mp3"
        }
        
        if filepath.hasSuffix("opus") {
            filename = filepath
            mimetype = "audio/opus"
        }
        
        if filepath == "video_file" {
            filename = filepath
            mimetype = "video/mov"
        }
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(dataKey as Data)
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
