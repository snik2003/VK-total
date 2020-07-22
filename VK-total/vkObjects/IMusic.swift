//
//  IMusic.swift
//  VK-total
//
//  Created by Сергей Никитин on 23.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class IMusic: Object {
    @objc dynamic var songID = 0
    @objc dynamic var userID = 0
    @objc dynamic var playlistID = 0
    @objc dynamic var artist = ""
    @objc dynamic var album = ""
    @objc dynamic var song = ""
    @objc dynamic var URL = ""
    @objc dynamic var reserv1 = 0 // artistID
    @objc dynamic var reserv2 = 0
    @objc dynamic var reserv3 = 0
    @objc dynamic var reserv4 = "" // previewURL
    @objc dynamic var reserv5 = "" // avatarURL
    @objc dynamic var reserv6 = ""
    
    override static func primaryKey() -> String? {
        return "URL"
    }
    
    convenience init(json: JSON) {
        self.init()
        
        self.userID = Int(vkSingleton.shared.userID)!
        self.URL = json["trackViewUrl"].stringValue
        self.reserv4 = json["previewUrl"].stringValue
        self.songID = json["trackId"].intValue
        self.reserv1 = json["artistId"].intValue
        self.song = json["trackName"].stringValue
        self.artist = json["artistName"].stringValue
        self.album = json["collectionName"].stringValue
        self.reserv5 = json["artworkUrl100"].stringValue
        self.reserv6 = json["artistViewUrl"].stringValue
    }
}
