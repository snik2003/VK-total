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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        
        if let userInfo = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            vkSingleton.shared.pushInfo = userInfo
        }
        
        StoreReviewHelper.incrementAppOpenedCount()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if AppConfig.shared.passwordOn {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
                let vc = currentVC.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
                vc.state = "login"
                currentVC.present(vc, animated: true)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), let controllers = currentVC.navigationController?.viewControllers {
            for controller in controllers {
                if let dc = controller as? DialogController, dc.mode == .dialog {
                    
                    var code = "var a = API.messages.getHistory({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"offset\":\"0\",\"count\":\"1\",\"user_id\":\"\(dc.userID)\",\"start_message_id\":\"-1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
                    
                    code = "\(code) var b = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(dc.userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
                    
                    code = "\(code) return [a,b];"
                    
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
                        
                        let users = json["response"][1].compactMap { DialogsUsers(json: $0.1) }
                        
                        var currID = 0
                        if let id = dc.dialogs.last?.id {
                            currID = id
                        }
                        
                        OperationQueue.main.addOperation {
                            if let user = users.first {
                                dc.setStatusLabel(user: user, status: "")
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
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        vkSingleton.shared.deviceToken = token
        //print("Device Token: \(token)")
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
        print(userInfo)
        
        if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
            
            if currentVC is UIAlertController {
                currentVC.dismiss(animated: false) { () -> Void in
                    if let currentVC2 = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) {
                        self.tapPushNotification(userInfo, controller: currentVC2)
                    }
                }
            } else {
                self.tapPushNotification(userInfo, controller: currentVC)
            }
        }
        
        completionHandler()
    }
    
    func tapPushNotification(_ userInfo: [AnyHashable: Any], controller: UIViewController) {

        UIApplication.shared.applicationIconBadgeNumber = 0
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
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        }
                    } else if placeType == "photo" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "photo")
                        }
                    } else if placeType == "video" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1 {
                            let ownerID = comp[0]
                            let videoID = comp[1]
                            
                            controller.openVideoController(ownerID: ownerID, vid: videoID, accessKey: "", title: "Видеозапись")
                        }
                    } else {
                        controller.tabBarController?.selectedIndex = 1
                    }
                } else {
                    controller.tabBarController?.selectedIndex = 1
                }
            } else if type == "like" {
                if let userID = (userInfo["data"] as AnyObject).object(forKey: "owner_id") as? String, let itemID = (userInfo["data"] as AnyObject).object(forKey: "item_id") as? String, let likeType = (userInfo["data"] as AnyObject).object(forKey: "like_type") as? String {
                    if likeType == "post" || likeType == "comment"{
                        if let ownerID = Int(userID), let postID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        }
                    } else if likeType == "photo" || likeType == "photo_comment" {
                        if let ownerID = Int(userID), let photoID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo")
                        }
                    } else if likeType == "video" || likeType == "video_comment"{
                        controller.openVideoController(ownerID: userID, vid: itemID, accessKey: "", title: "Видеозапись")
                    } else if likeType == "topic_comment"{
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
                        controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                    }
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
        }
    }
}
