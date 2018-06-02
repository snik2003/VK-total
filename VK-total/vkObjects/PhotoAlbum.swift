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
    var description = ""
    var created = 0
    var updated = 0
    var size = 0
    var canUpload = 0
    var commentsDisabled = 0
    var thumbSrc = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.thumbID = json["thumb_id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.created = json["created"].intValue
        self.updated = json["updated"].intValue
        self.size = json["size"].intValue
        self.canUpload = json["can_upload"].intValue
        self.commentsDisabled = json["comments_disabled"].intValue
        self.thumbSrc = json["thumb_src"].stringValue
    }
}
