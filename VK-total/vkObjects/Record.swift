//
//  Record.swift
//  VK-total
//
//  Created by Сергей Никитин on 05.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Record {
    var id: Int = 0
    var ownerID: Int = 0
    var fromID: Int = 0
    var date: Int = 0
    var text: String = ""
    var repostID: Int = 0
    var repostOwnerID: Int = 0
    var repostDate: Int = 0
    var repostText: String = ""
    var countComments: Int = 0
    var canComment: Int = 0
    var countLikes: Int = 0
    var userLikes: Int = 0
    var canLikes: Int = 0
    var canRepost: Int = 0
    var countReposts: Int = 0
    var userPeposted: Int = 0
    var countViews: Int = 0
    var postType: String = ""
    var mediaType: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var photoID: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var photoOwnerID: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var photoAccessKey: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var photoURL: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var photoWidth: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var photoHeight: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var photoText: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var videoURL: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var linkURL: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var linkText: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var audioArtist: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var audioTitle: [String] = ["", "", "", "", "", "", "", "", "", ""]
    var size = [Int] (repeating: 0, count: 10)
    var videoViews = [Int] (repeating: 0, count: 10)
    var canPin: Int = 0
    var canDelete: Int = 0
    var canEdit: Int = 0
    var isPinned: Int = 0
    var friendsOnly: Int = 0
    var createdBy: Int = 0
    var signerID: Int = 0
    var poll: Poll?
    var postSource = ""

    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
        self.repostID = json["copy_history"][0]["id"].intValue
        self.repostOwnerID = json["copy_history"][0]["owner_id"].intValue
        self.repostDate = json["copy_history"][0]["date"].intValue
        self.repostText = json["copy_history"][0]["text"].stringValue
        self.countComments = json["comments"]["count"].intValue
        self.canComment = json["comments"]["can_post"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.canLikes = json["likes"]["can_like"].intValue
        self.canRepost = json["likes"]["can_publish"].intValue
        self.countReposts = json["reposts"]["count"].intValue
        self.userPeposted = json["reposts"]["user_reposted"].intValue
        self.countViews = json["views"]["count"].intValue
        self.postType = json["post_type"].stringValue
        
        self.canPin = json["can_pin"].intValue
        self.canDelete = json["can_delete"].intValue
        self.canEdit = json["can_edit"].intValue
        self.isPinned = json["is_pinned"].intValue
        self.friendsOnly = json["friends_only"].intValue
        self.createdBy = json["created_by"].intValue
        self.signerID = json["signer_id"].intValue
        self.postSource = json["post_source"]["platform"].stringValue
        
        var json2 = json
        if self.repostOwnerID != 0 { json2 = json["copy_history"][0] }
            
        //print(json2)
        
        self.signerID = json2["signer_id"].intValue
        
        for index in 0...9 {
            self.mediaType[index] = json2["attachments"][index]["type"].stringValue
            
            if self.mediaType[index] == "photo" {
                self.photoID[index] = json2["attachments"][index]["photo"]["id"].intValue
                self.photoOwnerID[index] = json2["attachments"][index]["photo"]["owner_id"].intValue
                self.photoText[index] = json2["attachments"][index]["photo"]["text"].stringValue
                self.photoAccessKey[index] = json2["attachments"][index]["photo"]["access_key"].stringValue
                
                
                let sizes = json2["attachments"][index]["photo"]["sizes"].arrayValue
                if let size = sizes.filter({ $0["type"].stringValue == "x" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "y" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "q" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "p" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                }
            }
            
            if self.mediaType[index] == "video" {
                self.photoID[index] = json2["attachments"][index]["video"]["id"].intValue
                self.photoOwnerID[index] = json2["attachments"][index]["video"]["owner_id"].intValue
                self.photoText[index] = json2["attachments"][index]["video"]["title"].stringValue
                self.size[index] = json2["attachments"][index]["video"]["duration"].intValue
                self.videoViews[index] = json2["attachments"][index]["video"]["views"].intValue
                self.videoURL[index] = json2["attachments"][index]["video"]["player"].stringValue
                
                self.photoWidth[index] = json2["attachments"][index]["video"]["width"].intValue
                self.photoHeight[index] = json2["attachments"][index]["video"]["height"].intValue
                
                if self.photoWidth[index] == 0 { self.photoWidth[index] = 640 }
                if self.photoHeight[index] == 0 { self.photoHeight[index] = 480 }
                
                self.photoURL[index] = json2["attachments"][index]["video"]["photo_640"].stringValue
                if self.photoURL[index] == "" {
                    self.photoURL[index] = json2["attachments"][index]["video"]["photo_320"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json2["attachments"][index]["video"]["photo_800"].stringValue
                        self.photoWidth[index] = 800
                        self.photoHeight[index] = 450
                    }
                }
            }
            
            if self.mediaType[index] == "link" {
                self.photoText[index] = json2["attachments"][index]["link"]["description"].stringValue
                self.linkText[index] = json2["attachments"][index]["link"]["title"].stringValue
                self.linkURL[index] = json2["attachments"][index]["link"]["url"].stringValue
                
                
                let sizes = json2["attachments"][index]["link"]["photo"]["sizes"].arrayValue
                if let size = sizes.filter({ $0["type"].stringValue == "x" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "y" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "q" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "p" }).first {
                    self.photoURL[index] = size["url"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                }
            }
            
            if self.mediaType[index] == "doc" {
                self.photoText[index] = json2["attachments"][index]["doc"]["ext"].stringValue
                self.videoURL[index] = json2["attachments"][index]["doc"]["url"].stringValue
                self.size[index] = json2["attachments"][index]["doc"]["size"].intValue
                
                let sizes = json2["attachments"][index]["doc"]["preview"]["photo"]["sizes"].arrayValue
                if let size = sizes.filter({ $0["type"].stringValue == "x" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "y" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "q" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "p" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "o" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                } else if let size = sizes.filter({ $0["type"].stringValue == "i" }).first {
                    self.photoURL[index] = size["src"].stringValue
                    self.photoWidth[index] = size["width"].intValue
                    self.photoHeight[index] = size["height"].intValue
                }
            }
            
            if self.mediaType[index]  == "audio" {
                self.audioArtist[index] = json2["attachments"][index]["audio"]["artist"].stringValue
                self.audioTitle[index] = json2["attachments"][index]["audio"]["title"].stringValue
            }
            
            if self.mediaType[index] == "poll" {
                self.poll = Poll(json: json2["attachments"][index]["poll"])
            }
        }
    }
}

class RecordProfiles {
    var uid: Int
    var firstName: String
    var lastName: String
    var photoURL: String
    
    init(json: JSON) {
        self.uid = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.photoURL = json["photo_max"].stringValue
    }
}

class RecordGroups {
    var gid: Int
    var name: String
    var photoURL: String
    
    init(json: JSON) {
        self.gid = json["id"].intValue
        self.name = json["name"].stringValue
        self.photoURL = json["photo_max"].stringValue
    }
}

