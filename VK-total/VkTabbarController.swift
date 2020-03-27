//
//  VkTabbarController.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class VkTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    
        var code = "var a = API.account.getCounters({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"filter\":\"friends,messages\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var b = API.notifications.get({\"count\":\"100\",\"start_time\":\"\(Date().timeIntervalSince1970 - 15552000)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.groups.getInvites({\"count\":\"100\",\"extended\":\"1\",\"fields\":\"id,first_name,last_name,photo_100,sex\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var d = API.groups.get({\"user_id\":\"\(vkSingleton.shared.userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"filter\":\"moder\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var stat = API.stats.trackVisitor({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var e1 = API.groups.isMember({\"group_id\":\"166099539\",\"user_id\":\"\(vkSingleton.shared.userID)\"});\n"
        
        code = "\(code) if (e1 != 1) { var e2 = API.groups.join({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_id\":\"166099539\",\"v\": \"\(vkSingleton.shared.version)\"}); return [a,b,c,d,stat,e1,e2]; } \n"
        
        code = "\(code) return [a,b,c,d,stat,e1];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let messages = json["response"][0]["messages"].intValue
            let friends = json["response"][0]["friends"].intValue
                
            OperationQueue.main.addOperation {
                if let item = self.tabBar.items?[0] {
                    if friends > 0 {
                        item.badgeValue = "\(friends)"
                    }
                }
                
                if let item = self.tabBar.items?[3] {
                    if messages > 0 {
                        item.badgeValue = "\(messages)"
                    }
                }
            }
            
            let notData = json["response"][1]["items"].compactMap { Notifications(json: $0.1) }
            
            var countNewNots = 0
            let lastViewed = json["response"][1]["last_viewed"].intValue
            for not in notData {
                if not.date > lastViewed {
                    countNewNots += not.feedback.count
                }
            }
            
            let groups = json["response"][2]["items"].compactMap { Groups(json: $0.1) }
            
            OperationQueue.main.addOperation {
                if let item = self.tabBar.items?[1] {
                    if countNewNots + groups.count > 0 {
                        item.badgeValue = "\(countNewNots + groups.count)"
                    } else {
                        item.badgeValue = nil
                    }
                }
            }
            
            let count = json["response"][3]["count"].intValue
            vkSingleton.shared.adminGroupID.removeAll(keepingCapacity: false)
            if count > 0 {
                for index in 0...count-1 {
                    let groupID = json["response"][3]["items"][index].intValue
                    vkSingleton.shared.adminGroupID.append(groupID)
                }
            }
            
            //self.launchAllGroupsLongPollServer()
        }
        OperationQueue().addOperation(getServerDataOperation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
