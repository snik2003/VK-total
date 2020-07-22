//
//  MyMusicCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 23.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class MyMusicCell: UITableViewCell {

    var avatarImage = UIImageView()
    var artistLabel = UILabel()
    var songLabel = UILabel()
    var listenButton = UIButton()
    
    var leftInsets: CGFloat = 10.0
    var topInsets: CGFloat = 5.0
    var avatarSize: CGFloat = 40.0
    var listenButtonSize: CGFloat = 30.0
    
    func configureCell(song: IMusic, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = .clear
        
        for subview in self.subviews {
            if subview is UIImageView || subview is UILabel || subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        if song.reserv5 != "" {
            let getCacheImage = GetCacheImage(url: song.reserv5, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.avatarImage.clipsToBounds = true
                self.avatarImage.contentMode = .scaleAspectFit
                self.avatarImage.layer.cornerRadius = 20.0
            }
        } else {
            avatarImage.image = UIImage(named: "music")
        }
        
        artistLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        songLabel.font = UIFont(name: "Verdana", size: 13)!
        
        avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarSize, height: avatarSize)
                
        artistLabel.frame = CGRect (x: 2 * leftInsets + avatarSize, y: 9, width: bounds.size.width - 4 * leftInsets - avatarSize - listenButtonSize, height: 16)
        artistLabel.text = song.artist
        artistLabel.textColor = vkSingleton.shared.labelColor
        
        songLabel.frame = CGRect (x: 2 * leftInsets + avatarSize, y: 25, width: bounds.size.width - 4 * leftInsets - avatarSize - listenButtonSize, height: 16)
        songLabel.textColor = songLabel.tintColor
        songLabel.text = song.song
        
        listenButton.setImage(UIImage(named: "listen-music"), for: .normal)
        listenButton.imageView?.tintColor = vkSingleton.shared.mainColor
        listenButton.frame = CGRect(x: bounds.size.width - leftInsets - listenButtonSize, y: 2 * topInsets, width: listenButtonSize, height: listenButtonSize)
        
        self.addSubview(avatarImage)
        self.addSubview(artistLabel)
        self.addSubview(songLabel)
        self.addSubview(listenButton)
    }
}
