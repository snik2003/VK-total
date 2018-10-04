//
//  BrowserController.swift
//  VK-total
//
//  Created by Сергей Никитин on 16.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift
import AVFoundation

class BrowserController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var urlTextField: UITextField!
    
    var isObserving = false
    
    var path: String = "https://geekbrains.ru/login"
    
    var type = ""
    var artistID = 0
    var songID = 0
    var artist = ""
    var album = ""
    var song = ""
    var previewURL = ""
    var workURL = ""
    var avatarURL = ""
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress.isHidden = true
        progress.tintColor = vkSingleton.shared.mainColor
        
        if UIScreen.main.nativeBounds.height == 2436 {
            self.navHeight = 88
            self.tabHeight = 83
        }
        
        let configuration = WKWebViewConfiguration()
        let frameRect = CGRect(x: 0, y: navHeight + 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight - 50 - 44)
        
        webView = WKWebView(frame: frameRect, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36"
        view.addSubview(webView)
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        let barButton = UIBarButtonItem(image: UIImage(named: "three-dots"), style: .plain, target: self, action: #selector(self.barButtonTouch(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if let url = URL(string: path), url.host != nil {
            let request = URLRequest(url: url)
            urlTextField.text = path
            webView.load(request)
            
            if !isObserving {
                isObserving = true
                webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            }
        } else {
            showErrorMessage(title: "Ошибка", msg: "Некорректная ссылка:\n\(path)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isObserving {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            //print(webView.estimatedProgress)
            progress.progress = Float(webView.estimatedProgress);
        }
    }
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            urlTextField.text = url.absoluteString
        }
        progress.progress = 0.15
        progress.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            urlTextField.text = url.absoluteString
        }
        progress.progress = 1
        progress.isHidden = true
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progress.progress = 1
        progress.isHidden = true
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        if webView.canGoBack {
            if AppConfig.shared.soundEffectsOn { AudioServicesPlaySystemSound(1104) }
            webView.goBack()
        }
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        if webView.canGoForward {
            if AppConfig.shared.soundEffectsOn { AudioServicesPlaySystemSound(1104) }
            webView.goForward()
        }
    }
    
    @IBAction func reload(sender: UIBarButtonItem) {
        if let url = webView.url {
            if AppConfig.shared.soundEffectsOn { AudioServicesPlaySystemSound(1104) }
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
   private func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
    
        self.progress.progress = 1
        self.progress.isHidden = true
        self.showErrorMessage(title: "Ошибка!", msg: error.localizedDescription)
    }
    
    @IBAction func barButtonTouch(sender: UIBarButtonItem) {
        if AppConfig.shared.soundEffectsOn { AudioServicesPlaySystemSound(1104) }
        
        var alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if type == "song" {
            alertController = UIAlertController(title: "\(artist): «\(song)»", message: nil, preferredStyle: .actionSheet)
        }
        
        if type == "artist" {
            alertController = UIAlertController(title: "\(artist)", message: nil, preferredStyle: .actionSheet)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        if type == "song" {
            let action2 = UIAlertAction(title: "Сохранить песню в «Избранное»", style: .default) { action in
                self.saveSongToRealm()
            }
            alertController.addAction(action2)
        }
        
        let action1 = UIAlertAction(title: "Скопировать текущий URL", style: .default) { action in
            
            if let url = self.webView.url {
                let link = String(describing: url)
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Текущий URL:" , msg: "\(string)")
                }
            }
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Открыть ссылку в Safari", style: .default) { action in
            
            if let url = self.webView.url {
                UIApplication.shared.open(url, options: [:])
            }
        }
        alertController.addAction(action2)
        
        self.present(alertController, animated: true)
    }
    
    func saveSongToRealm() {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            
            let song = IMusic()
        
            song.songID = songID
            song.userID = Int(vkSingleton.shared.userID)!
            song.artist = artist
            song.song = self.song
            song.URL = workURL
            song.reserv1 = artistID
            song.reserv4 = previewURL
            song.reserv5 = avatarURL
            
            let realm = try Realm(configuration: config)
            
            //print(realm.configuration.fileURL!)
            
            realm.beginWrite()
            realm.add(song, update: true)
            try realm.commitWrite()
            showSuccessMessage(title: "Моя музыка ITunes", msg: "Песня «\(self.song)» успешно записана в «Избранное»")
        } catch {
            showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
        }
    }
}
