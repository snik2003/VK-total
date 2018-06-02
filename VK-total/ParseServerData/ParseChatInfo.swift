//
//  ParseChatInfo.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseChatInfo: Operation {
    
    var outputData: [ChatInfo] = []
    var chatUsers: [Friends] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let chat = ChatInfo(json: JSON.null)
        chat.id = json["response"]["id"].intValue
        chat.type = json["response"]["type"].stringValue
        chat.title = json["response"]["title"].stringValue
        chat.membersCount = json["response"]["members_count"].intValue
        chat.adminID = json["response"]["admin_id"].intValue
        chat.photo50 = json["response"]["photo_50"].stringValue
        chat.photo100 = json["response"]["photo_100"].stringValue
        chat.photo200 = json["response"]["photo_200"].stringValue
        
        let users = json["response"]["users"].compactMap { Friends(json: $0.1) }
        
        outputData.append(chat)
        chatUsers = users
    }
}
