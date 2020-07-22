//
//  AddAccountCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 01.06.2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import UIKit

class AddAccountCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    
    @IBOutlet weak var friendsButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var notesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messagesButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleLabelTrainlingConstraint: NSLayoutConstraint!
    
    func configureCell(account: AccountVK, friendsCounter: Int, messagesCounter: Int, notesCounter: Int, indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        self.backgroundColor = .clear
        
        for subview in self.subviews {
            if subview.tag == 100 { subview.removeFromSuperview() }
        }
        
        titleLabel.tag = 100
        titleLabel.text = "\(account.firstName) \(account.lastName)"
        titleLabel.textColor = vkSingleton.shared.labelColor
        titleLabel.font = UIFont(name: "Verdana", size: 13.0)
        titleLabel.numberOfLines = 1
        
        if vkSingleton.shared.userID == "\(account.userID)" {
            titleLabel.font = UIFont(name: "Verdana-Bold", size: 13.0)
        }
        
        subtitleLabel.tag = 100
        subtitleLabel.textColor = self.tintColor
        subtitleLabel.font = UIFont(name: "Verdana", size: 11.0)
        subtitleLabel.isEnabled = true
        subtitleLabel.text = "https://vk.com/\(account.screenName)"
        
        
        avatarImage.tag = 100
        avatarImage.layer.cornerRadius = 25
        avatarImage.clipsToBounds = true
        avatarImage.layer.borderColor = UIColor.gray.cgColor
        avatarImage.layer.borderWidth = 0.6
        avatarImage.image = UIImage(named: "error")
        
        let getCacheImage = GetCacheImage(url: account.avatarURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImage.contentMode = .scaleAspectFit
            
            if vkSingleton.shared.userID == "\(account.userID)" {
                cell.backgroundColor = vkSingleton.shared.separatorColor
            } else {
                cell.backgroundColor = vkSingleton.shared.backColor
                
            }
        }
        
        var rightX: CGFloat = 0
        
        if friendsCounter == 0 {
            friendsButtonWidthConstraint.constant = 0
            friendsButton.isHidden = true
            
            friendsButton.imageView?.tintColor = vkSingleton.shared.mainColor
            friendsButton.setTitleColor(vkSingleton.shared.mainColor, for: .normal)
            friendsButton.setTitle("0", for: .normal)
        } else {
            rightX += 50
            friendsButtonWidthConstraint.constant = 50
            friendsButton.isHidden = false
            
            friendsButton.imageView?.tintColor = vkSingleton.shared.likeColor
            friendsButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
            friendsButton.setTitle("+\(friendsCounter)", for: .normal)
        }
        
        if messagesCounter == 0 {
            messagesButtonWidthConstraint.constant = 0
            messagesButton.isHidden = true
            
            messagesButton.imageView?.tintColor = vkSingleton.shared.mainColor
            messagesButton.setTitleColor(vkSingleton.shared.mainColor, for: .normal)
            messagesButton.setTitle("0", for: .normal)
        } else {
            rightX += 50
            messagesButtonWidthConstraint.constant = 50
            messagesButton.isHidden = false
            
            messagesButton.imageView?.tintColor = vkSingleton.shared.likeColor
            messagesButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
            messagesButton.setTitle("+\(messagesCounter)", for: .normal)
        }
        
        if notesCounter == 0 {
            notesButtonWidthConstraint.constant = 0
            notesButton.isHidden = true
            
            notesButton.imageView?.tintColor = vkSingleton.shared.mainColor
            notesButton.setTitleColor(vkSingleton.shared.mainColor, for: .normal)
            notesButton.setTitle("0", for: .normal)
        } else {
            rightX += 50
            notesButtonWidthConstraint.constant = 50
            notesButton.isHidden = false
            
            notesButton.imageView?.tintColor = vkSingleton.shared.likeColor
            notesButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
            notesButton.setTitle("+\(notesCounter)", for: .normal)
        }
        
        subtitleLabelTrainlingConstraint.constant = 10 + rightX
    }
}
