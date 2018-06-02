//
//  Topics.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Topic {
    var id = 0
    var title = ""
    var created = 0
    var createdBy = 0
    var updated = 0
    var updatedBy = 0
    var isClosed = 0
    var isFixed = 0
    var commentsCount = 0
    var firstCommentText = ""
    var lastCommentText = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.created = json["created"].intValue
        self.updated = json["updated"].intValue
        self.createdBy = json["created_by"].intValue
        self.updatedBy = json["updated_by"].intValue
        self.isClosed = json["is_closed"].intValue
        self.isFixed = json["is_fixed"].intValue
        self.commentsCount = json["comments"].intValue
        self.firstCommentText = json["first_comment"].stringValue
        self.lastCommentText = json["last_comment"].stringValue
    }
}
