//
//  Wall.swift
//  VK-total
//
//  Created by Сергей Никитин on 23.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Wall {
    var id: Int = 0
    var ownerID: Int = 0
    var fromID: Int = 0
    var date: Int = 0
    var text: String = ""
    var repostID: Int = 0
    var repostOwnerID: Int = 0
    var repostDate: Int = 0
    var repostText: String = ""
    var onlyForFriends: Int = 0
    var countComments: Int = 0
    var canComment: Int = 0
    var countLikes: Int = 0
    var userLikes: Int = 0
    var canLikes: Int = 0
    var canRepost: Int = 0
    var countReposts: Int = 0
    var userPeposted: Int = 0
    var countViews: Int = 0
    var isPinned: Int = 0
    var postType: String = ""
    var filter = ""
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
    var readMore1: Int = 1
    var readMore2: Int = 1
    var friendsOnly: Int = 0
    var createdBy: Int = 0
    var signerID: Int = 0
    var postSource: String = ""
    
    var poll: Poll?
    
    init(json: JSON) {
        self.id = json["id"].intValue
        if self.id == 0 { self.id = json["post_id"].intValue }
        self.ownerID = json["owner_id"].intValue
        if self.ownerID == 0 { self.ownerID = json["source_id"].intValue }
        self.fromID = json["from_id"].intValue
        if self.fromID == 0 { self.fromID = json["source_id"].intValue }
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
        self.isPinned = json["is_pinned"].intValue
        self.postType = json["post_type"].stringValue
        self.friendsOnly = json["friends_only"].intValue
        self.createdBy = json["created_by"].intValue
        self.signerID = json["signer_id"].intValue
        self.postSource = json["post_source"]["platform"].stringValue
        
        if self.repostOwnerID == 0 {
            for index in 0...9 {
                self.mediaType[index] = json["attachments"][index]["type"].stringValue
                
                if self.mediaType[index] == "photo" {
                    self.photoURL[index] = json["attachments"][index]["photo"]["photo_807"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["photo"]["photo_604"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["photo"]["photo_130"].stringValue
                    }
                    self.photoID[index] = json["attachments"][index]["photo"]["id"].intValue
                    self.photoOwnerID[index] = json["attachments"][index]["photo"]["owner_id"].intValue
                    self.photoWidth[index] = json["attachments"][index]["photo"]["width"].intValue
                    self.photoHeight[index] = json["attachments"][index]["photo"]["height"].intValue
                    self.photoText[index] = json["attachments"][index]["photo"]["text"].stringValue
                    self.photoAccessKey[index] = json["attachments"][index]["photo"]["access_key"].stringValue
                }
                
                if self.mediaType[index] == "video" {
                    self.photoID[index] = json["attachments"][index]["video"]["id"].intValue
                    self.photoOwnerID[index] = json["attachments"][index]["video"]["owner_id"].intValue
                    self.photoAccessKey[index] = json["attachments"][index]["video"]["access_key"].stringValue
                    self.photoURL[index] = json["attachments"][index]["video"]["photo_800"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["video"]["photo_640"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["video"]["photo_320"].stringValue
                    }
                    self.photoWidth[index] = json["attachments"][index]["video"]["width"].intValue
                    self.photoHeight[index] = json["attachments"][index]["video"]["height"].intValue
                    self.photoText[index] = json["attachments"][index]["video"]["title"].stringValue
                    self.size[index] = json["attachments"][index]["video"]["duration"].intValue
                    self.videoViews[index] = json["attachments"][index]["video"]["views"].intValue
                }
                
                if self.mediaType[index] == "link" {
                    self.photoURL[index] = json["attachments"][index]["link"]["photo"]["photo_807"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["link"]["photo"]["photo_604"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["attachments"][index]["link"]["photo"]["photo_320"].stringValue
                    }
                    self.photoWidth[index] = json["attachments"][index]["link"]["photo"]["width"].intValue
                    self.photoHeight[index] = json["attachments"][index]["link"]["photo"]["height"].intValue
                    self.photoText[index] = json["attachments"][index]["link"]["description"].stringValue
                    
                    self.linkText[index] = json["attachments"][index]["link"]["title"].stringValue
                    self.linkURL[index] = json["attachments"][index]["link"]["url"].stringValue
                    
                }
                
                if self.mediaType[index] == "doc" {
                    self.photoText[index] = json["attachments"][index]["doc"]["ext"].stringValue
                    self.videoURL[index] = json["attachments"][index]["doc"]["url"].stringValue
                    self.size[index] = json["attachments"][index]["doc"]["size"].intValue
                    self.photoURL[index] = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["src"].stringValue
                    self.photoWidth[index] = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["width"].intValue
                    self.photoHeight[index] = json["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["height"].intValue
                }
                
                if self.mediaType[index]  == "audio" {
                    self.audioArtist[index] = json["attachments"][index]["audio"]["artist"].stringValue
                    self.audioTitle[index] = json["attachments"][index]["audio"]["title"].stringValue
                }
                
                if self.mediaType[index] == "poll" {
                    self.poll = Poll(json: json["attachments"][index]["poll"])
                }
            }
        } else {
            self.signerID = json["copy_history"][0]["signer_id"].intValue
            
            for index in 0...9 {
                self.mediaType[index] = json["copy_history"][0]["attachments"][index]["type"].stringValue
                
                if self.mediaType[index] == "photo" {
                    self.photoURL[index] = json["copy_history"][0]["attachments"][index]["photo"]["photo_807"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["photo"]["photo_604"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["photo"]["photo_130"].stringValue
                    }
                    self.photoID[index] = json["copy_history"][0]["attachments"][index]["photo"]["id"].intValue
                    self.photoOwnerID[index] = json["copy_history"][0]["attachments"][index]["photo"]["owner_id"].intValue
                    self.photoWidth[index] = json["copy_history"][0]["attachments"][index]["photo"]["width"].intValue
                    self.photoHeight[index] = json["copy_history"][0]["attachments"][index]["photo"]["height"].intValue
                    self.photoText[index] = json["copy_history"][0]["attachments"][index]["photo"]["text"].stringValue
                    self.photoAccessKey[index] = json["copy_history"][0]["attachments"][index]["photo"]["access_key"].stringValue
                }
                
                if self.mediaType[index] == "video" {
                    self.photoID[index] = json["copy_history"][0]["attachments"][index]["video"]["id"].intValue
                    self.photoOwnerID[index] = json["copy_history"][0]["attachments"][index]["video"]["owner_id"].intValue
                    self.photoURL[index] = json["copy_history"][0]["attachments"][index]["video"]["photo_800"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["video"]["photo_640"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["video"]["photo_320"].stringValue
                    }
                    self.photoWidth[index] = json["copy_history"][0]["attachments"][index]["video"]["width"].intValue
                    self.photoHeight[index] = json["copy_history"][0]["attachments"][index]["video"]["height"].intValue
                    self.photoText[index] = json["copy_history"][0]["attachments"][index]["video"]["title"].stringValue
                    self.size[index] = json["copy_history"][0]["attachments"][index]["video"]["duration"].intValue
                    self.videoViews[index] = json["copy_history"][0]["attachments"][index]["video"]["views"].intValue
                }
                
                if self.mediaType[index] == "link" {
                    self.photoURL[index] = json["copy_history"][0]["attachments"][index]["link"]["photo"]["photo_807"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["link"]["photo"]["photo_604"].stringValue
                    }
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["copy_history"][0]["attachments"][index]["link"]["photo"]["photo_130"].stringValue
                    }
                    self.photoWidth[index] = json["copy_history"][0]["attachments"][index]["link"]["photo"]["width"].intValue
                    self.photoHeight[index] = json["copy_history"][0]["attachments"][index]["link"]["photo"]["height"].intValue
                    self.photoText[index] = json["copy_history"][0]["attachments"][index]["link"]["description"].stringValue
                    
                    self.linkText[index] = json["copy_history"][0]["attachments"][index]["link"]["title"].stringValue
                    self.linkURL[index] = json["copy_history"][0]["attachments"][index]["link"]["url"].stringValue
                    
                }
                
                if self.mediaType[index] == "doc" {
                    self.photoText[index] = json["copy_history"][0]["attachments"][index]["doc"]["ext"].stringValue
                    self.videoURL[index] = json["copy_history"][0]["attachments"][index]["doc"]["url"].stringValue
                    self.size[index] = json["copy_history"][0]["attachments"][index]["doc"]["size"].intValue
                    self.photoURL[index] = json["copy_history"][0]["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["src"].stringValue
                    self.photoWidth[index] = json["copy_history"][0]["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["width"].intValue
                    self.photoHeight[index] = json["copy_history"][0]["attachments"][index]["doc"]["preview"]["photo"]["sizes"][2]["height"].intValue
                }
                
                if self.mediaType[index]  == "audio" {
                    self.audioArtist[index] = json["copy_history"][0]["attachments"][index]["audio"]["artist"].stringValue
                    self.audioTitle[index] = json["copy_history"][0]["attachments"][index]["audio"]["title"].stringValue
                }
                
                if self.mediaType[index] == "poll" {
                    self.poll = Poll(json: json["copy_history"][0]["attachments"][index]["poll"])
                }
            }
        }
    }
    
    init(json: JSON, filters: String) {
        self.id = json["post_id"].intValue
        self.ownerID = json["source_id"].intValue
        self.fromID = json["source_id"].intValue
        self.date = json["date"].intValue
        
        self.filter = json["type"].stringValue
        
        if self.filter == "wall_photo" {
            var count = json["photos"]["count"].intValue
            if count > 10 { count = 10 }
            
            if count > 0 {
                for index in 0...(count - 1) {
                    self.mediaType[index] = "photo"
                    
                    self.photoURL[index] = json["photos"]["items"][index]["photo_807"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["photos"]["items"][index]["photo_604"].stringValue
                        if self.photoURL[index] == "" {
                            self.photoURL[index] = json["photos"]["items"][index]["photo_130"].stringValue
                        }
                    }
                    
                    self.photoID[index] = json["photos"]["items"][index]["id"].intValue
                    self.photoOwnerID[index] = json["photos"]["items"][index]["owner_id"].intValue
                    self.photoWidth[index] = json["photos"]["items"][index]["width"].intValue
                    self.photoHeight[index] = json["photos"]["items"][index]["height"].intValue
                    self.photoText[index] = json["photos"]["items"][index]["text"].stringValue
                    self.photoAccessKey[index] = json["photos"]["items"][index]["access_key"].stringValue
                }
            }
        }
        
        if self.filter == "video" {
            var count = json["video"]["count"].intValue
            if count > 10 { count = 10 }
            
            if count > 0 {
                for index in 0...(count - 1) {
                    self.mediaType[index] = "video"
                    
                    self.photoURL[index] = json["video"]["items"][index]["photo_800"].stringValue
                    if self.photoURL[index] == "" {
                        self.photoURL[index] = json["video"]["items"][index]["photo_320"].stringValue
                        if self.photoURL[index] == "" {
                            self.photoURL[index] = json["video"]["items"][index]["photo_130"].stringValue
                        }
                    }
                    
                    self.photoID[index] = json["video"]["items"][index]["id"].intValue
                    self.photoOwnerID[index] = json["video"]["items"][index]["owner_id"].intValue
                    self.photoWidth[index] = json["video"]["items"][index]["width"].intValue
                    self.photoHeight[index] = json["video"]["items"][index]["height"].intValue
                    self.photoText[index] = json["video"]["items"][index]["title"].stringValue
                    self.size[index] = json["video"]["items"][index]["duration"].intValue
                    self.videoViews[index] = json["video"]["items"][index]["views"].intValue
                }
            }
        }
        
        if self.filter == "audio" {
            var count = json["audio"]["count"].intValue
            if count > 10 { count = 10 }
            
            if count > 0 {
                for index in 0...(count - 1) {
                    self.mediaType[index] = "audio"
                    
                    self.audioArtist[index] = json["audio"]["items"][index]["artist"].stringValue
                    self.audioTitle[index] = json["audio"]["items"][index]["title"].stringValue
                }
            }
        }
        
        if filters == "audio" && self.filter == "post" {
            for index in 0...9 {
                if json["attachments"][index]["type"].stringValue == "audio" {
                    self.mediaType[index] = "audio"
                    
                    self.audioArtist[index] = json["attachments"][index]["audio"]["artist"].stringValue
                    self.audioTitle[index] = json["attachments"][index]["audio"]["title"].stringValue
                } else if json["copy_history"][0]["attachments"][index]["type"].stringValue == "audio" {
                    self.mediaType[index] = "audio"
                    
                    self.audioArtist[index] = json["copy_history"][0]["attachments"][index]["audio"]["artist"].stringValue
                    self.audioTitle[index] = json["copy_history"][0]["attachments"][index]["audio"]["title"].stringValue
                }
            }
        }
    }
}

class WallProfiles {
    var uid: Int = 0
    var firstName: String = ""
    var lastName: String = ""
    var photoURL: String = ""
    var sex: Int = 0
    var firstNameGen: String = ""
    
    init(json: JSON) {
        self.uid = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.photoURL = json["photo_100"].stringValue
        self.sex = json["sex"].intValue
        self.firstNameGen = json["first_name_gen"].stringValue
    }
}

class WallGroups {
    var gid: Int = 0
    var name: String = ""
    var photoURL: String = ""
    
    init(json: JSON) {
        self.gid = json["id"].intValue
        self.name = json["name"].stringValue
        self.photoURL = json["photo_200"].stringValue
    }
}
