//
//  SetImageToRow.swift
//  VK-total
//
//  Created by Сергей Никитин on 03.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class SetImageToRowOfTableView: Operation {
    
    private let indexPath: IndexPath
    private weak var tableView: UITableView?
    private var imageView: UIImageView?
    private var cell: UITableViewCell?
    
    init(cell: UITableViewCell, imageView: UIImageView, indexPath: IndexPath, tableView: UITableView) {
        self.indexPath = indexPath
        self.tableView = tableView
        self.imageView = imageView
        self.cell = cell
    }
    
    override func main() {
        
        guard let tableView = tableView,
            let imageView = imageView,
            let cell = cell,
            let getCacheImage = dependencies.first as? GetCacheImage,
            let image = getCacheImage.outputImage else { return }
        
        if let newIndexPath = tableView.indexPath(for: cell), newIndexPath == indexPath {
            imageView.image = image
        } else if tableView.indexPath(for: cell) != nil {
            imageView.image = image
        } 
    }
}

class SetImageToRowOfCollectionView: Operation {
    
    private let indexPath: IndexPath
    private weak var collectionView: UICollectionView?
    private var imageView: UIImageView?
    private var cell: UICollectionViewCell?
    
    init(cell: UICollectionViewCell, imageView: UIImageView, indexPath: IndexPath, collectionView: UICollectionView) {
        self.indexPath = indexPath
        self.collectionView = collectionView
        self.imageView = imageView
        self.cell = cell
    }
    
    override func main() {
        
        guard let collectionView = collectionView,
            let imageView = imageView,
            let cell = cell,
            let getCacheImage = dependencies.first as? GetCacheImage,
            let image = getCacheImage.outputImage else { return }
        
        if let newIndexPath = collectionView.indexPath(for: cell), newIndexPath == indexPath {
            imageView.image = image
        } else if collectionView.indexPath(for: cell) == nil {
            imageView.image = image
        }
    }
}

class SetImageToCommentRow: Operation {
    
    private var imageView: UIImageView?
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    override func main() {
        
        guard let imageView = imageView,
            let getCacheImage = dependencies.first as? GetCacheImage,
            let image = getCacheImage.outputImage else { return }
        
        imageView.image = image
    }
}
