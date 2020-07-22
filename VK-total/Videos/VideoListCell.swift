//
//  VideoListCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox

class VideoListCell: UITableViewCell {
    
    var videoImage: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var markCheck: BEMCheckBox!
    
    var delegate: UIViewController!
    
    let leftInsets: CGFloat = 5
    let topInsets: CGFloat = 5
    
    
    func configureCell(video: Videos, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
     
        self.backgroundColor = .clear
        
        let subviews = self.subviews
        for subview in subviews {
            if subview is UIImageView || subview is UILabel || subview is BEMCheckBox {
                subview.removeFromSuperview()
            }
        }
        
        videoImage = UIImageView()
        
        let getCacheImage = GetCacheImage(url: video.photoURL, lifeTime: .userPhotoImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: videoImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.videoImage.contentMode = .scaleAspectFit
            self.videoImage.clipsToBounds = true
            self.videoImage.layer.cornerRadius = 4
            
        }
        
        let width = UIScreen.main.bounds.width * 0.5
        let height = width * CGFloat(240) / CGFloat(320)
        
        videoImage.frame = CGRect(x: leftInsets, y: topInsets, width: width - 2 * leftInsets, height: height - 2 * topInsets)
        
        self.addSubview(videoImage)
        
        
        let vidImage = UIImageView()
        vidImage.image = UIImage(named: "video")
        vidImage.frame = CGRect(x: (width - 2 * leftInsets) / 2 - 20, y: (height - 2 * topInsets) / 2 - 20, width: 40, height: 40)
        videoImage.addSubview(vidImage)
        
        let durationLabel = UILabel()
        durationLabel.text = video.duration.getVideoDurationToString()
        durationLabel.numberOfLines = 1
        durationLabel.font = UIFont(name: "Verdana-Bold", size: 10.0)!
        durationLabel.textAlignment = .center
        durationLabel.contentMode = .center
        durationLabel.textColor = .white
        durationLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        durationLabel.layer.cornerRadius = 4
        durationLabel.clipsToBounds = true
        let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
        durationLabel.frame = CGRect(x: width - 2 * leftInsets - 10 - durationLabelWidth, y: height - 2 * topInsets - 5 - 16, width: durationLabelWidth, height: 16)
        videoImage.addSubview(durationLabel)
        
        titleLabel = UILabel()
        titleLabel.textColor = vkSingleton.shared.labelColor
        titleLabel.text = video.title
        titleLabel.prepareTextForPublish2(self.delegate)
        titleLabel.font = UIFont(name: "Verdana", size: 13)!
        titleLabel.textAlignment = .center
        titleLabel.contentMode = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        
        if video.description != "" {
            titleLabel.frame = CGRect(x: width + leftInsets, y: topInsets, width: UIScreen.main.bounds.width - width - leftInsets - 30, height: 40)
            self.addSubview(titleLabel)
        } else {
            titleLabel.frame = CGRect(x: width + leftInsets, y: topInsets, width: UIScreen.main.bounds.width - width - leftInsets - 30, height: height - 2 * topInsets)
            self.addSubview(titleLabel)
        }
        
        if video.description != "" {
            descriptionLabel = UILabel()
            descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            descriptionLabel.text = video.description
            descriptionLabel.prepareTextForPublish2(self.delegate)
            descriptionLabel.font = UIFont(name: "Verdana", size: 12)!
            descriptionLabel.textAlignment = .left
            descriptionLabel.contentMode = .center
            descriptionLabel.numberOfLines = 0
            descriptionLabel.adjustsFontSizeToFitWidth = true
            descriptionLabel.minimumScaleFactor = 0.75
            
            descriptionLabel.frame = CGRect(x: width + leftInsets, y: topInsets + titleLabel.frame.height, width: UIScreen.main.bounds.width - width - leftInsets - 30, height: height - 2 * topInsets - titleLabel.frame.height)
            self.addSubview(descriptionLabel)
        }
        
        if let vc = delegate as? VideoListController, vc.source != "" {
            markCheck = BEMCheckBox()
            markCheck.tag = 200
            markCheck.onTintColor = vkSingleton.shared.mainColor
            markCheck.onCheckColor = vkSingleton.shared.mainColor
            markCheck.lineWidth = 2
            
            markCheck.isEnabled = false
            markCheck.on = false

            if let vc = delegate as? VideoListController {
                if vc.markPhotos[video.id] != nil {
                    markCheck.on = true
                }
            }
            
            
            if markCheck.on == true {
                let markImage = UIImageView()
                markImage.tag = 200
                markImage.backgroundColor = UIColor.white.withAlphaComponent(0.75)
                markImage.frame = videoImage.frame
                self.addSubview(markImage)
            }
            
            markCheck.frame = CGRect(x: leftInsets + 5, y: topInsets + 5, width: 30, height: 30)
            self.addSubview(markCheck)
        }
    }
}
