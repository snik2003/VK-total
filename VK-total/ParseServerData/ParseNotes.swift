//
//  ParseNotes.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseNotes: Operation {
    
    var outputData: [Notes] = []
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        guard let json = try? JSON(data: data) else { print("json error"); return }
        //print(json)
        
        outputData = json["response"]["items"].compactMap { Notes(json: $0.1) }
    }
}
