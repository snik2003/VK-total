//
//  Sticker.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.08.2021.
//  Copyright © 2021 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Sticker {
    var stickerID = 0
    var isAllowed = false
    var url = ""
    var width = 0
    var height = 0
    
    init(json: JSON) {
        self.stickerID = json["sticker_id"].intValue
        self.isAllowed = json["is_allowed"].boolValue
        
        if let sticker = json["images"].filter({ $0.1["width"] == 256 }).first {
            self.url = sticker.1["url"].stringValue
            self.width = 256
            self.height = 256
        } else if let sticker = json["images"].filter({ $0.1["width"] == 128 }).first {
            self.url = sticker.1["url"].stringValue
            self.width = 128
            self.height = 128
        }
    }
}

class Stickers {
    var id = 0
    var title = ""
    var active = 0
    var purchased = 0
    var purchaseDate = 0
    
    var previewURL = ""
    var stickers: [Sticker] = []
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.title = json["title"].stringValue
        self.active = json["active"].intValue
        self.purchased = json["purchased"].intValue
        self.purchaseDate = json["purchase_date"].intValue
        
        let previewJSON = json["previews"]
        
        if let preview = previewJSON.filter({ $0.1["width"] == 102 }).first {
            self.previewURL = preview.1["url"].stringValue
        } else if let preview = previewJSON.filter({ $0.1["width"] == 68 }).first {
            self.previewURL = preview.1["url"].stringValue
        } else if let preview = previewJSON.filter({ $0.1["width"] == 44 }).first {
            self.previewURL = preview.1["url"].stringValue
        } else if let preview = previewJSON.filter({ $0.1["width"] == 34 }).first {
            self.previewURL = preview.1["url"].stringValue
        } else if let preview = previewJSON.filter({ $0.1["width"] == 22 }).first {
            self.previewURL = preview.1["url"].stringValue
        }
        
        let stickersJSON = json["stickers"]
        self.stickers = stickersJSON.compactMap({ Sticker(json: $0.1) })
    }
}
