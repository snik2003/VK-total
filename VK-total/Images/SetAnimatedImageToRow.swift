//
//  SetAnimatedImageToRow.swift
//  VK-total
//
//  Created by Сергей Никитин on 20.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import FLAnimatedImage

class SetAnimatedImageToRow: Operation {
    
    private let data: Data
    private let indexPath: IndexPath
    private weak var tableView: UITableView?
    private var imageView: UIImageView?
    private var cell: UITableViewCell?
    
    init(data: Data, imageView: UIImageView,  cell: UITableViewCell, indexPath: IndexPath, tableView: UITableView) {
        self.data = data
        self.indexPath = indexPath
        self.tableView = tableView
        self.imageView = imageView
        self.cell = cell
    }
    
    override func main() {
        
        guard let tableView = tableView,
            let imageView = imageView,
            let cell = cell,
            let imageGIF = FLAnimatedImage(animatedGIFData: data) else { return }
        
        if let newIndexPath = tableView.indexPath(for: cell), newIndexPath == indexPath {
            let imageViewGif = FLAnimatedImageView()
            imageViewGif.animatedImage = imageGIF
            imageViewGif.frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
            imageView.image = nil
            imageView.addSubview(imageViewGif)
        }
    }
}
