//
//  LoginFormController.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.12.2017.
//  Copyright © 2017 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class LoginFormController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var webview: WKWebView!
    
    let userDefaults = UserDefaults.standard
    
    var changeAccount = false
    var exitAccount = false
    var checkPassword = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readAppConfig()
        vkSingleton.shared.configureColors(controller: self)
        
        OperationQueue.main.addOperation {
            self.view.backgroundColor = vkSingleton.shared.backColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if exitAccount == true {
            if self.getNumberOfAccounts() > 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountController") as! AddAccountController
                controller.readAccountsFromRealm()
                self.present(controller, animated: true)
            } else {
                vkAutorize()
            }
        } else {
            if changeAccount == false {
                if let userID = userDefaults.string(forKey: "vkUserID") {
                    vkSingleton.shared.userID = userID
                }
                
                readAppConfig()
                
                if AppConfig.shared.passwordOn && !checkPassword {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
                    vc.state = "login"
                    present(vc, animated: true)
                    checkPassword = true
                }
            }
            
            if vkSingleton.shared.userID == "" {
                vkAutorize()
            } else {
                if let userID = Int(vkSingleton.shared.userID) {
                    vkSingleton.shared.accessToken = getAccessTokenFromRealm(userID: userID)
                }
                
                if !vkSingleton.shared.accessToken.isEmpty {
                    performSegue(withIdentifier: "goTabbar", sender: nil)
                } else {
                    vkAutorize()
                }
            }
        }
        
        exitAccount = false
        changeAccount = false
    }
    
    func vkAutorize() {
        webview = WKWebView(frame: self.view.frame)
        webview.navigationDelegate = self
        webview.backgroundColor = vkSingleton.shared.backColor
        webview.isOpaque = false
        self.view.addSubview(webview)
        
        if vkSingleton.shared.vkAppID.count > 0 {
            var urlComponents = URLComponents()
        
            var num = self.getNumberOfAccounts()
            
            if num >= vkSingleton.shared.vkAppID.count {
                num = vkSingleton.shared.vkAppID.count - 1
            }
            urlComponents.scheme = "https"
            urlComponents.host = "oauth.vk.com"
            urlComponents.path = "/authorize"
        
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: "\(vkSingleton.shared.vkAppID[num])"),
                URLQueryItem(name: "display", value: "mobile"),
                URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
                URLQueryItem(name: "scope", value: "friends, photos, audio, video, pages, status, notes, messages, wall, docs, groups, notifications, offline"),
                URLQueryItem(name: "response_type", value: "token"),
                URLQueryItem(name: "v", value: vkSingleton.shared.version)
            ]

            print("vkAppID = \(vkSingleton.shared.vkAppID[num])")
            
            if let url = urlComponents.url {
                let request = URLRequest(url: url)
                webview.load(request)
            }
        }
    }
    
    func vkLogout() {
        cleanCookies()
        
        deleteAccountFromRealm(userID: Int(vkSingleton.shared.userID)!)
        
        vkSingleton.shared.accessToken = ""
        vkSingleton.shared.userID = ""
    }

    @IBAction func logoutVKsegue(unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "logoutVK" {
            
            vkLogout()
            var webview_new = WKWebView() {
                didSet{
                    webview_new.navigationDelegate = self
                }
            }
            vkSingleton.shared.accessToken = ""
            vkSingleton.shared.userID = ""
            exitAccount = true
        }
        
        if unwindSegue.identifier == "addAccountVK" {
            cleanCookies()
            var webview_new = WKWebView() {
                didSet{
                    webview_new.navigationDelegate = self
                }
            }
            vkSingleton.shared.accessToken = ""
            vkSingleton.shared.userID = ""
            changeAccount = true
            
            modalTransitionStyle = .flipHorizontal
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

extension LoginFormController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment  else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        if let token = params["access_token"], let id = params["user_id"] {
            vkSingleton.shared.accessToken = token
            vkSingleton.shared.userID = id
            userDefaults.set(vkSingleton.shared.userID, forKey: "vkUserID")
            
            performSegue(withIdentifier: "goTabbar", sender: nil)
            
            decisionHandler(.cancel)
            webView.removeFromSuperview()
        } else {
            decisionHandler(.cancel)
            webView.removeFromSuperview()
            
            if self.getNumberOfAccounts() > 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountController") as! AddAccountController
                controller.readAccountsFromRealm()
                self.present(controller, animated: true)
            } else {
                vkAutorize()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTabbar" {
            if let controller = segue.destination as? VkTabbarController {
                controller.modalTransitionStyle = .flipHorizontal
            }
        }
    }
}
