//
//  Conversation.swift
//  VK-total
//
//  Created by Сергей Никитин on 06.10.2021.
//  Copyright © 2021 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Conversation: Equatable, Codable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        if lhs.peerID == rhs.peerID, lhs.type == rhs.type, lhs.localID == rhs.localID {
            return true
        }
        return false
    }
    
    var lastMessageID = 0
    var peerID = 0
    var type = ""
    var localID = 0
    
    var isMarkedUnread = false
    var inRead = 0
    var outRead = 0
    var unreadCount = 0
    var important = false
    var unanswered = false
    
    var canWrite: CanWrite = CanWrite(json: JSON.null)
    var chatSettings: ChatSettings = ChatSettings(json: JSON.null)
    
    init(json: JSON) {
        self.lastMessageID = json["last_message_id"].intValue
        self.peerID = json["peer"]["id"].intValue
        self.type = json["peer"]["type"].stringValue
        self.localID = json["peer"]["local_id"].intValue
        
        self.isMarkedUnread = json["is_marked_unread"].boolValue
        self.inRead = json["in_read"].intValue
        self.outRead = json["out_read"].intValue
        self.unreadCount = json["unread_count"].intValue
        self.important = json["important"].boolValue
        self.unanswered = json["unanswered"].boolValue
        
        self.canWrite = CanWrite(json: json["can_write"])
        self.chatSettings = ChatSettings(json: json["chat_settings"])
    }
}

class CanWrite: Codable {
    var allowed = false
    var reasonID = 0
    var reason = ""
    
    init(json: JSON) {
        self.allowed = json["allowed"].boolValue
        self.reasonID = json["reason"].intValue
        
        switch reasonID {
        case 18:
            self.reason = "пользователь заблокирован или удален"
        case 900:
            self.reason = "нельзя отправить сообщение пользователю, который в чёрном списке"
        case 901:
            self.reason = "пользователь запретил сообщения от сообщества"
        case 902:
            self.reason = "пользователь запретил присылать ему сообщения с помощью настроек приватности"
        case 915:
            self.reason = "в сообществе отключены сообщения"
        case 916:
            self.reason = "в сообществе заблокированы сообщения"
        case 917:
            self.reason = "нет доступа к чату"
        case 918:
            self.reason = "нет доступа к e-mai"
        case 203:
            self.reason = "нет доступа к сообществу"
        default:
            self.reason = "неизвестная причина"
        }
    }
}

class ChatSettings: Codable {
    var membersCount = 0
    var title = ""
    var state = ""
    var photo50 = ""
    var photo100 = ""
    var photo200 = ""
    var isGroupChannel = false
    var activeIDs: [Int] = []
    
    init(json: JSON) {
        self.membersCount = json["members_count"].intValue
        self.title = json["title"].stringValue
        self.state = json["state"].stringValue
        self.photo50 = json["photo"]["photo_50"].stringValue
        self.photo100 = json["photo"]["photo_100"].stringValue
        self.photo200 = json["photo"]["photo_200"].stringValue
        self.isGroupChannel = json["is_group_channel"].boolValue
        self.activeIDs = json["active_ids"].arrayValue.map({ $0.intValue })
    }
}
