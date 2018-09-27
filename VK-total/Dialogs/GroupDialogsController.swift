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
        
        let opq = OperationQueue()
        isRefresh = true
    
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
    
    
        let url = "/method/messages.getDialogs"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "preview_length": "90",
            "group_id": groupID,
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
}
