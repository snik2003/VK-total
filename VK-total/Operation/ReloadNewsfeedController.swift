//
//  ReloadNewsfeedController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadNewsfeedController: Operation {
    var controller: NewsTableViewController
    
    init(controller: NewsTableViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseNewsfeed = dependencies.first as? ParseNewsfeed else { return }
        
        if controller.startFrom == "" {
            controller.news = parseNewsfeed.news
            controller.newsProfiles = parseNewsfeed.profiles
            controller.newsGroups = parseNewsfeed.groups
        } else {
            for new in parseNewsfeed.news {
                controller.news.append(new)
            }
            for profile in parseNewsfeed.profiles {
                controller.newsProfiles.append(profile)
            }
            for group in parseNewsfeed.groups {
                controller.newsGroups.append(group)
            }
        }
        controller.startFrom = parseNewsfeed.nextFrom
        controller.tableView.reloadData()
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
