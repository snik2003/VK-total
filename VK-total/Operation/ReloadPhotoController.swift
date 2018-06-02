//
//  ReloadPhotoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadPhotoController: Operation {
    var controller: PhotoViewController
    
    init(controller: PhotoViewController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parsePhoto = dependencies[0] as? ParsePhotoData, let parseLikes = dependencies[1] as? ParseLikes, let parseReposts = dependencies[2] as? ParseLikes else { return }
        
        controller.photo = parsePhoto.outputData
        controller.likes = parseLikes.outputData
        controller.reposts = parseReposts.outputData
        
        if controller.photo.count > 0 {
            let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: controller, action: #selector(controller.tapBarButtonItem(sender:)))
            controller.navigationItem.rightBarButtonItem = barButton
        }
        
        controller.title = "Фото \(controller.numPhoto + 1)/\(controller.photos.count)"
        controller.tableView.reloadData()
        ViewControllerUtils().hideActivityIndicator()
    }
}
