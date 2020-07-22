//
//  NewRecordOptionsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 15.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NewRecordOptionsController: InnerViewController {

    var userID: Int = 0
    var delegate: NewRecordController!
    
    @IBOutlet weak var onlyFriendsSwitch: UISwitch!
    @IBOutlet weak var inTimeSwitch: UISwitch!
    @IBOutlet weak var postFromMeSwitch: UISwitch!
    @IBOutlet weak var addMySignSwitch: UISwitch!
    
    @IBOutlet weak var onlyFriendsLabel: UILabel!
    @IBOutlet weak var inTimeLabel: UILabel!
    @IBOutlet weak var postFromMeLabel: UILabel!
    @IBOutlet weak var addMySignLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapPostButton(sender:)))
        self.navigationItem.rightBarButtonItem = postButton
        self.navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if delegate.onlyFriends == 1 {
            onlyFriendsSwitch.isOn = true
        } else {
            onlyFriendsSwitch.isOn = false
        }
        onlyFriendsLabel.isEnabled = onlyFriendsSwitch.isOn
        
        if delegate.inTime == 1 {
            inTimeSwitch.isOn = true
        } else {
            inTimeSwitch.isOn = false
            
        }
        inTimeLabel.isEnabled = inTimeSwitch.isOn
        datePicker.isHidden = !inTimeSwitch.isOn

        
        if delegate.publishDate != nil {
            datePicker.date = delegate.publishDate
        } else {
            let currentDate = Date()
            datePicker.date = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
            datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        }
        
        
        if userID > 0 {
            onlyFriendsLabel.text = "Только для друзей"
            
            postFromMeSwitch.isHidden = true
            postFromMeLabel.isHidden = true
            addMySignSwitch.isHidden = true
            addMySignLabel.isHidden = true
        } else {
            onlyFriendsLabel.isHidden = true
            onlyFriendsSwitch.isHidden = true
            
            postFromMeSwitch.isOn = true
            postFromMeSwitch.isEnabled = false
            postFromMeLabel.isEnabled = postFromMeSwitch.isOn
            
            if delegate.signed == 1 {
                addMySignSwitch.isOn = true
            } else {
                addMySignSwitch.isOn = false
            }
            addMySignLabel.isEnabled = addMySignSwitch.isOn
            
            postFromMeSwitch.isHidden = false
            postFromMeLabel.isHidden = false
            addMySignLabel.isHidden = !postFromMeSwitch.isOn
            addMySignSwitch.isHidden = !postFromMeSwitch.isOn
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        onlyFriendsLabel.textColor = vkSingleton.shared.labelColor
        inTimeLabel.textColor = vkSingleton.shared.labelColor
        postFromMeLabel.textColor = vkSingleton.shared.labelColor
        addMySignLabel.textColor = vkSingleton.shared.labelColor
        
        onlyFriendsSwitch.backgroundColor = vkSingleton.shared.backColor
        onlyFriendsSwitch.onTintColor = vkSingleton.shared.mainColor
        onlyFriendsSwitch.tintColor = vkSingleton.shared.mainColor
        
        inTimeSwitch.backgroundColor = vkSingleton.shared.backColor
        inTimeSwitch.onTintColor = vkSingleton.shared.mainColor
        inTimeSwitch.tintColor = vkSingleton.shared.mainColor
        
        onlyFriendsSwitch.backgroundColor = vkSingleton.shared.backColor
        onlyFriendsSwitch.onTintColor = vkSingleton.shared.mainColor
        onlyFriendsSwitch.tintColor = vkSingleton.shared.mainColor
        
        postFromMeSwitch.backgroundColor = vkSingleton.shared.backColor
        postFromMeSwitch.onTintColor = vkSingleton.shared.mainColor
        postFromMeSwitch.tintColor = vkSingleton.shared.mainColor
        
        addMySignSwitch.backgroundColor = vkSingleton.shared.backColor
        addMySignSwitch.onTintColor = vkSingleton.shared.mainColor
        addMySignSwitch.tintColor = vkSingleton.shared.mainColor
        
        datePicker.backgroundColor = vkSingleton.shared.backColor
        datePicker.tintColor = vkSingleton.shared.labelColor
        datePicker.setValue(vkSingleton.shared.labelColor, forKeyPath: "textColor")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapPostButton(sender: UIBarButtonItem) {
        
        if onlyFriendsSwitch.isOn {
            delegate.onlyFriends = 1
        } else {
            delegate.onlyFriends = 0
        }
        
        if inTimeSwitch.isOn {
            delegate.inTime = 1
            delegate.publishDate = datePicker.date
        } else {
            delegate.inTime = 0
        }
        
        if userID < 0 {
            if postFromMeSwitch.isOn {
                delegate.fromGroup = 1
            } else {
                delegate.fromGroup = 0
            }
            
            if addMySignSwitch.isOn {
                delegate.signed = 1
            } else {
                delegate.signed = 0
            }
        }
        
        delegate.configureSetupLabel()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onlyFriendsSwitchValueChanged(sender: UISwitch) {
        
        onlyFriendsLabel.isEnabled = sender.isOn
    }
    
    @IBAction func inTimeSwitchValueChanged(sender: UISwitch) {
        
        inTimeLabel.isEnabled = sender.isOn
        if sender.isOn {
            let currentDate = Date()
            datePicker.date = Calendar.current.date(byAdding: .hour, value: 3, to: currentDate)!
            datePicker.minimumDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        }
        datePicker.isHidden = !sender.isOn
    }
    
    @IBAction func postFromMeSwitchValueChanged(sender: UISwitch) {
        
        postFromMeLabel.isEnabled = sender.isOn
        addMySignLabel.isHidden = !postFromMeSwitch.isOn
        addMySignSwitch.isHidden = !postFromMeSwitch.isOn
    }
    
    @IBAction func addMySignSwitchValueChanged(sender: UISwitch) {
        
        addMySignLabel.isEnabled = sender.isOn
    }
    
}
