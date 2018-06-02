//
//  ReloadUsersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadUsersController: Operation {
    var controller: UsersController
    var type: String
    
    init(controller: UsersController, type: String) {
        self.controller = controller
        self.type = type
    }
    
    override func main() {
        if type == "friends" || type == "commonFriends" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            
            if type == "friends" {
                controller.friends = parseFriends.outputData
            } else {
                controller.friends = parseFriends.outputData.filter({ $0.isFriend == 1 })
            }
            
            controller.sortedFriends = controller.friends.sorted(by: { "\($0.lastName) \($0.firstName)" < "\($1.lastName) \($1.firstName) " })
            controller.users = controller.sortedFriends
            
            controller.segmentedControl.setTitle("Все друзья: \(controller.users.count)", forSegmentAt: 0)
            var onlineCount = 0
            for user in controller.users {
                if user.onlineStatus == 1 {
                    onlineCount += 1
                }
            }
            controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
        } else if type == "followers" {
            guard let parseFriends = dependencies.first as? ParseFriendList else { return }
            
            controller.friends = parseFriends.outputData
            controller.sortedFriends = controller.friends
            controller.users = controller.sortedFriends
            
            controller.segmentedControl.setTitle("Подписчики: \(controller.users.count)", forSegmentAt: 0)
            var onlineCount = 0
            for user in controller.users {
                if user.onlineStatus == 1 {
                    onlineCount += 1
                }
            }
            controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
        } else if type == "subscript" {
            guard let parseFriends = dependencies.first as? ParseRequestList else { return }
            
            controller.friends = parseFriends.outputData
            controller.sortedFriends = controller.friends
            controller.users = controller.sortedFriends
            
            controller.segmentedControl.setTitle("Подписки: \(controller.users.count)", forSegmentAt: 0)
            var onlineCount = 0
            for user in controller.users {
                if user.onlineStatus == 1 {
                    onlineCount += 1
                }
            }
            controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
        } else if type == "requests" {
            guard let parseFriends = dependencies.first as? ParseRequestList else { return }
            
            controller.friends = parseFriends.outputData
            controller.sortedFriends = controller.friends
            controller.users = controller.sortedFriends
            
            controller.segmentedControl.setTitle("Заявки: \(controller.users.count)", forSegmentAt: 0)
            var onlineCount = 0
            for user in controller.users {
                if user.onlineStatus == 1 {
                    onlineCount += 1
                }
            }
            controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
        }

        controller.tableView.separatorStyle = .singleLine
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
