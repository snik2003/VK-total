//
//  Photos.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Photos {
    var uid: String = "0"
    var pid: String = "0"
    var ownerID: String = "0"
    var createdTime: Int = 0
    var text: String = ""
    var width: Int = 0
    var height: Int = 0
    var photoURL: String = ""
    var photoAccessKey: String = ""
    var smallPhotoURL: String = ""
    var bigPhotoURL: String = ""
    var xbigPhotoURL: String = ""
    var xxbigPhotoURL: String = ""
    
    init(json: JSON) {
        self.ownerID = json["owner_id"].stringValue
        self.uid = json["user_id"].stringValue
        if self.uid.isEmpty { self.uid = self.ownerID }
        self.pid = json["id"].stringValue
        self.createdTime = json["date"].intValue
        self.text = json["text"].stringValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photoAccessKey = json["access_key"].stringValue
        
        let photoSizes = json["sizes"]
        
        if let size = photoSizes.filter({ $0.1["type"] == "m"}).first {
            self.photoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "s"}).first {
            self.smallPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "x"}).first {
            self.bigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "y"}).first {
            self.xbigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "z"}).first {
            self.xxbigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
    }
}

class Photo {
    var photoID: String = ""
    var albumID: String = ""
    var ownerID: String = ""
    var userID: String = ""
    var postID: Int = 0
    var text: String = ""
    var createdTime: Int = 0
    var width: Int = 0
    var height: Int = 0
    var photoURL: String = ""
    var photoAccessKey: String = ""
    var smallPhotoURL: String = ""
    var bigPhotoURL: String = ""
    var xbigPhotoURL: String = ""
    var xxbigPhotoURL: String = ""
    var likesCount: Int = 0
    var userLikesThisPhoto: Int = 0
    var repostsCount: Int = 0
    var userRepostedThisPhoto: Int = 0
    var commentsCount: Int = 0
    var tagsCount: Int = 0
    var canComment: Int = 0
    var canRepost: Int = 0

    init(json: JSON) {
        self.photoID = json["id"].stringValue
        self.albumID = json["album_id"].stringValue
        self.ownerID = json["owner_id"].stringValue
        self.userID = json["user_id"].stringValue
        if self.userID.isEmpty { self.userID = self.ownerID }
        self.postID = json["post_id"].intValue
        self.text = json["text"].stringValue
        self.createdTime = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photoAccessKey = json["access_key"].stringValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikesThisPhoto = json["likes"]["user_likes"].intValue
        self.repostsCount = json["reposts"]["count"].intValue
        self.userRepostedThisPhoto = json["reposts"]["user_reposted"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.tagsCount = json["tags"]["count"].intValue
        self.canComment = json["can_comment"].intValue
        self.canRepost = json["can_repost"].intValue
        
        let photoSizes = json["sizes"]
        
        if let size = photoSizes.filter({ $0.1["type"] == "m"}).first {
            self.photoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "s"}).first {
            self.smallPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "x"}).first {
            self.bigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "y"}).first {
            self.xbigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
        
        if let size = photoSizes.filter({ $0.1["type"] == "z"}).first {
            self.xxbigPhotoURL = size.1["url"].stringValue
            if width == 0 { self.width = size.1["width"].intValue }
            if height == 0 { self.height = size.1["height"].intValue }
        }
    }
}
