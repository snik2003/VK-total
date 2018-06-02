//
//  Friends.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Friends : Equatable {
    static func == (lhs: Friends, rhs: Friends) -> Bool {
        if lhs.uid == rhs.uid {
            return true
        }
        return false
    }
    
    var uid: String = ""
    var lastName: String = ""
    var userID: String = ""
    var onlineStatus: Int = 0
    var onlineMobile: Int = 0
    var deactivated: String = ""
    var firstName: String = ""
    var photoURL: String = ""
    var lastSeen: Int = 0
    var platform: Int = 0
    var sex: Int = 0
    var isFriend: Int = 0
    var role: String = ""
    
    init(json: JSON) {
        self.uid = json["id"].stringValue
        self.lastName = json["last_name"].stringValue
        self.userID = json["id"].stringValue
        self.firstName = json["first_name"].stringValue
        self.onlineStatus = json["online"].intValue
        self.onlineMobile = json["online_mobile"].intValue
        self.deactivated = json["deactivated"].stringValue
        self.photoURL = json["photo_max"].stringValue
        self.lastSeen = json["last_seen"]["time"].intValue
        self.platform = json["last_seen"]["platform"].intValue
        self.sex = json["sex"].intValue
        self.isFriend = json["is_friend"].intValue
        self.role = json["role"].stringValue
    }
}
