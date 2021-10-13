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
    
    var conversation: Conversation?
    var outputData: [DialogHistory] = []
    var count: Int = 0
    var unread: Int = 0
    var inRead: Int = 0
    var outRead: Int = 0
    var canWrite: Bool = true
    var lastMessageId: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print("history = \(json)")
        
        conversation =  Conversation(json: json["response"]["conversations"][0])
        outputData = json["response"]["items"].compactMap { DialogHistory(json: $0.1, conversation: json["response"]["conversations"][0]) }
        count = json["response"]["count"].intValue
        unread = json["response"]["conversations"][0]["unread_count"].intValue
        inRead = json["response"]["conversations"][0]["in_read"].intValue
        outRead = json["response"]["conversations"][0]["out_read"].intValue
        canWrite = json["response"]["conversations"][0]["can_write"]["allowed"].boolValue
        lastMessageId = json["response"]["conversations"][0]["last_message_id"].intValue
    }
}
