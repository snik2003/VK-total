//
//  ReloadDialogsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadDialogsController: Operation {
    var controller: DialogsController
    
    init(controller: DialogsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseDialogs = dependencies[0] as? ParseDialogs else { return }
        
        
        switch controller.selectedMenu {
        case 0:
            controller.dialogs = controller.menuDialogs
            break
        case 1:
            var importantDialogs: [Message] = []
            for dialog in controller.menuDialogs {
                if let conversation = controller.conversations.filter({ $0.peerID == dialog.peerID }).first, conversation.important {
                    importantDialogs.append(dialog)
                }
            }
            controller.dialogs = importantDialogs
            break
        case 2:
            controller.dialogs = controller.menuDialogs.filter({ $0.chatID > 0 })
            break
        case 3:
            controller.dialogs = controller.menuDialogs.filter({ $0.userID < 0 })
            break
        case 4:
            controller.dialogs = controller.menuDialogs.filter({ $0.readState == 0 && $0.out == 0 })
            break
        default:
            break
        }
        
        controller.removeDuplicatesFromDialogs()
        controller.dialogs.sort(by: { $0.date > $1.date })
        
        controller.totalCount = parseDialogs.count
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        controller.refreshControl?.endRefreshing()
        
        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(controller.tapBarButtonItem(sender:)))
        controller.navigationItem.rightBarButtonItem = barButton
        
        ViewControllerUtils().hideActivityIndicator()
    }
}

