//
//  ReloadGroupsListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 06.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupsListController: Operation {
    var controller: GroupsListController
    
    init(controller: GroupsListController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroups = dependencies.first as? ParseGroupList else { return }
        
        if vkSingleton.shared.age < 16 {
            controller.groups = parseGroups.outputData.filter({ $0.ageLimits < 2 && !$0.name.contains("16+") && !$0.desc.contains("16+") && !$0.status.contains("16+") && !$0.name.contains("18+") && !$0.desc.contains("18+") && !$0.status.contains("18+") })
            controller.groupsList = parseGroups.outputData.filter({ $0.ageLimits < 2 && !$0.name.contains("16+") && !$0.desc.contains("16+") && !$0.status.contains("16+") && !$0.name.contains("18+") && !$0.desc.contains("18+") && !$0.status.contains("18+") })
        } else if vkSingleton.shared.age < 18 {
            controller.groups = parseGroups.outputData.filter({ $0.ageLimits < 3 && !$0.name.contains("18+") && !$0.desc.contains("18+") && !$0.status.contains("18+") })
            controller.groupsList = parseGroups.outputData.filter({ $0.ageLimits < 3 && !$0.name.contains("18+") && !$0.desc.contains("18+") && !$0.status.contains("18+") })
        } else {
            controller.groups = parseGroups.outputData
            controller.groupsList = parseGroups.outputData
        }
        
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .singleLine
        ViewControllerUtils().hideActivityIndicator()
    }
}
