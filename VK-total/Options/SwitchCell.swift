//
//  SwitchCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 08.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    @IBOutlet weak var pushSwitch: UISwitch!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 40 - 40
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getRowHeight(text: String, font: UIFont) -> CGFloat {
        
        if text == "" {
            return 45
        }
        
        let height = getTextSize(text: text, font: font).height
        return height + 45
    }
}
