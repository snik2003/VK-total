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
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

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
        
        if !changeAccount && indexPath.row == accounts.count + 1 {
            return 100
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
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.backgroundColor = UIColor.lightGray
                    
                    let alertController = VKAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.backgroundColor = .clear
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "\(account.firstName) \(account.lastName) \n https://vk.com/\(account.screenName)", style: .default) { action in
                        
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
                            }
                        }
                        
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginFormController") as! LoginFormController
                        controller.changeAccount = true
                        
                        UIApplication.shared.keyWindow?.rootViewController = controller
                    }
                    
                    alertController.addAction(action1)
                    present(alertController, animated: true)
                }
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func addAccountButtonAction(sender: UIButton) {
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
                }
            }
            
            self.performSegue(withIdentifier: "addAccountVK", sender: nil)
        }
        alertController.addAction(action1)
        
        present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath)
            
            return cell
        case 1...accounts.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
            
            for subview in cell.subviews {
                if subview.tag == 100 { subview.removeFromSuperview() }
            }
            
            let account = accounts[indexPath.row - 1]
            
            cell.textLabel?.text = "\(account.firstName) \(account.lastName)"
            cell.textLabel?.font = UIFont(name: "Verdana", size: 13.0)
            cell.textLabel?.numberOfLines = 1
            
            cell.imageView?.isHidden = true
            
            cell.detailTextLabel?.textColor = cell.tintColor
            cell.detailTextLabel?.isEnabled = true
            cell.detailTextLabel?.text = "https://vk.com/\(account.screenName)"
            
            if vkSingleton.shared.userID == "\(account.userID)" {
                cell.textLabel?.font = UIFont(name: "Verdana-Bold", size: 13.0)
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
            }
            
            let avatarImage = UIImageView()
            avatarImage.tag = 100
            avatarImage.frame = CGRect(x: 20, y: 5, width: 50, height: 50)
            avatarImage.image = UIImage(named: "error")
            
            let getCacheImage = GetCacheImage(url: account.avatarURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                avatarImage.layer.cornerRadius = 25
                avatarImage.layer.borderColor = UIColor.gray.cgColor
                avatarImage.layer.borderWidth = 0.6
                avatarImage.contentMode = .scaleAspectFit
                avatarImage.clipsToBounds = true
            }
            cell.addSubview(avatarImage)
            
            return cell
        case accounts.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addAccountCell", for: indexPath)
            
            for subview in cell.subviews {
                if subview.tag == 100 { subview.removeFromSuperview() }
            }
            
            let button = UIButton()
            button.tag = 100
            button.frame = CGRect(x: 50, y: 28, width: UIScreen.main.bounds.width - 100, height: 44)
            button.layer.cornerRadius = 6
            button.clipsToBounds = true
            button.backgroundColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
            button.setTitle("Добавить учетную запись", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12.0)!
            button.addTarget(self, action: #selector(addAccountButtonAction(sender:)), for: .touchUpInside)
            cell.addSubview(button)
            
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

class VKAlertController : UIAlertController {
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }

    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}

extension VKAlertController {
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let accounts = readAccountsFromRealm()
        
        for i in self.actions {
            let fullString = i.title ?? ""
            let attributedText = NSMutableAttributedString(string: fullString, attributes: [NSAttributedString.Key.font : UIFont(name: "Verdana", size: 14.0)!])

            for account in accounts {
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], range: NSRange(fullString.range(of: "https://vk.com/\(account.screenName)") ?? fullString.startIndex..<fullString.startIndex, in: fullString))
            }
            
            guard let label = (i.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.attributedText = attributedText
        }

    }
    
    func readAccountsFromRealm() -> [AccountVK] {
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
            
            return Array(accounts)
        } catch {
            print(error)
        }
        
        return []
    }
}

extension UIAlertController {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for i in self.actions {
            let attributedText = NSAttributedString(string: i.title ?? "", attributes: [NSAttributedString.Key.font : UIFont(name: "Verdana", size: 16.0)!])

            guard let label = (i.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label.attributedText = attributedText
        }

    }
}
