//
//  ReloadRecord2Controller.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReloadRecord2Controller: Operation {
    
    var controller: Record2Controller
    var type: String
    
    init(controller: Record2Controller, type: String) {
        self.controller = controller
        self.type = type
    }
    
    override func main() {
        
        if type == "post" {
            guard let parseRecord = dependencies[0] as? ParseRecord, let parseLikes = dependencies[1] as? ParseLikes, let parseComments = dependencies[2] as? ParseComments2, let parseReposts = dependencies[3] as? ParseLikes else { return }
            
            controller.news = parseRecord.news
            controller.newsGroups = parseRecord.groups
            controller.newsProfiles = parseRecord.profiles
            
            controller.likes = parseLikes.outputData
            controller.reposts = parseReposts.outputData
            
            controller.totalComments = parseComments.count
            if controller.offset == 0 {
                controller.comments = parseComments.comments
                controller.commentsGroups = parseComments.groups
                controller.commentsProfiles = parseComments.profiles
            } else {
                for comment in parseComments.comments {
                    controller.comments.append(comment)
                }
                for profile in parseComments.profiles {
                    controller.commentsProfiles.append(profile)
                }
                for group in parseComments.groups {
                    controller.commentsGroups.append(group)
                }
            }
            
            controller.title = "Запись"
        } else if type == "photo" {
            guard let parsePhoto = dependencies[0] as? ParsePhotoData, let parseLikes = dependencies[1] as? ParseLikes, let parseComments = dependencies[2] as? ParseComments2, let parseReposts = dependencies[3] as? ParseLikes else { return }
            
            if parsePhoto.outputData.count > 0 {
                controller.news.removeAll(keepingCapacity: false)
                let photo = parsePhoto.outputData[0]
                
                controller.photo = photo
                let record = Record(json: JSON.null)
                record.ownerID = Int(photo.userID)!
                record.fromID = Int(photo.userID)!
                record.id = Int(photo.photoID)!
                
                record.mediaType[0] = "photo"
                record.photoURL[0] = photo.xxbigPhotoURL
                if record.photoURL[0] == "" { record.photoURL[0] = photo.xbigPhotoURL }
                if record.photoURL[0] == "" { record.photoURL[0] = photo.bigPhotoURL }
                if record.photoURL[0] == "" { record.photoURL[0] = photo.photoURL }
                if record.photoURL[0] == "" { record.photoURL[0] = photo.smallPhotoURL }
                record.photoID[0] = Int(photo.photoID)!
                record.photoOwnerID[0] = Int(photo.userID)!
                record.photoWidth[0] = photo.width
                record.photoHeight[0] = photo.height
                record.date = photo.createdTime
                record.text = photo.text
                record.userLikes = photo.userLikesThisPhoto
                record.countLikes = photo.likesCount
                record.countComments = photo.commentsCount
                record.countReposts = photo.repostsCount
                record.canComment = photo.canComment
                record.canRepost = photo.canRepost
                record.userPeposted = photo.userRepostedThisPhoto
                
                controller.news.append(record)
                
                controller.title = "Фотография"
            }
            
            controller.likes = parseLikes.outputData
            controller.reposts = parseReposts.outputData
            
            controller.totalComments = parseComments.count
            if controller.offset == 0 {
                controller.comments = parseComments.comments
                controller.commentsGroups = parseComments.groups
                controller.commentsProfiles = parseComments.profiles
            } else {
                for comment in parseComments.comments {
                    controller.comments.append(comment)
                }
                for profile in parseComments.profiles {
                    controller.commentsProfiles.append(profile)
                }
                for group in parseComments.groups {
                    controller.commentsGroups.append(group)
                }
            }
        }
        
        if controller.news.count > 0 {
            if controller.news[0].canComment == 0 {
                controller.tableView.frame = CGRect(x: 0, y: controller.navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - controller.navHeight - controller.tabHeight)
                controller.view.addSubview(controller.tableView)
                controller.commentView.removeFromSuperview()
                controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            } else {
                controller.view.addSubview(controller.commentView)
            }
        }
        controller.offset += controller.count
        controller.tableView.reloadData()
        controller.tableView.separatorStyle = .singleLine
        ViewControllerUtils().hideActivityIndicator()
    }
}
