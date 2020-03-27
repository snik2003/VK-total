//
//  ParsePage.swift
//  VK-total
//
//  Created by Сергей Никитин on 26.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParsePage: Operation {
    
    var outputData: [Page] = []
    var dataString: String = ""
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        do {
            let json = try JSON(data: data)
            //print(json)
            dataString = String(data: data, encoding: .utf8)!
            outputData = json["response"].compactMap { Page(json: $0.1) }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

