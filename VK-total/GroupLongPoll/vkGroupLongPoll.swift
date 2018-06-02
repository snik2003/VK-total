//
//  vkGroupLongPoll.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

final class vkGroupLongPoll {
    static let shared = vkGroupLongPoll()
    
    var lpVersion = "3"
    var groupID = ""
    
    var server: [Int: String] = [:]
    var key: [Int: String] = [:]
    var ts: [Int: String] = [:]
    
    var firstLaunch: [Int: Bool] = [:]
    
    var updates: [Int: [Updates]] = [:]
    var request: [Int: GetLongPollServerRequest] = [:]
}
