//
//  ReloadPhotosListController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ReloadPhotosListController: Operation {
    var controller: PhotosListController
    
    init(controller: PhotosListController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parsePhotos = dependencies[0] as? ParsePhotosList, let parseAlbums = dependencies[1] as? ParsePhotoAlbums else { return }
        
        controller.albums = parseAlbums.outputData
        controller.photosCount = parsePhotos.count
        
        controller.segmentedControl.selectedSegmentIndex = controller.selectIndex
        switch controller.selectIndex {
        case 0:
            if controller.offset == 0 {
                controller.photos = parsePhotos.outputData
            } else {
                for index in 0...parsePhotos.outputData.count-1 {
                    controller.photos.append(parsePhotos.outputData[index])
                }
            }
            controller.heightRow = (UIScreen.main.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
        case 1:
            controller.photos = parsePhotos.outputData
            controller.heightRow = (UIScreen.main.bounds.width * 0.5) * CGFloat(240) / CGFloat(320) + 30
        default:
            break
        }
        
        controller.offset += controller.count
        controller.tableView.estimatedRowHeight = controller.heightRow
        controller.tableView.rowHeight = controller.heightRow
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .none
        ViewControllerUtils().hideActivityIndicator()
    }
}
