//
//  ParseRequestList.swift
//  VK-total
//
//  Created by Сергей Никитин on 19.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseRequestList: Operation {
    
    var outputData: [Friends] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        let users = json["response"].compactMap { Friends(json: $0.1) }
        outputData = users
    }
}
