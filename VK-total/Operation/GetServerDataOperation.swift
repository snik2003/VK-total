//
//  GetServerDataOperation.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GetServerDataOperation: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"

    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    private var request: DataRequest
    private var url: String
    private var parameters: Parameters?
    var data: Data?
    
    override func main() {
        request.responseData(queue: DispatchQueue.global()) { [weak self] response in
            self?.data = response.data
            self?.state = .finished
        }
    }
    
    init(url: String, parameters: Parameters) {
        self.url = baseUrl + url
        self.parameters = parameters
        request = Alamofire.request(self.url, method: .post, parameters: self.parameters)
    }
}

class GetServerDataOperation2: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        super.cancel()
    }
    
    private var url: String
    var data: Data?
    
    override func main() {
        guard let parseDialogs = dependencies.first as? ParseDialogs else { return }
        
        var userList = ""
        if parseDialogs.outputData.count > 0 {
            for index in 0...parseDialogs.outputData.count-1 {
                userList = "\(parseDialogs.outputData[index].userID), \(userList)"
            }
        }
        userList = "\(userList)\(vkSingleton.shared.userID)"
        
        let parameters: Parameters = [
            "user_ids": userList,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id, first_name, last_name, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, can_write_private_message",
            "name_case": "nom",
            "v": "3.0"
        ]
        
        Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
            self?.data = response.data
            self?.state = .finished
        }
    }
    
    init(url: String) {
        self.url = baseUrl + url
    }
}

class GetServerDataOperation3: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        super.cancel()
    }
    
    private var url: String
    private var type: String
    var data: Data?
    
    override func main() {
        if type == "post" {
            guard let parseRecord = dependencies.first as? ParseRecord else { return }
            
            if parseRecord.news.count > 0 {
                
                let record = parseRecord.news[0]
                
                let parameters: Parameters = [
                    "type": type,
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": record.ownerID,
                    "item_id": record.id,
                    "filter": "likes",
                    "extended": "1",
                    "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
                    
                    "count": "1000",
                    "skip_own": "0",
                    "v": vkSingleton.shared.version
                ]
            
            
                Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                    self?.data = response.data
                    self?.state = .finished
                }
            }
        }
        
        if type == "photo" {
            guard let parsePhoto = dependencies.first as? ParsePhotoData else { return }
            
            if parsePhoto.outputData.count > 0 {
                
                let record = parsePhoto.outputData[0]
                
                let parameters: Parameters = [
                    "type": type,
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": record.userID,
                    "item_id": record.photoID,
                    "filter": "likes",
                    "extended": "1",
                    "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
                    
                    "count": "1000",
                    "skip_own": "0",
                    "v": vkSingleton.shared.version
                ]
                
                
                Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                    self?.data = response.data
                    self?.state = .finished
                }
            }
        }
    }
    
    init(url: String, type: String) {
        self.url = baseUrl + url
        self.type = type
    }
}

class GetServerDataOperation4: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        super.cancel()
    }
    
    private var url: String
    private var offset: Int
    private var type: String
    private var record1: Record
    
    var data: Data?
    
    override func main() {
        if type == "post" {
            guard let parseRecord = dependencies.first as? ParseRecord else { return }
            
            if parseRecord.news.count > 0 {
                let record = parseRecord.news[0]
                
                let parameters: Parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": record.ownerID,
                    "post_id": record.id,
                    "need_likes": "1",
                    "offset": "\(offset)",
                    "count": "30",
                    "sort": "desc",
                    "preview_length": "0",
                    "extended": "1",
                    "v": vkSingleton.shared.version
                ]
                
                Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                    self?.data = response.data
                    self?.state = .finished
                }
            }
        } else if type == "photo" {
            let parameters: Parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": record1.ownerID,
                "photo_id": record1.photoID[0],
                "need_likes": "1",
                "offset": "\(offset)",
                "count": "30",
                "sort": "desc",
                "preview_length": "0",
                "extended": "1",
                "v": vkSingleton.shared.version
            ]
            
            Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                self?.data = response.data
                self?.state = .finished
            }
        } else if type == "video" {
            guard let parseVideo = dependencies.first as? ParseVideos else { return }
            
            if parseVideo.outputData.count > 0 {
                
                let video = parseVideo.outputData[0]
                
                let parameters: Parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": video.ownerID,
                    "video_id": video.id,
                    "need_likes": "1",
                    "offset": "\(offset)",
                    "count": "30",
                    "sort": "desc",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
                    "v": vkSingleton.shared.version
                ]
                
                Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                    self?.data = response.data
                    self?.state = .finished
                }
            }
        }
    }
    
    init(url: String, offset: Int, type: String, record: Record) {
        self.url = baseUrl + url
        self.offset = offset
        self.type = type
        self.record1 = record
    }
}

class GetServerDataOperation5: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        super.cancel()
    }
    
    private var url: String
    private var type: String
    private var record1: Record
    var data: Data?
    
    override func main() {
        if type == "post" {
            guard let parseRecord = dependencies.first as? ParseRecord else { return }
            
            if parseRecord.news.count > 0 {
                let record = parseRecord.news[0]
                
                let parameters: Parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": record.ownerID,
                    "post_id": record.id,
                    "offset": "0",
                    "count": "100",
                    "v": vkSingleton.shared.version
                ]
                
                Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                    self?.data = response.data
                    self?.state = .finished
                }
            }
        } else if type == "photo" {
            
            
            let parameters: Parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": record1.ownerID,
                "photo_id": record1.id,
                "offset": "0",
                "count": "100",
                "v": vkSingleton.shared.version
            ]
            
            Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
                self?.data = response.data
                self?.state = .finished
            }
        }
    }
    
    init(url: String, type: String, record: Record) {
        self.url = baseUrl + url
        self.type = type
        self.record1 = record
    }
}


class GetServerDataOperation7: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        super.cancel()
    }
    
    private var url: String
    private var type: String
    private var ownerID: Int
    private var itemID: Int
    var data: Data?
    
    override func main() {
        
        let parameters: Parameters = [
            "type": type,
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(ownerID)",
            "item_id": "\(itemID)",
            "filter": "likes",
            "extended": "1",
            "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
            
            "count": "1000",
            "skip_own": "0",
            "v": vkSingleton.shared.version
        ]
        
        
        Alamofire.request(self.url, method: .post, parameters: parameters).responseData(queue: DispatchQueue.global()) { [weak self] response in
            self?.data = response.data
            self?.state = .finished
        }
        
    }
    
    init(url: String, type: String, owner: Int, item: Int) {
        self.url = baseUrl + url
        self.type = type
        self.ownerID = owner
        self.itemID = item
    }
}

