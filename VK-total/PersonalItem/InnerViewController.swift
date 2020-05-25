//
//  InnerViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.05.2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation

class InnerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if AppConfig.shared.autoMode {
                vkSingleton.shared.mainColor = UIColor(named: "appMainColor")!.resolvedColor(with: traitCollection)
                vkSingleton.shared.backColor = UIColor(named: "appMainBackColor")!.resolvedColor(with: traitCollection)
                
                self.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
                self.navigationController?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
            } else if AppConfig.shared.darkMode {
                vkSingleton.shared.mainColor = UIColor(named: "appMainColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                vkSingleton.shared.backColor = UIColor(named: "appMainBackColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                
                self.overrideUserInterfaceStyle = .dark
                self.navigationController?.overrideUserInterfaceStyle = .dark
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
            } else {
                vkSingleton.shared.mainColor = UIColor(named: "appMainColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                vkSingleton.shared.backColor = UIColor(named: "appMainBackColor")!.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                
                self.overrideUserInterfaceStyle = .light
                self.navigationController?.overrideUserInterfaceStyle = .light
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = .light
            }
        }
        
        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 13.0, *) {
            if AppConfig.shared.autoMode {
                self.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
                self.navigationController?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
                self.tabBarController?.overrideUserInterfaceStyle = traitCollection.userInterfaceStyle
            } else if AppConfig.shared.darkMode {
                self.overrideUserInterfaceStyle = .dark
                self.navigationController?.overrideUserInterfaceStyle = .dark
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
                self.tabBarController?.overrideUserInterfaceStyle = .dark
            } else {
                self.overrideUserInterfaceStyle = .light
                self.navigationController?.overrideUserInterfaceStyle = .light
                self.navigationController?.navigationBar.overrideUserInterfaceStyle = .light
                self.tabBarController?.overrideUserInterfaceStyle = .light
            }
        }
        
        super.viewDidLayoutSubviews()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension UIViewController {
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
    }
}

extension UIAlertController {
    open override func viewDidLayoutSubviews() {
        
        if #available(iOS 13.0, *) {
            if AppConfig.shared.autoMode {
                self.overrideUserInterfaceStyle = self.traitCollection.userInterfaceStyle
            } else if AppConfig.shared.darkMode {
                self.overrideUserInterfaceStyle = .dark
            } else {
                self.overrideUserInterfaceStyle = .light
            }
        }
        
        super.viewDidLayoutSubviews()
        
        for action in self.actions {
            let attributedText = NSAttributedString(string: action.title ?? "", attributes: [NSAttributedString.Key.font : UIFont(name: "Verdana", size: 16.0)!])

            guard let label = (action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label.attributedText = attributedText
        }

    }
}
