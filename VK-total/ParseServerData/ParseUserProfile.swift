//
//  ParseUserProfile.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseUserProfile: Operation {
    
    var outputData: [UserProfileInfo] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let profile: [UserProfileInfo] = json["response"].compactMap { UserProfileInfo(json: $0.1) }
        outputData = profile
    }
}
