//
//  Videos.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Videos {
    var id = 0
    var ownerID = 0
    var title = ""
    var description = ""
    var duration = 0
    var photoURL = ""
    var date = 0
    var addingDate = 0
    var player = ""
    var platform = ""
    var views = 0
    var canAdd = 0
    var userLikes = 0
    var countLikes = 0
    var canComment = 0
    var countComments = 0
    var userReposted = 0
    var countReposts = 0
    var accessKey = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.duration = json["duration"].intValue
        self.date = json["date"].intValue
        self.addingDate = json["adding_date"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.photoURL = json["photo_320"].stringValue
        self.player = json["player"].stringValue
        self.platform = json["platform"].stringValue
        
        self.views = json["views"].intValue
        self.countComments = json["comments"].intValue
        self.canAdd = json["can_add"].intValue
        self.canComment = json["can_comment"].intValue
        
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
        self.countReposts = json["reposts"]["count"].intValue
        
        self.accessKey = json["access_key"].stringValue
    }
}
