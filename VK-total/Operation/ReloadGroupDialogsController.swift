//
//  ReloadGroupDialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadGroupDialogsController: Operation {
    var controller: GroupDialogsController
    
    init(controller: GroupDialogsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseDialogs = dependencies[0] as? ParseDialogs, let parseDialogsUsers = dependencies[1] as? ParseDialogsUsers, let parseDialogsGroups = dependencies[2] as? ParseGroupProfile else { return }
        
        if parseDialogsUsers.outputData.count > 0 {
            for user in parseDialogsUsers.outputData {
                controller.users.append(user)
            }
        }
        
        if parseDialogsGroups.outputData.count > 0 {
            for group in parseDialogsGroups.outputData {
                let newGroup = DialogsUsers(json: JSON.null)
                newGroup.uid = "-\(group.gid)"
                newGroup.firstName = group.name
                newGroup.maxPhotoOrigURL = group.photo200
                controller.users.append(newGroup)
            }
        }
        
        for dialog in parseDialogs.outputData {
            controller.dialogs.append(dialog)
        }
        
        /*if let item = controller.tabBarController?.tabBar.items?[3] {
            if parseDialogs.unread > 0 {
                item.badgeValue = "\(parseDialogs.unread)"
            } else {
                item.badgeValue = nil
            }
        }*/
        
        controller.totalCount = parseDialogs.count
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
