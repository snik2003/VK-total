//
//  ParseNewsfeed.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseNewsfeed: Operation {
    
    var news: [Wall] = []
    var profiles: [WallProfiles] = []
    var groups: [WallGroups] = []
    var nextFrom: String = ""
    
    var filters: String
    var source: String
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        var newsData = json["response"]["items"].compactMap { Wall(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { WallProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { WallGroups(json: $0.1) }
        let newFrom = json["response"]["next_from"].stringValue
        
        if filters != "post" {
            newsData = json["response"]["items"].compactMap { Wall(json: $0.1, filters: self.filters) }
        }
        
        nextFrom = newFrom
        news = newsData
        profiles = profilesData
        groups = groupsData
    }
    
    init(filters: String, source: String) {
        self.filters = filters
        self.source = source
    }
}
