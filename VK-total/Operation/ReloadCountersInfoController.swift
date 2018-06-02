//
//  ReloadCountersInfoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadCountersInfoController: Operation {
    var controller: CountersInfoTableViewController
    var dataType: String
    
    init(controller: CountersInfoTableViewController, type: String) {
        self.controller = controller
        self.dataType = type
    }
    
    override func main() {
        
        if dataType == "photosCount" {
            guard let parsePhotos = dependencies.first as? ParsePhotosList else { return }
            controller.photos = parsePhotos.outputData
        }
        
        if dataType == "friendsCount" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            controller.friends = parseFriends.outputData
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "searchFriendsCount" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            controller.searchFriends = parseFriends.outputData
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "searchMutualFriendsCount" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            controller.searchMutualFriends = parseFriends.outputData.filter({ $0.isFriend == 1 })
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "commonFriendsCount" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            controller.friends = parseFriends.outputData
            controller.mutualFriends = parseFriends.outputData.filter({ $0.isFriend == 1 })
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "followersCount" {
            guard let parseFollowers = dependencies.first as? ParseFollowersList else { return }
            controller.followers = parseFollowers.outputData
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "groupsCount" {
            guard let parseGroups = dependencies.first as? ParseGroupList else { return }
            controller.groups = parseGroups.outputData
            controller.tableView.separatorStyle = .singleLine
        }
        
        if dataType == "pagesCount" {
            guard let parsePages = dependencies.first as? ParseGroupList else { return }
            controller.pages = parsePages.outputData
            controller.tableView.separatorStyle = .singleLine
        }
        
        controller.tableView.reloadData()
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
