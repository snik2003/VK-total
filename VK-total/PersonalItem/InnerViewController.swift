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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {} else {
            if AppConfig.shared.darkMode {
                return .lightContent
            } else {
                return .default
            }
        }
        
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vkSingleton.shared.configureColors(controller: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                vkSingleton.shared.deviceInterfaceStyle = .dark
            } else {
                vkSingleton.shared.deviceInterfaceStyle = .light
            }
        }
        
        self.viewDidLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        vkSingleton.shared.configureColors(controller: self)
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if vkSingleton.shared.openLink != "" {
            self.openBrowserController(url: vkSingleton.shared.openLink)
            vkSingleton.shared.openLink = ""
        }
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
    
    private var cancelActionView: UIView? {
        return view.recursiveSubviews.compactMap({
            $0 as? UILabel}
        ).first(where: {
            $0.text == actions.first(where: { $0.style == .cancel })?.title
        })?.superview?.superview
    }
    
    open override func viewDidLayoutSubviews() {
        
        if #available(iOS 13.0, *) {
            if AppConfig.shared.autoMode {
                self.overrideUserInterfaceStyle = self.traitCollection.userInterfaceStyle
            } else if AppConfig.shared.darkMode {
                self.overrideUserInterfaceStyle = .dark
            } else {
                self.overrideUserInterfaceStyle = .light
            }
        } else if AppConfig.shared.darkMode {
            self.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = vkSingleton.shared.backColor
            self.cancelActionView?.backgroundColor = vkSingleton.shared.backColor
        }
        
        super.viewDidLayoutSubviews()
        
        for action in self.actions {
            let attributedText = NSAttributedString(string: action.title ?? "", attributes: [NSAttributedString.Key.font : UIFont(name: "Verdana", size: 16.0)!])

            guard let label = (action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
            label.attributedText = attributedText
        }

    }
}
