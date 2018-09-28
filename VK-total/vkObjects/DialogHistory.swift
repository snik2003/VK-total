//
//  DialogHistory.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class DialogHistory: Equatable {
    static func == (lhs: DialogHistory, rhs: DialogHistory) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        return false
    }
    
    var id = 0
    var userID = 0
    var fromID = 0
    var peerID = 0
    var date = 0
    var readState = 0
    var out = 0
    var title = ""
    var body = ""
    var typeAttach = ""
    var emoji = 0
    var important = 0
    var deleted = 0
    var randomID = 0
    var attach: [DialogAttach] = []
    var fwdMessage: [Message] = []
    
    // доп.поля для групповой беседы
    var chatID = 0
    var chatActive: [Int] = []
    var usersCount = 0
    var adminID = 0
    var action = ""
    var actionID = 0
    var actionEmail = ""
    var actionText = ""
    var photo50 = ""
    var photo100 = ""
    var photo200 = ""
    
    var hasSticker = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.chatID = json["chat_id"].intValue
        self.userID = json["user_id"].intValue
        self.fromID = json["from_id"].intValue
        self.peerID = json["peer_id"].intValue
        self.date = json["date"].intValue
        self.readState = json["read_state"].intValue
        self.out = json["out"].intValue
        self.title = json["title"].stringValue
        self.body = json["body"].stringValue
        self.typeAttach = json["attachment"]["type"].stringValue
        self.emoji = json["emoji"].intValue
        self.important = json["important"].intValue
        self.deleted = json["deleted"].intValue
        self.randomID = json["random_id"].intValue
        
        if self.chatID != 0 {
            for index in 0...19 {
                let chActive = json["chat_active"][index].intValue
                if chActive > 0 {
                    self.chatActive.append(chActive)
                }
            }
            self.usersCount = json["users_count"].intValue
            self.adminID = json["admin_id"].intValue
            self.actionID = json["action_mid"].intValue
            self.action = json["action"].stringValue
            self.actionEmail = json["action_email"].stringValue
            self.actionText = json["action_text"].stringValue
            self.photo50 = json["photo_50"].stringValue
            self.photo100 = json["photo_100"].stringValue
            self.photo200 = json["photo_200"].stringValue
        }
        
        if self.fromID == 0 {
            if self.out == 0 {
                self.fromID = self.userID
            } else {
                if let id = Int(vkSingleton.shared.userID) {
                    self.fromID = id
                }
            }
        }
        
        if self.body == "" {
            self.body = json["text"].stringValue
        }
        
        for index in 0...9 {
            let att = DialogAttach(json: JSON.null)
            att.type = json["attachments"][index]["type"].stringValue
            
            if att.type == "photo" {
                let photos = PhotoAttach(json: JSON.null)
                photos.id = json["attachments"][index]["photo"]["id"].intValue
                photos.albumID = json["attachments"][index]["photo"]["album_id"].intValue
                photos.ownerID = json["attachments"][index]["photo"]["owner_id"].intValue
                photos.userID = json["attachments"][index]["photo"]["user_id"].intValue
                photos.date = json["attachments"][index]["photo"]["date"].intValue
                photos.width = json["attachments"][index]["photo"]["width"].intValue
                photos.height = json["attachments"][index]["photo"]["height"].intValue
                photos.text = json["attachments"][index]["photo"]["text"].stringValue
                photos.photo604 = json["attachments"][index]["photo"]["photo_604"].stringValue
                photos.photo807 = json["attachments"][index]["photo"]["photo_807"].stringValue
                photos.accessKey = json["attachments"][index]["photo"]["access_key"].stringValue
                att.photos.append(photos)
            }
            
            if att.type == "video" {
                let video = VideoAttach(json: JSON.null)
                video.id = json["attachments"][index]["video"]["id"].intValue
                video.ownerID = json["attachments"][index]["video"]["owner_id"].intValue
                video.title = json["attachments"][index]["video"]["title"].stringValue
                video.description = json["attachments"][index]["video"]["description"].stringValue
                video.date = json["attachments"][index]["video"]["date"].intValue
                video.duration = json["attachments"][index]["video"]["duration"].intValue
                video.photo320 = json["attachments"][index]["video"]["photo_320"].stringValue
                video.isPrivate = json["attachments"][index]["video"]["is_private"].intValue
                video.accessKey = json["attachments"][index]["video"]["access_key"].stringValue
                att.videos.append(video)
            }
            
            if att.type == "sticker" {
                self.hasSticker = true
                
                let sticker = StickerAttach(json: JSON.null)
                sticker.id = json["attachments"][index]["sticker"]["id"].intValue
                sticker.productID = json["attachments"][index]["sticker"]["product_id"].intValue
                sticker.width = json["attachments"][index]["sticker"]["width"].intValue
                sticker.height = json["attachments"][index]["sticker"]["height"].intValue
                sticker.photo256 = json["attachments"][index]["sticker"]["photo_256"].stringValue
                sticker.photo128 = json["attachments"][index]["sticker"]["photo_128"].stringValue
                att.stickers.append(sticker)
            }
            
            if att.type == "wall" {
                let wall = WallAttach(json: JSON.null)
                wall.id = json["attachments"][index]["wall"]["id"].intValue
                wall.fromID = json["attachments"][index]["wall"]["from_id"].intValue
                wall.date = json["attachments"][index]["wall"]["date"].intValue
                wall.text = json["attachments"][index]["wall"]["text"].stringValue
                wall.postType = json["attachments"][index]["wall"]["post_type"].stringValue
                att.wall.append(wall)
            }
            
            if att.type == "gift" {
                let gift = GiftAttach(json: JSON.null)
                gift.id = json["attachments"][index]["gift"]["id"].intValue
                gift.thumb48 = json["attachments"][index]["gift"]["thumb_48"].stringValue
                gift.thumb96 = json["attachments"][index]["gift"]["thumb_96"].stringValue
                gift.thumb256 = json["attachments"][index]["gift"]["thumb_256"].stringValue
                att.gift.append(gift)
            }
            
            if att.type == "doc" {
                let doc = DocAttach(json: JSON.null)
                doc.id = json["attachments"][index]["doc"]["id"].intValue
                doc.ownerID = json["attachments"][index]["doc"]["owner_id"].intValue
                doc.title = json["attachments"][index]["doc"]["title"].stringValue
                doc.size = json["attachments"][index]["doc"]["size"].intValue
                doc.ext = json["attachments"][index]["doc"]["ext"].intValue
                doc.url = json["attachments"][index]["doc"]["url"].stringValue
                doc.date = json["attachments"][index]["doc"]["date"].intValue
                doc.type = json["attachments"][index]["doc"]["type"].intValue
                att.docs.append(doc)
            }
            
            if att.type == "link" {
                let link = LinkAttach(json: JSON.null)
                link.title = json["attachments"][index]["link"]["title"].stringValue
                if link.title == "" {
                    link.title = json["attachments"][index]["link"]["description"].stringValue
                    if link.title == "" {
                        link.title = json["attachments"][index]["link"]["caption"].stringValue
                        if link.title == "" {
                            link.title = json["attachments"][index]["link"]["photo"]["text"].stringValue
                        }
                    }
                }
                link.url = json["attachments"][index]["link"]["url"].stringValue
                att.link.append(link)
            }
            
            attach.append(att)
        }
        
        for index1 in 0...19 {
            let mess = Message(json: JSON.null)
            mess.userID = json["fwd_messages"][index1]["user_id"].intValue
            
            if mess.userID == 0 {
                mess.userID = json["fwd_messages"][index1]["from_id"].intValue
            }
            
            if mess.userID != 0 {
                mess.date = json["fwd_messages"][index1]["date"].intValue
                mess.body = json["fwd_messages"][index1]["body"].stringValue
                
                if mess.body == "" {
                    mess.body = json["fwd_messages"][index1]["text"].stringValue
                }
                
                for index2 in 0...9 {
                    let att = DialogAttach(json: JSON.null)
                    att.type = json["fwd_messages"][index1]["attachments"][index2]["type"].stringValue
                    
                    if att.type == "photo" {
                        let photos = PhotoAttach(json: JSON.null)
                        photos.id = json["fwd_messages"][index1]["attachments"][index2]["photo"]["id"].intValue
                        photos.albumID = json["fwd_messages"][index1]["attachments"][index2]["photo"]["album_id"].intValue
                        photos.ownerID = json["fwd_messages"][index1]["attachments"][index2]["photo"]["owner_id"].intValue
                        photos.userID = json["fwd_messages"][index1]["attachments"][index2]["photo"]["user_id"].intValue
                        photos.date = json["fwd_messages"][index1]["attachments"][index2]["photo"]["date"].intValue
                        photos.width = json["fwd_messages"][index1]["attachments"][index2]["photo"]["width"].intValue
                        photos.height = json["fwd_messages"][index1]["attachments"][index2]["photo"]["height"].intValue
                        photos.text = json["fwd_messages"][index1]["attachments"][index2]["photo"]["text"].stringValue
                        photos.photo604 = json["fwd_messages"][index1]["attachments"][index2]["photo"]["photo_604"].stringValue
                        photos.photo807 = json["fwd_messages"][index1]["attachments"][index2]["photo"]["photo_807"].stringValue
                        photos.accessKey = json["fwd_messages"][index1]["attachments"][index2]["photo"]["access_key"].stringValue
                        att.photos.append(photos)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "video" {
                        let video = VideoAttach(json: JSON.null)
                        video.id = json["fwd_messages"][index1]["attachments"][index2]["video"]["id"].intValue
                        video.ownerID = json["fwd_messages"][index1]["attachments"][index2]["video"]["owner_id"].intValue
                        video.title = json["fwd_messages"][index1]["attachments"][index2]["video"]["title"].stringValue
                        video.description = json["fwd_messages"][index1]["attachments"][index2]["video"]["description"].stringValue
                        video.date = json["fwd_messages"][index1]["attachments"][index2]["video"]["date"].intValue
                        video.duration = json["fwd_messages"][index1]["attachments"][index2]["video"]["duration"].intValue
                        video.photo320 = json["fwd_messages"][index1]["attachments"][index2]["video"]["photo_320"].stringValue
                        video.isPrivate = json["fwd_messages"][index1]["attachments"][index2]["video"]["is_private"].intValue
                        video.accessKey = json["fwd_messages"][index1]["attachments"][index2]["video"]["access_key"].stringValue
                        att.videos.append(video)
                        mess.attach.append(att)
                    }
                }
                
                fwdMessage.append(mess)
            }
        }
    }
    
    func canEdit() -> Bool {
        if self.chatID != 0 {
            return false
        }
        
        if self.out != 1 {
            return false
        }
        
        if Int(Date().timeIntervalSince1970) - self.date >= 24 * 60 * 60 {
            return false
        }
        
        for attach in self.attach {
            if attach.type == "sticker" && attach.stickers.count > 0 {
                return false
            }
            
            if attach.type == "gift" && attach.gift.count > 0 {
                return false
            }
            
            if attach.type == "wall" && attach.wall.count > 0 {
                return false
            }
                
            if attach.type == "doc" && attach.docs.count > 0 {
                return false
            }
        }
        
        return true
    }
}

class HistoryAttachments: Equatable {
    static func == (lhs: HistoryAttachments, rhs: HistoryAttachments) -> Bool {
        if lhs.messID == rhs.messID {
            return true
        }
        
        return false
    }
    
    var messID = 0
    
    init(json: JSON) {
        self.messID = json["message_id"].intValue
    }
}

extension Array where Element: Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}

