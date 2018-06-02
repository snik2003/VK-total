//
//  VK_Services.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyVK

class VKServices {

    let api_ID = "6324060"
    let delegate: SwiftyVKDelegate
    
    VK.setUp(api_ID, delegate)
    
    // авторизация приложения
    
    
   /* func authorizationVK() {
        let path = "/authorize"
        
        // https://oauth.vk.com/authorize?client_id=6324060&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=friends,photos,status,groups&response_type=token&v=5.69
        
        let parameters: Parameters = [
            "client_id": api_ID,
            "display": "mobile",
            "redirect_uri": "https://oauth.vk.com/blank.html",
            "scope": "friends,photos,status,groups",
            "response_type": "token",
            "v": "5.69"
        ]
        
        let url = authUrl + path
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }*/
    
}
