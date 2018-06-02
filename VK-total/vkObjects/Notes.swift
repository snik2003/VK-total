//
//  Notes.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Notes {
    var id = 0
    var ownerID = 0
    var title = ""
    var text = ""
    var date = 0
    var comments = 0
    var readComments = 0
    var viewURL = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.text = json["text"].stringValue
        self.date = json["date"].intValue
        self.comments = json["comments"].intValue
        self.readComments = json["read_comments"].intValue
        self.viewURL = json["view_url"].stringValue
    }
}
