//
//  ReloadProfileInfoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 29.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

class ReloadProfileInfoController: Operation {
    var controller: ChangeProfileInfoController
    
    init(controller: ChangeProfileInfoController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseProfile = dependencies[0] as? ParseProfileInfo else { return }
        
        controller.profile = parseProfile.outputData
        controller.loadProfileInfo()
        ViewControllerUtils().hideActivityIndicator()
    }
}
