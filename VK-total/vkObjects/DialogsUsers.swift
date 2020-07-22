//
//  DialogsUsers.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class DialogsUsers: Codable {
    var uid: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var lastSeen: Int = 0
    var platform: Int = 0
    var maxPhotoURL: String = ""
    var maxPhotoOrigURL: String = ""
    var deactivated: String = ""
    var firstNameAbl: String = "" // Имя в предложном падеже (О Ком?)
    var firstNameGen: String = "" // Имя в родительном падеже (Чей?)
    var online: Int = 0
    var onlineMobile: Int = 0
    var canWritePrivateMessage: Int = 0
    var sex: Int = 0
    var photo100 = ""
    
    init(json: JSON) {
        self.uid = json["id"].stringValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.lastSeen = json["last_seen"]["time"].intValue
        self.platform = json["last_seen"]["platform"].intValue
        self.maxPhotoURL = json["photo_max"].stringValue
        self.maxPhotoOrigURL = json["photo_max_orig"].stringValue
        self.deactivated = json["deactivated"].stringValue
        self.firstNameAbl = json["first_name_abl"].stringValue
        self.firstNameGen = json["first_name_gen"].stringValue
        self.online = json["online"].intValue
        self.onlineMobile = json["online_mobile"].intValue
        self.canWritePrivateMessage = json["can_write_private_message"].intValue
        self.sex = json["sex"].intValue
        self.photo100 = json["photo_100"].stringValue
    }
    
    var inLove: Bool {
        
        if vkSingleton.shared.userID == "34051891" && uid == "451439315" {
            return true
        }
        
        if vkSingleton.shared.userID == "451439315" && uid == "34051891" {
            return true
        }
        
        return false
    }
}
