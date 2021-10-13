//
//  Comments.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comments: Equatable, Comparable {
    static func == (lhs: Comments, rhs: Comments) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        return false
    }
    
    static public func < (lhs: Comments, rhs: Comments) -> Bool {
        if lhs.date < rhs.date {
            return true
        }
        return false
    }
    
    static public func > (lhs: Comments, rhs: Comments) -> Bool {
        if lhs.date > rhs.date {
            return true
        }
        return false
    }
    
    var id: Int = 0
    var fromID: Int = 0
    var date: Int = 0
    var text: String = ""
    var attach = [Attachment]()
    var canLike = 0
    var userLikes = 0
    var countLikes = 0
    var replyUser = 0
    var replyComment = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
        self.canLike = json["likes"]["can_like"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.replyUser = json["reply_to_user"].intValue
        self.replyComment = json["reply_to_comment"].intValue
        
        for index in 0...9 {
            let att = Attachment(json: json, index: index)
            if att.type != "" {
                self.attach.append(att)
            }
        }
    }
}

struct Attachment {
    var id: Int = 0
    var productID: Int = 0
    var userID: Int = 0
    var ownerID: Int = 0
    var type: String = ""
    var accessKey: String = ""
    var photoURL: String = ""
    var photoWidth: Int = 0
    var photoHeight: Int = 0
    var videoURL: String = ""
    var size: Int = 0
    var ext: String = ""
    var text: String = ""
    var artist: String = ""
    var title: String = ""
    
    init(json: JSON, index: Int) {
        self.type = json["attachments"][index]["type"].stringValue
        
        if self.type == "sticker" {
            self.id = json["attachments"][index]["sticker"]["sticker_id"].intValue
            self.productID = json["attachments"][index]["sticker"]["product_id"].intValue
            self.text = json["attachments"][index]["sticker"]["text"].stringValue
            
            let sImages = json["attachments"][index]["sticker"]["images"]
            if sImages.count > 2 {
                self.photoWidth = sImages[2]["width"].intValue
                self.photoHeight = sImages[2]["height"].intValue
                self.photoURL = sImages[2]["url"].stringValue
            } else {
                self.photoWidth = sImages[0]["width"].intValue
                self.photoHeight = sImages[0]["height"].intValue
                self.photoURL = sImages[0]["url"].stringValue
            }
            
        }
        
        if self.type == "photo" {
            self.id = json["attachments"][index]["photo"]["id"].intValue
            self.userID = json["attachments"][index]["photo"]["user_id"].intValue
            self.ownerID = json["attachments"][index]["photo"]["owner_id"].intValue
            self.accessKey = json["attachments"][index]["photo"]["access_key"].stringValue
            self.photoWidth = json["attachments"][index]["photo"]["width"].intValue
            self.photoHeight = json["attachments"][index]["photo"]["height"].intValue
            self.text = json["attachments"][index]["photo"]["text"].stringValue
            
            let photoSizes = json["attachments"][index]["photo"]["sizes"]
            
            if let size = photoSizes.filter({ $0.1["type"] == "x"}).first {
                self.photoURL = size.1["url"].stringValue
                self.photoWidth = size.1["width"].intValue
                self.photoHeight = size.1["height"].intValue
            }
            
            if self.photoURL.isEmpty, let size = photoSizes.filter({ $0.1["type"] == "r"}).first {
                self.photoURL = size.1["url"].stringValue
                self.photoWidth = size.1["width"].intValue
                self.photoHeight = size.1["height"].intValue
            }
            
            if self.photoURL.isEmpty, let size = photoSizes.filter({ $0.1["type"] == "y"}).first {
                self.photoURL = size.1["url"].stringValue
                self.photoWidth = size.1["width"].intValue
                self.photoHeight = size.1["height"].intValue
            }
        }
        
        if self.type == "doc" {
            self.id = json["attachments"][index]["doc"]["id"].intValue
            self.ownerID = json["attachments"][index]["doc"]["owner_id"].intValue
            self.size = json["attachments"][index]["doc"]["size"].intValue
            self.videoURL = json["attachments"][index]["doc"]["url"].stringValue
            self.ext = json["attachments"][index]["doc"]["ext"].stringValue
            self.text = json["attachments"][index]["doc"]["text"].stringValue
            
            
            self.photoWidth = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["width"].intValue
            self.photoHeight = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["height"].intValue
            self.photoURL = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["src"].stringValue
        }
        
        if self.type == "video" {
            self.id = json["attachments"][index]["video"]["id"].intValue
            self.ownerID = json["attachments"][index]["video"]["owner_id"].intValue
            self.size = json["attachments"][index]["video"]["duration"].intValue
            self.videoURL = json["attachments"][index]["video"]["access_key"].stringValue
            self.text = json["attachments"][index]["video"]["title"].stringValue
            
            self.photoWidth = 320
            self.photoHeight = 240
            self.photoURL = json["attachments"][index]["video"]["photo_320"].stringValue
        }
        
        if self.type == "audio" {
            self.id = json["attachments"][index]["audio"]["id"].intValue
            self.ownerID = json["attachments"][index]["audio"]["owner_id"].intValue
            self.artist = json["attachments"][index]["audio"]["artist"].stringValue
            self.title = json["attachments"][index]["audio"]["title"].stringValue
        }
    }
}

class CommentsProfiles {
    var uid: Int
    var firstName: String
    var lastName: String
    var photoURL: String
    var firstNameDat: String = "" // Имя в дательном падеже (Кому?)
    var firstNameAcc: String = "" // Имя в винительном падеже (Кому?)
    var sex: Int = 0
    
    init(json: JSON) {
        self.uid = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.photoURL = json["photo_100"].stringValue
        self.firstNameDat = json["first_name_dat"].stringValue
        self.firstNameAcc = json["first_name_acc"].stringValue
        self.sex = json["sex"].intValue
    }
}

class CommentsGroups {
    var gid: Int
    var name: String
    var photoURL: String
    
    init(json: JSON) {
        self.gid = json["id"].intValue
        self.name = json["name"].stringValue
        self.photoURL = json["photo_200"].stringValue
    }
}
