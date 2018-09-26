//
//  StatusButtonsCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 12.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class StatusButtonsCell: UITableViewCell {

    @IBOutlet weak var messageButton: UIButton! {
        didSet {
            messageButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var friendButton: UIButton! {
        didSet {
            friendButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let leftInsets: CGFloat = 10.0
    let interInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureCell(profile: UserProfileInfo) {
        
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.layer.borderWidth = 0.6
        messageButton.layer.cornerRadius = 15
        messageButton.clipsToBounds = true
        
        friendButton.titleLabel?.textAlignment = .center
        friendButton.layer.borderColor = UIColor.black.cgColor
        friendButton.layer.borderWidth = 0.6
        friendButton.layer.cornerRadius = 15
        friendButton.clipsToBounds = true
        
        if profile.canWritePrivateMessage == 1 {
            messageButton.isEnabled = true
            messageButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        } else {
            messageButton.isEnabled = false
            messageButton.backgroundColor = UIColor.lightGray
        }
        
        if profile.friendStatus == 0 {
            if profile.canSendFriendRequest == 1 {
                friendButton.setTitle("Добавить в друзья", for: UIControl.State.normal)
                friendButton.setTitle("Добавить в друзья", for: UIControl.State.disabled)
                friendButton.isEnabled = true
                friendButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            } else {
                friendButton.setTitle("Вы не друзья", for: UIControl.State.normal)
                friendButton.setTitle("Вы не друзья", for: UIControl.State.disabled)
                friendButton.isEnabled = false
                friendButton.backgroundColor = UIColor.lightGray
            }
        }
        
        if profile.friendStatus == 1 {
            friendButton.setTitle("Вы подписаны", for: UIControl.State.normal)
            friendButton.setTitle("Вы подписаны", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.lightGray
        }
        
        if profile.friendStatus == 2 {
            friendButton.setTitle("Подписан на вас", for: UIControl.State.normal)
            friendButton.setTitle("Подписан на вас", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        }
        
        if profile.friendStatus == 3 {
            friendButton.setTitle("У Вас в друзьях", for: UIControl.State.normal)
            friendButton.setTitle("У Вас в друзьях", for: UIControl.State.disabled)
            friendButton.isEnabled = true
            friendButton.backgroundColor = UIColor.lightGray
        }
        
        messageButton.isHidden = false
        //friendButton.isSelected = false
        //friendButton.isHighlighted = false
        friendButton.isHidden = false
        
        let width = (bounds.size.width - 2 * leftInsets - interInsets) / 2
        let friendButtonX = bounds.size.width - leftInsets - width
        
        messageButton.frame = CGRect(x: leftInsets, y: topInsets, width: width, height: bounds.size.height - 2 * topInsets)
        friendButton.frame = CGRect(x: friendButtonX, y: topInsets, width: width, height: bounds.size.height - 2 * topInsets)
        
    }
}
