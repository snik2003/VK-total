//
//  vkSingleton.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation

final class vkSingleton {
    static let shared = vkSingleton()
    
    let vkAppID: [String] = ["6363391","6483790","6483830","6483831"]
    var accessToken: String = ""
    
    var adminGroupID: [Int] = []
    
    var avatarURL = ""
    var age = 0
    
    var userID: String = ""
    var commentFromGroup = 0
    
    let version = "5.71"
    let lpVersion = "3"
    
    var deviceToken = "" // "604a50395f505b94a0b8a15ae198d34d6cbb0b034387154701ddeabb0a873058"
    var deviceRegisterOnPush = false
    let sandbox = 0
    
    var errorCode = 0
    var errorMsg = ""
    
    var pushInfo: [AnyHashable: Any]? = nil
    
    let appOpenedCountKey = "APP_OPENED_COUNT"
    
    let mainColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
    
    let errorSound: SystemSoundID = 1000
    let infoSound: SystemSoundID = 1001
    let dialogSound: SystemSoundID = 1003
    let buttonSound: SystemSoundID = 1104
    let linkSound: SystemSoundID = 1211
    let likeSound: SystemSoundID = 1004
    let unlikeSound: SystemSoundID = 1003
}
