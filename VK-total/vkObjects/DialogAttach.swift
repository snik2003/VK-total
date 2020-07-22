//
//  AttachPhoto.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class DialogAttach: Codable {
    var type = ""
    var photos: [PhotoAttach] = []
    var videos: [VideoAttach] = []
    var audio: [AudioAttach] = []
    var stickers: [StickerAttach] = []
    var wall: [WallAttach] = []
    var gift: [GiftAttach] = []
    var docs: [DocAttach] = []
    var link: [LinkAttach] = []
    
    init(json: JSON) {
        self.type = json["type"].stringValue
    }
}

class PhotoAttach: Codable {
    var id = 0
    var albumID = 0
    var ownerID = 0
    var userID = 0
    var text = ""
    var date = 0
    var width = 0
    var height = 0
    var photo604 = ""
    var photo807 = ""
    var photo1280 = ""
    var accessKey = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.albumID = json["album_id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.userID = json["user_id"].intValue
        self.date = json["date"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.text = json["text"].stringValue
        self.photo604 = json["photo_604"].stringValue
        self.photo807 = json["photo_807"].stringValue
        self.photo1280 = json["photo_1280"].stringValue
        self.accessKey = json["access_key"].stringValue
    }
}

class VideoAttach: Codable {
    var id = 0
    var ownerID = 0
    var title = ""
    var description = ""
    var date = 0
    var duration = 0
    var photo320 = ""
    var isPrivate = 0
    var accessKey = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.date = json["date"].intValue
        self.duration = json["duration"].intValue
        self.photo320 = json["photo_320"].stringValue
        self.isPrivate = json["is_private"].intValue
        self.accessKey = json["access_key"].stringValue
    }
}

class AudioAttach: Codable {
    var id = 0
    var ownerID = 0
    var artist = ""
    var title = ""
    var duration = 0
    var url = 0
    var albumID = 0
    var accessKey = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.artist = json["artist"].stringValue
        self.title = json["title"].stringValue
        self.duration = json["duration"].intValue
        self.url = json["url"].intValue
        self.albumID = json["album_id"].intValue
        self.accessKey = json["access_key"].stringValue
    }
}

class StickerAttach: Codable {
    var id = 0
    var productID = 0
    var width = 0
    var height = 0
    var photo256 = ""
    var photo128 = ""
    
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.productID = json["product_id"].intValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
        self.photo256 = json["photo_256"].stringValue
        self.photo128 = json["photo_128"].stringValue
    }
}

class WallAttach: Codable {
    var id = 0
    var fromID = 0
    var date = 0
    var text = ""
    var postType = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
        self.postType = json["post_type"].stringValue
    }
}

class GiftAttach: Codable {
    var id = 0
    var thumb48 = ""
    var thumb96 = ""
    var thumb256 = ""
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.thumb48 = json["thumb_48"].stringValue
        self.thumb96 = json["thumb_96"].stringValue
        self.thumb256 = json["thumb_256"].stringValue
    }
}

class DocAttach: Codable {
    var id = 0
    var ownerID = 0
    var title = ""
    var size = 0
    var ext = ""
    var url = ""
    var date = 0
    var type = 0
    var linkMP3 = ""
    var linkOGG = ""
    var duration = 0
    var accessKey = ""
    var link = ""
    var width = 0
    var height = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.size = json["size"].intValue
        self.ext = json["ext"].stringValue
        self.url = json["url"].stringValue
        self.date = json["date"].intValue
        self.type = json["type"].intValue
        self.accessKey = json["access_key"].stringValue
        
        self.linkMP3 = json["preview"]["audio_msg"]["link_mp3"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.linkOGG = json["preview"]["audio_msg"]["link_ogg"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.duration = json["preview"]["audio_msg"]["duration"].intValue
        
        self.link = json["preview"]["graffiti"]["src"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.width = json["preview"]["graffiti"]["width"].intValue
        self.height = json["preview"]["graffiti"]["height"].intValue
        
        if self.link.isEmpty {
            self.link = json["preview"]["photo"]["sizes"][0]["src"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            self.width = json["preview"]["photo"]["sizes"][0]["width"].intValue
            self.height = json["preview"]["photo"]["sizes"][0]["height"].intValue
        }
    }
}

class LinkAttach: Codable {
    var title = ""
    var url = ""
    
    init(json: JSON) {
        self.title = json["title"].stringValue
        if self.title == "" {
            self.title = json["description"].stringValue
            if self.title == "" {
                self.title = json["caption"].stringValue
                if self.title == "" {
                    self.title = json["photo"]["text"].stringValue
                }
            }
        }
        self.url = json["url"].stringValue
    }
}

