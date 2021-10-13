//
//  AddAccountController.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift

class AddAccountController: InnerTableViewController {

    var accounts = [AccountVK]()
    let userDefaults = UserDefaults.standard
    
    var friendsCounters: [String: Int] = [:]
    var notesCounters: [String: Int] = [:]
    var messagesCounters: [String: Int] = [:]
    
    var changeAccount = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //readAccountsFromRealm()
        
        if let aView = self.tableView.superview {
            ViewControllerUtils().showActivityIndicator(uiView: aView)
        } else {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let requestGroup = DispatchGroup()
        
        for account in accounts {
            requestGroup.enter()
            self.getAccountCounters(account: account, counters: { token, friendsCounters, messagesCounters, notesCounters in
                self.friendsCounters[token] = friendsCounters
                self.notesCounters[token] = notesCounters
                self.messagesCounters[token] = messagesCounters
                requestGroup.leave()
            })
        }
        
        requestGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.tableView.reloadData()
            ViewControllerUtils().hideActivityIndicator()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if accounts.count == 0 { return 0 }
        
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
        
        return 70
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1...accounts.count:
            let account = accounts[indexPath.row - 1]
            
            if vkSingleton.shared.userID != "\(account.userID)" {
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    if #available(iOS 13.0, *) {
                        cell.backgroundColor = .opaqueSeparator
                    } else {
                        cell.backgroundColor = UIColor.lightGray
                    }
                    
                    let alertController = VKAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                        cell.backgroundColor = .clear
                    }
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "\(account.firstName) \(account.lastName) \n https://vk.com/\(account.screenName)", style: .default) { action in
                        
                        vkSingleton.shared.userID = "\(account.userID)"
                        vkSingleton.shared.avatarURL = ""
                        vkSingleton.shared.stickers = []
                        
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
                        
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let window = UIApplication.shared.keyWindow
                        
                        if let controller  = storyboard.instantiateViewController(withIdentifier: "LoginFormController") as? LoginFormController {
                            
                            controller.view.backgroundColor = vkSingleton.shared.backColor
                            controller.changeAccount = true
                            
                            UIView.transition(with: window!, duration: 0.9, options: .transitionFlipFromLeft, animations: {
                                window?.rootViewController = controller
                                window?.makeKeyAndVisible()
                            }, completion: nil)
                        }
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
        sender.buttonTouched(controller: self)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Добавить учетную запись", style: .destructive) { action in
            
            vkSingleton.shared.avatarURL = ""
            vkSingleton.shared.stickers = []
            
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
            cell.backgroundColor = vkSingleton.shared.backColor
            
            if let label = cell.viewWithTag(1) as? UILabel {
                label.textColor = vkSingleton.shared.labelColor
            }
            
            return cell
        case 1...accounts.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! AddAccountCell
            
            let account = accounts[indexPath.row - 1]
            
            var friendsCounter = 0
            var notesCounter = 0
            var messagesCounter = 0
            
            if let counter1 = self.friendsCounters[account.token],
                let counter2 = self.messagesCounters[account.token],
                let counter3 = self.notesCounters[account.token] {
                
                friendsCounter = counter1
                messagesCounter = counter2
                notesCounter = counter3
            }
            
            cell.configureCell(account: account, friendsCounter: friendsCounter, messagesCounter: messagesCounter, notesCounter: notesCounter, indexPath: indexPath, cell: cell, tableView: tableView)
            
            return cell
        case accounts.count + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addAccountCell", for: indexPath)
            cell.backgroundColor = vkSingleton.shared.backColor
            
            for subview in cell.subviews {
                if subview.tag == 100 { subview.removeFromSuperview() }
            }
            
            let button = UIButton()
            button.tag = 100
            button.frame = CGRect(x: 50, y: 28, width: UIScreen.main.bounds.width - 100, height: 44)
            button.layer.cornerRadius = 6
            button.clipsToBounds = true
            button.backgroundColor = vkSingleton.shared.mainColor
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

extension UIView {

    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
}

extension VKAlertController {
    
    private var cancelActionView: UIView? {
        return view.recursiveSubviews.compactMap({
            $0 as? UILabel}
        ).first(where: {
            $0.text == actions.first(where: { $0.style == .cancel })?.title
        })?.superview?.superview
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 13.0, *) {
            if !AppConfig.shared.autoMode {
                if AppConfig.shared.darkMode {
                    self.overrideUserInterfaceStyle = .dark
                } else {
                    self.overrideUserInterfaceStyle = .light
                }
            }
        } else if AppConfig.shared.darkMode {
            self.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = vkSingleton.shared.backColor
            self.cancelActionView?.backgroundColor = vkSingleton.shared.backColor
        }
        
        let accounts = readAccountsFromRealm()
        
        for i in self.actions {
            let fullString = i.title ?? ""
            let attributedText = NSMutableAttributedString(string: fullString, attributes: [NSAttributedString.Key.font : UIFont(name: "Verdana", size: 15.0)!])

            for account in accounts {
                attributedText.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray, NSAttributedString.Key.font : UIFont(name: "Verdana", size: 12.0)!], range: NSRange(fullString.range(of: "https://vk.com/\(account.screenName)") ?? fullString.startIndex..<fullString.startIndex, in: fullString))
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
