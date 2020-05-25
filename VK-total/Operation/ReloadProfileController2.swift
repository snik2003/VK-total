//
//  ReloadProfileController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadProfileController2: Operation {
    var controller: ProfileController2
    
    init(controller: ProfileController2) {
        self.controller = controller
    }
    
    override func main() {
        guard let parsePhotos = dependencies[0] as? ParsePhotosList, let parseUserWall = dependencies[1] as? ParseUserWall, let parseUserProfile = dependencies[2] as? ParseUserProfile, let parsePostponed = dependencies[3] as? ParseUserWall else { return }
        
        
        controller.userProfile = parseUserProfile.outputData
        controller.photos = parsePhotos.outputData
        
        if controller.userProfile.count > 0 {
            let user = controller.userProfile[0]
            if user.blacklisted == 1 {
                //controller.showErrorMessage(title: "Предупреждение", msg: "\nВы находитесь в черном списке \(user.firstNameGen)\n")
            }
        }
        
        controller.postponedWall = parsePostponed.wall
        controller.postponedWallProfiles = parsePostponed.profiles
        controller.postponedWallGroups = parsePostponed.groups
        
        if controller.offset == 0 {
            controller.wall = parseUserWall.wall
            controller.wallProfiles = parseUserWall.profiles
            controller.wallGroups = parseUserWall.groups
        } else {
            for record in parseUserWall.wall {
                controller.wall.append(record)
            }
            for group in parseUserWall.groups {
                controller.wallGroups.append(group)
            }
            for profile in parseUserWall.profiles {
                controller.wallProfiles.append(profile)
            }
        }
        controller.offset += controller.count
        controller.setProfileView()
        print("save realm")
        controller.saveAccountToRealm()
        controller.tableView.reloadData()
        if controller.userProfile.count > 0 {
            let user = controller.userProfile[0]
            controller.title = "\(user.firstName) \(user.lastName)"
        }
        controller.refreshControl.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}

