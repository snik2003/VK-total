//
//  NotificationsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationsController: InnerTableViewController {

    var notifications = [Notifications]()
    var groupInvites = [Groups]()
    
    var profiles = [WallProfiles]()
    var groups = [WallGroups]()
    
    var newNots = 0
    
    var readButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(self.updateNotifications), for: UIControl.Event.valueChanged)
        if #available(iOS 13.0, *) {
            self.refreshControl?.tintColor = .secondaryLabel
        } else {
            self.refreshControl?.tintColor = .gray
        }
        tableView.addSubview(refreshControl!)
        
        self.refreshControl?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OperationQueue.main.addOperation {
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView.superview!)
        }
        
        getNotifications()
    }

    @objc func updateNotifications() {
        getNotifications()
    }
    
    func getNotifications() {
        let opq = OperationQueue()
        let url = "/method/notifications.get"
        let parameters = [
            "count": "100",
            "start_time": "\(Date().timeIntervalSince1970 - 15552000)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        // парсим объект с данными
        let parseNotifications = ParseNotifications()
        parseNotifications.addDependency(getServerDataOperation)
        opq.addOperation(parseNotifications)
        
        
        let url2 = "/method/groups.getInvites"
        let parameters2 = [
            "count": "100",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100, sex",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        // парсим объект с данными
        let parseGroups = ParseGroupInvites()
        parseGroups.addDependency(getServerDataOperation2)
        opq.addOperation(parseGroups)
        
        self.setOfflineStatus(dependence: getServerDataOperation2)
        
        // обновляем данные на UI
        let reloadTableController = ReloadNotificationsController(controller: self)
        reloadTableController.addDependency(parseNotifications)
        reloadTableController.addDependency(parseGroups)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifications[section].countFeedback
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separator
        } else {
            view.backgroundColor = UIColor.lightText
        }
        
        if section == 0 && newNots > 0 {
            
            let label = UILabel()
            if #available(iOS 13.0, *) {
                label.textColor = .label
                label.backgroundColor = .separator
            } else {
                label.textColor = .black
            }
            label.text = "Непросмотренные уведомления (\(newNots))"
            label.textAlignment = .center
            label.contentMode = .center
            label.font = UIFont(name: "Verdana", size: 12.0)!
            label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15)
            view.addSubview(label)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && newNots > 0 {
            return 15
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var count = 0
        for index1 in 0...section {
            count += notifications[index1].countFeedback
        }
        if count == newNots && newNots > 0 {
            return 10
        }
        if section == tableView.numberOfSections - 1 {
            return 0.01
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let not = notifications[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "notsCell") as! NotificationCell
        
        let height = cell.getRowHeight(not: not, profiles: profiles, groups: groups, indexPath: indexPath)
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notsCell", for: indexPath) as! NotificationCell

        let not = notifications[indexPath.section]
        
        cell.delegate = self
        cell.configureCell(not: not, profiles: profiles, groups: groups, indexPath: indexPath, cell: cell, tableView: tableView, viewController: self)
        
        return cell
    }
    
    @objc func readButtonClick(sender: UIButton!) {
        
        sender.buttonTouched(controller: self)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Пометить как просмотренные", style: .destructive) { action in
            
            let url = "/method/notifications.markAsViewed"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "v": vkSingleton.shared.version
            ]
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            for group in self.groupInvites {
                let url2 = "/method/groups.leave"
                let parameters2 = [
                    "group_id": group.gid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                request.addDependency(request2)
                OperationQueue().addOperation(request2)
            }
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    self.newNots = 0
                    self.notifications = self.notifications.filter({ $0.type != "group_invite" })
                    
                    OperationQueue.main.addOperation {
                        self.tabBarController?.tabBar.selectedItem?.badgeValue = nil
                        self.tableView.tableHeaderView = nil
                        self.tableView.reloadData()
                    }
                } else {
                    self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                }
            }
            
            OperationQueue().addOperation(request)
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
    }
    
    func leaveGroupInvite(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section {
            let not = notifications[index]
            
            if not.type == "group_invite" {
                var typeGroup = "в группу"
                if not.feedback[0].type == "page" {
                    typeGroup = "в сообщество"
                } else if not.feedback[0].type == "event" {
                    typeGroup = "на мероприятие"
                }
                
                let alertController = UIAlertController(title: "Приглашение \(typeGroup):", message: "«\(not.feedback[0].text)»", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                typeGroup = "группы"
                if not.feedback[0].type == "page" {
                    typeGroup = "сообщества"
                } else if not.feedback[0].type == "event" {
                    typeGroup = "мероприятия"
                }
                
                let action3 = UIAlertAction(title: "Перейти на страницу \(typeGroup)", style: .default) { action in

                    var name = not.feedback[0].text
                    if name.length > 20 {
                        name = "\((name).prefix(20))..."
                    } else {
                        name = "Сообщество"
                    }
                    
                    self.openProfileController(id: -1 * not.feedback[0].id, name: name)
                }
                alertController.addAction(action3)
                
                let action1 = UIAlertAction(title: "Принять приглашение", style: .default) { action in
                    
                    let url = "/method/groups.join"
                    let parameters = [
                        "group_id": "\(not.feedback[0].id)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                        ] as [String : Any]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            self.notifications.remove(at: index)
                            self.newNots -= 1
                            OperationQueue.main.addOperation {
                                self.tableView.reloadData()
                                if self.newNots > 0 {
                                    self.tabBarController?.tabBar.selectedItem?.badgeValue = "\(self.newNots)"
                                } else {
                                    self.tabBarController?.tabBar.selectedItem?.badgeValue = nil
                                }
                            }
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Отклонить приглашение", style: .destructive) { action in
                    
                    let url = "/method/groups.leave"
                    let parameters = [
                        "group_id": "\(not.feedback[0].id)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                        ] as [String : Any]
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            self.notifications.remove(at: index)
                            self.newNots -= 1
                            OperationQueue.main.addOperation {
                                self.tableView.reloadData()
                                if self.newNots > 0 {
                                    self.tabBarController?.tabBar.selectedItem?.badgeValue = "\(self.newNots)"
                                } else {
                                    self.tabBarController?.tabBar.selectedItem?.badgeValue = nil
                                }
                            }
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action2)
                
                present(alertController, animated: true)
            }
            
        }
    }
}
