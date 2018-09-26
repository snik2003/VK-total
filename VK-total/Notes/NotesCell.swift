//
//  NotesCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let urlLabel = UILabel()
    let createdLabel = UILabel()
    let countLabel = UILabel()
    
    let leftInsets: CGFloat = 10
    let topInsets: CGFloat = 5
    
    
    let titleFont = UIFont(name: "Verdana", size: 14)!
    let dateFont = UIFont(name: "Verdana", size: 10)!
    let urlFont = UIFont(name: "Verdana", size: 12)!
    let countFont = UIFont(name: "Verdana", size: 11)!
    
    
    func configureCell(note: Notes) {
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }
        
        createdLabel.tag = 100
        createdLabel.text = "\(note.date.toStringLastTime())"
        createdLabel.font = dateFont
        createdLabel.textAlignment = .left
        createdLabel.adjustsFontSizeToFitWidth = true
        createdLabel.minimumScaleFactor = 0.5
        createdLabel.isEnabled = false
        
        createdLabel.frame = CGRect(x: leftInsets, y: 0, width: UIScreen.main.bounds.width - 4 * leftInsets, height: 20)
        self.addSubview(createdLabel)
        var topY: CGFloat = 20
        
        titleLabel.tag = 100
        titleLabel.text = note.title.prepareTextForPublic()
        titleLabel.font = titleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        let titleLabelSize = getTextSize(text: note.title.prepareTextForPublic(), font: titleFont)
        
        titleLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 4 * leftInsets, height: titleLabelSize.height)
        self.addSubview(titleLabel)
        topY += titleLabelSize.height
        
        /*urlLabel.tag = 100
        urlLabel.text = note.viewURL
        urlLabel.font = urlFont
        urlLabel.numberOfLines = 0
        urlLabel.textAlignment = .left
        urlLabel.systemURLStyle = true
        urlLabel.isAutomaticLinkDetectionEnabled = true
        let urlLabelSize = getTextSize(text: note.viewURL, font: urlFont)
        
        urlLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 4 * leftInsets, height: urlLabelSize.height)
        self.addSubview(urlLabel)
        topY += urlLabelSize.height*/
        
        countLabel.tag = 100
        countLabel.text = "Комментариев: \(note.comments)"
        countLabel.textAlignment = .right
        countLabel.font = countFont
        countLabel.numberOfLines = 1
        //countLabel.isEnabled = false
        
        countLabel.frame = CGRect(x: leftInsets, y: topY, width: UIScreen.main.bounds.width - 4 * leftInsets, height: 20)
        self.addSubview(countLabel)
        topY += 20
        
        
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 4 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getRowHeight(note: Notes) -> CGFloat {
        
        var topY: CGFloat = 20
        
        let titleLabelSize = getTextSize(text: note.title.prepareTextForPublic(), font: titleFont)
        topY += titleLabelSize.height
        
        /*let urlLabelSize = getTextSize(text: note.viewURL, font: urlFont)
        topY += urlLabelSize.height*/
        
        topY += 20
        
        return topY
    }
}
