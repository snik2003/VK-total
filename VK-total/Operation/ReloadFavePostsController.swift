//
//  ReloadFavePostsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 28.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadFavePostsController: Operation {
    var controller: FavePostsController2
    var type: String
    
    init(controller: FavePostsController2, type: String) {
        self.controller = controller
        self.type = type
    }
    
    override func main() {
        guard let parseFaves = dependencies.first as? ParseFaves else { return }
        
        controller.estimatedHeightCache.removeAll(keepingCapacity: false)
        if type == "post" {
            if controller.offset == 0 {
                controller.wall = parseFaves.wall
                controller.wallProfiles = parseFaves.profiles
                controller.wallGroups = parseFaves.groups
            } else {
                for new in parseFaves.wall {
                    controller.wall.append(new)
                }
                for profile in parseFaves.profiles {
                    controller.wallProfiles.append(profile)
                }
                for group in parseFaves.groups {
                    controller.wallGroups.append(group)
                }
            }
        } else if type == "photo" {
            if controller.offset == 0 {
                controller.photos = parseFaves.photos
            } else {
                for photo in parseFaves.photos {
                    controller.photos.append(photo)
                }
            }
        } else if type == "video" {
            
            controller.videos = parseFaves.videos
            controller.newsProfiles = parseFaves.profiles2
            controller.newsGroups = parseFaves.groups2
            controller.tableView.separatorStyle = .singleLine
            
        } else if type == "users" || type == "banned" {
            
            controller.faveUsers = parseFaves.users
            controller.tableView.separatorStyle = .singleLine
            
        } else if type == "groups" {
            
            controller.favePages = parseFaves.pages
            controller.tableView.separatorStyle = .singleLine
            
        } else if type == "links" {
            
            controller.faveLinks.removeAll(keepingCapacity: false)
            for link in parseFaves.links {
                if link.id.prefix(2) != "2_" {
                    controller.faveLinks.append(link)
                }
            }
            controller.tableView.separatorStyle = .singleLine
            
        }
        
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.menuView.isUserInteractionEnabled = true
        ViewControllerUtils().hideActivityIndicator()
    }
}
