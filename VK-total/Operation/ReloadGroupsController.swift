//
//  ReloadGroupsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupsController: Operation {
    var controller: GroupsController
    
    init(controller: GroupsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroups = dependencies.first as? ParseGroupList else { return }
        controller.groups = parseGroups.outputData
        
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .singleLine
        ViewControllerUtils().hideActivityIndicator()
    }
}
