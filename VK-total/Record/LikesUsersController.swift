//
//  LikesUsersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 08.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class LikesUsersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var likes = [Likes]()
    var reposts = [Likes]()
    var users = [Likes]()
    
    var mode: Int = 0
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.selectedSegmentIndex = 0
        for like in likes {
            users.append(like)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        users.removeAll(keepingCapacity: false)
        switch sender.selectedSegmentIndex {
        case 0:
            self.title = "Оценили"
            for like in likes {
                users.append(like)
            }
        case 1:
            self.title = "Поделились"
            for repost in reposts {
                users.append(repost)
            }
        case 2:
            self.title = "Оценили друзья"
            for like in likes {
                if like.friendStatus == 3 {
                    users.append(like)
                }
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        
        viewHeader.backgroundColor = UIColor.white
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = UIColor.white
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        let user = users[indexPath.row]
        
        if user.maxPhotoURL != "" {
            cell.imageView?.image = UIImage(named: "error")
            let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .userWallImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = 19
                cell.imageView?.clipsToBounds = true
            }
        }
        
        cell.textLabel?.attributedText = nil
        cell.textLabel?.text = "\(user.firstName) \(user.lastName) "
        if user.onlineStatus == 1 {
            if user.onlineMobile == 1 {
                let fullString = "\(user.firstName) \(user.lastName) "
                cell.textLabel?.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
            } else {
                let fullString = "\(user.firstName) \(user.lastName) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                if let color = cell.textLabel?.tintColor {
                    attributedString.setAttributes([NSAttributedString.Key.foregroundColor:  color], range: rangeOfColoredString)
                }
                cell.textLabel?.attributedText = attributedString
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if let id = Int(user.uid) {
            
            var title = ""
            if id > 0 {
                title = "\(user.firstName) \(user.lastName)"
            } else {
                let name = user.firstName
                if name.length > 20 {
                    title = "\((name).prefix(20))..."
                } else {
                    title = name
                }
            }
            
            if user.type == "profile" {
                self.openProfileController(id: id, name: title)
            } else {
                self.openProfileController(id: -1 * id, name: title)
            }
        }
    }
}

extension UILabel {
    func setOnlineMobileStatus(text: String, platform: Int) {
        let attachment = NSTextAttachment()
        
        if platform == 2 || platform == 3 {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        } else if platform == 4 {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        } else {
            attachment.image = UIImage(named: "onlinemobile")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: -5, y: -5, width: 20, height: 20)
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        
        let mutableAttributedString = NSMutableAttributedString()
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        mutableAttributedString.append(attachmentStr)
        
        let range2 = NSMakeRange(textString.length-1, attachmentStr.length);
        
        mutableAttributedString.setAttributes([NSAttributedString.Key.foregroundColor: self.tintColor], range: range2)
        
        self.attributedText = mutableAttributedString
    }
    
    func setPlatformStatus(text: String, platform: Int, online: Int) {
        let attachment = NSTextAttachment()
        
        if platform == 2 || platform == 3 {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -2, width: 15, height: 15)
        } else if platform == 4 {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -4, width: 15, height: 15)
        } else {
            attachment.image = UIImage(named: "onlinemobile")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 5, y: -6, width: 20, height: 20)
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        let mutableAttributedString = NSMutableAttributedString(string: " ")
        mutableAttributedString.append(attachmentStr)
        
        if online == 1 {
            let range2 = NSMakeRange(0, attachmentStr.length);
            
            mutableAttributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: range2)
        }
        
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        
        self.attributedText = mutableAttributedString
    }
    
    func setSourceOfRecord(text: String, source: String, delegate: UIViewController) {
        let attachment = NSTextAttachment()
        
        if source == "iphone" || source == "ipad" {
            attachment.image = UIImage(named: "iphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -2, width: 15, height: 15)
        } else if source == "android" {
            attachment.image = UIImage(named: "android")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "wphone" {
            attachment.image = UIImage(named: "wphone")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "instagram" {
            attachment.image = UIImage(named: "instagram2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "facebook" {
            attachment.image = UIImage(named: "facebook2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "twitter" {
            attachment.image = UIImage(named: "twitter2")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else if source == "windows" {
            attachment.image = UIImage(named: "windows")?.withRenderingMode(.alwaysTemplate)
            attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        } else {
            if vkSingleton.shared.userID == "357365563" {
                delegate.showInfoMessage(title: "Источник записи", msg: "Неопознанный источник записи: \(source)")
            }
        }
        
        let attachmentStr = NSAttributedString(attachment: attachment)
        
        let mutableAttributedString = NSMutableAttributedString(string: " ")
        mutableAttributedString.append(attachmentStr)
        
        let textString = NSAttributedString(string: text, attributes: [.font: self.font])
        mutableAttributedString.append(textString)
        
        self.attributedText = mutableAttributedString
    }
}
