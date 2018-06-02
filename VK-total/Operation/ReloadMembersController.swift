//
//  ReloadMembersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadMembersController: Operation {
    var controller: MembersController
    
    init(controller: MembersController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseFriends = dependencies[0] as? ParseFriendList else { return }
        
        if controller.offset == 0 {
            controller.members = parseFriends.outputData
        } else {
            for member in parseFriends.outputData {
                controller.members.append(member)
            }
        }
        controller.users = controller.members
        controller.total = parseFriends.count
        
        controller.offset += controller.count
        controller.tableView.separatorStyle = .singleLine
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
