//
//  PersonalController.swift
//  VK-total
//
//  Created by Сергей Никитин on 22.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
//import SWRevealViewController

class PersonalController: UITableViewController {

    @IBOutlet weak var addAAccountButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*addAAccountButton.isEnabled = false
        addAAccountButton.tintColor = UIColor.clear
        addAAccountButton.target = revealViewController()
        addAAccountButton.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //self.revealViewController().panGestureRecognizer()
        self.revealViewController().tapGestureRecognizer()*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // show friends list
        if indexPath.section == 0 && indexPath.row == 0 {
            self.openUsersController(uid: vkSingleton.shared.userID, title: "Мои друзья", type: "friends")
        }
        
        // show groups list
        if indexPath.section == 0 && indexPath.row == 1 {
            self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Мои сообщества", type: "")
        }
        
        // show photos list
        if indexPath.section == 0 && indexPath.row == 2 {
            self.openPhotosListController(ownerID: vkSingleton.shared.userID, title: "Мои фотографии", type: "photos")
        }
        
        // show videos list
        if indexPath.section == 0 && indexPath.row == 3 {
            self.openVideoListController(ownerID: vkSingleton.shared.userID, title: "Мои видеозаписи", type: "")
        }
        
        // show fave posts
        if indexPath.section == 0 && indexPath.row == 4 {
            self.openFavePostsController()
        }
        
        // show subscript list
        if indexPath.section == 0 && indexPath.row == 5 {
            self.openUsersController(uid: vkSingleton.shared.userID, title: "Мои подписки", type: "subscript")
        }
        
        // search ITunes music
        if indexPath.section == 0 && indexPath.row == 6 {
            self.openMyMusicController(ownerID: vkSingleton.shared.userID)
        }
        
        // app options controller
        if indexPath.section == 1 && indexPath.row == 0 {
            self.openOptionsController()
        }
        
        // add/change account
        if indexPath.section == 1 && indexPath.row == 1 {
            self.openAddAccountController()
        }
        
        // exit from account
        if indexPath.section == 1 && indexPath.row == 2 {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Выйти из учетной записи", style: .destructive) { action in
                
                self.unregisterDeviceOnPush()
                if let request = vkUserLongPoll.shared.request {
                    request.cancel()
                }
                vkUserLongPoll.shared.firstLaunch = true
                
                for id in vkGroupLongPoll.shared.request.keys {
                    if let request = vkGroupLongPoll.shared.request[id] {
                        request.cancel()
                        vkGroupLongPoll.shared.firstLaunch[id] = true
                        vkSingleton.shared.groupToken[id] = nil
                    }
                }
                
                self.performSegue(withIdentifier: "logoutVK", sender: nil)
            }
            alertController.addAction(OKAction)
            
            present(alertController, animated: true)
        }
        
        // write-review AppStore
        if indexPath.section == 1 && indexPath.row == 3 {
            self.writeReviewAppStore()
        }
        
        // feedback
        if indexPath.section == 1 && indexPath.row == 4 {
            let url = "/method/messages.getHistory"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "count": "1",
                "user_id": "-166099539",
                "start_message_id": "-1",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            OperationQueue().addOperation(getServerDataOperation)
            
            let parseDialog = ParseDialogHistory()
            parseDialog.completionBlock = {
                var startID = parseDialog.inRead
                if parseDialog.outRead > startID {
                    startID = parseDialog.outRead
                }
                OperationQueue.main.addOperation {
                    self.openDialogController(userID: "-166099539", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                }
            }
            parseDialog.addDependency(getServerDataOperation)
            OperationQueue().addOperation(parseDialog)
        }
    }
}
