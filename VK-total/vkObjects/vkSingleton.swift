//
//  vkSingleton.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation

enum VKUserInterfaceStyle {
    case light
    case dark
}

final class vkSingleton {
    static let shared = vkSingleton()
    
    let vkAppID: [String] = ["6363391","6483790","6483830","6483831"]
    var accessToken: String = ""
    
    var adminGroupID: [Int] = []
    
    var avatarURL = ""
    var age = 0
    
    var userID: String = ""
    var commentFromGroup = 0
    
    let version = "5.85"
    let lpVersion = "3"
    
    var deviceToken = "" // "604a50395f505b94a0b8a15ae198d34d6cbb0b034387154701ddeabb0a873058"
    var deviceRegisterOnPush = false
    
    var errorCode = 0
    var errorMsg = ""
    
    var pushInfo: [AnyHashable: Any]? = nil
    var pushInfo2: [AnyHashable: Any]? = nil
    
    var stickers: [Stickers] = []
    
    let appOpenedCountKey = "APP_OPENED_COUNT"
    let dialogsOpenedCountKey = "DIALOGS_OPENED_COUNT"
    
    var deviceInterfaceStyle: VKUserInterfaceStyle = .light
    
    var mainColor = UIColor(named: "appMainColor")!
    var backColor = UIColor(named: "appMainBackColor")!
    var separatorColor = UIColor(named: "appSeparatorColor")!
    var separatorColor2 = UIColor(named: "appSeparatorColor2")!
    var labelColor = UIColor(named: "appLabelColor")!
    var secondaryLabelColor = UIColor(named: "appSecondaryLabelColor")!
    
    var inBackColor = UIColor(named: "messageInColor")!
    var outBackColor = UIColor(named: "messageOutColor")!
    var unreadColor = UIColor(named: "messageUnreadColor")!
    var likeColor = UIColor(named: "appLikeColor")!
    
    let errorSound: SystemSoundID = 1000
    let infoSound: SystemSoundID = 1001
    let dialogSound: SystemSoundID = 1003
    let buttonSound: SystemSoundID = 1104
    let linkSound: SystemSoundID = 1211
    let likeSound: SystemSoundID = 1004
    let unlikeSound: SystemSoundID = 1003
    
    var openLink = ""
    
    var actionColor = UIColor(named: "appSecondaryLabelColor")!
    
