//
//  AddAccountController.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift

class AddAccountController: UITableViewController {

    var accounts = [AccountVK]()
    let userDefaults = UserDefaults.standard
    
    var changeAccount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readAccountsFromRealm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if changeAccount {
            return accounts.count + 1
        }
        return accounts.count + 2
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 0.01
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 30
        }
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1...accounts.count:
            
            let account = accounts[indexPath.row - 1]
            
            if vkSingleton.shared.userID != "\(account.userID)" {
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Сменить учетную запись", style: .destructive) { action in
                    
                    vkSingleton.shared.userID = "\(account.userID)"
                    vkSingleton.shared.avatarURL = ""
                    
                    self.userDefaults.set(vkSingleton.shared.userID, forKey: "vkUserID")
                    self.readAppConfig()
                
                    vkSingleton.shared.accessToken = self.getAccessTokenFromRealm(userID: Int(vkSingleton.shared.userID)!)
                
                    vkUserLongPoll.shared.request.cancel()
                    vkUserLongPoll.shared.firstLaunch = true
                    
                    for id in vkGroupLongPoll.shared.request.keys {
                        if let request = vkGroupLongPoll.shared.request[id] {
                            request.cancel()
                            vkGroupLongPoll.shared.firstLaunch[id] = true
                            vkSingleton.shared.groupToken[id] = nil
                        }
                    }
                    
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginFormController") as! LoginFormController
                    controller.changeAccount = true
                    
                    UIApplication.shared.keyWindow?.rootViewController = controller
                }
                
                alertController.addAction(action1)
                present(alertController, animated: true)
            }
            
        case accounts.count + 1:
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Добавить учетную запись", style: .destructive) { action in
                
                vkSingleton.shared.avatarURL = ""
                
                vkUserLongPoll.shared.request.cancel()
                vkUserLongPoll.shared.firstLaunch = true
                
                for id in vkGroupLongPoll.shared.request.keys {
                    if let request = vkGroupLongPoll.shared.request[id] {
                        request.cancel()
                        vkGroupLongPoll.shared.firstLaunch[id] = true
                        vkSingleton.shared.groupToken[id] = nil
                    }
                }
                
                self.performSegue(withIdentifier: "addAccountVK", sender: nil)
            }
            alertController.addAction(action1)
            
            present(alertController, animated: true)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath)
            
            return cell
        case 1...accounts.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
            
            let account = accounts[indexPath.row - 1]
            
            cell.textLabel?.text = "\(account.firstName) \(account.lastName)"
            cell.textLabel?.font = UIFont(name: "Verdana", size: 15.0)
            cell.textLabel?.numberOfLines = 1
            
            if vkSingleton.shared.userID == "\(account.userID)" {
                cell.detailTextLabel?.textColor = UIColor.red
                cell.detailTextLabel?.isEnabled = true
                cell.detailTextLabel?.text = "текущая учетная запись"
            } else {
                cell.detailTextLabel?.textColor = UIColor.black
                cell.detailTextLabel?.isEnabled = false
                cell.detailTextLabel?.text = account.lastSeen.toStringLastTime()
            }
            
            let getCacheImage = GetCacheImage(url: account.avatarURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = 28
                cell.imageView?.clipsToBounds = true
            }
            
            return cell
        case accounts.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
            
            cell.textLabel?.text = "Добавить новую \nучетную запись"
            cell.textLabel?.font = UIFont(name: "Verdana", size: 13.0)
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.textColor = UIColor.darkGray // UIColor(displayP3Red: 71/255, green: 74/255, blue: 85/255, alpha: 1)
            
            cell.detailTextLabel?.text = ""
            
            OperationQueue.main.addOperation {
                cell.imageView?.image = UIImage(named: "add-account")
                cell.imageView?.backgroundColor = UIColor.lightGray// UIColor.white
                cell.imageView?.layer.cornerRadius = 28
                cell.imageView?.clipsToBounds = true
                cell.imageView?.contentMode = .scaleToFill
            }
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    func readAccountsFromRealm() {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            config.migrationBlock = { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: AccountVK.className()) { oldObject, newObject in
                        newObject?["userID"] = oldObject?["userID"]
                        newObject?["firstName"] = oldObject?["firstName"]
                        newObject?["lastName"] = oldObject?["lastName"]
                        newObject?["avatarURL"] = oldObject?["avatarURL"]
                        newObject?["screenName"] = oldObject?["screenName"]
                        newObject?["lastSeen"] = oldObject?["lastSeen"]
                        newObject?["token"] = oldObject?["token"]
                    }
                }
            }
            let realm = try Realm(configuration: config)
            let accounts = realm.objects(AccountVK.self)
            
            self.accounts = Array(accounts)
        } catch {
            print(error)
        }
    }
}
