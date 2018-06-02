//
//  VK_API_Services.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UserIdList {
    var uid: String
    
    init(json: JSON) {
        uid = json.stringValue
    }
}

class vkApiServices {
    
    let authUrl = "https://oauth.vk.com"
    let baseUrl = "https://api.vk.com"

    // получения списка друзей указанного пользователя
    /*func getFriendsList(userID uid: String, order ord: String, completion: @escaping ([Friends]) -> Void) {
        let path = "/method/friends.get"
        
        let parameters: Parameters = [
            "user_id": uid,
            "access_token": vkSingleton.shared.accessToken,
            "order": ord,
            "fields": "online,photo_max,last_seen,sex,is_friend",
            "v": vkSingleton.shared.version
        ]
        
        let url = baseUrl + path
        
        Alamofire.request(url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success:
                guard let data = response.value else { return }
                let json = JSON(data)
                let users = json["response"]["items"].flatMap { Friends(json: $0.1) }
       
                completion(users)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }*/
    
    // получения списка друзей указанного пользователя по поисковому запросу
    /*func getFriendsSearch(userID uid: String, search text: String, completion: @escaping ([Friends]) -> Void) {
        let path = "/method/friends.search"
        
        let parameters: Parameters = [
            "user_id": uid,
            "access_token": vkSingleton.shared.accessToken,
            "q": text,
            "count": "1000",
            "fields": "online,photo_max,last_seen,sex,is_friend",
            "v": vkSingleton.shared.version
        ]
        
        let url = baseUrl + path
        
        Alamofire.request(url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success:
                guard let data = response.value else { return }
                let json = JSON(data)
                let users = json["response"]["items"].flatMap { Friends(json: $0.1) }
                
                completion(users)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }*/
    
    // получения списка общих друзей указанного пользователя
    /*func getMutualFriendsList(userID uid: String, completion: @escaping ([Friends]) -> Void) {
        let path = "/method/friends.get"
        
        let parameters: Parameters = [
            "user_id": uid,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "online,photo_max,last_seen,sex,is_friend",
            "v": vkSingleton.shared.version
        ]
        
        let url = baseUrl + path
        
        Alamofire.request(url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { response in
            switch response.result {
            case .success:
                guard let data = response.value else { return }
                let json = JSON(data)
                let users = json["response"]["items"].flatMap { Friends(json: $0.1) }
                
                completion(users)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }*/
}


