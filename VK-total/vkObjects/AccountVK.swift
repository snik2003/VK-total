//
//  AccountVK.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import RealmSwift

class AccountVK: Object {
    @objc dynamic var userID = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var avatarURL = ""
    @objc dynamic var screenName = ""
    @objc dynamic var lastSeen = 0
    @objc dynamic var token = ""
    
    override static func primaryKey() -> String? {
        return "userID"
    }
}
