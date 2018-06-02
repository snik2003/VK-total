//
//  ParseRequest.swift
//  VK-total
//
//  Created by Сергей Никитин on 19.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseRequest: Operation {
    
    var outputData: String = ""
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        count = json["response"]["count"].intValue
        let ids = json["response"]["items"].compactMap { FriendRequest(json: $0.1) }
        if count > 0 {
            var str = ""
            for id in ids {
                if str != "" {
                    str = "\(str),"
                }
                str = "\(str)\(id.id)"
            }
            outputData = str
        }
    }
}
