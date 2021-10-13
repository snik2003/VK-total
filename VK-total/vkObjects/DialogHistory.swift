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
    var type = ""
    var attach: [DialogAttach] = []
    var fwdMessage: [Message] = []
    var canWrite = true
    
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
    
    init(json: JSON, conversation: JSON? = nil) {
        self.id = json["id"].intValue
        self.userID = json["user_id"].intValue
        self.fromID = json["from_id"].intValue
        self.peerID = json["peer_id"].intValue
        self.date = json["date"].intValue
        self.readState = json["read_state"].intValue
        self.out = json["out"].intValue
        self.title = json["title"].stringValue
        self.body = json["body"].stringValue
        self.typeAttach = json["attachments"]["type"].stringValue
        self.emoji = json["emoji"].intValue
        self.important = json["important"].intValue
        self.deleted = json["deleted"].intValue
        self.randomID = json["random_id"].intValue
        
        
        if let conversation = conversation {
            self.type = conversation["peer"]["type"].stringValue
            self.canWrite = conversation["can_write"]["allowed"].boolValue
        
            if self.type == "chat" { self.chatID = conversation["peer"]["id"].intValue }
        
            if self.chatID != 0 {
                self.chatActive = conversation["chat_settings"]["active_ids"].map({ $0.1.intValue })
                self.usersCount = conversation["chat_settings"]["members_count"].intValue
                self.adminID = json["admin_id"].intValue
                self.actionID = json["action"]["member_id"].intValue
                self.action = json["action"]["type"].stringValue
                self.actionEmail = json["action_email"].stringValue
                self.actionText = json["action"]["text"].stringValue
                self.photo50 = conversation["chat_settings"]["photo_50"].stringValue
                self.photo100 = conversation["chat_settings"]["photo_100"].stringValue
                self.photo200 = conversation["chat_settings"]["photo_200"].stringValue
            }
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
                photos.text = json["attachments"][index]["photo"]["text"].stringValue
                photos.accessKey = json["attachments"][index]["photo"]["access_key"].stringValue
                
                let photoSizes = json["attachments"][index]["photo"]["sizes"]
                
                if let size = photoSizes.filter({ $0.1["type"] == "x"}).first {
                    photos.photo604 = size.1["url"].stringValue
                    photos.width = size.1["width"].intValue
                    photos.height = size.1["height"].intValue
                }
                
                if let size = photoSizes.filter({ $0.1["type"] == "y"}).first {
                    photos.photo807 = size.1["url"].stringValue
                    if photos.width == 0 { photos.width = size.1["width"].intValue }
                    if photos.height == 0 { photos.height = size.1["height"].intValue }
                }
                
                if let size = photoSizes.filter({ $0.1["type"] == "z"}).first {
                    photos.photo1280 = size.1["url"].stringValue
                    if photos.width == 0 { photos.width = size.1["width"].intValue }
                    if photos.height == 0 { photos.height = size.1["height"].intValue }
                }
                
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
            
            if att.type == "audio" {
                let audio = AudioAttach(json: JSON.null)
                audio.id = json["attachments"][index]["audio"]["id"].intValue
                audio.ownerID = json["attachments"][index]["audio"]["owner_id"].intValue
                audio.artist = json["attachments"][index]["audio"]["artist"].stringValue
                audio.title = json["attachments"][index]["audio"]["title"].stringValue
                audio.duration = json["attachments"][index]["audio"]["duration"].intValue
                audio.url = json["attachments"][index]["audio"]["url"].intValue
                audio.albumID = json["attachments"][index]["audio"]["album_id"].intValue
                audio.accessKey = json["attachments"][index]["audio"]["access_key"].stringValue
                att.audio.append(audio)
            }
            
            if att.type == "sticker" {
                self.hasSticker = true
                
                let sticker = StickerAttach(json: JSON.null)
                sticker.id = json["attachments"][index]["sticker"]["sticker_id"].intValue
                sticker.productID = json["attachments"][index]["sticker"]["product_id"].intValue
                
                let sImages = json["attachments"][index]["sticker"]["images"]
                if sImages.count > 2 {
                    sticker.width = sImages[2]["width"].intValue
                    sticker.height = sImages[2]["height"].intValue
                    sticker.photo256 = sImages[2]["url"].stringValue
                    sticker.photo128 = sImages[2]["url"].stringValue
                } else {
                    sticker.width = sImages[0]["width"].intValue
                    sticker.height = sImages[0]["height"].intValue
                    sticker.photo256 = sImages[0]["url"].stringValue
                    sticker.photo128 = sImages[0]["url"].stringValue
                }
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
                doc.ext = json["attachments"][index]["doc"]["ext"].stringValue
                doc.url = json["attachments"][index]["doc"]["url"].stringValue
                doc.date = json["attachments"][index]["doc"]["date"].intValue
                doc.type = json["attachments"][index]["doc"]["type"].intValue
                doc.accessKey = json["attachments"][index]["doc"]["access_key"].stringValue
                
                doc.linkMP3 = json["attachments"][index]["doc"]["preview"]["audio_msg"]["link_mp3"].stringValue
                doc.linkOGG = json["attachments"][index]["doc"]["preview"]["audio_msg"]["link_ogg"].stringValue
                doc.duration = json["attachments"][index]["doc"]["preview"]["audio_msg"]["duration"].intValue
                
                if doc.type == 4 {
                    self.hasSticker = true
                    
                    doc.link = json["attachments"][index]["doc"]["preview"]["graffiti"]["src"].stringValue
                    doc.width = json["attachments"][index]["doc"]["preview"]["graffiti"]["width"].intValue
                    doc.height = json["attachments"][index]["doc"]["preview"]["graffiti"]["height"].intValue
                    
                    if doc.link.isEmpty {
                        doc.link = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][0]["src"].stringValue
                        doc.width = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][0]["width"].intValue
                        doc.height = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][0]["height"].intValue
                    }
                }
                
                att.docs.append(doc)
            }
            
            if att.type == "audio_message" {
                att.type = "doc"
                
                let doc = DocAttach(json: JSON.null)
                doc.id = json["attachments"][index]["audio_message"]["id"].intValue
                doc.ownerID = json["attachments"][index]["audio_message"]["owner_id"].intValue
                doc.title = json["attachments"][index]["audio_message"]["title"].stringValue
                doc.size = json["attachments"][index]["audio_message"]["size"].intValue
                doc.ext = "ogg"
                doc.url = json["attachments"][index]["audio_message"]["url"].stringValue
                doc.date = json["attachments"][index]["audio_message"]["date"].intValue
                doc.type = 5
                doc.accessKey = json["attachments"][index]["audio_message"]["access_key"].stringValue
                
                doc.linkMP3 = json["attachments"][index]["audio_message"]["link_mp3"].stringValue
                doc.linkOGG = json["attachments"][index]["audio_message"]["link_ogg"].stringValue
                doc.duration = json["attachments"][index]["audio_message"]["duration"].intValue
                
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
                        photos.text = json["fwd_messages"][index1]["attachments"][index2]["photo"]["text"].stringValue
                        photos.accessKey = json["fwd_messages"][index1]["attachments"][index2]["photo"]["access_key"].stringValue
                        
                        let photoSizes = json["fwd_messages"][index1]["attachments"][index2]["photo"]["sizes"]
                        
                        if let size = photoSizes.filter({ $0.1["type"] == "x"}).first {
                            photos.photo604 = size.1["url"].stringValue
                            photos.width = size.1["width"].intValue
                            photos.height = size.1["height"].intValue
                        }
                        
                        if let size = photoSizes.filter({ $0.1["type"] == "y"}).first {
                            photos.photo807 = size.1["url"].stringValue
                            if photos.width == 0 { photos.width = size.1["width"].intValue }
                            if photos.height == 0 { photos.height = size.1["height"].intValue }
                        }
                        
                        if let size = photoSizes.filter({ $0.1["type"] == "z"}).first {
                            photos.photo1280 = size.1["url"].stringValue
                            if photos.width == 0 { photos.width = size.1["width"].intValue }
                            if photos.height == 0 { photos.height = size.1["height"].intValue }
                        }
                        
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
                    
                    if att.type == "audio" {
                        let audio = AudioAttach(json: JSON.null)
                        audio.id = json["fwd_messages"][index1]["attachments"][index2]["audio"]["id"].intValue
                        audio.ownerID = json["fwd_messages"][index1]["attachments"][index2]["audio"]["owner_id"].intValue
                        audio.artist = json["fwd_messages"][index1]["attachments"][index2]["audio"]["artist"].stringValue
                        audio.title = json["fwd_messages"][index1]["attachments"][index2]["audio"]["title"].stringValue
                        audio.duration = json["fwd_messages"][index1]["attachments"][index2]["audio"]["duration"].intValue
                        audio.url = json["fwd_messages"][index1]["attachments"][index2]["audio"]["url"].intValue
                        audio.albumID = json["fwd_messages"][index1]["attachments"][index2]["audio"]["album_id"].intValue
                        audio.accessKey = json["fwd_messages"][index1]["attachments"][index2]["audio"]["access_key"].stringValue
                        att.audio.append(audio)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "sticker" {
                        self.hasSticker = true
                        
                        let sticker = StickerAttach(json: JSON.null)
                        sticker.id = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["sticker_id"].intValue
                        sticker.productID = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["product_id"].intValue
                        
                        let sImages = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["images"]
                        if sImages.count > 2 {
                            sticker.width = sImages[2]["width"].intValue
                            sticker.height = sImages[2]["height"].intValue
                            sticker.photo256 = sImages[2]["url"].stringValue
                            sticker.photo128 = sImages[2]["url"].stringValue
                        } else {
                            sticker.width = sImages[0]["width"].intValue
                            sticker.height = sImages[0]["height"].intValue
                            sticker.photo256 = sImages[0]["url"].stringValue
                            sticker.photo128 = sImages[0]["url"].stringValue
                        }
                        
                        att.stickers.append(sticker)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "wall" {
                        let wall = WallAttach(json: JSON.null)
                        wall.id = json["fwd_messages"][index1]["attachments"][index2]["wall"]["id"].intValue
                        wall.fromID = json["fwd_messages"][index1]["attachments"][index2]["wall"]["from_id"].intValue
                        wall.date = json["fwd_messages"][index1]["attachments"][index2]["wall"]["date"].intValue
                        wall.text = json["fwd_messages"][index1]["attachments"][index2]["wall"]["text"].stringValue
                        wall.postType = json["fwd_messages"][index1]["attachments"][index2]["wall"]["post_type"].stringValue
                        att.wall.append(wall)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "gift" {
                        let gift = GiftAttach(json: JSON.null)
                        gift.id = json["fwd_messages"][index1]["attachments"][index2]["gift"]["id"].intValue
                        gift.thumb48 = json["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_48"].stringValue
                        gift.thumb96 = json["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_96"].stringValue
                        gift.thumb256 = json["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_256"].stringValue
                        att.gift.append(gift)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "doc" {
                        let doc = DocAttach(json: JSON.null)
                        doc.id = json["fwd_messages"][index1]["attachments"][index2]["doc"]["id"].intValue
                        doc.ownerID = json["fwd_messages"][index1]["attachments"][index2]["doc"]["owner_id"].intValue
                        doc.title = json["fwd_messages"][index1]["attachments"][index2]["doc"]["title"].stringValue
                        doc.size = json["fwd_messages"][index1]["attachments"][index2]["doc"]["size"].intValue
                        doc.ext = json["fwd_messages"][index1]["attachments"][index2]["doc"]["ext"].stringValue
                        doc.url = json["fwd_messages"][index1]["attachments"][index2]["doc"]["url"].stringValue
                        doc.date = json["fwd_messages"][index1]["attachments"][index2]["doc"]["date"].intValue
                        doc.type = json["fwd_messages"][index1]["attachments"][index2]["doc"]["type"].intValue
                        doc.accessKey = json["fwd_messages"][index1]["attachments"][index2]["doc"]["access_key"].stringValue
                        
                        doc.linkMP3 = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["link_mp3"].stringValue
                        doc.linkOGG = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["link_ogg"].stringValue
                        doc.duration = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["duration"].intValue

                        if doc.type == 4 {
                            self.hasSticker = true
                            
                            doc.link = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["graffiti"]["src"].stringValue
                            doc.width = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["graffiti"]["width"].intValue
                            doc.height = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["graffiti"]["height"].intValue
                            
                            if doc.link.isEmpty {
                                doc.link = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["photo"]["sizes"][0]["src"].stringValue
                                doc.width = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["photo"]["sizes"][0]["width"].intValue
                                doc.height = json["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["photo"]["sizes"][0]["height"].intValue
                            }
                        }
                    
                        att.docs.append(doc)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "audio_message" {
                        att.type = "doc"
                        
                        let doc = DocAttach(json: JSON.null)
                        doc.id = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["id"].intValue
                        doc.ownerID = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["owner_id"].intValue
                        doc.title = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["title"].stringValue
                        doc.size = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["size"].intValue
                        doc.ext = "ogg"
                        doc.url = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["url"].stringValue
                        doc.date = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["date"].intValue
                        doc.type = 5
                        doc.accessKey = json["fwd_messages"][index1]["attachments"][index2]["doc"]["access_key"].stringValue
                        
                        doc.linkMP3 = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["link_mp3"].stringValue
                        doc.linkOGG = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["link_ogg"].stringValue
                        doc.duration = json["fwd_messages"][index1]["attachments"][index2]["audio_message"]["duration"].intValue

                        att.docs.append(doc)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "link" {
                        let link = LinkAttach(json: JSON.null)
                        link.title = json["fwd_messages"][index1]["attachments"][index2]["link"]["title"].stringValue
                        if link.title == "" {
                            link.title = json["fwd_messages"][index1]["attachments"][index2]["link"]["description"].stringValue
                            if link.title == "" {
                                link.title = json["fwd_messages"][index1]["attachments"][index2]["link"]["caption"].stringValue
                                if link.title == "" {
                                    link.title = json["fwd_messages"][index1]["attachments"][index2]["link"]["photo"]["text"].stringValue
                                }
                            }
                        }
                        link.url = json["fwd_messages"][index1]["attachments"][index2]["link"]["url"].stringValue
                        att.link.append(link)
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

extension Array where Element: Codable {
    
    func saveInUserDefaults(KeyName: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: KeyName)
        }
    }
    
    func loadFromUserDefaults(KeyName: String) -> Array {
        if let data = UserDefaults.standard.object(forKey: KeyName) as? Data {
            let decoder = JSONDecoder()
            if let objects = try? decoder.decode(Array.self, from: data) {
                return objects
            }
        }
        
        return []
    }
}


