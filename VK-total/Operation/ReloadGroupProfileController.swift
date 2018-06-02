//
//  ReloadGroupProfileController.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupProfileController: Operation {
    
    var controller: GroupProfileController
    
    init(controller: GroupProfileController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroupWall = dependencies[0] as? ParseGroupWall, let parseGroupProfile = dependencies[1] as? ParseGroupProfile else { return }
        
        if controller.offset == 0 {
            controller.wall = parseGroupWall.wall
            controller.profiles = parseGroupWall.profiles
            controller.groups = parseGroupWall.groups
        } else {
            for record in parseGroupWall.wall {
                controller.wall.append(record)
            }
            for profile in parseGroupWall.profiles {
                controller.profiles.append(profile)
            }
            for group in parseGroupWall.groups {
                controller.groups.append(group)
            }
        }
        controller.groupProfile = parseGroupProfile.outputData
        controller.offset += controller.count
        
        if controller.groupProfile.count > 0 {
            let group = controller.groupProfile[0]
            if group.name.length <= 20 {
                controller.title = group.name
            } else {
                controller.title = "\(group.name.prefix(20))..."
            }
        }
        
        controller.tableView.reloadData()
        controller.tableView.isHidden = false
        ViewControllerUtils().hideActivityIndicator()
    }
}
