//
//  vkUserLongPoll.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

final class vkUserLongPoll {
    static let shared = vkUserLongPoll()

    var lpVersion = "3"
    var userID = ""
    
    var server = ""
    var key = ""
    var ts = ""
    var pts = ""
    
    var updates: [Updates] = []
    var firstLaunch = true
    var request: GetLongPollServerRequest!
}

struct Updates {
    var elements: [Int] = []
    var text: String = ""
    var title: String = ""
    var fwdCount: Int = 0
    var emoji: Int = 0
    var type: String = ""
    var fromID: Int = 0
    var action: String = ""
    var actionID: Int = 0
    
    init(json: JSON) {
        for index in 0...4 {
            elements.append(json[index].intValue)
        }
        
        self.text = json[5].stringValue
        
        self.fwdCount = json[6]["fwd_count"].intValue
        self.title = json[6]["title"].stringValue
        self.emoji = json[6]["emoji"].intValue
        self.fromID = json[6]["from"].intValue
        self.action = json[6]["source_act"].stringValue
        self.actionID = json[6]["source_mid"].intValue
        
        self.type = json[7]["attach1_type"].stringValue
    }
}
