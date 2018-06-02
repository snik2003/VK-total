//
//  ParseRecord.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseRecord: Operation {
    
    var news: [Record] = []
    var profiles: [RecordProfiles] = []
    var groups: [RecordGroups] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let recordData: [Record] = json["response"]["items"].compactMap { Record(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { RecordProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { RecordGroups(json: $0.1) }
        
        
        news = recordData
        profiles = profilesData
        groups = groupsData
    }
}
