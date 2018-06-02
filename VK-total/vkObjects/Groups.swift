//
//  Groups.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Groups {
    var gid: String = ""
    var name: String = ""
    var membersCount: Int = 0
    var coverURL: String = ""
    var typeGroup: String = ""
    var invitedBy: Int = 0
    var isClosed: Int = 0
    var deactivated: String = ""
    
    init(json: JSON) {
        self.gid = json["id"].stringValue
        self.name = json["name"].stringValue
        self.membersCount = json["members_count"].intValue
        self.coverURL = json["photo_200"].stringValue
        self.typeGroup = json["type"].stringValue
        self.invitedBy = json["invited_by"].intValue
        self.isClosed = json["is_closed"].intValue
        self.deactivated = json["deactivated"].stringValue
    }
}
