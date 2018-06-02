//
//  ReloadTopicsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadTopicsController: Operation {
    var controller: TopicsController
    
    init(controller: TopicsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseTopics = dependencies[0] as? ParseTopics else { return }
        
        if controller.offset == 0 {
            controller.topics = parseTopics.outputData
            controller.profiles = parseTopics.profiles
        } else {
            for topic in parseTopics.outputData {
                controller.topics.append(topic)
            }
            for profile in parseTopics.profiles {
                controller.profiles.append(profile)
            }
        }
        
        controller.canAddTopics = parseTopics.canAddTopics
        controller.total = parseTopics.count
        
        controller.offset += controller.count
        controller.tableView.separatorStyle = .none
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
