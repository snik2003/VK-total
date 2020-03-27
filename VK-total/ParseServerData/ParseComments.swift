//
//  ParseComments.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseComments: Operation {
    
    var comments: [Comments] = []
    var profiles: [CommentsProfiles] = []
    var groups: [CommentsGroups] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation4, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let commentsData: [Comments] = json["response"]["items"].compactMap { Comments(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { CommentsProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { CommentsGroups(json: $0.1) }
        count = json["response"]["count"].intValue
        
        comments = commentsData
        profiles = profilesData
        groups = groupsData
    }
}

class ParseComments2: Operation {
    
    var comments: [Comments] = []
    var profiles: [CommentsProfiles] = []
    var groups: [CommentsGroups] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json["response"]["items"])
        let commentsData: [Comments] = json["response"]["items"].compactMap { Comments(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { CommentsProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { CommentsGroups(json: $0.1) }
        count = json["response"]["count"].intValue
        
        comments = commentsData
        profiles = profilesData
        groups = groupsData
    }
}

