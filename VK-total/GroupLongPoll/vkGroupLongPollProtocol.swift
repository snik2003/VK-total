//
//  vkGroupLongPollProtocol.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SWRevealViewController

protocol vkGroupLongPollProtocol {
    func launchAllGroupsLongPollServer()
    func getGroupLongPollServer(groupID: Int)
    func groupLongPoll(_ groupID: Int)
    func handleGroupUpdates(_ groupID: Int)
}

extension UIViewController: vkGroupLongPollProtocol {
    
    func launchAllGroupsLongPollServer() {
        
        var index = 0
        var code: [String] = []
        
        for gid in vkSingleton.shared.adminGroupID {
            if vkGroupLongPoll.shared.firstLaunch[gid] != false {
                let codex = "var a\(index) = API.messages.getLongPollServer({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"lp_version\":\(vkSingleton.shared.lpVersion),\"group_id\": \"\(gid)\",\"v\":\"\(vkSingleton.shared.version)\"})"
                code.append(codex)
                    
                index += 1
            }
        }
        
        if index > 0 {
            var codeString = ""
            var returnString = ""
            for index2 in 0...index-1 {
                codeString = "\(codeString)\n\(code[index2]);"
                if returnString != "" {
                    returnString = "\(returnString),"
                }
                returnString = "\(returnString)a\(index2)"
            }
            codeString = "\(codeString); return [\(returnString)];"
            //print(codeString)
            
            let url = "/method/execute"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "code": codeString,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                var index = 0
                for gid in vkSingleton.shared.adminGroupID {
                    if vkGroupLongPoll.shared.firstLaunch[gid] != false {
                            
                        vkGroupLongPoll.shared.server[gid] = json["response"][index]["server"].stringValue
                        vkGroupLongPoll.shared.key[gid] = json["response"][index]["key"].stringValue
                        vkGroupLongPoll.shared.ts[gid] = json["response"][index]["ts"].stringValue
                        
                        vkSingleton.shared.errorCode = json["error"][index]["error_code"].intValue
                        vkSingleton.shared.errorMsg = json["error"][index]["error_msg"].stringValue
                        
                        if vkSingleton.shared.errorCode == 0 {
                            self.groupLongPoll(gid)
                        }  else {
                            print("Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                        }
                        index += 1
                    }
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        }
    }
    
    func getGroupLongPollServer(groupID: Int) {
        if vkGroupLongPoll.shared.firstLaunch[groupID] != false {
            vkGroupLongPoll.shared.firstLaunch[groupID] = false
                
            let url = "/method/messages.getLongPollServer"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "need_pts": "1",
                "lp_version": vkSingleton.shared.lpVersion,
                "group_id": "\(groupID)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { print("data error"); return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                vkGroupLongPoll.shared.server[groupID] = json["response"]["server"].stringValue
                vkGroupLongPoll.shared.key[groupID] = json["response"]["key"].stringValue
                vkGroupLongPoll.shared.ts[groupID] = json["response"]["ts"].stringValue
                
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    self.groupLongPoll(groupID)
                }  else {
                    print("Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func groupLongPoll(_ groupID: Int) {
        autoreleasepool {
            if let server = vkGroupLongPoll.shared.server[groupID], let key = vkGroupLongPoll.shared.key[groupID], let ts = vkGroupLongPoll.shared.ts[groupID] {
                
                let url = "https://\(server)"
                let parameters = [
                    "act": "a_check",
                    "key": key,
                    "ts": ts,
                    "wait": "25",
                    "mode": "2",
                    "version": vkSingleton.shared.lpVersion
                ]
                
                vkGroupLongPoll.shared.request[groupID] = GetLongPollServerRequest(url: url, parameters: parameters)
                if let request = vkGroupLongPoll.shared.request[groupID] {
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else {
                            request.cancel()
                            vkGroupLongPoll.shared.firstLaunch[groupID] = true
                            self.getGroupLongPollServer(groupID: groupID)
                            return
                        }
                        
                        let failed = json["failed"].intValue
                        vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                        vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if vkSingleton.shared.errorCode == 0 {
                            if failed == 0 || failed == 1 {
                                vkGroupLongPoll.shared.ts[groupID] = json["ts"].stringValue
                                vkGroupLongPoll.shared.updates[groupID] = json["updates"].compactMap { Updates(json: $0.1) }
                                
                                print("groupID = \(groupID)")
                                print(json)
                                self.handleGroupUpdates(groupID)
                                self.groupLongPoll(groupID)
                            } else if failed == 2 && failed == 3 {
                                request.cancel()
                                vkGroupLongPoll.shared.firstLaunch[groupID] = true
                                self.getGroupLongPollServer(groupID: groupID)
                            }
                        } else {
                            print("#\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                            request.cancel()
                            vkGroupLongPoll.shared.firstLaunch[groupID] = true
                            self.getGroupLongPollServer(groupID: groupID)
                        }
                    }
                    OperationQueue().addOperation(request)
                }
            }
        }
    }
    
    func handleGroupUpdates(_ groupID: Int) {
        
        if var updates = vkGroupLongPoll.shared.updates[groupID] {
            for update in updates {
                
                if update.elements[0] == 4 {
                    let flags = update.elements[2]
                    var summands: [Int] = []
                    for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                        if flags & number != 0 {
                            summands.append(number)
                        }
                    }
                    
                    var text = update.text.prepareTextForPublic()
                    
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
                    if !summands.contains(2) && update.action == "" {
                        OperationQueue.main.addOperation {
                            self.showMessageNotification(title: "Новое сообщение", text: text, userID: userID, chatID: 0, groupID: groupID, startID: update.elements[1])
                        }
                    }
                }
            }
            
            if let viewControllers = self.tabBarController?.viewControllers {
                for vc1 in viewControllers {
                    if let vcs = (vc1 as? UINavigationController)?.viewControllers {
                        for vc in vcs {
                            if let controller = vc as? GroupDialogController {
                                for update in updates {
                                    if update.elements[0] == 4 {
                                        if controller.userID == "\(update.elements[3])" {
                                            let mess = DialogHistory(json: JSON.null)
                                            
                                            mess.id = update.elements[1]
                                            mess.userID = update.elements[3]
                                            mess.body = update.text
                                            mess.date = update.elements[4]
                                            mess.emoji = update.emoji
                                            mess.title = update.title
                                            
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
                                            
                                            if update.type == "" && update.fwdCount == 0 {
                                                OperationQueue.main.addOperation {
                                                    controller.dialogs.append(mess)
                                                    controller.totalCount += 1
                                                    controller.tableView.reloadData()
                                                    if controller.tableView.numberOfSections > 0 {
                                                        controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                                                    }
                                                }
                                            } else {
                                                controller.startMessageID = update.elements[1]
                                                controller.getDialog()
                                            }
                                            self.markAsReadMessages(controller: controller)
                                        }
                                    } else if update.elements[0] == 5 {
                                        if controller.userID == "\(update.elements[3])" {
                                            controller.startMessageID = -1
                                            if let id = controller.dialogs.last?.id {
                                                controller.startMessageID = id
                                            }
                                            controller.getDialog()
                                        }
                                    } else if update.elements[0] == 6 {
                                        if controller.userID == "\(update.elements[1])" {
                                            for dialog in controller.dialogs {
                                                if dialog.id <= update.elements[2] && dialog.out == 0 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            
                                            OperationQueue.main.addOperation {
                                                controller.tableView.reloadData()
                                                if controller.tableView.numberOfSections > 0 {
                                                    controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: true)
                                                }
                                            }
                                        }
                                    } else if update.elements[0] == 7 {
                                        if controller.userID == "\(update.elements[1])" {
                                            for dialog in controller.dialogs {
                                                if dialog.id <= update.elements[2] && dialog.out == 1 {
                                                    dialog.readState = 1
                                                }
                                            }
                                            
                                            OperationQueue.main.addOperation {
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
                                                        controller.dialogs.remove(object: dialog)
                                                    }
                                                    
                                                    OperationQueue.main.addOperation {
                                                        controller.estimatedHeightCache.removeAll(keepingCapacity: false)
                                                        controller.tableView.reloadData()
                                                        if controller.tableView.numberOfSections > 0 {
                                                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .bottom, animated: false)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if let controller = vc as? GroupDialogsController, controller.users.count > 0 {
                                var change = false
                                
                                for update in updates {
                                    if update.elements[0] == 2 {
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
                                            
                                            for index in 0...controller.dialogs.count-1 {
                                                if controller.dialogs[index].userID == update.elements[3] {
                                                    
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
                                        for dialog in controller.dialogs {
                                            if dialog.userID == update.elements[1] {
                                                for dialog in controller.dialogs {
                                                    if dialog.id == update.elements[2] && dialog.out == 0 {
                                                        dialog.readState = 1
                                                    }
                                                }
                                                change = true
                                            }
                                        }
                                    } else if update.elements[0] == 7 {
                                        for dialog in controller.dialogs {
                                            if dialog.userID == update.elements[1] {
                                                for dialog in controller.dialogs {
                                                    if dialog.id == update.elements[2] && dialog.out == 1 {
                                                        dialog.readState = 1
                                                    }
                                                }
                                                
                                                change = true
                                            }
                                        }
                                    }
                                }
                                
                                if change {
                                    OperationQueue.main.addOperation {
                                        controller.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            updates.removeAll(keepingCapacity: false)
        }
    }
}
