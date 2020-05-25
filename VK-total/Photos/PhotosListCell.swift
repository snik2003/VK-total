//
//  PhotosListCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox

class PhotosListCell: UITableViewCell {

    var delegate: UIViewController!
    
    var photoView: [UIImageView?] = [nil, nil, nil]
    var markCheck: [BEMCheckBox?] = [nil, nil, nil]
    
    var tap1: UITapGestureRecognizer!
    var tap2: UITapGestureRecognizer!
    var tap3: UITapGestureRecognizer!
    
    func configureCell(photos: [Photos], indexPath: IndexPath) {
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in self.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        for ind in 0...2 {
            let index = 3 * indexPath.row + ind
            
            if index < photos.count {
                photoView[ind] = UIImageView()
                photoView[ind]?.image = UIImage(named: "error")
                photoView[ind]?.tag = 200
                
                var source = ""
                if let vc = delegate as? PhotosListController {
                    source = vc.source
                } else if let vc = delegate as? PhotoAlbumController {
                    source = vc.source
                }
                
                let photo = photos[index]
                
                var url = photo.xbigPhotoURL
                if url == "" {
                    url = photo.bigPhotoURL
                }
                if url == "" {
                    url = photo.photoURL
                }
                
                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.photoView[ind]?.image = getCacheImage.outputImage
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation {
                    self.photoView[ind]?.contentMode = .scaleAspectFill
                    self.photoView[ind]?.clipsToBounds = true
                }
                
                let photoX: CGFloat = 3 + CGFloat(ind) * UIScreen.main.bounds.width * 0.333
                let photoY: CGFloat = 3
                
                let photoWidth: CGFloat = UIScreen.main.bounds.width * 0.333 - 3
                let photoHeight: CGFloat = (photoWidth + 3) * CGFloat(240) / CGFloat(320) - 3
                
                photoView[ind]?.frame = CGRect(x: photoX, y: photoY, width: photoWidth, height: photoHeight)
                self.addSubview(photoView[ind]!)
                
                if source != "" && source != "change_avatar" {
                    markCheck[ind] = BEMCheckBox()
                    markCheck[ind]?.tag = 200
                    markCheck[ind]?.onTintColor = vkSingleton.shared.mainColor
                    markCheck[ind]?.onCheckColor = vkSingleton.shared.mainColor
                    markCheck[ind]?.lineWidth = 2
                    
                    markCheck[ind]?.isEnabled = false
                    markCheck[ind]?.on = false
                    if let id = Int(photo.pid) {
                        if let vc = delegate as? PhotosListController {
                            if vc.markPhotos[id] != nil {
                                markCheck[ind]?.on = true
                            }
                        } else if let vc = delegate as? PhotoAlbumController {
                            if vc.markPhotos[id] != nil {
                                markCheck[ind]?.on = true
                            }
                        }
                    }
                    
                    if markCheck[ind]?.on == true {
                        let markImage = UIImageView()
                        markImage.tag = 200
                        markImage.backgroundColor = UIColor.white.withAlphaComponent(0.75)
                        markImage.frame = CGRect(x: photoX, y: photoY, width: photoWidth, height: photoHeight)
                        self.addSubview(markImage)
                    }
                        
                    markCheck[ind]?.frame = CGRect(x: photoX + 5, y: photoY + 5, width: 20, height: 20)
                    self.addSubview(markCheck[ind]!)
                }
                
                
                if ind == 0 {
                    tap1 = UITapGestureRecognizer()
                    tap1.numberOfTapsRequired = 1
                    photoView[ind]?.addGestureRecognizer(tap1)
                    photoView[ind]?.isUserInteractionEnabled = true
                }
                
                if ind == 1 {
                    tap2 = UITapGestureRecognizer()
                    tap2.numberOfTapsRequired = 1
                    photoView[ind]?.addGestureRecognizer(tap2)
                    photoView[ind]?.isUserInteractionEnabled = true
                }
                
                if ind == 2 {
                    tap3 = UITapGestureRecognizer()
                    tap3.numberOfTapsRequired = 1
                    photoView[ind]?.addGestureRecognizer(tap3)
                    photoView[ind]?.isUserInteractionEnabled = true
                }
            }
        }
    }
}
