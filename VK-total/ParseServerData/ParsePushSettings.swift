//
//  ParsePushSettings.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParsePushSettings: Operation {
    
    var settings = PushSettings(json: JSON.null)
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        
        print(json)
        vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
        vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
        
        if vkSingleton.shared.errorCode == 0 {
            settings.disabled = json["response"]["disabled"].intValue
            
            for index in 0...2 {
                settings.like[index] = json["response"]["settings"]["like"][index].stringValue
                settings.comment[index] = json["response"]["settings"]["comment"][index].stringValue
                settings.groupInvite[index] = json["response"]["settings"]["group_invite"][index].stringValue
                settings.repost[index]  = json["response"]["settings"]["repost"][index].stringValue
                settings.mention[index]  = json["response"]["settings"]["mention"][index].stringValue
                settings.newPost[index]  = json["response"]["settings"]["new_post"][index].stringValue
                settings.gift[index]  = json["response"]["settings"]["gift"][index].stringValue
                settings.msg[index]  = json["response"]["settings"]["msg"][index].stringValue
                settings.groupAccepted[index]  = json["response"]["settings"]["group_accepted"][index].stringValue
                settings.live[index]  = json["response"]["settings"]["live"][index].stringValue
                settings.friendAccepted[index]  = json["response"]["settings"]["friend_accepted"][index].stringValue
                settings.wallPost[index]  = json["response"]["settings"]["wall_post"][index].stringValue
                settings.friend[index]  = json["response"]["settings"]["friend"][index].stringValue
                settings.wallPublish[index]  = json["response"]["settings"]["wall_publish"][index].stringValue
                settings.reply[index]  = json["response"]["settings"]["reply"][index].stringValue
            }
        }
    }
}
