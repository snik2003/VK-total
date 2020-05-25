//
//  ChangeProfileInfoController.swift
//  VK-total
//
//  Created by Сергей Никитин on 29.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown

class ChangeProfileInfoController: InnerViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var maidenField: UITextField!
    @IBOutlet weak var screenNameField: UITextField!
    @IBOutlet weak var homeTownField: UITextField!
    @IBOutlet weak var bdateField: UITextField!
    
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var bdateVisLabel: UILabel!
    
    var delegate: UserInfoTableViewController!
    
    var profile: [ProfileInfo] = []
    
    let sexDrop = DropDown()
    let sexPicker = ["не указан",
                     "женский",
                     "мужской"]
    
    let relationDrop = DropDown()
    let relationPicker = ["не показывать",
                          "не женат/не замужем",
                          "есть друг/есть подруга",
                          "помолвлен/помолвлена",
                          "женат/замужем",
                          "всё сложно",
                          "в активном поиске",
                          "влюблён/влюблена",
                          "в гражданском браке"]
    
    let bdateDrop = DropDown()
    let bdateVisPicker = ["не показывать дату рождения",
                          "показывать дату рождения",
                          "показывать только день и месяц"]
    
    var textColor = UIColor.black
    var fieldBackgroundColor = vkSingleton.shared.backColor
    var dropBackgroundColor = vkSingleton.shared.backColor
    var shadowColor = UIColor.darkGray
    var fieldBackgroundColorDisabled = UIColor.red.withAlphaComponent(0.4)
    var selectedBackgroundColor = vkSingleton.shared.mainColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            textColor = .label
            fieldBackgroundColorDisabled = .separator
            
            if AppConfig.shared.autoMode {
                if self.traitCollection.userInterfaceStyle == .dark {
                    selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                    dropBackgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                    shadowColor = .lightGray
                    textColor = .white
                } else {
                    selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                    dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                    shadowColor = .darkGray
                    textColor = .black
                }
            } else if AppConfig.shared.darkMode {
                selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
                dropBackgroundColor = UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1)
                shadowColor = .lightGray
                textColor = .white
            } else {
                selectedBackgroundColor = vkSingleton.shared.mainColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                dropBackgroundColor = UIColor(red: 233/255, green: 238/255, blue: 255/255, alpha: 1)
                shadowColor = .darkGray
                textColor = .black
            }
        }
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            
            self.maidenField.delegate = self
            self.screenNameField.delegate = self
            self.homeTownField.delegate = self
            self.bdateField.delegate = self
            
            self.maidenField.textColor = self.textColor
            self.screenNameField.textColor = self.textColor
            self.homeTownField.textColor = self.textColor
            self.bdateField.textColor = self.textColor
            
            self.sexLabel.textColor = self.textColor
            self.relationLabel.textColor = self.textColor
            self.bdateVisLabel.textColor = self.textColor
            
            self.maidenField.backgroundColor = self.fieldBackgroundColor
            self.maidenField.layer.cornerRadius = 4
            self.maidenField.layer.borderColor = self.textColor.cgColor
            self.maidenField.layer.borderWidth = 0.8
            
            self.screenNameField.backgroundColor = self.fieldBackgroundColor
            self.screenNameField.layer.cornerRadius = 4
            self.screenNameField.layer.borderColor = self.textColor.cgColor
            self.screenNameField.layer.borderWidth = 0.8
            
            self.homeTownField.backgroundColor = self.fieldBackgroundColor
            self.homeTownField.layer.cornerRadius = 4
            self.homeTownField.layer.borderColor = self.textColor.cgColor
            self.homeTownField.layer.borderWidth = 0.8
            
            self.bdateField.backgroundColor = self.fieldBackgroundColor
            self.bdateField.layer.cornerRadius = 4
            self.bdateField.layer.borderColor = self.textColor.cgColor
            self.bdateField.layer.borderWidth = 0.8
            
            self.sexLabel.backgroundColor = self.fieldBackgroundColor
            self.sexLabel.layer.cornerRadius = 4
            self.sexLabel.layer.borderColor = self.textColor.cgColor
            self.sexLabel.layer.borderWidth = 0.8
            
            let sexTap = UITapGestureRecognizer(target: self, action: #selector(self.tapSexLabel))
            self.sexLabel.addGestureRecognizer(sexTap)
            
            self.sexDrop.anchorView = self.sexLabel
            self.sexDrop.dataSource = self.sexPicker
            
            self.sexDrop.textColor = self.textColor
            self.sexDrop.textFont = UIFont(name: "Verdana", size: 12)!
            self.sexDrop.selectedTextColor = self.textColor
            self.sexDrop.backgroundColor = self.dropBackgroundColor
            self.sexDrop.selectionBackgroundColor = self.selectedBackgroundColor
            self.sexDrop.cellHeight = 30
            self.sexDrop.shadowColor = self.shadowColor
            
            self.sexDrop.selectionAction = { [unowned self] (index: Int, item: String) in
                self.profile[0].sex = index
                self.sexLabel.text = item
                
                if self.profile[0].sex == 1 {
                    self.maidenField.isEnabled = true
                    self.maidenField.backgroundColor = self.fieldBackgroundColor
                } else {
                    self.maidenField.isEnabled = false
                    self.maidenField.backgroundColor = self.fieldBackgroundColorDisabled
                    self.maidenField.text = ""
                }
                
                self.sexDrop.hide()
            }
            
            self.relationLabel.backgroundColor = self.fieldBackgroundColor
            self.relationLabel.layer.cornerRadius = 4
            self.relationLabel.layer.borderColor = self.textColor.cgColor
            self.relationLabel.layer.borderWidth = 0.8
            
            let relationTap = UITapGestureRecognizer(target: self, action: #selector(self.tapRelationLabel))
            self.relationLabel.addGestureRecognizer(relationTap)
            
            self.relationDrop.anchorView = self.relationLabel
            self.relationDrop.dataSource = self.relationPicker
            
            self.relationDrop.textColor = self.textColor
            self.relationDrop.textFont = UIFont(name: "Verdana", size: 12)!
            self.relationDrop.selectedTextColor = self.textColor
            self.relationDrop.backgroundColor = self.dropBackgroundColor
            self.relationDrop.selectionBackgroundColor = self.selectedBackgroundColor
            self.relationDrop.shadowColor = self.shadowColor
            self.relationDrop.cellHeight = 30
            
            
            self.relationDrop.selectionAction = { [unowned self] (index: Int, item: String) in
                self.profile[0].relation = index
                self.relationLabel.text = item
                self.relationDrop.hide()
            }
            
            self.bdateVisLabel.backgroundColor = self.fieldBackgroundColor
            self.bdateVisLabel.layer.cornerRadius = 4
            self.bdateVisLabel.layer.borderColor = self.textColor.cgColor
            self.bdateVisLabel.layer.borderWidth = 0.8
            
            let bdateVisTap = UITapGestureRecognizer(target: self, action: #selector(self.tapBdateVisLabel))
            self.bdateVisLabel.addGestureRecognizer(bdateVisTap)
            
            self.bdateDrop.anchorView = self.bdateVisLabel
            self.bdateDrop.dataSource = self.bdateVisPicker
            
            self.bdateDrop.textColor = self.textColor
            self.bdateDrop.textFont = UIFont(name: "Verdana", size: 12)!
            self.bdateDrop.selectedTextColor = self.textColor
            self.bdateDrop.backgroundColor = self.dropBackgroundColor
            self.bdateDrop.selectionBackgroundColor = self.selectedBackgroundColor
            self.bdateDrop.shadowColor = self.shadowColor
            self.bdateDrop.cellHeight = 30
            
            self.bdateDrop.selectionAction = { [unowned self] (index: Int, item: String) in
                self.profile[0].bdateVisibility = index
                self.bdateVisLabel.text = item
                self.bdateDrop.hide()
            }
            
            let saveButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapSaveButton(sender:)))
            self.navigationItem.rightBarButtonItem = saveButton
            self.navigationItem.hidesBackButton = true
            let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.tapCancelButton(sender:)))
            self.navigationItem.leftBarButtonItem = cancelButton
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
            self.view.addGestureRecognizer(tap)
        }
        
        getProfileInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: kbSize.height + 10, right: 0)
        
        self.scrollView?.contentSize = CGSize(width: (self.scrollView?.frame.width)!, height: (self.scrollView?.frame.height)! - kbSize.height + 10)
        
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        self.scrollView?.contentInset = contentInsets
        self.scrollView?.scrollIndicatorInsets = contentInsets
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapSaveButton(sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
        
        var snChange = false
        if profile.count > 0 {
            if profile[0].screenName != screenNameField.text! {
                profile[0].screenName = screenNameField.text!
                snChange = true
            }
            profile[0].homeTown = homeTownField.text!
            profile[0].bdate = bdateField.text!
            profile[0].maidenName = maidenField.text!
            
            let url = "/method/account.saveProfileInfo"
            var parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "sex": "\(profile[0].sex)",
                "relation": "\(profile[0].relation)",
                "bdate": profile[0].bdate,
                "bdate_visibility": "\(profile[0].bdateVisibility)",
                "home_town": profile[0].homeTown,
                "v": vkSingleton.shared.version
            ]
            
            if profile[0].sex == 1 {
                parameters["maiden_name"] = profile[0].maidenName
            }
            
            if snChange == true {
                parameters["screen_name"] = profile[0].screenName
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                let redirect = json["error"]["redirect_uri"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.delegate.users[0].maidenName = self.profile[0].maidenName
                        self.delegate.users[0].domain = self.profile[0].screenName
                        self.delegate.users[0].sex = self.profile[0].sex
                        self.delegate.users[0].relation = self.profile[0].relation
                        self.delegate.users[0].birthDate = self.profile[0].bdate
                        self.delegate.users[0].homeTown = self.profile[0].homeTown
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if error.errorCode == 1260 {
                    self.showErrorMessage(title: "Ошибка!", msg: "Некорректно задано короткое имя страницы.")
                } else if error.errorCode == 17 {
                    OperationQueue.main.addOperation {
                        self.navigationController?.popViewController(animated: true)
                        if AppConfig.shared.setOfflineStatus {
                            let alertController = UIAlertController(title: "внутренняя ссылка ВКонтакте:", message: redirect, preferredStyle: .actionSheet)
                            
                            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                            alertController.addAction(cancelAction)
                            
                            let action1 = UIAlertAction(title: "Открыть ссылку", style: .destructive){ action in
                                
                                self.delegate.openBrowserControllerNoCheck(url: redirect)
                            }
                            alertController.addAction(action1)
                            
                            self.delegate.present(alertController, animated: true)
                        } else {
                            self.delegate.openBrowserControllerNoCheck(url: redirect)
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
            self.setOfflineStatus(dependence: request)
        }
    }
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadProfileInfo() {
        if profile.count > 0 {
            self.title = "\(profile[0].firstName) \(profile[0].lastName)"
            
            maidenField.text = profile[0].maidenName
            screenNameField.text = profile[0].screenName
            homeTownField.text = profile[0].homeTown
            bdateField.text = profile[0].bdate
            
            if profile[0].sex == 1 {
                maidenField.isEnabled = true
                maidenField.backgroundColor = fieldBackgroundColor
            } else {
                maidenField.isEnabled = false
                maidenField.backgroundColor = fieldBackgroundColorDisabled
                maidenField.text = ""
            }
            
            sexLabel.text = sexPicker[profile[0].sex]
            relationLabel.text = relationPicker[profile[0].relation]
            
            bdateVisLabel.text = bdateVisPicker[profile[0].bdateVisibility]
        }
    }
    
    func getProfileInfo() {
        let opq = OperationQueue()
        
        let url = "/method/account.getProfileInfo"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseProfile = ParseProfileInfo()
        parseProfile.addDependency(getServerDataOperation)
        opq.addOperation(parseProfile)
        
        let reloadController = ReloadProfileInfoController(controller: self)
        reloadController.addDependency(parseProfile)
        OperationQueue.main.addOperation(reloadController)
    }
    
    @objc func tapSexLabel() {
        self.view.endEditing(true)
        sexDrop.selectRow(profile[0].sex)
        sexDrop.show()
    }
    
    @objc func tapRelationLabel() {
        self.view.endEditing(true)
        relationDrop.selectRow(profile[0].relation)
        relationDrop.show()
    }
    
    @objc func tapBdateVisLabel() {
        self.view.endEditing(true)
        bdateDrop.selectRow(profile[0].bdateVisibility)
        bdateDrop.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    
    func  textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == bdateField {
            let datePickerView:UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = .date
            datePickerView.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
            datePickerView.backgroundColor = vkSingleton.shared.backColor
            datePickerView.setValue(textColor, forKeyPath: "textColor")
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "dd.M.yyyy"
            if let date = dateFormatter2.date(from: textField.text!) {
                datePickerView.date = date
            } else {
                datePickerView.date = dateFormatter2.date(from: "01.1.1998")!
            }
            textField.inputView = datePickerView
            
            datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        }
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.M.yyyy"
        bdateField.text = dateFormatter.string(from: sender.date)
        profile[0].bdate = bdateField.text!
    }
}
