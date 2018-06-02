//
//  ReloadDialogHistoryController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadDialogHistoryController: Operation {
    var controller: DialogTableViewController
    
    init(controller: DialogTableViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseDialogHistory = dependencies.first as? ParseDialogHistory, let parseDialogsUsers = dependencies[1] as? ParseDialogsUsers else { return }
        controller.dialog = parseDialogHistory.outputData
        controller.users = parseDialogsUsers.outputData
        
        controller.view.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 244/255, alpha: 1)
        
        if controller.dialog.count > 0 {
            for index in 0...controller.dialog.count - 1 {
                let mess = controller.dialog[index]
                if mess.mid != 0 && mess.readState == 0 {
                    controller.unreadSection = index
                    break
                }
            }
        }
            
        let navView = setTitleView(url: controller.photoURL, title: controller.userName, titleFont: UIFont(name: "Verdana-Bold", size: 14.0)!)
        controller.navigationItem.titleView = navView
        controller.navigationItem.backBarButtonItem?.title = ""
        navView.sizeToFit()
        
        controller.tableView.reloadData()
        if controller.dialog.count > 0 {
            controller.tableView.scrollToRow(at: IndexPath(item: 0, section: controller.dialog.count - 1), at: UITableViewScrollPosition.bottom, animated: false)
        }
        ViewControllerUtils().hideActivityIndicator()
    }
    
    func setTitleView(url: String, title: String, titleFont: UIFont) -> UIView {
        
        let navView = UIView()
        
        let label = UILabel()
        label.text = title
        if title.length > 18 {
            let arr = title.components(separatedBy: " ")
            label.text = arr[0]
        }
        label.textColor = UIColor.white
        label.font = titleFont
        label.sizeToFit()
        label.center = CGPoint(x: navView.center.x + 25, y: navView.center.y)
        label.textAlignment = .center
        
        let imageView = UIImageView()
        let getCacheImage = GetCacheImage(url: controller.photoURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage.outputImage
                imageView.layer.cornerRadius = 17
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: label.frame.origin.x - 40, y: label.frame.origin.y - 7, width: 34.0, height: 34)
                imageView.contentMode = .scaleAspectFit
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        navView.addSubview(label)
        navView.addSubview(imageView)
        
        return navView
    }
}
