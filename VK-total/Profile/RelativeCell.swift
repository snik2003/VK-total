//
//  RelativeCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class RelativeCell: UITableViewCell {

    var delegate: UserInfoTableViewController!
    
    func configureCell(relatives: [Relatives], users: [DialogsUsers]) {
        
        for subview in self.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        let titleLabel = UILabel()
        titleLabel.tag = 200
        titleLabel.text = "Родственники"
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        titleLabel.textColor = vkSingleton.shared.mainColor
        titleLabel.frame = CGRect(x: 16, y: 3, width: UIScreen.main.bounds.width - 20, height: 20)
        self.addSubview(titleLabel)
        
        var topY: CGFloat = 23
        for rel in relatives {
            
            let user = users.filter({ $0.uid == "\(rel.id)" })
            if user.count > 0 {
                let typeLabel = UILabel()
                typeLabel.tag = 200
                typeLabel.text = delegate.relativesToString(type: rel.type, sex: user[0].sex)
                typeLabel.font = UIFont(name: "Verdana", size: 13)!
                typeLabel.frame = CGRect(x: 50, y: topY, width: 70, height: 30)
                self.addSubview(typeLabel)
                
                let nameLabel = UILabel()
                nameLabel.tag = 200
                nameLabel.text = "\(user[0].firstName) \(user[0].lastName)"
                nameLabel.textColor = nameLabel.tintColor
                nameLabel.font = UIFont(name: "Verdana", size: 13)!
                nameLabel.frame = CGRect(x: 120, y: topY, width: self.bounds.width - 130, height: 30)
                self.addSubview(nameLabel)
                
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                tap.add {
                    self.delegate.openProfileController(id: rel.id, name: "\(user[0].firstName) \(user[0].lastName)")
                }
                nameLabel.addGestureRecognizer(tap)
                nameLabel.isUserInteractionEnabled = true
                
                topY += 30
            }
        }
    }
    
    func getRowHeight(relatives: [Relatives], users: [DialogsUsers]) -> CGFloat {
        
        var topY: CGFloat = 23
        for rel in relatives {
            
            let user = users.filter({ $0.uid == "\(rel.id)" })
            if user.count > 0 {
                topY += 30
            }
        }
        
        topY += 10
        
        return topY
    }
}
