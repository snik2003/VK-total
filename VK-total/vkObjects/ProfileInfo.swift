//
//  ProfileInfo.swift
//  VK-total
//
//  Created by Сергей Никитин on 29.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProfileInfo {
    var firstName: String = ""
    var lastName: String = ""
    var maidenName: String = ""
    var screenName: String = ""
    var sex: Int = 0
    var relation: Int = 0
    var relationID: Int = 0
    var relationName: String = ""
    var relationPending: Int = 0
    var bdate: String = ""
    var bdateVisibility: Int = 0
    var homeTown: String = ""
    var status: String = ""
    
    init(json: JSON) {
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.maidenName = json["maiden_name"].stringValue
        self.screenName = json["screen_name"].stringValue
        self.sex = json["sex"].intValue
        self.relation = json["relation"].intValue
        self.relationID = json["relation_id"].intValue
        self.relationPending = json["relation_name"].intValue
        self.bdate = json["bdate"].stringValue
        self.bdateVisibility = json["bdate_visibility"].intValue
        self.homeTown = json["home_town"].stringValue
        self.status = json["status"].stringValue
    }
}
