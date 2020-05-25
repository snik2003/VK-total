//
//  ReloadGroupProfileController2.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadGroupProfileController2: Operation {
    
    var controller: GroupProfileController2
    
    init(controller: GroupProfileController2) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseGroupWall = dependencies[0] as? ParseGroupWall, let parseGroupProfile = dependencies[1] as? ParseGroupProfile, let parsePostponed = dependencies[2] as? ParseGroupWall else { return }
        
        
        controller.postponedWall = parsePostponed.wall
        controller.postponedProfiles = parsePostponed.profiles
        controller.postponedGroups = parsePostponed.groups
        
        if controller.offset == 0 {
            controller.wall = parseGroupWall.wall
            controller.profiles = parseGroupWall.profiles
            controller.groups = parseGroupWall.groups
        } else {
            for record in parseGroupWall.wall {
                controller.wall.append(record)
            }
            for profile in parseGroupWall.profiles {
                controller.profiles.append(profile)
            }
            for group in parseGroupWall.groups {
                controller.groups.append(group)
            }
        }
        
        controller.groupProfile = parseGroupProfile.outputData
        if controller.groupProfile.count > 0 && controller.offset == 0 {
            ViewControllerUtils().hideActivityIndicator()
            
            let group = controller.groupProfile[0]
            if group.name.length <= 20 {
                controller.title = group.name
            } else {
                controller.title = "\(group.name.prefix(20))..."
            }
            
            switch group.ageLimits {
            case 2:
                warning16PlusLimits()
            case 3:
                warning18PlusLimits()
            default:
                if group.name.contains("16+") || group.status.contains("16+") || group.description.contains("16+") {
                    warning16PlusLimits()
                } else if group.name.contains("18+") || group.status.contains("18+") || group.description.contains("18+") {
                    warning18PlusLimits()
                } else {
                    controller.offset += controller.count
                    controller.setProfileView()
                    controller.tableView.reloadData()
                    controller.tableView.isHidden = false
                    controller.refreshControl.endRefreshing()
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
        } else {
            controller.offset += controller.count
            controller.setProfileView()
            controller.tableView.reloadData()
            controller.tableView.isHidden = false
            controller.refreshControl.endRefreshing()
            ViewControllerUtils().hideActivityIndicator()
        }
    }
    
    func warning16PlusLimits() {
        let alertController = UIAlertController(title: "Внимание!", message: "Данное сообщество имеет возрастное ограничение 16+. Вы подтвержаете, что ваш возраст превышает 16 лет?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
            self.controller.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Да, мне уже есть 16 лет", style: .default) { action in
            self.controller.offset += self.controller.count
            self.controller.setProfileView()
            self.controller.tableView.reloadData()
            self.controller.tableView.isHidden = false
            ViewControllerUtils().hideActivityIndicator()
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
            if self.controller.wall.count > 0 {
                let groupID = self.controller.groupID
                let itemID = self.controller.wall[0].id
                if let navC = self.controller.navigationController {
                    self.controller.navigationController?.popViewController(animated: true)
                    navC.topViewController?.reportOnObject(ownerID: "-\(groupID)", itemID: "\(itemID)", type: "group")
                }
            } else {
                let title = "Жалоба на сообщество"
                let text = "Ваша жалоба на сообщество успешно отправлена."
                self.controller.showSuccessMessage(title: title, msg: text)
                self.controller.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(action2)
        
        controller.present(alertController, animated: true)
    }
    
    func warning18PlusLimits() {
        let alertController = UIAlertController(title: "Внимание!", message: "Данное сообщество имеет возрастное ограничение 18+. Вы подтвержаете, что ваш возраст превышает 18 лет?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
            self.controller.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Да, мне уже есть 18 лет", style: .default) { action in
            self.controller.offset += self.controller.count
            self.controller.setProfileView()
            self.controller.tableView.reloadData()
            self.controller.tableView.isHidden = false
            ViewControllerUtils().hideActivityIndicator()
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
            if self.controller.wall.count > 0 {
                let groupID = self.controller.groupID
                let itemID = self.controller.wall[0].id
                if let navC = self.controller.navigationController {
                    self.controller.navigationController?.popViewController(animated: true)
                    navC.topViewController?.reportOnObject(ownerID: "-\(groupID)", itemID: "\(itemID)", type: "group")
                }
            } else {
                let title = "Жалоба на сообщество"
                let text = "Ваша жалоба на сообщество успешно отправлена."
                self.controller.showSuccessMessage(title: title, msg: text)
                self.controller.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(action2)
        
        controller.present(alertController, animated: true)
    }
}

