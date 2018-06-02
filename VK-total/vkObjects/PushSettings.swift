//
//  PushSettings.swift
//  VK-total
//
//  Created by Сергей Никитин on 25.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class PushSettings {
    var disabled: Int = 0
    var like: [String] = ["", "", ""]
    var comment: [String] = ["", "", ""]
    var groupInvite: [String] = ["", "", ""]
    var repost: [String] = ["", "", ""]
    var reply: [String] = ["", "", ""]
    var mention: [String] = ["", "", ""]
    var newPost: [String] = ["", "", ""]
    var gift: [String] = ["", "", ""]
    var msg: [String] = ["", "", ""]
    var groupAccepted: [String] = ["", "", ""]
    var live: [String] = ["", "", ""]
    var friendAccepted: [String] = ["", "", ""]
    var wallPost: [String] = ["", "", ""]
    var friend: [String] = ["", "", ""]
    var wallPublish: [String] = ["", "", ""]
    
    init(json: JSON) {
        self.disabled = json["disabled"].intValue
    }
    
    
}

