//
//  ReloadNewsfeedSearchController.swift
//  VK-total
//
//  Created by Сергей Никитин on 08.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadNewsfeedSearchController: Operation {
    var controller: NewsfeedSearchController
    
    init(controller: NewsfeedSearchController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseUserWall = dependencies[0] as? ParseUserWall else { return }
        
        controller.wall = parseUserWall.wall
        controller.wallProfiles = parseUserWall.profiles
        controller.wallGroups = parseUserWall.groups
        
        controller.tableView.separatorStyle = .none
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
