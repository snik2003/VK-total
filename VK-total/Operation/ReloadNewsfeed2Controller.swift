//
//  ReloadNewsfeed2Controller.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadNewsfeed2Controller: Operation {
    var controller: Newsfeed2Controller
    
    init(controller: Newsfeed2Controller) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseNewsfeed = dependencies.first as? ParseNewsfeed else { return }
        
        if controller.startFrom == "" && controller.offset == 0 {
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
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
