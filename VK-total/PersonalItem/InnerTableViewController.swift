//
//  InnerTableViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.05.2020.
//  Copyright © 2020 Sergey Nikitin. All rights reserved.
//

import UIKit

class InnerTableViewController: UITableViewController {

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
