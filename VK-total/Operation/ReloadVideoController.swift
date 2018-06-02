//
//  ReloadVideoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadVideoController: Operation {
    var controller: VideoController
    
    init(controller: VideoController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseVideos = dependencies[0] as? ParseVideos, let parseLikes = dependencies[1] as? ParseLikes, let parseComments = dependencies[2] as? ParseComments, let parseReposts = dependencies[3] as? ParseLikes else { return }
        
        controller.video = parseVideos.outputData
        controller.users = parseVideos.profiles
        controller.groups = parseVideos.groups
        
        controller.likes = parseLikes.outputData
        controller.reposts = parseReposts.outputData
        
        controller.totalComments = parseComments.count
        if controller.offset == 0 {
            controller.comments = parseComments.comments
            controller.commentsGroups = parseComments.groups
            controller.commentsProfiles = parseComments.profiles
        } else {
            for comment in parseComments.comments {
                controller.comments.append(comment)
            }
            for profile in parseComments.profiles {
                controller.commentsProfiles.append(profile)
            }
            for group in parseComments.groups {
                controller.commentsGroups.append(group)
            }
        }
        
        if controller.video.count > 0 {
            if controller.video[0].canComment == 0 {
                controller.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44)
                controller.view.addSubview(controller.tableView)
                controller.commentView.removeFromSuperview()
            } else {
                controller.view.addSubview(controller.commentView)
            }
        }
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.delaysContentTouches = false
        controller.tableView.separatorStyle = .singleLine
        ViewControllerUtils().hideActivityIndicator()
    }
}
