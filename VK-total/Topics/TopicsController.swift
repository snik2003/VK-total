//
//  TopicsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class TopicsController: InnerViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var groupID: String = ""
    var group: [GroupProfile] = []
    var topics: [Topic] = []
    var profiles: [WallProfiles] = []
    
    var total = 0
    var canAddTopics = 0
    
    var order = 1
    var offset = 0
    var count = 50
    var isRefresh = false
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    
    var navHeight: CGFloat {
           if #available(iOS 13.0, *) {
               return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           } else {
               return UIApplication.shared.statusBarFrame.size.height +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           }
       }
    var tabHeight: CGFloat = 49
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBar.Style.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.tapBarButtonItem(sender:)))
            self.navigationItem.rightBarButtonItem = barButton
            
            self.tableView.separatorStyle = .none
        }
        
        getTopics()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getTopics() {
        let opq = OperationQueue()
        isRefresh = true
        
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
            ViewControllerUtils().showActivityIndicator(uiView: self.tableView)
        }
        
        let url = "/method/board.getTopics"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "order": "\(order)",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "preview": "1",
            "preview_length": "200",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseTopics = ParseTopics()
        parseTopics.addDependency(getServerDataOperation)
        opq.addOperation(parseTopics)
        
        let reloadController = ReloadTopicsController(controller: self)
        reloadController.addDependency(parseTopics)
        OperationQueue.main.addOperation(reloadController)
    }
    
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: 0))
        searchBar.tintColor = vkSingleton.shared.labelColor
        
        if #available(iOS 13.0, *) {
            let searchField = searchBar.searchTextField
            searchField.backgroundColor = vkSingleton.shared.separatorColor
            searchField.textColor = vkSingleton.shared.labelColor
        } else {
            searchBar.changeKeyboardAppearanceMode()
            if let searchField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchField.backgroundColor = vkSingleton.shared.separatorColor
                searchField.textColor = vkSingleton.shared.labelColor
                searchField.changeKeyboardAppearanceMode()
            } else if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.backgroundColor = vkSingleton.shared.separatorColor
                searchField.textColor = vkSingleton.shared.labelColor
                searchField.changeKeyboardAppearanceMode()
            }
        }
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.backgroundColor = vkSingleton.shared.backColor
        tableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabHeight - searchBar.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TopicTitleCell.self, forCellReuseIdentifier: "groupCell")
        tableView.register(TopicCell.self, forCellReuseIdentifier: "topicCell")
        
        self.view.addSubview(tableView)
    }
    
    @objc func tapBackButtonItem(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        if topics.count > 0 {
            playSoundEffect(vkSingleton.shared.buttonSound)
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if canAddTopics == 1 {
                let action1 = UIAlertAction(title: "Создать новую тему для обсуждения", style: .default) { action in
                
                    self.openAddTopicController(ownerID: self.groupID, title: "Новое обсуждение", delegate: self)
                }
                alertController.addAction(action1)
            }
            
            let action2 = UIAlertAction(title: "Изменить порядок сортировки тем", style: .default) { action in
                
                let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController2.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "По убыванию даты обновления     ", style: .default) { action in
                    
                    self.order = 1
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action1)
                
                let action2 = UIAlertAction(title: "По убыванию даты создания     ", style: .default) { action in
                    
                    self.order = 2
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action2)
                
                let action3 = UIAlertAction(title: "По возрастанию даты обновления", style: .default) { action in
                    
                    self.order = -1
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action3)
                
                let action4 = UIAlertAction(title: "По возрастанию даты создания", style: .default) { action in
                    
                    self.order = -2
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
    
                    self.getTopics()
                }
                alertController2.addAction(action4)
                
                self.present(alertController2, animated: true)
            }
            alertController.addAction(action2)
            
            present(alertController, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return topics.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 60
        case 1...topics.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! TopicCell
            
            return cell.getRowHeight(topic: topics[indexPath.section - 1])
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 7
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as! TopicTitleCell
            
            cell.configureCell(group: group[0], indexPath: indexPath, cell: cell, tableView: tableView)
            cell.selectionStyle = .none
            
            return cell
        case 1...topics.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
            
            let topic = topics[indexPath.section - 1]
            
            cell.configureCell(topic: topic, group: group, profiles: profiles, indexPath: indexPath, cell: cell, tableView: tableView)
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if let gid = Int("-\(groupID)") {
                self.openProfileController(id: gid, name: "")
            }
        case 1...topics.count:
            let topic = topics[indexPath.section - 1]
            self.openTopicController(groupID: groupID, topicID: "\(topic.id)", title: topic.title, delegate: self)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset && offset < total {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            OperationQueue.main.addOperation {
                self.getTopics()
            }
        }
    }
}
