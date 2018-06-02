//
//  Notifications.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notifications {
    var date = 0
    var type = ""
    var countFeedback = 0
    var feedback = [Feedback]()
    var parent = [Parent]()
    
    init(json: JSON) {
        self.date = json["date"].intValue
        self.type = json["type"].stringValue
        
        self.countFeedback = json["feedback"]["count"].intValue
        if self.countFeedback == 0 {
            self.countFeedback = 1
        }
        if self.countFeedback > 0 {
            for index in 0...self.countFeedback-1 {
                self.feedback.append(Feedback(json: json, index: index, type: self.type))
            }
        } else {
            self.feedback.append(Feedback(json: JSON.null, index: 0, type: self.type))
        }
        
        self.parent.append(Parent(json: json, type: self.type))
    }
}

struct Feedback {
    var id = 0
    var toID = 0
    var fromID = 0
    var text = ""
    var type = ""
    var attach = [Attachment]()
    
    init(json: JSON, index: Int, type: String) {
        
        if type == "follow" || type == "friend_accepted" || type == "like_post" || type == "like_comment" || type == "like_photo" || type == "like_video" || type == "like_comment_photo" || type == "like_comment_video" || type == "like_comment_topic" || type == "copy_post" || type == "copy_photo" || type == "copy_video" {
            
            self.id = json["feedback"]["items"][index]["id"].intValue
            self.toID = json["feedback"]["items"][index]["to_id"].intValue
            self.fromID = json["feedback"]["items"][index]["from_id"].intValue
            self.text = json["feedback"]["items"][index]["text"].stringValue
            self.type = ""
            self.attach.append(Attachment(json: json["feedback"], index: 0))
            
        } else if type == "mention_comments" || type == "comment_post" || type == "comment_photo" || type == "comment_video" || type == "reply_comment" || type == "reply_comment_photo" || type == "reply_comment_video" || type == "reply_topic" || type == "mention_comment_photo" || type == "mention_comment_video" {
            
            self.id = json["feedback"]["id"].intValue
            self.fromID = json["feedback"]["from_id"].intValue
            self.text = json["feedback"]["text"].stringValue
            self.attach.append(Attachment(json: json["feedback"], index: 0))
        } else if type == "mention" || type == "wall" || type == "wall_publish" {
            
            self.id = json["feedback"]["id"].intValue
            self.toID = json["feedback"]["to_id"].intValue
            self.fromID = json["feedback"]["from_id"].intValue
            self.text = json["feedback"]["text"].stringValue
            self.attach.append(Attachment(json: json["feedback"], index: 0))
        } 
    }
}

struct Parent {
    var id = 0
    var toID = 0
    var fromID = 0
    var ownerID = 0
    var typeID = 0
    var date = 0
    var width = 0
    var height = 0
    var photoURL = ""
    var text = ""
    var attach = [Attachment]()
    var repostText = ""
    var repostAttach = [Attachment]()
    init(json: JSON, type: String) {
        
        if type == "mention_comments" || type == "comment_post" || type == "like_post" || type == "copy_post" {
            self.id = json["parent"]["id"].intValue
            self.toID = json["parent"]["to_id"].intValue
            self.fromID = json["parent"]["from_id"].intValue
            self.date = json["parent"]["date"].intValue
            
            self.text = json["parent"]["text"].stringValue
            self.repostText = json["parent"]["copy_history"][0]["text"].stringValue
            
            self.attach.append(Attachment(json: json["parent"], index: 0))
            self.repostAttach.append(Attachment(json: json["parent"]["copy_history"][0], index: 0))
            
        } else if type == "reply_comment" || type == "reply_comment_photo" || type == "reply_comment_video" || type == "like_comment" || type == "like_comment_photo" || type == "like_comment_video" || type == "like_comment_topic" {
            
            self.id = json["parent"]["id"].intValue
            self.ownerID = json["parent"]["owner_id"].intValue
            self.date = json["parent"]["date"].intValue
            self.text = json["parent"]["text"].stringValue
            
            if type == "reply_comment" || type == "like_comment" {
                self.typeID = json["parent"]["post"]["id"].intValue
                self.fromID = json["parent"]["post"]["from_id"].intValue
            }
            if type == "reply_comment_photo" || type == "like_comment_photo" {
                self.typeID = json["parent"]["photo"]["id"].intValue
                self.width = json["parent"]["photo"]["width"].intValue
                self.height = json["parent"]["photo"]["height"].intValue
                self.photoURL = json["parent"]["photo"]["photo_807"].stringValue
                if self.photoURL == "" {
                    self.photoURL = json["parent"]["photo"]["photo_604"].stringValue
                }
                if self.photoURL == "" {
                    self.photoURL = json["parent"]["photo"]["photo_130"].stringValue
                }
                if self.photoURL == "" {
                    self.photoURL = json["parent"]["photo"]["photo_75"].stringValue
                }
            }
            if type == "reply_comment_video" || type == "like_comment_video" {
                self.typeID = json["parent"]["video"]["id"].intValue
                self.ownerID = json["parent"]["video"]["owner_id"].intValue
            }
            if type == "like_comment_topic" {
                self.typeID = json["parent"]["topic"]["id"].intValue
                self.ownerID = json["parent"]["topic"]["owner_id"].intValue
            }
        } else if type == "comment_photo" || type == "like_photo" || type == "copy_photo" || type == "mention_comment_photo" {
            
            self.id = json["parent"]["id"].intValue
            self.ownerID = json["parent"]["owner_id"].intValue
            self.text = json["parent"]["text"].stringValue
            self.date = json["parent"]["date"].intValue
            self.width = json["parent"]["width"].intValue
            self.height = json["parent"]["height"].intValue
            self.photoURL = json["parent"]["photo_807"].stringValue
            if self.photoURL == "" {
                self.photoURL = json["parent"]["photo_604"].stringValue
            }
            if self.photoURL == "" {
                self.photoURL = json["parent"]["photo_130"].stringValue
            }
            if self.photoURL == "" {
                self.photoURL = json["parent"]["photo_75"].stringValue
            }
        
        } else if type == "comment_video" || type == "like_video" || type == "copy_video" || type == "mention_comment_video" {
            
            self.id = json["parent"]["id"].intValue
            self.ownerID = json["parent"]["owner_id"].intValue
            self.text = json["parent"]["title"].stringValue
            self.date = json["parent"]["date"].intValue
            self.width = json["parent"]["width"].intValue
            self.height = json["parent"]["height"].intValue
            self.photoURL = json["parent"]["image"].stringValue
        }
    }
}
