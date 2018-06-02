//
//  ParseProfileInfo.swift
//  VK-total
//
//  Created by Сергей Никитин on 29.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseProfileInfo: Operation {
    
    var outputData: [ProfileInfo] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let profile = ProfileInfo(json: JSON.null)
        profile.firstName = json["response"]["first_name"].stringValue
        profile.lastName = json["response"]["last_name"].stringValue
        profile.maidenName = json["response"]["maiden_name"].stringValue
        profile.screenName = json["response"]["screen_name"].stringValue
        profile.sex = json["response"]["sex"].intValue
        profile.relation = json["response"]["relation"].intValue
        profile.relationID = json["response"]["relation_id"].intValue
        profile.relationPending = json["response"]["relation_name"].intValue
        profile.bdate = json["response"]["bdate"].stringValue
        profile.bdateVisibility = json["response"]["bdate_visibility"].intValue
        profile.homeTown = json["response"]["home_town"].stringValue
        
        outputData.append(profile)
    }
}
