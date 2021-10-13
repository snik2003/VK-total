//
//  ParseDialogs.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseDialogs: Operation {
    
    var conversations: [Conversation] = []
    var outputData: [Message] = []
    var unread: Int = 0
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        conversations = json["response"]["items"].compactMap({ Conversation(json: $0.1["conversation"]) })
        let dialogs = json["response"]["items"].compactMap { Message(json: $0.1["last_message"], conversations: conversations) }
        unread = json["response"]["unread_dialogs"].intValue
        count = json["response"]["count"].intValue
        outputData = dialogs
    }
}
