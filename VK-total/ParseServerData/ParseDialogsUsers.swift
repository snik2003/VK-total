//
//  ParseDialogsUsers.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseDialogsUsers: Operation {
    
    var outputData: [DialogsUsers] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
            
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
            
        let dialogsUsers: [DialogsUsers] = json["response"].compactMap { DialogsUsers(json: $0.1) }
        outputData = dialogsUsers
    }
}
