//
//  AppConfig.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

final class AppConfig {
    static let shared = AppConfig()
    
    var firstAppear = "first"
    
    var pushNotificationsOn = false
    
    var pushNewMessage = true
    var pushComment = true
    var pushNewFriends = true
    var pushNots = true
    var pushLikes = true
    var pushMentions = true
    var pushFromGroups = true
    var pushNewPosts = true
    
    var showStartMessage = false
    
    var setOfflineStatus = true
    var checkUnreadMessageWhileStart = false
    var readMessageInDialog = true
    var showTextEditInDialog = true
    
    var passwordOn = true
    var passwordDigits = "0000"
    var touchID = true
    
    var soundEffectsOn = true
}

enum AppConfiguration: String {
    case Debug = "Debug"
    case TestFlight = "TestFlight"
    case AppStore = "AppStore"
}

struct Config {
    // This is private because the use of 'appConfiguration' is preferred.
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }
}
