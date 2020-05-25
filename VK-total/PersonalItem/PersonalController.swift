//
//  PersonalController.swift
//  VK-total
//
//  Created by Сергей Никитин on 22.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
//import SWRevealViewController

class PersonalController: InnerTableViewController {

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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 1 { return 10 }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        
        let label = UILabel()
        label.font = UIFont(name: "Verdana-Bold", size: 14)!
        label.frame = CGRect(x: 10, y: 2, width: tableView.frame.width - 20, height: 16)
        label.textAlignment = .right
        label.text = "Личное"
        if section == 1 { label.text = "Служебное" }
        
        if #available(iOS 13.0, *) {
            viewHeader.backgroundColor = .separator
            label.textColor = .label
        } else {
            viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            label.textColor = .black
        }
        
        //viewHeader.addSubview(label)
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        if #available(iOS 13.0, *) {
            viewFooter.backgroundColor = .separator
        } else {
            viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        }
        return viewFooter
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
        
        if indexPath.section == 1 && indexPath.row == 5 {
            self.openBrowserControllerNoCheck(url: "https://vk.com/terms")
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
