//
//  ParseDialogHistory.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseDialogHistory: Operation {
    
    var outputData: [DialogHistory] = []
    var count: Int = 0
    var unread: Int = 0
    var inRead: Int = 0
    var outRead: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        outputData = json["response"]["items"].compactMap { DialogHistory(json: $0.1) }
        count = json["response"]["count"].intValue
        unread = json["response"]["unread"].intValue
        inRead = json["response"]["in_read"].intValue
        outRead = json["response"]["out_read"].intValue
    }
}
