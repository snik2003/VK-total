//
//  StartViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 13.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                vkSingleton.shared.deviceInterfaceStyle = .dark
            } else {
                vkSingleton.shared.deviceInterfaceStyle = .light
            }
        }
            
        vkSingleton.shared.configureColors(controller: self)
        
        OperationQueue.main.addOperation {
            self.view.backgroundColor = vkSingleton.shared.backColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performSegue(withIdentifier: "goLoginForm", sender: self)
    }
    
    override func viewDidLayoutSubviews() {
        vkSingleton.shared.configureColors(controller: self)
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
