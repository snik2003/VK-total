//
//  AppDelegate.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.12.2017.
//  Copyright © 2017 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import DropDown
import SwiftMessages
import SwiftyJSON
import Popover
import SCLAlertView
import SafariServices
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
            let configuration = YMMYandexMetricaConfiguration.init(apiKey: "7f7648a4-5c2f-4b87-9951-7ccdd7de2469")
            YMMYandexMetrica.activate(with: configuration!)
        #else
            let configuration = YMMYandexMetricaConfiguration.init(apiKey: "e62996d5-ac3b-4823-80c0-04d1aa5714d4")
            YMMYandexMetrica.activate(with: configuration!)
        #endif
        
        clearPreferencesDirectory()
        registerForPushNotifications()
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            vkSingleton.shared.pushInfo2 = userInfo
        }
        
        StoreReviewHelper.incrementAppOpenedCount()
        return true
    }

    func clearPreferencesDirectory() {
        do {
            let homeDir = NSHomeDirectory()
            let fileManager = FileManager.default
            
            let directory = homeDir.appending("/Library/Preferences")
            let files = try fileManager.contentsOfDirectory(atPath: directory)
            
            for file in files {
                if file.contains(".plist.") {
                    let path = directory.appending("/\(file)")
                    try fileManager.removeItem(atPath: path)
                }
            }
            
            let directory2 = homeDir.appending("/Library/Cookies")
            let files2 = try fileManager.contentsOfDirectory(atPath: directory2)
            
            for file in files2 {
                let path = directory2.appending("/\(file)")
                try fileManager.removeItem(atPath: path)
            }
            
            let directory3 = homeDir.appending("/Library/Caches/Snik2003.VK-inThe-City/fsCachedData")
            let files3 = try fileManager.contentsOfDirectory(atPath: directory3)
            
            for file in files3 {
                let path = directory3.appending("/\(file)")
                try fileManager.removeItem(atPath: path)
            }
            
            let directory4 = homeDir.appending("/Library/Caches/images")
            let files4 = try fileManager.contentsOfDirectory(atPath: directory4)
            
            for file in files4 {
                let path = directory4.appending("/\(file)")
                try fileManager.removeItem(atPath: path)
            }
        } catch {
            print("Ошибка удаления кэша приложения в хранилище iPhone")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if !url.absoluteString.isEmpty {
            let stringURL = url.absoluteString.replacingOccurrences(of: "vktotal://", with: "https://").replacingOccurrences(of: "vk://", with: "https://")
            vkSingleton.shared.openLink = stringURL
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if AppConfig.shared.passwordOn {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
                let vc = currentVC.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
                vc.state = "login"
                vc.modalPresentationStyle = .fullScreen
                currentVC.present(vc, animated: true)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if vkSingleton.shared.openLink != "" {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
                if currentVC is InnerViewController || currentVC is InnerTableViewController {
                    currentVC.openBrowserController(url: vkSingleton.shared.openLink)
                    vkSingleton.shared.openLink = ""
                } else if currentVC is UIAlertController {
                    currentVC.dismiss(animated: false) { () -> Void in
                        if let currentVC2 = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) {
                            currentVC2.openBrowserController(url: vkSingleton.shared.openLink)
                            vkSingleton.shared.openLink = ""
                        }
                    }
                } else if currentVC is SFSafariViewController {
                    vkSingleton.shared.openLink = ""
                }
            }
        }
        
    
        if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
            for controller in controllers {
                
                if let dc = controller as? DialogController, dc.mode == .dialog {
                    dc.commentView.endEditing(true)
                    
                    var code = "var a = API.messages.getHistory({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"offset\":\"0\",\"count\":\"1\",\"user_id\":\"\(dc.userID)\",\"start_message_id\":\"-1\",\"extended\": \"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
                    
                    if dc.chatID == "" {
                        code = "\(code) var b = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(dc.userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
                        
                        code = "\(code) return [a,b];"
                    } else {
                        code = "\(code) return [a];"
                    }
                    
                    let url = "/method/execute"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "code": code,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    getServerDataOperation.completionBlock = {
                        guard let data = getServerDataOperation.data else { return }
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        //print(json)
                        
                        let inRead = json["response"][0]["in_read"].intValue
                        let outRead = json["response"][0]["out_read"].intValue
                        let startID = max(inRead,outRead)
                        
                        var currID = 0
                        if let id = dc.dialogs.last?.id {
                            currID = id
                        }
                        
                        OperationQueue.main.addOperation {
                            if dc.chatID == "" {
                                let users = json["response"][1].compactMap { DialogsUsers(json: $0.1) }
                                if let user = users.first {
                                    dc.setStatusLabel(user: user, status: "")
                                }
                            }
                            
                            if startID > currID {
                                ViewControllerUtils().showActivityIndicator(uiView: dc.commentView)
                                dc.startMessageID = startID
                                dc.getDialog()
                            }
                        }
                    }
                    OperationQueue().addOperation(getServerDataOperation)
                }
                
                if let dc = controller as? DialogsController {
                    
                    if let view = dc.view.superview {
                        ViewControllerUtils().showActivityIndicator(uiView: view)
                    } else {
                        ViewControllerUtils().showActivityIndicator(uiView: dc.view)
                    }
                    
                    dc.offset = 0
                    if AppConfig.shared.setOfflineStatus {
                        dc.refreshExecute()
                    } else {
                        dc.getAllDialogsOnline()
                    }
                }
            }
        }
        
        
        if let userInfo = vkSingleton.shared.pushInfo {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
                
                if currentVC is UIAlertController || currentVC is SFSafariViewController {
                    currentVC.dismiss(animated: false) { () -> Void in
                        if let currentVC2 = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) {
                            self.tapPushNotification(userInfo, controller: currentVC2)
                        }
                    }
                } else {
                    self.tapPushNotification(userInfo, controller: currentVC)
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            //print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            //print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            OperationQueue.main.addOperation {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        
        if #available(iOS 13, *) {
            token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        } else {
            let tokenParts = deviceToken.map { data -> String in
                return String(format: "%02.2hhx", data)
            }
            token = tokenParts.joined()
        }
        
        vkSingleton.shared.deviceToken = token
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController! {
        
        if rootViewController is UITabBarController {
            let tabbarController =  rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(rootViewController: tabbarController.selectedViewController)
        } else if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(rootViewController: navigationController.visibleViewController2)
        } else if rootViewController.presentedViewController != nil {
            let controller = rootViewController.presentedViewController
            
            return self.topViewControllerWithRootViewController(rootViewController: controller)
        } else {
            return rootViewController
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         
        let userInfo = response.notification.request.content.userInfo
        vkSingleton.shared.pushInfo = userInfo
        print(userInfo)
        
        if UIApplication.shared.applicationState == .active {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
                
                if currentVC is UIAlertController || currentVC is SFSafariViewController {
                    currentVC.dismiss(animated: false) { () -> Void in
                        if let currentVC2 = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) {
                            self.tapPushNotification(userInfo, controller: currentVC2)
                        }
                    }
                } else {
                    self.tapPushNotification(userInfo, controller: currentVC)
                }
            } 
        }
        
        completionHandler()
    }
    
    func tapPushNotification(_ userInfo: [AnyHashable: Any], controller: UIViewController) {

        UIApplication.shared.applicationIconBadgeNumber = 0
        vkSingleton.shared.pushInfo = nil
        SwiftMessages.hideAll()
        if let type = (userInfo["data"] as AnyObject).object(forKey: "category") as? String {
            
            if type == "comment" {
                if let place = (userInfo["data"] as AnyObject).object(forKey: "place") as? String {
                    var placeType = place.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: nil)
                    placeType = placeType.replacingOccurrences(of: "_", with: "", options: .regularExpression, range: nil)
                    
                    if placeType == "wall" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post", scrollToComment: true)
                        }
                    } else if placeType == "photo" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "photo", scrollToComment: true)
                        }
                    } else if placeType == "video" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1 {
                            let ownerID = comp[0]
                            let videoID = comp[1]
                            
                            controller.openVideoController(ownerID: ownerID, vid: videoID, accessKey: "", title: "Видеозапись", scrollToComment: true)
                        }
                    } else {
                        controller.tabBarController?.selectedIndex = 1
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "like" {
                if let userID = (userInfo["data"] as AnyObject).object(forKey: "owner_id") as? String, let itemID = (userInfo["data"] as AnyObject).object(forKey: "item_id") as? String, let likeType = (userInfo["data"] as AnyObject).object(forKey: "like_type") as? String {
                    if likeType == "post" {
                        if let ownerID = Int(userID), let postID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post", scrollToComment: false)
                        }
                    } else if likeType == "comment" {
                        if let ownerID = Int(userID), let postID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post", scrollToComment: true)
                        }
                    } else if likeType == "photo" || likeType == "photo_comment" {
                        if let ownerID = Int(userID), let photoID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo", scrollToComment: true)
                        }
                    } else if likeType == "video" {
                        controller.openVideoController(ownerID: userID, vid: itemID, accessKey: "", title: "Видеозапись", scrollToComment: false)
                    } else if likeType == "video_comment" {
                            controller.openVideoController(ownerID: userID, vid: itemID, accessKey: "", title: "Видеозапись", scrollToComment: true)
                    } else if likeType == "topic_comment" {
                        controller.openTopicController(groupID: userID, topicID: itemID, title: "", delegate: controller)
                    } else {
                        controller.tabBarController?.selectedIndex = 1
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "msg" {
                if let pushID = (userInfo["data"] as AnyObject).object(forKey: "push_id") as? String {
                    let comp = pushID.components(separatedBy: "_")
                    if comp.count == 3, let startID = Int(comp[2]) {
                        let userID = comp[1]
                        
                        if userID != vkSingleton.shared.userID {
                            controller.openDialogController(userID: "\(userID)", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                        }
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "new_post" {
                if let place = (userInfo["data"] as AnyObject).object(forKey: "place") as? String {
                    let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                    let comp = digits.components(separatedBy: "_")
                    
                    if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                        controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post", scrollToComment: false)
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "open_url" {
                if let url = (userInfo["data"] as AnyObject).object(forKey: "url") as? String {
                    controller.openBrowserController(url: url)
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "show_message" {
                
            } else if type == "birthday" {
                controller.openUsersController(uid: vkSingleton.shared.userID, title: "Мои друзья", type: "friends")
            } else if type == "chat" {
                if let pushID = (userInfo["data"] as AnyObject).object(forKey: "push_id") as? String {
                    let comp = pushID.components(separatedBy: "_")
                    if comp.count == 3, let startID = Int(comp[2]), let chatID = Int(comp[1]) {
                        let userID = comp[1]
                        
                        if userID != vkSingleton.shared.userID {
                            controller.openDialogController(userID: "\(userID)", chatID: "\(chatID - 2000000000)", startID: startID, attachment: "", messIDs: [], image: nil)
                        }
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "friend" {
                if let uid = (userInfo["data"] as AnyObject).object(forKey: "uid") as? String, let id = Int(uid) {
                    controller.getCounters()
                    controller.openProfileController(id: id, name: "")
                }
            } else if type == "group_invite" {
                controller.tabBarController?.selectedIndex = 1
            } else {
                controller.tabBarController?.selectedIndex = 1
                if vkSingleton.shared.userID == "357365563" || vkSingleton.shared.userID == "34051891" {
                    controller.showInfoMessage(title: "Push Settings", msg: "category = \"\(type)\"")
                }
            }
        } else if let type = (userInfo["data"] as AnyObject).object(forKey: "type") as? String {
            if type == "msg" || type == "chat" {
                if let string = (userInfo["data"] as AnyObject).object(forKey: "id") as? String {
                    let comp = string.components(separatedBy: "_")
                    if comp.count == 3, let startID = Int(comp[2]), let chatID = Int(comp[1]) {
                        let userID = comp[1]
                        let type = comp[0]
                        
                        if type == "chat" {
                            controller.openDialogController(userID: "\(userID)", chatID: "\(chatID - 2000000000)", startID: startID, attachment: "", messIDs: [], image: nil)
                        } else if type == "msg" {
                            if userID == vkSingleton.shared.userID { return }
                            controller.openDialogController(userID: "\(userID)", chatID: "", startID: startID, attachment: "", messIDs: [], image: nil)
                        }
                    }
                }
            } else if let url = (userInfo["data"] as AnyObject).object(forKey: "url") as? String {
                let urls = url.components(separatedBy: "?")
                if let vkURL = urls.first {
                    controller.openBrowserController(url: vkURL)
                }
            }
        }
    }
}
