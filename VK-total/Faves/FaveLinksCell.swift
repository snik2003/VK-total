//
//  FaveLinksCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class FaveLinksCell: UITableViewCell {

    var nameLabel: UILabel!
    var descriptionLabel: UILabel!
    var avatarImage: UIImageView!
    
    var urlLabel: UILabel!
    
    let nameFont = UIFont(name: "Verdana", size: 13)!
    let descFont = UIFont(name: "Verdana", size: 12)!
    
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = bounds.size.width - 90
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 0.0
        }
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func configureCell(link: FaveLinks, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        avatarImage = UIImageView()
        avatarImage.tag = 100
        
        if link.photoURL != "" {
            let getCacheImage = GetCacheImage(url: link.photoURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            
        } else {
            self.avatarImage.image = UIImage(named: "url")
        }
        
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 19
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
        self.addSubview(avatarImage)
        
        nameLabel = UILabel()
        nameLabel.tag = 100
        nameLabel.text = "\(link.title)"
        nameLabel.font = nameFont
        nameLabel.numberOfLines = 0
        let nameLabelSize = getTextSize(text: nameLabel.text!, font: nameLabel.font)
        nameLabel.frame = CGRect(x: 60, y: 5, width: nameLabelSize.width, height: nameLabelSize.height)
        self.addSubview(nameLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.tag = 100
        descriptionLabel.text = "\(link.description)"
        descriptionLabel.font = descFont
        descriptionLabel.numberOfLines = 0
        descriptionLabel.isEnabled = false
        let descriptionLabelSize = getTextSize(text: descriptionLabel.text!, font: descriptionLabel.font)
        
        descriptionLabel.frame = CGRect(x: 60, y: 5 + nameLabelSize.height, width: descriptionLabelSize.width, height: descriptionLabelSize.height)
        self.addSubview(descriptionLabel)
        
        nameLabel.textColor = vkSingleton.shared.labelColor
        descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
        
        urlLabel = UILabel()
        urlLabel.tag = 100
        urlLabel.text = link.url
        urlLabel.font = descFont
        urlLabel.numberOfLines = 0
        urlLabel.textColor = urlLabel.tintColor
        urlLabel.numberOfLines = 0
        
        let urlLabelSize = getTextSize(text: urlLabel.text!, font: descriptionLabel.font)
        urlLabel.frame = CGRect(x: 60, y: 5 + nameLabelSize.height + descriptionLabelSize.height, width: urlLabelSize.width, height: urlLabelSize.height)
        
        self.addSubview(urlLabel)
    }
    
    func getRowHeight(link: FaveLinks) -> CGFloat {
        
        var height: CGFloat = 0
        let nameLabelSize = getTextSize(text: link.title, font: nameFont)
        let descriptionLabelSize = getTextSize(text: link.description, font: descFont)
        let urlLabelSize = getTextSize(text: link.url, font: descFont)
        
        height = 5 + nameLabelSize.height + descriptionLabelSize.height + urlLabelSize.height
        
        if height > 60 {
            return height
        }
        
        return 60
    }
}
