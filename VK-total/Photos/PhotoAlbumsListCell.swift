//
//  PhotoAlbumsListCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotoAlbumsListCell: UITableViewCell {

    var coverImage: [UIImageView?] = [nil, nil]
    var nameLabel: [UILabel?] = [nil, nil]
    
    var tap1: UITapGestureRecognizer!
    var tap2: UITapGestureRecognizer!
    
    func configureCell(albums: [PhotoAlbum], indexPath: IndexPath ) {
       
        for subview in self.subviews {
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        for ind in 0...1 {
            let index = 2 * indexPath.row + ind
            
            if index < albums.count {
                coverImage[ind] = UIImageView()
                coverImage[ind]?.image = UIImage(named: "error")
                
                let getCacheImage = GetCacheImage(url: albums[index].thumbSrc, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.coverImage[ind]?.image = getCacheImage.outputImage
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation {
                    self.coverImage[ind]?.contentMode = .scaleAspectFill
                    self.coverImage[ind]?.clipsToBounds = true
                }
                
                let coverX: CGFloat = 5 + CGFloat(ind) * UIScreen.main.bounds.width * 0.5
                let coverY: CGFloat = 30
                
                let width: CGFloat = UIScreen.main.bounds.width * 0.5 - 5
                let height: CGFloat = UIScreen.main.bounds.width * 0.5 * CGFloat(240) / CGFloat(320) - 5
                
                coverImage[ind]?.frame = CGRect(x: coverX, y: coverY, width: width, height: height)
                
                self.addSubview(coverImage[ind]!)
                
                nameLabel[ind] = UILabel()
                nameLabel[ind]?.text = albums[index].title
                nameLabel[ind]?.font = UIFont(name: "Verdana", size: 12)!
                nameLabel[ind]?.contentMode = .center
                nameLabel[ind]?.textAlignment = .center
                nameLabel[ind]?.numberOfLines = 2
                nameLabel[ind]?.adjustsFontSizeToFitWidth = true
                nameLabel[ind]?.minimumScaleFactor = 0.6
                
                nameLabel[ind]?.frame = CGRect(x: 10 + CGFloat(ind) * UIScreen.main.bounds.width * 0.5, y: 0, width: width - 10, height: 30)
                self.addSubview(nameLabel[ind]!)
                
                
                let countLabel = UILabel()
                countLabel.text = "\(albums[index].size) фото"
                countLabel.font = UIFont(name: "Verdana", size: 12)!
                countLabel.backgroundColor = UIColor(displayP3Red: 146/255, green: 146/255, blue: 146/255, alpha: 1).withAlphaComponent(0.7)
                countLabel.contentMode = .bottom
                countLabel.textAlignment = .center
                countLabel.numberOfLines = 1
                
                countLabel.frame = CGRect(x: 0, y: height - 15, width: width, height: 15)
                coverImage[ind]?.addSubview(countLabel)
                
                if ind == 0 {
                    tap1 = UITapGestureRecognizer()
                    tap1.numberOfTapsRequired = 1
                    coverImage[ind]?.addGestureRecognizer(tap1)
                    coverImage[ind]?.isUserInteractionEnabled = true
                }
                
                if ind == 1 {
                    tap2 = UITapGestureRecognizer()
                    tap2.numberOfTapsRequired = 1
                    coverImage[ind]?.addGestureRecognizer(tap2)
                    coverImage[ind]?.isUserInteractionEnabled = true
                }
            }
        }
    }
}
