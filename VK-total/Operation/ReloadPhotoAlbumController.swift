//
//  ReloadPhotoAlbumController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadPhotoAlbumController: Operation {
    var controller: PhotoAlbumController
    
    init(controller: PhotoAlbumController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parsePhotos = dependencies[0] as? ParsePhotosList else { return }
        
        controller.photosCount = parsePhotos.count
        
        if controller.offset == 0 {
            controller.photos = parsePhotos.outputData
        } else {
            for index in 0...parsePhotos.outputData.count-1 {
                controller.photos.append(parsePhotos.outputData[index])
            }
        }
        
        controller.offset += controller.count
        controller.tableView.estimatedRowHeight = controller.heightRow
        controller.tableView.rowHeight = controller.heightRow
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        ViewControllerUtils().hideActivityIndicator()
    }
}

