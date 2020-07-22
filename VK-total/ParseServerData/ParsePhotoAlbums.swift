//
//  ParsePhotoAlbums.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParsePhotoAlbums: Operation {
    
    var outputData: [PhotoAlbum] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        let albums = json["response"]["items"].compactMap { PhotoAlbum(json: $0.1) }
        count = json["response"]["count"].intValue
        outputData = albums
    }
}
