//
//  TopicCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 02.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {

    let avatarImage = UIImageView()
    let nameLabel = UILabel()
    let createdLabel = UILabel()
    let updatedLabel = UILabel()
    let titleLabel = UILabel()
    let commentLabel = UILabel()
    let countLabel = UILabel()
    let closedLabel = UILabel()
    
    let leftInsets: CGFloat = 10
    let topInsets: CGFloat = 5
    
    let avatarHeight: CGFloat = 50
    
    let titleFont = UIFont(name: "Verdana-Bold", size: 12)!
    let commentFont = UIFont(name: "Verdana", size: 12)!
    let countFont = UIFont(name: "Verdana-Bold", size: 10)!
    let closedFont = UIFont(name: "Verdana-Bold", size: 11)!
    
    func configureCell(topic: Topic, group: [GroupProfile], profiles: [WallProfiles], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        for subview in self.subviews {
            if subview is UILabel || subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        var url = ""
        var name = ""
        
        if group.count > 0 {
            url = group[0].photo100
            name = group[0].name
        }
        
        let profile = profiles.filter({ $0.uid == topic.createdBy })
        if profile.count > 0 && profile[0].lastName != "Администратор" && profile[0].firstName != "Администратор"{
            url = profile[0].photoURL
            name = "\(profile[0].firstName) \(profile[0].lastName)"
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.layer.cornerRadius = 25
            self.avatarImage.contentMode = .scaleAspectFit
            self.avatarImage.clipsToBounds = true
        }
        
        avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
        self.addSubview(avatarImage)
        
        
        nameLabel.text = name
        if topic.isFixed == 1 {
            nameLabel.text = "📌 \(name)"
        }
        nameLabel.textColor = UIColor.black
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.3
        
        nameLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 5, width: bounds.width - 3 * leftInsets - avatarHeight, height: 20)
        self.addSubview(nameLabel)
        
        
        createdLabel.text = "Дата создания: \(topic.created.toStringLastTime())"
        createdLabel.font = UIFont(name: "Verdana", size: 10)!
        createdLabel.adjustsFontSizeToFitWidth = true
        createdLabel.minimumScaleFactor = 0.5
        createdLabel.isEnabled = false
        
        createdLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 24, width: bounds.width - 3 * leftInsets - avatarHeight, height: 15)
        self.addSubview(createdLabel)
        
        updatedLabel.text = "Дата обновления: \(topic.updated.toStringLastTime())"
        updatedLabel.font = UIFont(name: "Verdana", size: 10)!
        updatedLabel.adjustsFontSizeToFitWidth = true
        updatedLabel.minimumScaleFactor = 0.5
        updatedLabel.isEnabled = false
        
        updatedLabel.frame = CGRect(x: 2 * leftInsets + avatarHeight, y: 38, width: bounds.width - 3 * leftInsets - avatarHeight, height: 15)
        self.addSubview(updatedLabel)
        
        var topY: CGFloat = 2 * topInsets + avatarHeight
        
        titleLabel.text = topic.title.prepareTextForPublic()
        titleLabel.font = titleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        let titleLabelSize = getTextSize(text: topic.title.prepareTextForPublic(), font: titleFont)
        
        titleLabel.frame = CGRect(x: leftInsets, y: topY, width: titleLabelSize.width, height: titleLabelSize.height)
        self.addSubview(titleLabel)
        
        topY += titleLabelSize.height
        
        commentLabel.text = topic.firstCommentText.prepareTextForPublic()
        commentLabel.font = commentFont
        commentLabel.numberOfLines = 0
        let commentLabelSize = getTextSize(text: topic.firstCommentText.prepareTextForPublic(), font: commentFont)
        
        commentLabel.frame = CGRect(x: leftInsets, y: topY, width: commentLabelSize.width, height: commentLabelSize.height)
        self.addSubview(commentLabel)
        
        topY += commentLabelSize.height
        
        if topic.isClosed == 1 {
            closedLabel.text = "Обсуждение закрыто"
            closedLabel.textAlignment = .center
            closedLabel.textColor = UIColor.purple
            closedLabel.font = closedFont
            closedLabel.numberOfLines = 1
            
            closedLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.width - 2 * leftInsets, height: 20)
            self.addSubview(closedLabel)
            topY += 20
        }
        
        countLabel.text = "Комментариев: \(topic.commentsCount)"
        countLabel.textAlignment = .right
        countLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        countLabel.font = countFont
        countLabel.numberOfLines = 1
        
        countLabel.frame = CGRect(x: leftInsets, y: topY, width: bounds.width - 2 * leftInsets, height: 20)
        self.addSubview(countLabel)
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getRowHeight(topic: Topic) -> CGFloat {
        
        var topY: CGFloat = 2 * topInsets + avatarHeight
        
        let titleLabelSize = getTextSize(text: topic.title.prepareTextForPublic(), font: titleFont)
        topY += titleLabelSize.height
        
        let commentLabelSize = getTextSize(text: topic.firstCommentText.prepareTextForPublic(), font: commentFont)
        topY += commentLabelSize.height + 20
        
        if topic.isClosed == 1 {
            topY += 20
        }
        
        return topY
    }
}
