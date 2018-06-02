//
//  ChatInfo.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatInfo {
    var id = 0
    var type = ""
    var title = ""
    var adminID = 0
    var membersCount = 0
    var members: [Int] = []
    var photo50 = ""
    var photo100 = ""
    var photo200 = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.type = json["type"].stringValue
        self.title = json["title"].stringValue
        self.membersCount = json["members_count"].intValue
        self.adminID = json["admin_id"].intValue
        self.photo50 = json["photo_50"].stringValue
        self.photo100 = json["photo_100"].stringValue
        self.photo200 = json["photo_200"].stringValue
        
        if self.membersCount > 0 {
            for index in 0...membersCount-1 {
                let userID = json["users"][index].intValue
                if userID != 0 {
                    members.append(userID)
                }
            }
        }
    }
}
