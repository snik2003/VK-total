//
//  vkUserLongPollProtocol.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import AVFoundation
import SWRevealViewController

protocol vkUserLongPollProtocol {
    func getLongPollServer()
    func longPoll()
    func handleUpdates()
}

extension UIViewController: vkUserLongPollProtocol {
    
    func getLongPollServer() {
        if vkUserLongPoll.shared.firstLaunch {
            vkUserLongPoll.shared.firstLaunch = false
            
            let url = "/method/messages.getLongPollServer"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "need_pts": "1",
                "lp_version": vkSingleton.shared.lpVersion,
                "v": vkSingleton.shared.version
                ]
        
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                vkUserLongPoll.shared.server = json["response"]["server"].stringValue
                vkUserLongPoll.shared.key = json["response"]["key"].stringValue
                vkUserLongPoll.shared.pts = json["response"]["pts"].stringValue
                vkUserLongPoll.shared.ts = json["response"]["ts"].stringValue
                
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    self.longPoll()
                }  else {
                    print("Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func longPoll() {
        autoreleasepool {
            let url = "https://\(vkUserLongPoll.shared.server)"
            let parameters = [
                "act": "a_check",
                "key": vkUserLongPoll.shared.key,
                "ts": vkUserLongPoll.shared.ts,
                "wait": "25",
                "mode": "2",
                "version": vkSingleton.shared.lpVersion
            ]
            
            vkUserLongPoll.shared.request = GetLongPollServerRequest(url: url, parameters: parameters)
            vkUserLongPoll.shared.request.completionBlock = {
                guard let data = vkUserLongPoll.shared.request.data else { return }
                
                guard let json = try? JSON(data: data) else {
                    vkUserLongPoll.shared.request.cancel()
                    vkUserLongPoll.shared.firstLaunch = true
                    if let viewControllers = self.tabBarController?.viewControllers {
                        for vc1 in viewControllers {
                            if let vcs = (vc1 as? UINavigationController)?.viewControllers {
                                for vc in vcs {
                                    if let controller = vc as? ProfileController2 {
                                        controller.getLongPollServer()
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                
                let failed = json["failed"].intValue
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    if failed == 0 || failed == 1 {
                        vkUserLongPoll.shared.ts = json["ts"].stringValue
                        vkUserLongPoll.shared.updates = json["updates"].compactMap { Updates(json: $0.1) }
                        
                        print(json)
                        self.handleUpdates()
                        self.longPoll()
                    } else if failed == 2 && failed == 3 {
                        vkUserLongPoll.shared.request.cancel()
                        vkUserLongPoll.shared.firstLaunch = true
                        if let viewControllers = self.tabBarController?.viewControllers {
                            for vc1 in viewControllers {
                                if let vcs = (vc1 as? UINavigationController)?.viewControllers {
                                    for vc in vcs {
                                        if let controller = vc as? ProfileController2 {
                                            controller.getLongPollServer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("#\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                    vkUserLongPoll.shared.request.cancel()
                    vkUserLongPoll.shared.firstLaunch = true
                    if let viewControllers = self.tabBarController?.viewControllers {
                        for vc1 in viewControllers {
                            if let vcs = (vc1 as? UINavigationController)?.viewControllers {
                                for vc in vcs {
                                    if let controller = vc as? ProfileController2 {
                                        controller.getLongPollServer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            OperationQueue().addOperation(vkUserLongPoll.shared.request)
        }
    }
    
    func handleUpdates() {
        
        for update in vkUserLongPoll.shared.updates {
            
            if update.elements[0] == 4 {
                let flags = update.elements[2]
                var summands: [Int] = []
                for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                    if flags & number != 0 {
                        summands.append(number)
                    }
                }
                
                var text = update.text.prepareTextForPublic()
                if text.length > 100 {
                    text = "\(text.prefix(100))..."
                }
                
                if update.type != "" {
                    if text != "" {
                        text = "\(text)\n"
                    }
                    
                    if update.type == "photo" {
                        text = "\(text)[Фотография]"
                    } else if update.type == "video" {
                        text = "\(text)[Видеозапись]"
                    } else if update.type == "sticker" {
                        text = "\(text)[Стикер]"
                    } else if update.type == "wall" {
                        text = "\(text)[Запись на стене]"
                    } else if update.type == "gift" {
                        text = "\(text)[Подарок]"
                    } else if update.type == "doc" {
                        text = "\(text)[Документ]"
                    }
                }
                
                var userID = update.elements[3]
                if update.fromID != 0 {
                    userID = update.fromID
                }
                
                var chatID = 0
                if update.elements[3] > 2000000000 {
                    chatID = update.elements[3] - 2000000000
                }
                
                if !summands.contains(2) && update.action == "" {
                    OperationQueue.main.addOperation {
                        self.showMessageNotification(title: "Новое сообщение", text: text, userID: userID, chatID: chatID, groupID: 0, startID: update.elements[1])
                    }
                }
            }
            
            if update.elements[0] == 80 {
                OperationQueue.main.addOperation {
                    guard let items = self.tabBarController?.tabBar.items else { return }
                    for item in items {
                        if let title = item.title, title == "Сообщения" {
                            if update.elements[1] > 0 {
                                item.badgeValue = "\(update.elements[1])"
                            } else {
                                item.badgeValue = nil
                            }
                        }
                    }
                }
            }
        }
        
        if let viewControllers = self.tabBarController?.viewControllers {
            for vc1 in viewControllers {
                if let vcs = (vc1 as? UINavigationController)?.viewControllers {
                    for vc in vcs {
                        if let controller = vc as? DialogController, controller.mode == .dialog {
                            var typing = false
                            
                            var delMess = false
                            var delMessIDs = ""
                            var delIDs: [Int] = []
                            var delCount = 0
                            
                            var spamMess = false
                            var spamMessIDs = ""
                            var spamIDs: [Int] = []
                            var spamCount = 0
                            
                            for update in vkUserLongPoll.shared.updates {
                                if update.elements[0] == 8 {
                                    if controller.userID == "\(abs(update.elements[1]))" {
                                        for user in controller.users {
                                            if controller.userID == user.uid {
                                                user.online = 1
                                                let platform = update.elements[2] % 256
                                                if platform > 0 && platform != 7 {
                                                    user.onlineMobile = 1
                                                }
                                                
                                                OperationQueue.main.addOperation {
                                                    if controller.chatID == "" {
                                                        controller.setStatusLabel(user: user, status: "")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 9 {
                                    if controller.userID == "\(abs(update.elements[1]))" {
                                        for user in controller.users {
                                            if controller.userID == user.uid {
                                                user.online = 0
                                                user.lastSeen = update.elements[3]
                                                
                                                OperationQueue.main.addOperation {
                                                    if controller.chatID == "" {
                                                        controller.setStatusLabel(user: user, status: "")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 4 {
                                    if controller.userID == "\(update.elements[3])" {
                                        let mess = DialogHistory(json: JSON.null)
                                        
                                        if controller.chatID == "" {
                                            mess.id = update.elements[1]
                                            mess.userID = update.elements[3]
                                            mess.body = update.text
                                            mess.date = update.elements[4]
                                            mess.emoji = update.emoji
                                            mess.title = update.title
                                        } else {
                                            mess.id = update.elements[1]
                                            mess.userID = update.fromID
                                            mess.action = update.action
                                            mess.actionID = update.actionID
                                            mess.body = update.text
                                            mess.date = update.elements[4]
                                            mess.emoji = update.emoji
                                            mess.title = update.title
                                            
                                            OperationQueue.main.addOperation {
                                                if update.action == "chat_invite_user" || update.action == "chat_invite_user_by_link" {
                                                    if controller.chat.count > 0 {
                                                        controller.chat[0].membersCount += 1
                                                        controller.statusLabel.text = "групповой чат (\(controller.chat[0].membersCount.membersAdder()))"
                                                    }
                                                }
                                            
                                                if update.action == "chat_kick_user" {
                                                    if controller.chat.count > 0 {
                                                        controller.chat[0].membersCount -= 1
                                                        controller.statusLabel.text = "групповой чат (\(controller.chat[0].membersCount.membersAdder()))"
                                                    }
                                                }
                                            }
                                        }
                                        
                                        let flags = update.elements[2]
                                        var summands: [Int] = []
                                        for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                                            if flags & number != 0 {
                                                summands.append(number)
                                            }
                                        }
                                        
                                        if summands.contains(1) {
                                            mess.readState = 0
                                        } else {
                                            mess.readState = 1
                                        }
                                        
                                        if summands.contains(2) {
                                            mess.out = 1
                                            mess.fromID = Int(vkSingleton.shared.userID)!
                                        } else {
                                            mess.out = 0
                                            mess.fromID = mess.userID
                                        }
                                        
                                        if update.type == "" && update.fwdCount == 0 && controller.chatID == "" {
                                            OperationQueue.main.addOperation {
                                                controller.dialogs.append(mess)
                                                controller.totalCount += 1
                                                controller.tableView.reloadData()
                                                if controller.tableView.numberOfSections > 0 {
                                                    controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                                                }
                                                AudioServicesPlaySystemSound(1003)
                                                self.markAsReadMessages(controller: controller)
                                            }
                                        } else {
                                            OperationQueue.main.addOperation {
                                                controller.startMessageID = update.elements[1]
                                                controller.getDialog()
                                                AudioServicesPlaySystemSound(1003)
                                            }
                                        }
                                        
                                    }
                                } else if update.elements[0] == 5 {
                                    if controller.userID == "\(update.elements[3])" {
                                        controller.startMessageID = -1
                                        if let id = controller.dialogs.last?.id {
                                            controller.startMessageID = id
                                        }
                                        OperationQueue.main.addOperation {
                                            controller.getDialog()
                                            self.showMessageNotification(title: "", text: update.text, userID: update.elements[3], chatID: 0, groupID: 0, startID: -1)
                                            AudioServicesPlaySystemSound(1003)
                                        }
                                    }
                                } else if update.elements[0] == 6 {
                                    if controller.userID == "\(update.elements[1])" {
                                        
                                        OperationQueue.main.addOperation {
                                            for dialog in controller.dialogs {
                                                if dialog.id <= update.elements[2] && dialog.out == 0 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            
                                            controller.tableView.reloadData()
                                            if controller.tableView.numberOfSections > 0 {
                                                controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 7 {
                                    if controller.userID == "\(update.elements[1])" {
                                        
                                        OperationQueue.main.addOperation {
                                            for dialog in controller.dialogs {
                                                if dialog.id <= update.elements[2] && dialog.out == 1 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            
                                            controller.tableView.reloadData()
                                            if controller.tableView.numberOfSections > 0 {
                                                controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 2 {
                                    if controller.userID == "\(update.elements[3])" {
                                        let flags = update.elements[2]
                                        var summands: [Int] = []
                                        for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536, 131072] {
                                            if flags & number != 0 {
                                                summands.append(number)
                                            }
                                        }
                                        
                                        for dialog in controller.dialogs {
                                            if dialog.id == update.elements[1] {
                                                if summands.contains(131072) || summands.contains(128) {
                                                    if !delIDs.contains(dialog.id) {
                                                        delMess = true
                                                        delIDs.append(dialog.id)
                                                        delCount += 1
                                                        if delMessIDs != "" {
                                                            delMessIDs = "\(delMessIDs), "
                                                        }
                                                        delMessIDs = "\(delMessIDs)#\(dialog.id)"
                                                    }
                                                    controller.dialogs.remove(object: dialog)
                                                }
                                                
                                                if summands.contains(64) {
                                                    if !spamIDs.contains(dialog.id) {
                                                        spamMess = true
                                                        spamIDs.append(dialog.id)
                                                        spamCount += 1
                                                        if spamMessIDs != "" {
                                                            spamMessIDs = "\(spamMessIDs), "
                                                        }
                                                        spamMessIDs = "\(spamMessIDs)#\(dialog.id)"
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                } else if update.elements[0] == 61 {
                                    if controller.userID == "\(update.elements[1])" {
                                        typing = true
                                        let user = controller.users.filter({ $0.uid == controller.userID })
                                        if user.count > 0 {
                                            OperationQueue.main.addOperation {
                                                if controller.chatID == "" {
                                                    controller.setStatusLabel(user: user[0], status: "набирает сообщение...")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if typing == false {
                                let user = controller.users.filter({ $0.uid == controller.userID })
                                if user.count > 0 {
                                    OperationQueue.main.addOperation {
                                        if controller.chatID == "" {
                                            controller.setStatusLabel(user: user[0], status: "")
                                        }
                                    }
                                }
                            }
                            
                            if delMess {
                                var mess = "\(delCount.messageAdder()) успешно удалено из диалога"
                                if delCount > 1 {
                                    mess = "\(delCount.messageAdder()) успешно удалены из диалога"
                                }
                                
                                var userID = Int(controller.userID)!
                                if userID > 2000000000 {
                                    userID = Int(vkSingleton.shared.userID)!
                                }
                                
                                OperationQueue.main.addOperation {
                                    controller.estimatedHeightCache.removeAll(keepingCapacity: false)
                                    controller.tableView.reloadData()
                                    if controller.tableView.numberOfSections > 0 {
                                        controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                                    }
                                    self.showMessageNotification(title: "", text: mess, userID: userID, chatID: 0, groupID: 0, startID: -1)
                                    AudioServicesPlaySystemSound(1003)
                                }
                            }
                            
                            if spamMess {
                                var mess = "\(spamCount.messageAdder()) успешно помечено как спам"
                                if delCount > 1 {
                                    mess = "\(spamCount.messageAdder()) успешно помечены как спам"
                                }
                                
                                var userID = Int(controller.userID)!
                                if userID > 2000000000 {
                                    userID = Int(vkSingleton.shared.userID)!
                                }
                                
                                OperationQueue.main.addOperation {
                                    self.showMessageNotification(title: "", text: mess, userID: userID, chatID: 0, groupID: 0, startID: -1)
                                    AudioServicesPlaySystemSound(1003)
                                }
                            }
                        }
                        
                        if let controller = vc as? DialogsController, controller.users.count > 0 {
                            var typing = false
                            var change = false
                            
                            for update in vkUserLongPoll.shared.updates {
                                if update.elements[0] == 8 {
                                    for dialog in controller.dialogs {
                                        if dialog.userID == abs(update.elements[1]) {
                                            for user in controller.users {
                                                if "\(dialog.userID)" == user.uid {
                                                    user.online = 1
                                                    let platform = update.elements[2] % 256
                                                    if platform > 0 && platform != 7 {
                                                        user.onlineMobile = 1
                                                    }
                                                    change = true
                                                }
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 9 {
                                    for dialog in controller.dialogs {
                                        if dialog.userID == abs(update.elements[1]) {
                                            for user in controller.users {
                                                if "\(dialog.userID)" == user.uid {
                                                    user.online = 0
                                                    user.lastSeen = update.elements[3]
                                                    change = true
                                                }
                                            }
                                        }
                                    }
                                } else if update.elements[0] == 2 {
                                    var updateID = update.elements[3]
                                    if update.elements[3] > 2000000000 {
                                        updateID = update.elements[3] - 2000000000
                                    }
                                    
                                    let flags = update.elements[2]
                                    var summands: [Int] = []
                                    for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536, 131072] {
                                        if flags & number != 0 {
                                            summands.append(number)
                                        }
                                    }
                                    
                                    for dialog in controller.dialogs {
                                        if dialog.userID == updateID || dialog.chatID == updateID {
                                            if summands.contains(128) || summands.contains(131072) {
                                                if dialog.id == update.elements[1] {
                                                    dialog.body = "Сообщение удалено..."
                                                    change = true
                                                }
                                            }
                                        }
                                    }
                                    
                                } else if update.elements[0] == 4 {
                                    if controller.dialogs.count > 0 {
                                        var find = false
                                        var changeIndex = 0
                                        
                                        var updateID = update.elements[3]
                                        if update.elements[3] > 2000000000 {
                                            updateID = update.elements[3] - 2000000000
                                        }
                                        
                                        for index in 0...controller.dialogs.count-1 {
                                            if (controller.dialogs[index].userID == updateID && controller.dialogs[index].chatID == 0) || controller.dialogs[index].chatID == updateID {
                                                
                                                find = true
                                                controller.dialogs[index].id = update.elements[1]
                                                controller.dialogs[index].body = update.text
                                                controller.dialogs[index].date = update.elements[4]
                                                controller.dialogs[index].emoji = update.emoji
                                                controller.dialogs[index].fromID = update.fromID
                                                controller.dialogs[index].action = update.action
                                                controller.dialogs[index].actionID = update.actionID
                                                
                                                let flags = update.elements[2]
                                                var summands: [Int] = []
                                                for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                                                    if flags & number != 0 {
                                                        summands.append(number)
                                                    }
                                                }
                                                
                                                if summands.contains(1) {
                                                    controller.dialogs[index].readState = 0
                                                } else {
                                                    controller.dialogs[index].readState = 1
                                                }
                                                
                                                controller.dialogs[index].typeAttach = update.type
                                                
                                                if controller.dialogs[index].chatID == 0 {
                                                    if summands.contains(2) {
                                                        controller.dialogs[index].out = 1
                                                        controller.dialogs[index].fromID = Int(vkSingleton.shared.userID)!
                                                    } else {
                                                        controller.dialogs[index].out = 0
                                                        controller.dialogs[index].fromID = update.elements[3]
                                                    }
                                                } else {
                                                    controller.dialogs[index].fromID = update.fromID
                                                    if summands.contains(2) {
                                                        controller.dialogs[index].out = 1
                                                    } else {
                                                        controller.dialogs[index].out = 0
                                                    }
                                                }
                                                
                                                change = true
                                                changeIndex = index
                                            }
                                        }
                                        
                                        if find == false {
                                            let mess = Message(json: JSON.null)
                                            mess.id = update.elements[1]
                                            if update.elements[3] > 2000000000 {
                                                mess.chatID = update.elements[3] - 2000000000
                                                mess.userID = update.fromID
                                            } else {
                                                mess.chatID = 0
                                                mess.userID = update.elements[3]
                                            }
                                            mess.userID = update.elements[3]
                                            mess.body = update.text
                                            mess.date = update.elements[4]
                                            mess.emoji = update.emoji
                                            mess.title = update.title
                                            mess.fromID = update.fromID
                                            mess.action = update.action
                                            mess.actionID = update.actionID
                                            
                                            let flags = update.elements[2]
                                            var summands: [Int] = []
                                            for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                                                if flags & number != 0 {
                                                    summands.append(number)
                                                }
                                            }
                                            
                                            if summands.contains(1) {
                                                mess.readState = 0
                                            } else {
                                                mess.readState = 1
                                            }
                                            
                                            if mess.chatID == 0 {
                                                if summands.contains(2) {
                                                    mess.out = 1
                                                    mess.fromID = Int(vkSingleton.shared.userID)!
                                                } else {
                                                    mess.out = 0
                                                    mess.fromID = update.elements[3]
                                                }
                                            } else {
                                                mess.fromID = update.fromID
                                                if summands.contains(2) {
                                                    mess.out = 1
                                                } else {
                                                    mess.out = 0
                                                }
                                            }
                                            
                                            controller.dialogs.insert(mess, at: 0)
                                            change = true
                                        } else {
                                            if changeIndex > 0 {
                                                controller.dialogs.rearrange(from: changeIndex, to: 0)
                                            }
                                        }
                                    } else {
                                        let mess = Message(json: JSON.null)
                                        mess.id = update.elements[1]
                                        if update.elements[3] > 2000000000 {
                                            mess.chatID = update.elements[3] - 2000000000
                                            mess.userID = update.fromID
                                        } else {
                                            mess.chatID = 0
                                            mess.userID = update.elements[3]
                                        }
                                        mess.userID = update.elements[3]
                                        mess.body = update.text
                                        mess.date = update.elements[4]
                                        mess.emoji = update.emoji
                                        mess.title = update.title
                                        mess.fromID = update.fromID
                                        mess.action = update.action
                                        mess.actionID = update.actionID
                                        
                                        let flags = update.elements[2]
                                        var summands: [Int] = []
                                        for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                                            if flags & number != 0 {
                                                summands.append(number)
                                            }
                                        }
                                        
                                        if summands.contains(1) {
                                            mess.readState = 0
                                        } else {
                                            mess.readState = 1
                                        }
                                        
                                        if mess.chatID == 0 {
                                            if summands.contains(2) {
                                                mess.out = 1
                                                mess.fromID = Int(vkSingleton.shared.userID)!
                                            } else {
                                                mess.out = 0
                                                mess.fromID = update.elements[3]
                                            }
                                        } else {
                                            mess.fromID = update.fromID
                                            if summands.contains(2) {
                                                mess.out = 1
                                            } else {
                                                mess.out = 0
                                            }
                                        }
                                        
                                        controller.dialogs.append(mess)
                                        change = true
                                    }
                                } else if update.elements[0] == 6 {
                                    var updateID = update.elements[1]
                                    if update.elements[1] > 2000000000 {
                                        updateID = update.elements[1] - 2000000000
                                    }
                                    
                                    for dialog in controller.dialogs {
                                        if dialog.userID == updateID || dialog.chatID == updateID {
                                            for dialog in controller.dialogs {
                                                if dialog.id == update.elements[2] && dialog.out == 0 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            change = true
                                        }
                                    }
                                } else if update.elements[0] == 7 {
                                    var updateID = update.elements[1]
                                    if update.elements[1] > 2000000000 {
                                        updateID = update.elements[1] - 2000000000
                                    }
                                    
                                    for dialog in controller.dialogs {
                                        if dialog.userID == updateID || dialog.chatID == updateID {
                                            for dialog in controller.dialogs {
                                                if dialog.id == update.elements[2] && dialog.out == 1 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            
                                            change = true
                                        }
                                    }
                                } else if update.elements[0] == 61 {
                                    for dialog in controller.dialogs {
                                        if dialog.userID == update.elements[1] {
                                    
                                            typing = true
                                        }
                                    }
                                }
                            }
                            
                            if typing == false {
                                
                            }
                            
                            if change {
                                OperationQueue.main.addOperation {
                                    controller.tableView.reloadData()
                                }
                            }
                        }
                        
                        if let controller = vc as? UsersController {
                            for update in vkUserLongPoll.shared.updates {
                                for user in controller.users {
                                    if user.uid == "\(abs(update.elements[1]))" {
                                        if update.elements[0] == 8 {
                                            user.onlineStatus = 1
                                            let platform = update.elements[2] % 256
                                            if platform > 0 && platform != 7 {
                                                user.onlineMobile = 1
                                            }
                                        } else if update.elements[0] == 9 {
                                            user.onlineStatus = 0
                                            user.lastSeen = update.elements[3]
                                        }
                                    }
                                }
                            }
                            
                            var onlineCount = 0
                            for user in controller.users {
                                if user.onlineStatus == 1 {
                                    onlineCount += 1
                                }
                            }
                            
                            OperationQueue.main.addOperation {
                                controller.tableView.reloadData()
                                controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
                            }
                        }
                    
                        if let controller = vc as? ProfileController2 {
                            for update in vkUserLongPoll.shared.updates {
                                
                                if controller.userID == "\(abs(update.elements[1]))" {
                                    if controller.userProfile.count > 0 {
                                        if update.elements[0] == 8 {
                                            controller.userProfile[0].onlineStatus = 1
                                            controller.userProfile[0].platform = update.elements[2] % 256
                                        } else if update.elements[0] == 9 {
                                            controller.userProfile[0].onlineStatus = 0
                                            controller.userProfile[0].lastSeen = update.elements[3]
                                        }
                                        
                                        OperationQueue.main.addOperation {
                                            if controller.userProfile[0].deactivated == "" {
                                                if controller.userProfile[0].onlineStatus == 1 {
                                                    controller.profileView.onlineStatusLabel.text = " онлайн"
                                                    controller.profileView.onlineStatusLabel.textColor = UIColor.blue
                                                } else {
                                                    controller.profileView.onlineStatusLabel.textColor = UIColor.black
                                                    controller.profileView.onlineStatusLabel.text = " заходил " + controller.userProfile[0].lastSeen.toStringLastTime()
                                                    if controller.userProfile[0].sex == 1 {
                                                        controller.profileView.onlineStatusLabel.text = " заходила " + controller.userProfile[0].lastSeen.toStringLastTime()
                                                    }
                                                }
                                                
                                                if controller.userProfile[0].platform > 0 && controller.userProfile[0].platform != 7 {
                                                   
                                                    if let text = controller.profileView.onlineStatusLabel.text {
                                                    controller.profileView.onlineStatusLabel.setPlatformStatus(text: text, platform: controller.userProfile[0].platform, online: controller.userProfile[0].onlineStatus)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        vkUserLongPoll.shared.updates.removeAll(keepingCapacity: false)
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}
