//
//  Page.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Page {
    var pageID = 0
    var ownerID = 0
    var groupID = 0
    var creatorID = 0
    var title = ""
    var canEdit = 0
    var canEditAccess = 0
    var whoCanView = 0
    var whoCanEdit = 0
    var edited = 0
    var created = 0
    var editorID = 0
    var views = 0
    var parent = ""
    var parent2 = ""
    var source = ""
    var html = ""
    var view_url = ""
    
    init(json: JSON) {
        self.pageID = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.groupID = json["group_id"].intValue
        self.creatorID = json["creator_id"].intValue
        self.title = json["title"].stringValue
        self.canEdit = json["current_user_can_edit"].intValue
        self.canEditAccess = json["current_user_can_edit_access"].intValue
        self.whoCanView = json["who_can_view"].intValue
        self.whoCanEdit = json["who_can_edit"].intValue
        self.edited = json["edited"].intValue
        self.created = json["created"].intValue
        self.editorID = json["editor_id"].intValue
        self.views = json["views"].intValue
        self.parent = json["parent"].stringValue
        self.parent2 = json["parent2"].stringValue
        self.source = json["source"].stringValue
        self.html = json["html"].stringValue
        self.view_url = json["view_url"].stringValue
    }
}
