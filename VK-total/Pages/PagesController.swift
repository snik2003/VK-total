//
//  PagesController.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class PagesController: InnerViewController {

    var pageID = 0
    var groupID = 0
    
    var page: [Page] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getPage() {
        let opq = OperationQueue()
        
        let url = "/method/pages.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(groupID)",
            "page_id": "\(pageID)",
            "global": "1",
            "site_preview": "1",
            "need_html": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parsePage = ParsePage()
        parsePage.addDependency(getServerDataOperation)
        parsePage.completionBlock = {
            self.showInfoMessage(title: "JSON of Page", msg: parsePage.dataString)
        }
        opq.addOperation(parsePage)
    }
}
