//
//  Likes.swift
//  VK-total
//
//  Created by Сергей Никитин on 06.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Likes {
    var uid: String = ""
    var type: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var sex: Int = 0
    var maxPhotoURL: String = ""
    var maxPhotoOrigURL: String = ""
    var friendStatus: Int = 0
    var onlineStatus: Int = 0
    var onlineMobile: Int = 0
    var platform: Int = 0
    var firstNameDat: String = "" // Имя в дательном падеже (Кому?)
    
    init(json: JSON) {
        self.uid = json["id"].stringValue
        self.type = json["type"].stringValue
        if self.type == "profile" {
            self.firstName = json["first_name"].stringValue
            self.lastName = json["last_name"].stringValue
            self.sex = json["sex"].intValue
            self.maxPhotoURL = json["photo_max"].stringValue
            self.maxPhotoOrigURL = json["photo_max_orig"].stringValue
            self.friendStatus = json["friend_status"].intValue
            self.onlineStatus = json["online"].intValue
            self.onlineMobile = json["online_mobile"].intValue
            self.platform = json["last_seen"]["platform"].intValue
            self.firstNameDat = json["first_name_dat"].stringValue
        } else {
            self.firstName = json["name"].stringValue
            self.maxPhotoURL = json["photo_200"].stringValue
            self.maxPhotoOrigURL = json["photo_200"].stringValue
        }
    }
}
