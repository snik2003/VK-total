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
        
        controller.viewCount += parseNewsfeed.news.count
        
        if controller.startFrom == "" && controller.offset == 0 {
            controller.news = parseNewsfeed.news
            controller.newsProfiles = parseNewsfeed.profiles
            controller.newsGroups = parseNewsfeed.groups
        } else {
            if controller.news.count > controller.leftCellCount {
                controller.news = Array(controller.news.dropFirst(controller.news.count - controller.leftCellCount))
                controller.tableView.reloadData()
                controller.tableView.scrollToRow(at: IndexPath(row: 0, section: controller.leftCellCount - 1), at: .bottom, animated: false)
            }
            
            controller.news.append(contentsOf: parseNewsfeed.news)
            controller.newsProfiles.append(contentsOf: parseNewsfeed.profiles)
            controller.newsGroups.append(contentsOf: parseNewsfeed.groups)
        }
        
        if parseNewsfeed.news.count == 0 {
            controller.tableView.tableFooterView = nil
        }
        controller.startFrom = parseNewsfeed.nextFrom
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.isScrollEnabled = true
        controller.refreshControl?.endRefreshing()
        controller.spinner.startAnimating()
        controller.menuView.isUserInteractionEnabled = true
        ViewControllerUtils().hideActivityIndicator()
    }
}
