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
    var users: [DialogsUsers] = []
    var unread: Int = 0
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        conversations = json["response"]["items"].compactMap({ Conversation(json: $0.1["conversation"]) })
        let dialogs = json["response"]["items"].compactMap { Message(json: $0.1["last_message"], conversations: conversations) }
    
        var users = json["response"]["profiles"].compactMap { DialogsUsers(json: $0.1) }
        let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
        for group in groups {
            let newGroup = DialogsUsers(json: JSON.null)
            newGroup.uid = "-\(group.gid)"
            newGroup.firstName = group.name
            newGroup.photo100 = group.photo100
            users.append(newGroup)
        }
        
        unread = json["response"]["unread_dialogs"].intValue
        count = json["response"]["count"].intValue
    
        self.users = users
        outputData = dialogs
    }
}
