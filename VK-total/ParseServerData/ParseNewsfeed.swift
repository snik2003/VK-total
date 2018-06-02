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
    
    var news: [News] = []
    var profiles: [NewsProfiles] = []
    var groups: [NewsGroups] = []
    var nextFrom: String = ""
    
    var filters: String
    var source: String
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        let newsData = json["response"]["items"].compactMap { News(json: $0.1, filters: filters) }
        let profilesData = json["response"]["profiles"].compactMap { NewsProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { NewsGroups(json: $0.1) }
        let newFrom = json["response"]["next_from"].stringValue
        
        nextFrom = newFrom
        news = newsData
        profiles = profilesData
        groups = groupsData
        
        if filters == "wall_photo" {
            if news.count > 0 {
                news.removeFirst()
            }
        }
    }
    
    init(filters: String, source: String) {
        self.filters = filters
        self.source = source
    }
}
