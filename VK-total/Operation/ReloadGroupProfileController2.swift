//
//  ReloadGroupProfileController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupProfileController2: Operation {
    
    var controller: GroupProfileController2
    
    init(controller: GroupProfileController2) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroupWall = dependencies[0] as? ParseGroupWall, let parseGroupProfile = dependencies[1] as? ParseGroupProfile, let parsePostponed = dependencies[2] as? ParseGroupWall else { return }
        
        
        controller.postponedWall = parsePostponed.wall
        controller.postponedProfiles = parsePostponed.profiles
        controller.postponedGroups = parsePostponed.groups
        
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
        
        controller.setProfileView()
        controller.tableView.reloadData()
        controller.tableView.isHidden = false
        ViewControllerUtils().hideActivityIndicator()
    }
}

