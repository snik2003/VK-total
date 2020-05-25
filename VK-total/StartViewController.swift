//
//  StartViewController.swift
//  VK-total
//
//  Created by Сергей Никитин on 13.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class StartViewController: InnerViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        performSegue(withIdentifier: "goLoginForm", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}
