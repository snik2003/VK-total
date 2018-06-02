//
//  GetServerResponseOperation.swift
//  VK-total
//
//  Created by Сергей Никитин on 04.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GetServerResponseOperation: AsyncOperation {
    
    let baseUrl = "https://api.vk.com"
    
    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    private var request: DataRequest
    private var url: String
    private var parameters: Parameters?
    var result: String?
    
    override func main() {
        
        request.responseData(queue: DispatchQueue.global()) { [weak self] response in
            switch response.result {
            case .success:
                self?.result = "success"
            case .failure(let error):
                self?.result = error.localizedDescription
            }
            self?.state = .finished
        }
    }
    
    init(url: String, parameters: Parameters) {
        self.url = baseUrl + url
        self.parameters = parameters
        request = Alamofire.request(self.url, method: .post, parameters: self.parameters)
        
    }
}
