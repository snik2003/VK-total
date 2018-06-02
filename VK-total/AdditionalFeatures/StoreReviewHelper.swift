//
//  StoreReviewHelper.swift
//  Template1
//
//  Created by Apple on 14/11/17.
//  Copyright © 2017 Mobiotics. All rights reserved.
//
import Foundation
import StoreKit

struct StoreReviewHelper {
    
    static func incrementAppOpenedCount() { // didfinishLaunchingWithOptions
        guard var appOpenCount = UserDefaults.standard.value(forKey: vkSingleton.shared.appOpenedCountKey) as? Int else {
            UserDefaults.standard.set(1, forKey: vkSingleton.shared.appOpenedCountKey)
            return
        }
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: vkSingleton.shared.appOpenedCountKey)
    }
    
    static func checkAndAskForReview() {
        guard let appOpenCount = UserDefaults.standard.value(forKey: vkSingleton.shared.appOpenedCountKey) as? Int else {
            UserDefaults.standard.set(1, forKey: vkSingleton.shared.appOpenedCountKey)
            return
        }
        
        switch appOpenCount {
        case 10,25:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount % 50 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("App run count is : \(appOpenCount)")
            break;
        }
        
    }
    
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            StoreReviewHelper.incrementAppOpenedCount()
        } else {
            
        }
    }
}
