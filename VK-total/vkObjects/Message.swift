//
//  Message.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        if lhs.id == rhs.id, lhs.userID == rhs.userID, lhs.chatID == rhs.chatID {
            return true
        }
        return false
    }
    
    var id = 0
    var userID = 0
    var fromID = 0
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
    var in_read = 0
    var out_read = 0
    var attach: [DialogAttach] = []
    
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
        self.in_read = json["in_read"].intValue
        self.out_read = json["out_read"].intValue
        
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
        }
    }
    
    init(json: JSON, class: Int) {
        self.id = json["id"].intValue
        self.chatID = json["chat_id"].intValue
        self.userID = json["user_id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.readState = json["read_state"].intValue
        self.out = json["out"].intValue
        self.title = json["title"].stringValue
        self.body = json["body"].stringValue
        self.typeAttach = json["attachments"][0]["type"].stringValue
        self.emoji = json["emoji"].intValue
        self.important = json["important"].intValue
        self.deleted = json["deleted"].intValue
        self.randomID = json["random_id"].intValue
        self.in_read = json["in_read"].intValue
        self.out_read = json["out_read"].intValue
        
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
        }
    }
}
