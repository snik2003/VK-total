//
//  ReloadNotificationsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadNotificationsController: Operation {
    var controller: NotificationsController
    
    init(controller: NotificationsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseNotifications = dependencies[0] as? ParseNotifications, let parseGroupInvites = dependencies[1] as? ParseGroupInvites else { return }
        
        controller.notifications.removeAll(keepingCapacity: false)
        for invite in parseGroupInvites.outputData {
            let not = Notifications(json: JSON.null)
            not.type = "group_invite"
            not.countFeedback = 1
            not.feedback[0].fromID = invite.invitedBy
            not.feedback[0].id = Int(invite.gid)!
            not.feedback[0].text = invite.name
            not.feedback[0].type = invite.typeGroup
            not.date = Int(Date().timeIntervalSince1970)
            controller.notifications.append(not)
        }
        
        for not in parseNotifications.outputData {
            controller.notifications.append(not)
        }
        controller.groupInvites = parseGroupInvites.outputData
        
        controller.profiles = parseNotifications.outputProfiles
        for profile in parseGroupInvites.outputUsers {
            controller.profiles.append(profile)
        }

        controller.groups = parseNotifications.outputGroups
        controller.newNots = parseNotifications.countNewNots + controller.groupInvites.count
        
        if controller.newNots > 0 {
            controller.tabBarController?.tabBar.selectedItem?.badgeValue = "\(controller.newNots)"
        
            controller.readButton = UIButton()
            controller.readButton.setTitle("Пометить как просмотренные", for: .normal)
            controller.readButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
            controller.readButton.setTitleColor(UIColor.white, for: .normal)
        
            controller.readButton.layer.borderColor = UIColor.black.cgColor
            controller.readButton.layer.borderWidth = 0.6
            controller.readButton.layer.cornerRadius = 12
            controller.readButton.clipsToBounds = true
            controller.readButton.backgroundColor = vkSingleton.shared.mainColor
            controller.readButton.isEnabled = true
            controller.readButton.frame = CGRect(x: 20, y: 10, width: controller.tableView.frame.width - 40, height: 25)
            controller.readButton.addTarget(self, action: #selector(controller.readButtonClick(sender:)), for: .touchUpInside)
        
            let view = UIView()
            view.addSubview(controller.readButton)
            view.frame = CGRect(x: 0, y: 0, width: controller.tableView.frame.width, height: 45)
            controller.tableView.tableHeaderView = view
        } else {
            controller.tabBarController?.tabBar.selectedItem?.badgeValue = nil
            controller.tableView.tableHeaderView = nil
        }
    
        if controller.notifications.count > 0 {
            controller.tableView.separatorStyle = .singleLine
        } else {
            controller.tableView.separatorStyle = .none
        }
        
        controller.tableView.reloadData()
        controller.refreshControl?.endRefreshing()
        ViewControllerUtils().hideActivityIndicator()
    }
}
