//
//  ParseUserWall.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseUserWall: Operation {
    
    var wall: [Wall] = []
    var profiles: [WallProfiles] = []
    var groups: [WallGroups] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let wallData = json["response"]["items"].compactMap { Wall(json: $0.1) }
        let profilesData = json["response"]["profiles"].compactMap { WallProfiles(json: $0.1) }
        let groupsData = json["response"]["groups"].compactMap { WallGroups(json: $0.1) }
        
        wall = wallData
        profiles = profilesData
        groups = groupsData
    }
}
