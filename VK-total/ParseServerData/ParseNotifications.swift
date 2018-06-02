//
//  ParseNotifications.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseNotifications: Operation {
    
    var outputData: [Notifications] = []
    var outputProfiles: [WallProfiles] = []
    var outputGroups: [WallGroups] = []
    var countNewNots: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        outputData = json["response"]["items"].compactMap { Notifications(json: $0.1) }
        outputProfiles = json["response"]["profiles"].compactMap { WallProfiles(json: $0.1) }
        outputGroups = json["response"]["groups"].compactMap { WallGroups(json: $0.1) }
        
        let lastViewed = json["response"]["last_viewed"].intValue
        for not in outputData {
            if not.date > lastViewed {
                countNewNots += not.feedback.count
            }
        }
        
    }
}
