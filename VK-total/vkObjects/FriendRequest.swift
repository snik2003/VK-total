//
//  FriendRequest.swift
//  VK-total
//
//  Created by Сергей Никитин on 19.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class FriendRequest {
    var id = ""
    
    init(json: JSON) {
        self.id = json.stringValue
    }
}
