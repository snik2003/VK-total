//
//  ReloadDialogController.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadDialogController: Operation {
    var controller: DialogController
    
    init(controller: DialogController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseDialog = dependencies[0] as? ParseDialogHistory, let parseDialogsUsers = dependencies[1] as? ParseDialogsUsers, let parseDialogsGroups = dependencies[2] as? ParseGroupProfile else { return }
        
        controller.users = parseDialogsUsers.outputData
        if parseDialogsGroups.outputData.count > 0 {
            for group in parseDialogsGroups.outputData {
                let newGroup = DialogsUsers(json: JSON.null)
                newGroup.uid = "-\(group.gid)"
                newGroup.firstName = group.name
                newGroup.maxPhotoOrigURL = group.photo200
                if group.type == "group" {
                    if group.isClosed == 0 {
                        newGroup.firstNameAbl = "Открытая группа"
                    } else if group.isClosed == 1 {
                        newGroup.firstNameAbl = "Закрытая группа"
                    } else {
                        newGroup.firstNameAbl = "Частная группа"
                    }
                } else if group.type == "page" {
                    newGroup.firstNameAbl = "Публичная страница"
                } else {
                    newGroup.firstNameAbl = "Мероприятие"
                }
                controller.users.append(newGroup)
            }
        }
        for dialog in parseDialog.outputData.reversed() {
            controller.dialogs.append(dialog)
        }
        controller.totalCount = parseDialog.count
        
        if controller.chatID == "" {
            let users = controller.users.filter({ $0.uid == controller.userID })
            if users.count > 0 {
                let titleItem = UIBarButtonItem(customView: controller.setTitleView(user: users[0], status: ""))
                controller.navigationItem.rightBarButtonItem = titleItem
                controller.title = ""
            }
        }
        
        controller.offset += controller.count
        controller.collectionView.reloadData()
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        if controller.tableView.numberOfSections > 1 {
            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
        }
        if parseDialog.unread > 0 {
            controller.markAsReadMessages(controller: controller)
        }
        ViewControllerUtils().hideActivityIndicator()
    }
}

class ReloadDialogController2: Operation {
    var controller: DialogController
    var startID: Int
    
    init(controller: DialogController, startID: Int) {
        self.controller = controller
        self.startID = startID
    }
    
    override func main() {
        guard let parseDialog = dependencies[0] as? ParseDialogHistory, let parseDialogsUsers = dependencies[1] as? ParseDialogsUsers, let parseDialogsGroups = dependencies[2] as? ParseGroupProfile else { return }
        
        if parseDialogsUsers.outputData.count > 0 {
            for user in parseDialogsUsers.outputData {
                controller.users.append(user)
            }
        }
        
        if parseDialogsGroups.outputData.count > 0 {
            for group in parseDialogsGroups.outputData {
                let newGroup = DialogsUsers(json: JSON.null)
                newGroup.uid = "-\(group.gid)"
                newGroup.firstName = group.name
                newGroup.maxPhotoOrigURL = group.photo200
                if group.type == "group" {
                    if group.isClosed == 0 {
                        newGroup.firstNameAbl = "Открытая группа"
                    } else if group.isClosed == 1 {
                        newGroup.firstNameAbl = "Закрытая группа"
                    } else {
                        newGroup.firstNameAbl = "Частная группа"
                    }
                } else if group.type == "page" {
                    newGroup.firstNameAbl = "Публичная страница"
                } else {
                    newGroup.firstNameAbl = "Мероприятие"
                }
                controller.users.append(newGroup)
            }
        }
        
        var newCount = controller.dialogs.count
        for dialog in parseDialog.outputData {
            if dialog.id < startID {
                controller.dialogs.insert(dialog, at: 0)
            }
        }
        newCount = controller.dialogs.count - newCount
        controller.totalCount = parseDialog.count
        
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        if controller.tableView.numberOfSections > 0 {
            controller.tableView.scrollToRow(at: IndexPath(row: newCount+1, section: 1), at: .bottom, animated: false)
        }
        ViewControllerUtils().hideActivityIndicator()
    }
}
