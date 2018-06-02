//
//  ReloadTopicController.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadTopicController: Operation {
    var controller: TopicController
    
    init(controller: TopicController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseComments = dependencies[0] as? ParseComments2, let parseTopics = dependencies[1] as? ParseTopics, let parseGroupProfile = dependencies[2] as? ParseGroupProfile else { return }
        
        if controller.offset == 0 {
            controller.comments = parseComments.comments
            controller.profiles = parseComments.profiles
            controller.groups = parseComments.groups
        } else {
            for comment in parseComments.comments {
                controller.comments.append(comment)
            }
            for profile in parseComments.profiles {
                controller.profiles.append(profile)
            }
            for group in parseComments.groups {
                controller.groups.append(group)
            }
        }
        
        controller.total = parseComments.count
        
        controller.topics = parseTopics.outputData
        controller.topicProfiles = parseTopics.profiles
        
        if controller.topics.count > 0 {
            controller.title = controller.topics[0].title
            if controller.topics[0].isClosed == 1 {
                controller.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44)
                controller.view.addSubview(controller.tableView)
                controller.commentView.removeFromSuperview()
            } else {
                controller.view.addSubview(controller.commentView)
            }
        }
        
        controller.group = parseGroupProfile.outputData
        if controller.group.count > 0 {
            if controller.group[0].isAdmin == 1 && controller.topics.count > 0{
                let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: controller, action: #selector(controller.tapBarButtonItem(sender:)))
                controller.navigationItem.rightBarButtonItem = barButton
            }
        }
        
        controller.offset += controller.count
        controller.tableView.separatorStyle = .none
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
