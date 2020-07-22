//
//  ReloadDialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadDialogsController: Operation {
    var controller: DialogsController
    
    init(controller: DialogsController) {
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
                newGroup.photo100 = group.photo100
                controller.users.append(newGroup)
            }
        }
        
        controller.menuDialogs.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_all-dialogs")
        controller.users.saveInUserDefaults(KeyName: "\(vkSingleton.shared.userID)_dialogs-users")
        
        controller.totalCount = parseDialogs.count
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        controller.refreshControl?.endRefreshing()
        
        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(controller.tapBarButtonItem(sender:)))
        controller.navigationItem.rightBarButtonItem = barButton
        
        ViewControllerUtils().hideActivityIndicator()
    }
}