    func configureColors(controller: UIViewController) {
        
        OperationQueue.main.addOperation {
            AppConfig.shared.autoMode = UserDefaults.standard.bool(forKey: "vktotal_autoMode")
            AppConfig.shared.darkMode = UserDefaults.standard.bool(forKey: "vktotal_darkMode")
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode {
                    controller.overrideUserInterfaceStyle = controller.traitCollection.userInterfaceStyle
                    controller.navigationController?.overrideUserInterfaceStyle = controller.traitCollection.userInterfaceStyle
                    controller.navigationController?.navigationBar.overrideUserInterfaceStyle = controller.traitCollection.userInterfaceStyle
                    controller.tabBarController?.overrideUserInterfaceStyle = controller.traitCollection.userInterfaceStyle
                    
                    if controller.overrideUserInterfaceStyle == .dark {
                        vkSingleton.shared.mainColor = UIColor(red: 10/255, green: 0, blue: 50/255, alpha: 1)
                        vkSingleton.shared.backColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                        
                        vkSingleton.shared.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
                        vkSingleton.shared.separatorColor2 = UIColor(red: 104/255, green: 104/255, blue: 108/255, alpha: 1)
                        vkSingleton.shared.labelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
                        vkSingleton.shared.secondaryLabelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.55)
                        
                        vkSingleton.shared.unreadColor = UIColor(red: 212/255, green: 139/255, blue: 204/255, alpha: 0.3)
                        vkSingleton.shared.likeColor = UIColor(red: 192/255, green: 90/255, blue: 242/255, alpha: 1)
                    } else {
                        vkSingleton.shared.mainColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
                        vkSingleton.shared.backColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                        
                        vkSingleton.shared.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                        vkSingleton.shared.separatorColor2 = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
                        vkSingleton.shared.labelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
                        vkSingleton.shared.secondaryLabelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                        
                        vkSingleton.shared.unreadColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 0.2)
                        vkSingleton.shared.likeColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 1)
                    }
                } else if AppConfig.shared.darkMode {
                    controller.overrideUserInterfaceStyle = .dark
                    controller.navigationController?.overrideUserInterfaceStyle = .dark
                    controller.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
                    controller.tabBarController?.overrideUserInterfaceStyle = .dark
                    
                    vkSingleton.shared.mainColor = UIColor(red: 10/255, green: 0, blue: 50/255, alpha: 1)
                    vkSingleton.shared.backColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                    
                    vkSingleton.shared.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
                    vkSingleton.shared.separatorColor2 = UIColor(red: 174/255, green: 174/255, blue: 178/255, alpha: 1)
                    vkSingleton.shared.labelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
                    vkSingleton.shared.secondaryLabelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.55)
                    
                    vkSingleton.shared.unreadColor = UIColor(red: 212/255, green: 139/255, blue: 204/255, alpha: 0.3)
                    vkSingleton.shared.likeColor = UIColor(red: 192/255, green: 90/255, blue: 242/255, alpha: 1)
                } else {
                    controller.overrideUserInterfaceStyle = .light
                    controller.navigationController?.overrideUserInterfaceStyle = .light
                    controller.navigationController?.navigationBar.overrideUserInterfaceStyle = .light
                    controller.tabBarController?.overrideUserInterfaceStyle = .light
                    
                    vkSingleton.shared.mainColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
                    vkSingleton.shared.backColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                    
                    vkSingleton.shared.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                    vkSingleton.shared.separatorColor2 = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
                    vkSingleton.shared.labelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
                    vkSingleton.shared.secondaryLabelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                    
                    vkSingleton.shared.unreadColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 0.2)
                    vkSingleton.shared.likeColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 1)
                }
                
                vkSingleton.shared.actionColor = vkSingleton.shared.secondaryLabelColor
                
                controller.navigationController?.navigationBar.barTintColor = vkSingleton.shared.mainColor
                controller.navigationController?.view.backgroundColor = vkSingleton.shared.backColor
                controller.tabBarController?.tabBar.barTintColor = vkSingleton.shared.mainColor
                controller.view.backgroundColor = vkSingleton.shared.backColor
                
                if let vc = controller as? InnerTableViewController {
                    vc.tableView.backgroundColor = vkSingleton.shared.backColor
                    vc.tableView.separatorColor = vkSingleton.shared.separatorColor
                } else if let vc = controller as? VkTabbarController {
                    vc.tabBar.barTintColor = vkSingleton.shared.mainColor
                }
                
                if let vc = controller as? VkTabbarController {
                    if AppConfig.shared.autoMode {
                        vc.overrideUserInterfaceStyle = vc.traitCollection.userInterfaceStyle
                        vc.tabBar.barTintColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: vc.overrideUserInterfaceStyle))
                    } else if AppConfig.shared.darkMode {
                        vc.tabBarController?.overrideUserInterfaceStyle = .dark
                        vc.tabBar.barTintColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    } else {
                        vc.tabBarController?.overrideUserInterfaceStyle = .light
                        vc.tabBar.barTintColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                    }
                }
            } else {
                vkSingleton.shared.inBackColor = UIColor(red: 244/255, green: 223/255, blue: 196/255, alpha: 1)
                vkSingleton.shared.outBackColor = UIColor(red: 200/255, green: 200/255, blue: 238/255, alpha: 1)
                
                controller.setNeedsStatusBarAppearanceUpdate()
                controller.navigationController?.setNeedsStatusBarAppearanceUpdate()
                
                if AppConfig.shared.darkMode {
                    vkSingleton.shared.mainColor = UIColor(red: 10/255, green: 0, blue: 50/255, alpha: 1)
                    vkSingleton.shared.backColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                    
                    vkSingleton.shared.separatorColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
                    vkSingleton.shared.separatorColor2 = UIColor(red: 104/255, green: 104/255, blue: 108/255, alpha: 1)
                    vkSingleton.shared.labelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
                    vkSingleton.shared.secondaryLabelColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.55)
                    
                    vkSingleton.shared.unreadColor = UIColor(red: 212/255, green: 139/255, blue: 204/255, alpha: 0.3)
                    vkSingleton.shared.likeColor = UIColor(red: 192/255, green: 90/255, blue: 242/255, alpha: 1)
                } else {
                    vkSingleton.shared.mainColor = UIColor(red: 0, green: 84/255, blue: 147/255, alpha: 1)
                    vkSingleton.shared.backColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                    
                    vkSingleton.shared.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                    vkSingleton.shared.separatorColor2 = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
                    vkSingleton.shared.labelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
                    vkSingleton.shared.secondaryLabelColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                    
                    vkSingleton.shared.unreadColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 0.2)
                    vkSingleton.shared.likeColor = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 1)
                }
                
                vkSingleton.shared.actionColor = vkSingleton.shared.secondaryLabelColor
                
                controller.navigationController?.navigationBar.barTintColor = vkSingleton.shared.mainColor
                controller.navigationController?.view.backgroundColor = vkSingleton.shared.backColor
                controller.tabBarController?.tabBar.barTintColor = vkSingleton.shared.mainColor
                controller.view.backgroundColor = vkSingleton.shared.backColor
                
                if let vc = controller as? InnerTableViewController {
                    vc.tableView.backgroundColor = vkSingleton.shared.backColor
                    vc.tableView.sectionIndexBackgroundColor = vkSingleton.shared.backColor
                    vc.tableView.sectionIndexTrackingBackgroundColor = vkSingleton.shared.backColor
                    vc.tableView.separatorColor = vkSingleton.shared.separatorColor
                } else if let vc = controller as? VkTabbarController {
                    vc.tabBar.barTintColor = vkSingleton.shared.mainColor
                }
            }
        }
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {} else {
            if AppConfig.shared.darkMode {
                return .lightContent
            } else {
                return .default
            }
        }
        
        return .default
    }
    
    
}
