//
//  ParseGroupInvites.swift
//  VK-total
//
//  Created by Сергей Никитин on 28.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseGroupInvites: Operation {
    
    var outputData: [Groups] = []
    var outputUsers: [WallProfiles] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let groups = json["response"]["items"].compactMap { Groups(json: $0.1) }
        let profiles = json["response"]["profiles"].compactMap { WallProfiles(json: $0.1) }
        outputData = groups
        outputUsers = profiles
    }
}
