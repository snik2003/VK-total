//
//  OwnerButtonsCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 12.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class OwnerButtonsCell: UITableViewCell {

    @IBOutlet weak var allRecordsButton: UIButton! {
        didSet {
            allRecordsButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var ownerButton: UIButton! {
        didSet {
            ownerButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let leftInsets: CGFloat = 25.0
    let topInsets: CGFloat = 5.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        
        let maxWidth = bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func configureCell(profile: UserProfileInfo) {
        
        allRecordsButton.setTitle("Все записи", for: .normal)
        allRecordsButton.setTitle("Все записи", for: .selected)
        
        let allRecordsButtonSize = getTextSize(text: "Все записи", font: UIFont(name: "Verdana", size: 14.0)!)
        
        allRecordsButton.frame = CGRect(x: leftInsets, y: topInsets, width: allRecordsButtonSize.width + 20, height: bounds.size.height - 2 * topInsets)
        
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .selected)
        ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .normal)
        
        let ownerButtonSize = getTextSize(text: "Записи \(profile.firstNameGen)", font: UIFont(name: "Verdana", size: 14.0)!)
        
        ownerButton.frame = CGRect(x: bounds.size.width - ownerButtonSize.width - leftInsets - 20, y: topInsets, width: ownerButtonSize.width + 20, height: bounds.size.height - 2 * topInsets)
        
        if allRecordsButton.isSelected {
            allRecordsButton.setTitleColor(UIColor.white, for: .selected)
            allRecordsButton.layer.borderColor = UIColor.black.cgColor
            allRecordsButton.clipsToBounds = true
            allRecordsButton.tintColor = UIColor.lightGray
            allRecordsButton.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(UIColor.black, for: .normal)
            ownerButton.clipsToBounds = true
            ownerButton.tintColor = UIColor.lightGray
            
        }
        
        if ownerButton.isSelected {
            ownerButton.setTitleColor(UIColor.white, for: .selected)
            ownerButton.layer.borderColor = UIColor.black.cgColor
            ownerButton.clipsToBounds = true
            ownerButton.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(UIColor.black, for: .normal)
            allRecordsButton.clipsToBounds = true
            allRecordsButton.tintColor = UIColor.lightGray
            
        }
        
        allRecordsButton.isHidden = false
        ownerButton.isHidden = false
    }

}
