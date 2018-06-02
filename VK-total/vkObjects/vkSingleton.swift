//
//  vkSingleton.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

final class vkSingleton {
    static let shared = vkSingleton()
    let vkAppID: [String] = ["6363391","6483790","6483830","6483831"]
    var accessToken: String = ""
    
    var groupToken: [Int: String] = [:]
    var adminGroupID: [Int] = []
    
    var avatarURL = ""
    
    var userID: String = ""
    var commentFromGroup = 0
    
    let version = "5.71"
    let lpVersion = "3"
    
    var deviceToken = "" // "604a50395f505b94a0b8a15ae198d34d6cbb0b034387154701ddeabb0a873058"
    var deviceRegisterOnPush = false
    
    var errorCode = 0
    var errorMsg = ""
    
    var pushInfo: [AnyHashable: Any]? = nil
    
    let appOpenedCountKey = "APP_OPENED_COUNT"
}
