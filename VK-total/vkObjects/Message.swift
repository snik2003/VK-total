//
//  Message.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message: Equatable, Codable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        if lhs.id == rhs.id, lhs.userID == rhs.userID, lhs.chatID == rhs.chatID {
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
    var inRead = 0
    var outRead = 0
    var unreadCount = 0
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
    
    init(json: JSON) {
        self.id = json["message"]["id"].intValue
        self.chatID = json["message"]["chat_id"].intValue
        self.userID = json["message"]["user_id"].intValue
        self.fromID = json["message"]["from_id"].intValue
        self.date = json["message"]["date"].intValue
        self.readState = json["message"]["read_state"].intValue
        self.out = json["message"]["out"].intValue
        self.title = json["message"]["title"].stringValue
        self.body = json["message"]["body"].stringValue
        self.typeAttach = json["message"]["attachments"][0]["type"].stringValue
        self.emoji = json["message"]["emoji"].intValue
        self.important = json["message"]["important"].intValue
        self.deleted = json["message"]["deleted"].intValue
        self.randomID = json["message"]["random_id"].intValue
        self.inRead = json["in_read"].intValue
        self.outRead = json["out_read"].intValue
        
        if self.chatID != 0 {
            for index in 0...19 {
                let chActive = json["message"]["chat_active"][index].intValue
                if chActive > 0 {
                    self.chatActive.append(chActive)
                }
            }
            self.usersCount = json["message"]["users_count"].intValue
            self.adminID = json["message"]["admin_id"].intValue
            self.actionID = json["message"]["action_mid"].intValue
            self.action = json["message"]["action"].stringValue
            self.actionEmail = json["message"]["action_email"].stringValue
            self.actionText = json["message"]["action_text"].stringValue
            self.photo50 = json["message"]["photo_50"].stringValue
            self.photo100 = json["message"]["photo_100"].stringValue
            self.photo200 = json["message"]["photo_200"].stringValue
        }
        
        for index in 0...9 {
            let att = DialogAttach(json: JSON.null)
            att.type = json["message"]["attachments"][index]["type"].stringValue
            
            if att.type == "photo" {
                let photos = PhotoAttach(json: JSON.null)
                photos.id = json["message"]["attachments"][index]["photo"]["id"].intValue
                photos.albumID = json["message"]["attachments"][index]["photo"]["album_id"].intValue
                photos.ownerID = json["message"]["attachments"][index]["photo"]["owner_id"].intValue
                photos.userID = json["message"]["attachments"][index]["photo"]["user_id"].intValue
                photos.date = json["message"]["attachments"][index]["photo"]["date"].intValue
                photos.width = json["message"]["attachments"][index]["photo"]["width"].intValue
                photos.height = json["message"]["attachments"][index]["photo"]["height"].intValue
                photos.text = json["message"]["attachments"][index]["photo"]["text"].stringValue
                photos.photo604 = json["message"]["attachments"][index]["photo"]["photo_604"].stringValue
                photos.photo807 = json["message"]["attachments"][index]["photo"]["photo_807"].stringValue
                photos.accessKey = json["message"]["attachments"][index]["photo"]["access_key"].stringValue
                att.photos.append(photos)
                attach.append(att)
            }
            
            if att.type == "video" {
                let video = VideoAttach(json: JSON.null)
                video.id = json["message"]["attachments"][index]["video"]["id"].intValue
                video.ownerID = json["message"]["attachments"][index]["video"]["owner_id"].intValue
                video.title = json["message"]["attachments"][index]["video"]["title"].stringValue
                video.description = json["message"]["attachments"][index]["video"]["description"].stringValue
                video.date = json["message"]["attachments"][index]["video"]["date"].intValue
                video.duration = json["message"]["attachments"][index]["video"]["duration"].intValue
                video.photo320 = json["message"]["attachments"][index]["video"]["photo_320"].stringValue
                video.isPrivate = json["message"]["attachments"][index]["video"]["is_private"].intValue
                video.accessKey = json["message"]["attachments"][index]["video"]["access_key"].stringValue
                att.videos.append(video)
                attach.append(att)
            }
            
            if att.type == "doc" {
                let doc = DocAttach(json: JSON.null)
                doc.id = json["message"]["attachments"][index]["doc"]["id"].intValue
                doc.ownerID = json["message"]["attachments"][index]["doc"]["owner_id"].intValue
                doc.title = json["message"]["attachments"][index]["doc"]["title"].stringValue
                doc.size = json["message"]["attachments"][index]["doc"]["size"].intValue
                doc.ext = json["message"]["attachments"][index]["doc"]["ext"].stringValue
                doc.url = json["message"]["attachments"][index]["doc"]["url"].stringValue
                doc.date = json["message"]["attachments"][index]["doc"]["date"].intValue
                doc.type = json["message"]["attachments"][index]["doc"]["type"].intValue
                doc.accessKey = json["message"]["attachments"][index]["doc"]["access_key"].stringValue
                
                doc.linkMP3 = json["message"]["attachments"][index]["doc"]["preview"]["audio_msg"]["link_mp3"].stringValue
                doc.linkOGG = json["message"]["attachments"][index]["doc"]["preview"]["audio_msg"]["link_ogg"].stringValue
                doc.duration = json["message"]["attachments"][index]["doc"]["preview"]["audio_msg"]["duration"].intValue
                
                att.docs.append(doc)
                attach.append(att)
            }
            
            if att.type == "audio" {
                let audio = AudioAttach(json: JSON.null)
                audio.id = json["message"]["attachments"][index]["audio"]["id"].intValue
                audio.ownerID = json["message"]["attachments"][index]["audio"]["owner_id"].intValue
                audio.artist = json["message"]["attachments"][index]["audio"]["artist"].stringValue
                audio.title = json["message"]["attachments"][index]["audio"]["title"].stringValue
                audio.duration = json["message"]["attachments"][index]["audio"]["duration"].intValue
                audio.url = json["message"]["attachments"][index]["audio"]["url"].intValue
                audio.albumID = json["message"]["attachments"][index]["audio"]["album_id"].intValue
                audio.accessKey = json["message"]["attachments"][index]["audio"]["access_key"].stringValue
                att.audio.append(audio)
                attach.append(att)
            }
            
            if att.type == "sticker" {
                let sticker = StickerAttach(json: JSON.null)
                sticker.id = json["message"]["attachments"][index]["sticker"]["id"].intValue
                sticker.productID = json["message"]["attachments"][index]["sticker"]["product_id"].intValue
                sticker.width = json["message"]["attachments"][index]["sticker"]["width"].intValue
                sticker.height = json["message"]["attachments"][index]["sticker"]["height"].intValue
                sticker.photo256 = json["message"]["attachments"][index]["sticker"]["photo_256"].stringValue
                sticker.photo128 = json["message"]["attachments"][index]["sticker"]["photo_128"].stringValue
                att.stickers.append(sticker)
                attach.append(att)
            }
            
            if att.type == "wall" {
                let wall = WallAttach(json: JSON.null)
                wall.id = json["message"]["attachments"][index]["wall"]["id"].intValue
                wall.fromID = json["message"]["attachments"][index]["wall"]["from_id"].intValue
                wall.date = json["message"]["attachments"][index]["wall"]["date"].intValue
                wall.text = json["message"]["attachments"][index]["wall"]["text"].stringValue
                wall.postType = json["message"]["attachments"][index]["wall"]["post_type"].stringValue
                att.wall.append(wall)
                attach.append(att)
            }
            
            if att.type == "gift" {
                let gift = GiftAttach(json: JSON.null)
                gift.id = json["message"]["attachments"][index]["gift"]["id"].intValue
                gift.thumb48 = json["message"]["attachments"][index]["gift"]["thumb_48"].stringValue
                gift.thumb96 = json["message"]["attachments"][index]["gift"]["thumb_96"].stringValue
                gift.thumb256 = json["message"]["attachments"][index]["gift"]["thumb_256"].stringValue
                att.gift.append(gift)
                attach.append(att)
            }
            
            if att.type == "link" {
                let link = LinkAttach(json: JSON.null)
                link.title = json["message"]["attachments"][index]["link"]["title"].stringValue
                if link.title == "" {
                    link.title = json["message"]["attachments"][index]["link"]["description"].stringValue
                    if link.title == "" {
                        link.title = json["message"]["attachments"][index]["link"]["caption"].stringValue
                        if link.title == "" {
                            link.title = json["message"]["attachments"][index]["link"]["photo"]["text"].stringValue
                        }
                    }
                }
                link.url = json["message"]["attachments"][index]["link"]["url"].stringValue
                att.link.append(link)
                attach.append(att)
            }
        }
        
        for index1 in 0...19 {
            var userID = json["message"]["fwd_messages"][index1]["user_id"].intValue
            if userID == 0 { userID = json["message"]["fwd_messages"][index1]["from_id"].intValue }
            
            if userID != 0 {
                let mess = Message(json: JSON.null)
                mess.userID = userID
                mess.date = json["message"]["fwd_messages"][index1]["date"].intValue
                mess.body = json["message"]["fwd_messages"][index1]["body"].stringValue
                
                if mess.body == "" {
                    mess.body = json["message"]["fwd_messages"][index1]["text"].stringValue
                }
                
                for index2 in 0...9 {
                    let att = DialogAttach(json: JSON.null)
                    att.type = json["message"]["fwd_messages"][index1]["attachments"][index2]["type"].stringValue
                    
                    if att.type == "photo" {
                        let photos = PhotoAttach(json: JSON.null)
                        photos.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["id"].intValue
                        photos.albumID = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["album_id"].intValue
                        photos.ownerID = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["owner_id"].intValue
                        photos.userID = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["user_id"].intValue
                        photos.date = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["date"].intValue
                        photos.width = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["width"].intValue
                        photos.height = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["height"].intValue
                        photos.text = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["text"].stringValue
                        photos.photo604 = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["photo_604"].stringValue
                        photos.photo807 = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["photo_807"].stringValue
                        photos.accessKey = json["message"]["fwd_messages"][index1]["attachments"][index2]["photo"]["access_key"].stringValue
                        att.photos.append(photos)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "video" {
                        let video = VideoAttach(json: JSON.null)
                        video.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["id"].intValue
                        video.ownerID = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["owner_id"].intValue
                        video.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["title"].stringValue
                        video.description = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["description"].stringValue
                        video.date = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["date"].intValue
                        video.duration = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["duration"].intValue
                        video.photo320 = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["photo_320"].stringValue
                        video.isPrivate = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["is_private"].intValue
                        video.accessKey = json["message"]["fwd_messages"][index1]["attachments"][index2]["video"]["access_key"].stringValue
                        att.videos.append(video)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "audio" {
                        let audio = AudioAttach(json: JSON.null)
                        audio.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["id"].intValue
                        audio.ownerID = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["owner_id"].intValue
                        audio.artist = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["artist"].stringValue
                        audio.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["title"].stringValue
                        audio.duration = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["duration"].intValue
                        audio.url = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["url"].intValue
                        audio.albumID = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["album_id"].intValue
                        audio.accessKey = json["message"]["fwd_messages"][index1]["attachments"][index2]["audio"]["access_key"].stringValue
                        att.audio.append(audio)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "sticker" {
                        let sticker = StickerAttach(json: JSON.null)
                        sticker.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["id"].intValue
                        sticker.productID = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["product_id"].intValue
                        sticker.width = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["width"].intValue
                        sticker.height = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["height"].intValue
                        sticker.photo256 = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["photo_256"].stringValue
                        sticker.photo128 = json["message"]["fwd_messages"][index1]["attachments"][index2]["sticker"]["photo_128"].stringValue
                        att.stickers.append(sticker)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "wall" {
                        let wall = WallAttach(json: JSON.null)
                        wall.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["wall"]["id"].intValue
                        wall.fromID = json["message"]["fwd_messages"][index1]["attachments"][index2]["wall"]["from_id"].intValue
                        wall.date = json["message"]["fwd_messages"][index1]["attachments"][index2]["wall"]["date"].intValue
                        wall.text = json["message"]["fwd_messages"][index1]["attachments"][index2]["wall"]["text"].stringValue
                        wall.postType = json["message"]["fwd_messages"][index1]["attachments"][index2]["wall"]["post_type"].stringValue
                        att.wall.append(wall)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "gift" {
                        let gift = GiftAttach(json: JSON.null)
                        gift.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["gift"]["id"].intValue
                        gift.thumb48 = json["message"]["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_48"].stringValue
                        gift.thumb96 = json["message"]["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_96"].stringValue
                        gift.thumb256 = json["message"]["fwd_messages"][index1]["attachments"][index2]["gift"]["thumb_256"].stringValue
                        att.gift.append(gift)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "doc" {
                        let doc = DocAttach(json: JSON.null)
                        doc.id = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["id"].intValue
                        doc.ownerID = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["owner_id"].intValue
                        doc.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["title"].stringValue
                        doc.size = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["size"].intValue
                        doc.ext = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["ext"].stringValue
                        doc.url = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["url"].stringValue
                        doc.date = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["date"].intValue
                        doc.type = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["type"].intValue
                        doc.accessKey = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["access_key"].stringValue
                        
                        doc.linkMP3 = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["link_mp3"].stringValue
                        doc.linkOGG = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["link_ogg"].stringValue
                        doc.duration = json["message"]["fwd_messages"][index1]["attachments"][index2]["doc"]["preview"]["audio_msg"]["duration"].intValue
                        
                        att.docs.append(doc)
                        mess.attach.append(att)
                    }
                    
                    if att.type == "link" {
                        let link = LinkAttach(json: JSON.null)
                        link.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["link"]["title"].stringValue
                        if link.title == "" {
                            link.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["link"]["description"].stringValue
                            if link.title == "" {
                                link.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["link"]["caption"].stringValue
                                if link.title == "" {
                                    link.title = json["message"]["fwd_messages"][index1]["attachments"][index2]["link"]["photo"]["text"].stringValue
                                }
                            }
                        }
                        link.url = json["message"]["fwd_messages"][index1]["attachments"][index2]["link"]["url"].stringValue
                        att.link.append(link)
                        mess.attach.append(att)
                    }
                }
                fwdMessage.append(mess)
            }
        }
    }
    
    init(json: JSON, conversations: [Conversation]) {
        self.id = json["id"].intValue
        self.peerID = json["peer_id"].intValue
        self.fromID = json["from_id"].intValue
        
        if peerID > 2000000000 {
            self.chatID = peerID - 2000000000
            self.userID = self.fromID
        } else {
            self.chatID = 0
            self.userID = self.peerID
        }
        
        self.date = json["date"].intValue
        self.body = json["text"].stringValue
        self.typeAttach = json["attachments"][0]["type"].stringValue
        self.emoji = json["emoji"].intValue
        self.important = json["important"].intValue
        self.deleted = json["deleted"].intValue
        self.randomID = json["random_id"].intValue
        self.out = json["out"].intValue
        
        if self.chatID > 0 {
            self.adminID = json["admin_author_id"].intValue
            self.actionID = json["action"]["member_id"].intValue
            self.action = json["action"]["type"].stringValue
            self.actionEmail = json["action"]["email"].stringValue
            self.actionText = json["action"]["text"].stringValue
            self.photo50 = json["photo"]["photo_50"].stringValue
            self.photo100 = json["photo"]["photo_100"].stringValue
            self.photo200 = json["photo"]["photo_200"].stringValue
            self.usersCount = json["members_count"].intValue
        }
        
        if let conversation = conversations.filter({ $0.peerID == self.peerID && $0.lastMessageID == self.id }).first {
            self.inRead = conversation.inRead
            self.outRead = conversation.outRead
            self.important = conversation.important ? 1 : 0
            
            if self.out == 1 { self.readState = self.id > self.outRead ? 0 : 1 }
            else if self.out == 0 { self.readState = self.id > self.inRead ? 0 : 1 }
            
            if chatID > 0 {
                self.chatActive = conversation.chatSettings.activeIDs
                self.title = conversation.chatSettings.title
                self.photo50 = conversation.chatSettings.photo50
                self.photo100 = conversation.chatSettings.photo100
                self.photo200 = conversation.chatSettings.photo200
            }
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
                attach.append(att)
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
                attach.append(att)
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
                att.docs.append(doc)
                attach.append(att)
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
                attach.append(att)
            }
            
            if att.type == "sticker" {
                let sticker = StickerAttach(json: JSON.null)
                sticker.id = json["attachments"][index]["sticker"]["id"].intValue
                sticker.productID = json["attachments"][index]["sticker"]["product_id"].intValue
                sticker.width = json["attachments"][index]["sticker"]["width"].intValue
                sticker.height = json["attachments"][index]["sticker"]["height"].intValue
                sticker.photo256 = json["attachments"][index]["sticker"]["photo_256"].stringValue
                sticker.photo128 = json["attachments"][index]["sticker"]["photo_128"].stringValue
                att.stickers.append(sticker)
                attach.append(att)
            }
            
            if att.type == "wall" {
                let wall = WallAttach(json: JSON.null)
                wall.id = json["attachments"][index]["wall"]["id"].intValue
                wall.fromID = json["attachments"][index]["wall"]["from_id"].intValue
                wall.date = json["attachments"][index]["wall"]["date"].intValue
                wall.text = json["attachments"][index]["wall"]["text"].stringValue
                wall.postType = json["attachments"][index]["wall"]["post_type"].stringValue
                att.wall.append(wall)
                attach.append(att)
            }
            
            if att.type == "gift" {
                let gift = GiftAttach(json: JSON.null)
                gift.id = json["attachments"][index]["gift"]["id"].intValue
                gift.thumb48 = json["attachments"][index]["gift"]["thumb_48"].stringValue
                gift.thumb96 = json["attachments"][index]["gift"]["thumb_96"].stringValue
                gift.thumb256 = json["attachments"][index]["gift"]["thumb_256"].stringValue
                att.gift.append(gift)
                attach.append(att)
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
                attach.append(att)
            }
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
                        let sticker = StickerAttach(json: JSON.null)
                        sticker.id = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["id"].intValue
                        sticker.productID = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["product_id"].intValue
                        sticker.width = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["width"].intValue
                        sticker.height = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["height"].intValue
                        sticker.photo256 = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["photo_256"].stringValue
                        sticker.photo128 = json["fwd_messages"][index1]["attachments"][index2]["sticker"]["photo_128"].stringValue
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
}
