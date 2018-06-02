//
//  GroupDialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

import UIKit
import SCLAlertView
import SwiftyJSON

class GroupDialogsController: UITableViewController {
    
    var isFirstAppear = true
    var isRefresh = false
    var type = ""
    var source = ""
    var attachment = ""
    var attachImage: UIImage?
    
    var groupID = ""
    
    var offset = 0
    var count = 30
    var totalCount = 0
    
    var dialogs: [Message] = []
    var users: [DialogsUsers] = []
    
    var fwdMessagesID: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = Int(self.groupID) {
            getGroupLongPollServer(groupID: id)
        }
        
        self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)
        
        OperationQueue.main.addOperation {
            self.navigationItem.hidesBackButton = true
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.tapCloseButton(sender:)))
            self.navigationItem.leftBarButtonItem = closeButton
            
            self.tableView.separatorStyle = .none
            self.tableView.register(GroupDialogsCell.self, forCellReuseIdentifier: "dialogCell")
        }
        
        refresh()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapCloseButton(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func pullToRefresh() {
        offset = 0
        dialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        refresh()
    }
    
    func refresh() {
        
        if let gid = Int(self.groupID), let token = vkSingleton.shared.groupToken[gid] {
            let opq = OperationQueue()
            isRefresh = true
        
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        
            let url = "/method/messages.getDialogs"
            let parameters = [
                "access_token": token,
                "offset": "\(offset)",
                "count": "\(count)",
                "preview_length": "90",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseDialogs = ParseDialogs()
            parseDialogs.completionBlock = {
                var userIDs = ""
                for dialog in parseDialogs.outputData {
                    if userIDs != "" {
                        userIDs = "\(userIDs),"
                    }
                    userIDs = "\(userIDs)\(dialog.userID)"
                }
                userIDs = "\(userIDs),\(vkSingleton.shared.userID)"
                
                let url = "/method/users.get"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_ids": userIDs,
                    "fields": "id, first_name, last_name, last_seen, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, online,  can_write_private_message, sex",
                    "name_case": "nom",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                opq.addOperation(getServerDataOperation)
                
                self.setOfflineStatus(dependence: getServerDataOperation)
                
                let parseDialogsUsers = ParseDialogsUsers()
                parseDialogsUsers.addDependency(getServerDataOperation)
                opq.addOperation(parseDialogsUsers)
                
                var groupIDs = self.groupID
                for dialog in parseDialogs.outputData {
                    if dialog.userID < 0 {
                        if groupIDs != "" {
                            groupIDs = "\(groupIDs),"
                        }
                        groupIDs = "\(groupIDs)\(abs(dialog.userID))"
                    }
                }
                
                let url2 = "/method/groups.getById"
                let parameters2 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_ids": groupIDs,
                    "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
                opq.addOperation(getServerDataOperation2)
                
                let parseGroupProfile = ParseGroupProfile()
                parseGroupProfile.addDependency(getServerDataOperation2)
                opq.addOperation(parseGroupProfile)
                
                let reloadController = ReloadGroupDialogsController(controller: self)
                reloadController.addDependency(parseDialogs)
                reloadController.addDependency(parseDialogsUsers)
                reloadController.addDependency(parseGroupProfile)
                OperationQueue.main.addOperation(reloadController)
            }
            parseDialogs.addDependency(getServerDataOperation)
            opq.addOperation(parseDialogs)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return dialogs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell") as! GroupDialogsCell
        
        return cell.userAvatarSize + 2 * cell.topInsets
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 6
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogCell", for: indexPath) as! GroupDialogsCell
        
        if indexPath.section < dialogs.count {
            cell.groupID = self.groupID
            cell.configureCell(mess: dialogs[indexPath.section], users: users, indexPath: indexPath, cell: cell, tableView: tableView)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dialog = dialogs[indexPath.section]
        
        openGroupDialogController(userID: "\(dialog.userID)", groupID: self.groupID, startID: dialog.id, attachment: attachment, messIDs: fwdMessagesID, image: attachImage)
        
        fwdMessagesID.removeAll(keepingCapacity: false)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections-1 && offset < totalCount {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            self.refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить диалог") { (rowAction, indexPath) in
            let dialog = self.dialogs[indexPath.section]
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 32.0,
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                kTextFont: UIFont(name: "Verdana", size: 13)!,
                kButtonFont: UIFont(name: "Verdana", size: 14)!,
                showCloseButton: false,
                showCircularIcon: true
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("Да, я уверен") {
                if let gid = Int(self.groupID), let token = vkSingleton.shared.groupToken[gid] {
                    
                    let url = "/method/messages.deleteDialog"
                    let parameters = [
                        "access_token": token,
                        "user_id": "\(dialog.userID)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            OperationQueue.main.addOperation {
                                self.dialogs.remove(at: indexPath.section)
                                self.totalCount -= 1
                                self.offset -= 1
                                self.tableView.reloadData()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка при удалении диалога", msg: "\(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
            }
            
            alertView.addButton("Отмена, я передумал") {
                
            }
            
            let user = self.users.filter({ $0.uid == "\(dialog.userID)" })
            var name = "данный диалог"
            if user.count > 0 {
                if dialog.userID > 0 {
                    name =  "диалог с пользователем \"\(user[0].firstName) \(user[0].lastName)\""
                } else {
                    name =  "диалог с сообществом \"\(user[0].firstName)\""
                }
            }
            alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить \(name)? Это действие необратимо.")
            
        }
        deleteAction.backgroundColor = UIColor.red
        
        return [deleteAction]
    }
}
