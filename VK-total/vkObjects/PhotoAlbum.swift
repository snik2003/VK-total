//
//  PhotoAlbum.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class PhotoAlbum {
    var id = 0
    var thumbID = 0
    var ownerID = 0
    var title = ""
    var descriptionText = ""
    var created = 0
    var updated = 0
    var size = 0
    var canUpload = 0
    var uploadByAdminsOnly = 0
    var commentsDisabled = 0
    var thumbSrc = ""
    var privacyComment: [String] = []
    var privacyView: [String] = []
    var isAdmin = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.thumbID = json["thumb_id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.descriptionText = json["description"].stringValue
        self.created = json["created"].intValue
        self.updated = json["updated"].intValue
        self.size = json["size"].intValue
        self.canUpload = json["can_upload"].intValue
        self.uploadByAdminsOnly = json["upload_by_admins_only"].intValue
        self.commentsDisabled = json["comments_disabled"].intValue
        self.thumbSrc = json["thumb_src"].stringValue
        self.privacyView = json["privacy_view"].arrayValue.map({ $0.stringValue })
        self.privacyComment = json["privacy_comment"].arrayValue.map({ $0.stringValue })
        
        if self.ownerID > 0 {
            if json["privacy_view"].exists() || json["privacy_comment"].exists() { self.isAdmin = true }
        } else if self.ownerID < 0 {
            if json["upload_by_admins_only"].exists() || json["comments_disabled"].exists() { self.isAdmin = true }
        }
    }
}
