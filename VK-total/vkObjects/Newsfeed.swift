//
//  Newsfeed.swift
//  VK-total
//
//  Created by Сергей Никитин on 24.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class News {
    var postID: Int = 0
    var sourceID: Int = 0
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
    var userReposted: Int = 0
    var countViews: Int = 0
    var postType: String = ""
    var mediaType = [String] (repeating: "", count: 10)
    var photoID = [Int] (repeating: 0, count: 10)
    var photoOwnerID = [Int] (repeating: 0, count: 10)
    var photoAccessKey = [String] (repeating: "", count: 10)
    var photoURL = [String] (repeating: "", count: 10)
    var photoWidth = [Int] (repeating: 0, count: 10)
    var photoHeight = [Int] (repeating: 0, count: 10)
    var photoText = [String] (repeating: "", count: 10)
    var videoURL = [String] (repeating: "", count: 10)
    var videoText = [String] (repeating: "", count: 10)
    var linkURL = [String] (repeating: "", count: 10)
    var linkText = [String] (repeating: "", count: 10)
    var audioArtist = [String] (repeating: "", count: 10)
    var audioTitle = [String] (repeating: "", count: 10)
    var size = [Int] (repeating: 0, count: 10)
    var signerID: Int = 0
    var readMore1: Int = 1
    var readMore2: Int = 1
    var postSource: String = ""
    
    var poll: Poll?
    
    init(json: JSON, filters: String) {
        
        if filters == "post" {
            self.postID = json["post_id"].intValue
            if self.postID == 0 {
                self.postID = json["id"].intValue
            }
            self.ownerID = json["owner_id"].intValue
            self.sourceID = json["source_id"].intValue
            if self.sourceID == 0 {
                self.sourceID = json["owner_id"].intValue
            }
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
            self.userReposted = json["reposts"]["user_reposted"].intValue
            self.countViews = json["views"]["count"].intValue
            self.postType = json["post_type"].stringValue
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
                    
                    if self.mediaType[index] == "poll" {
                        self.poll = Poll(json: json["attachments"][index]["poll"])
                    }
                }
                
                for index in 0...9 {
                    if self.mediaType[index]  == "audio" {
                        self.audioArtist[index] = json["attachments"][index]["audio"]["artist"].stringValue
                        self.audioTitle[index] = json["attachments"][index]["audio"]["title"].stringValue
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
                    }
                    
                    if self.mediaType[index] == "video" {
                        self.photoID[index] = json["copy_history"][0]["attachments"][index]["video"]["id"].intValue
                        self.photoOwnerID[index] = json["copy_history"][0]["attachments"][index]["video"]["owner_id"].intValue
                        self.photoAccessKey[index] = json["copy_history"][0]["attachments"][index]["video"]["access_key"].stringValue
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
                    
                    if self.mediaType[index] == "poll" {
                        self.poll = Poll(json: json["copy_history"][0]["attachments"][index]["poll"])
                    }
                
                    if self.mediaType[index]  == "audio" {
                        self.audioArtist[index] = json["copy_history"][0]["attachments"][index]["audio"]["artist"].stringValue
                        self.audioTitle[index] = json["copy_history"][0]["attachments"][index]["audio"]["title"].stringValue
                    }
                }
            }
        }
        
        if filters == "wall_photo" {
            self.sourceID = json["source_id"].intValue
            self.date = json["date"].intValue
            self.repostID = json["copy_history"][0]["id"].intValue
            self.repostOwnerID = json["copy_history"][0]["owner_id"].intValue
            self.postType = json["type"].stringValue
            self.countComments = json["photos"]["items"][0]["comments"]["count"].intValue
            self.canComment = json["photos"]["items"][0]["comments"]["can_comment"].intValue
            self.countLikes = json["photos"]["items"][0]["likes"]["count"].intValue
            self.userLikes = json["photos"]["items"][0]["likes"]["user_likes"].intValue
            self.canLikes = json["photos"]["items"][0]["likes"]["can_like"].intValue
            self.canRepost = json["photos"]["items"][0]["likes"]["can_publish"].intValue
            self.countReposts = json["photos"]["items"][0]["reposts"]["count"].intValue
            self.userReposted = json["photos"]["items"][0]["reposts"]["user_reposted"].intValue
            self.countViews = json["photos"]["items"][0]["views"]["count"].intValue

            for index in 0...9 {
                self.mediaType[index] = "photo"
                self.photoWidth[index] = json["photos"]["items"][index]["width"].intValue
                self.photoHeight[index] = json["photos"]["items"][index]["height"].intValue
                
                self.photoID[index] = json["photos"]["items"][index]["id"].intValue
                self.photoOwnerID[index] = json["photos"]["items"][index]["owner_id"].intValue
                self.photoURL[index] = json["photos"]["items"][index]["photo_807"].stringValue
                if self.photoURL[index].isEmpty {
                    self.photoURL[index] = json["photos"]["items"][index]["photo_604"].stringValue
                    if self.photoURL[index].isEmpty {
                        self.photoURL[index] = json["photos"]["items"][index]["photo_320"].stringValue
                        if self.photoURL[index].isEmpty {
                            self.photoURL[index] = json["video"]["items"][index]["photo_1280"].stringValue
                        }
                    }
                }
            }
        }
        
        if filters == "video" {
            self.sourceID = json["source_id"].intValue
            self.date = json["date"].intValue
            
            self.repostID = json["copy_history"][0]["id"].intValue
            self.repostOwnerID = json["copy_history"][0]["owner_id"].intValue
            
            for index in 0...9 {
                self.mediaType[index] = "video"
                self.photoID[index] = json["video"]["items"][index]["id"].intValue
                self.photoOwnerID[index] = json["video"]["items"][index]["owner_id"].intValue
                self.photoAccessKey[index] = json["video"]["items"][index]["access_key"].stringValue
                self.photoText[index] = json["video"]["items"][index]["title"].stringValue
                self.size[index] = json["video"]["items"][index]["duration"].intValue
                self.photoWidth[index] = json["video"]["items"][index]["width"].intValue
                self.photoHeight[index] = json["video"]["items"][index]["height"].intValue
                
                self.photoURL[index] = json["video"]["items"][index]["photo_807"].stringValue
                if self.photoURL[index].isEmpty {
                    self.photoURL[index] = json["video"]["items"][index]["photo_604"].stringValue
                    if self.photoURL[index].isEmpty {
                        self.photoURL[index] = json["video"]["items"][index]["photo_320"].stringValue
                        if self.photoURL[index].isEmpty {
                            self.photoURL[index] = json["video"]["items"][index]["photo_1280"].stringValue
                        }
                    }
                }
            }
        }
    }
}

class NewsProfiles {
    var uid: Int
    var firstName: String
    var lastName: String
    var photoURL: String
    var firstNameGen: String
    var screenName: String

    init(json: JSON) {
        self.uid = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.photoURL = json["photo_100"].stringValue
        self.firstNameGen = json["first_name_gen"].stringValue
        self.screenName = json["screen_name"].stringValue
    }
}

class NewsGroups {
    var gid: Int
    var name: String
    var photoURL: String
    
    init(json: JSON) {
        self.gid = json["id"].intValue
        self.name = json["name"].stringValue
        self.photoURL = json["photo_200"].stringValue
    }
}
