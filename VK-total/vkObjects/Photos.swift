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
    var uid: String = ""
    var pid: String = ""
    var createdTime: Int = 0
    var width: Int = 0
    var height: Int = 0
    var photoURL: String = ""
    var photoAccessKey: String = ""
    var smallPhotoURL: String = ""
    var bigPhotoURL: String = ""
    var xbigPhotoURL: String = ""
    var xxbigPhotoURL: String = ""

    init(json: JSON) {
        self.uid = json["owner_id"].stringValue
        self.pid = json["id"].stringValue
        self.createdTime = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photoURL = json["photo_130"].stringValue
        self.photoAccessKey = json["access_key"].stringValue
        self.smallPhotoURL = json["photo_75"].stringValue
        self.bigPhotoURL = json["photo_604"].stringValue
        self.xbigPhotoURL = json["photo_807"].stringValue
        self.xxbigPhotoURL = json["photo_1204"].stringValue
    }
}

class Photo {
    var photoID: String = ""
    var albumID: String = ""
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
        self.userID = json["owner_id"].stringValue
        self.postID = json["post_id"].intValue
        self.text = json["text"].stringValue
        self.createdTime = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photoAccessKey = json["access_key"].stringValue
        self.photoURL = json["photo_130"].stringValue
        self.smallPhotoURL = json["photo_75"].stringValue
        self.bigPhotoURL = json["photo_604"].stringValue
        self.xbigPhotoURL = json["photo_807"].stringValue
        self.xxbigPhotoURL = json["photo_1204"].stringValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikesThisPhoto = json["likes"]["user_likes"].intValue
        self.repostsCount = json["reposts"]["count"].intValue
        self.userRepostedThisPhoto = json["reposts"]["user_reposted"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.tagsCount = json["tags"]["count"].intValue
        self.canComment = json["can_comment"].intValue
        self.canRepost = json["can_repost"].intValue
    }
}
