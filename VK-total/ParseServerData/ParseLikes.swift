//
//  ParseLikes.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseLikes: Operation {
    
    var outputData: [Likes] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        let likes: [Likes] = json["response"]["items"].compactMap { Likes(json: $0.1) }
        
        outputData = likes
    }
}
