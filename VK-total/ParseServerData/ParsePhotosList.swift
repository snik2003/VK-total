//
//  ParsePhotosList.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParsePhotosList: Operation {
    
    var outputData: [Photos] = []
    var count: Int = 0
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print("photos = \(json)")
        let photos = json["response"]["items"].compactMap { Photos(json: $0.1) }
        count = json["response"]["count"].intValue
        outputData = photos
    }
}
