//
//  ParseFollowersList.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseFollowersList: Operation {
    
    var outputData: [Followers] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        let followers = json["response"]["items"].compactMap { Followers(json: $0.1) }
        outputData = followers
    }
}
