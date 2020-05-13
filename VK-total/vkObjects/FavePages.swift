//
//  FavePages.swift
//  VK-total
//
//  Created by Сергей Никитин on 13/05/2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class FavePages {
    var id: String = ""
    var name: String = ""
    var type: String = ""
    var description: String = ""
    var photoURL: String = ""
    var screenName: String = ""
    var deactivated: String = ""
    
    init(json: JSON) {
        self.id = json["group"]["id"].stringValue
        self.name = json["group"]["name"].stringValue
        self.type = json["group"]["type"].stringValue
        self.description = json["description"].stringValue
        self.photoURL = json["group"]["photo_200"].stringValue
        self.screenName = json["group"]["screen_name"].stringValue
        self.deactivated = json["group"]["deactivated"].stringValue
    }
}
