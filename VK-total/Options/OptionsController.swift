//
//  OptionsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox
import SCLAlertView
import LocalAuthentication

class OptionsController: InnerTableViewController {

    var passwordOn = AppConfig.shared.passwordOn
    var passDigits = AppConfig.shared.passwordDigits
    var touchID = AppConfig.shared.touchID
    
    var autoMode = AppConfig.shared.autoMode
    var darkMode = AppConfig.shared.darkMode
    
    var changeStatus = false
    
    var sizeCacheText = ""
    
    let descriptions: [String] = [
        "При активации опции автоматического переключения темы, приложение будет использовать цветовую тему системы.\n\nДля ручного управления цветовой темой отключите опцию автопереключения.",
        "Чтобы получать уведомления о происходящих с вашим аакаунтом событиях, когда приложение закрыто, включите данный параметр.",
        "Передавать в пуш-уведомлении текст присланного сообщения.",
        "К сожалению, режим «Невидимка» имеет огрниченные возможности. Проведение некоторых операций (таких, как отправка личного сообщения, загрузка всех диалогов в приложение, публикация новой записи на своей стене) изменяет ваш статус ВКонтакте на «онлайн».\n\nЕсли у вас активирован режим «Невидимка», то приложение сразу выставит вам статус «заходил только что».",
        "Если вы хотите оставаться в статусе «оффлайн» при запуске приложения, выключите этот параметр.",
        "Автоматически помечать сообщения как прочитанные при открытии конкретного диалога.",
        "Сообщать вашему собеседнику о том, что вы набираете текст.",
        "Вы можете включить звуковые эффекты при появлении информационных сообщений или нажатии на кнопки.",
        "Вы можете установить пароль для доступа в приложение (простой пароль из 4 цифр)"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        //self.navigationItem.hidesBackButton = true
        
        sizeCacheText = getSizeOfCachesDirectory()
        readAppConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        readAppConfig()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if !AppConfig.shared.passwordOn && passwordOn {
            changePassword()
        } else {
            AppConfig.shared.passwordOn = passwordOn
            AppConfig.shared.passwordDigits = passDigits
            AppConfig.shared.touchID = touchID
            
            AppConfig.shared.autoMode = autoMode
            AppConfig.shared.darkMode = darkMode
            saveAppConfig()
            
            print("device token = \(vkSingleton.shared.deviceToken)")
            if AppConfig.shared.pushNotificationsOn {
                registerDeviceOnPush()
            } else {
                unregisterDeviceOnPush()
            }
        }
        self.navigationController?.popViewController(animated: true)
        playSoundEffect(vkSingleton.shared.infoSound)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if vkSingleton.shared.userID == "34051891" {
            return 11
        }
        
        return 9
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if #available(iOS 13.0, *) {
                if !autoMode {
                    return 2
                }
            }
            return 1
        }
        
        if section == 1 {
            if AppConfig.shared.pushNotificationsOn {
                return 9
            }
            return 1
        }
        
        if section == 8 {
            if passwordOn && touchAuthenticationAvailable() {
                return 2
            }
            return 1
        }
        
        if section > 1 {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let index = indexPath.section
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if #available(iOS 13.0, *) {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
                    return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
                    return cell.getRowHeight(text: "Чтобы сменить цветовую тему, потребуется перезапустить приложение.", font: cell.descriptionLabel.font)
                }
            }
            return 50
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
                
                if AppConfig.shared.pushNotificationsOn {
                    return cell.getRowHeight(text: "", font: cell.descriptionLabel.font)
                } else {
                    return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
                }
            }
            return 40
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        if indexPath.section == 4 {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return 0
            //return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
        }
        
        if indexPath.section == 8 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
                
                if passwordOn {
                    return cell.getRowHeight(text: "", font: cell.descriptionLabel.font)
                } else {
                    return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
                }
            }
            return 50
        }
        
        if indexPath.section == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            if sizeCacheText.isEmpty {
                return cell.getRowHeight(text: "Ошибка чтения кэша приложения в хранилище iPhone", font: cell.descriptionLabel.font)
            }
            
            return cell.getRowHeight(text: sizeCacheText, font: cell.descriptionLabel.font)
        }
        
        if indexPath.section == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
            
            return cell.getRowHeight(text: vkSingleton.shared.deviceToken, font: cell.descriptionLabel.font)
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 || section == 1 || section == 3 || section == 5 || section == 7 || section == 8 {
            return 7
        }
        
        if section == 4 {
            return 0
        }
        
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 7
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.section
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
                cell.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.isHidden = false
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                if #available(iOS 13.0, *) {
                    cell.nameLabel.text = "Автопереключение темы"
                    cell.descriptionLabel.text = descriptions[index]
                    
                    if cell.descriptionLabel.text != "" {
                        cell.descriptionLabel.isHidden = false
                    }
                    
                    cell.pushSwitch.isOn = autoMode
                    cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                } else {
                    cell.nameLabel.text = "Тёмная тема"
                    cell.descriptionLabel.text = "Чтобы сменить цветовую тему, потребуется перезапустить приложение."
                    cell.descriptionLabel.isHidden = false
                    
                    cell.pushSwitch.isOn = darkMode
                    cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                }
                
                cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = darkMode
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Тёмная тема"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
                cell.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.isHidden = false
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                cell.nameLabel.text = "Пуш-уведомления"
                cell.descriptionLabel.text = descriptions[index]
                if cell.descriptionLabel.text != "" {
                    cell.descriptionLabel.isHidden = false
                }
                cell.pushSwitch.isOn = AppConfig.shared.pushNotificationsOn
                cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                
                cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNewMessage
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Новые сообщения"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushComment
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Новые комментарии"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNewFriends
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Заявки в друзья"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNots
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Ответы"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = AppConfig.shared.pushLikes
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Лайки"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = AppConfig.shared.pushMentions
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Упоминания"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = AppConfig.shared.pushFromGroups
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Уведомления от групп"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = AppConfig.shared.pushNewPosts
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Новые записи"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Передавать текст сообщения"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.showStartMessage
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Режим «Невидимка»"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.setOfflineStatus
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.adjustsFontSizeToFitWidth = true
            cell.nameLabel.minimumScaleFactor = 0.3
            cell.nameLabel.text = "Проверка сообщений"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.checkUnreadMessageWhileStart
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Читать сообщения"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.readMessageInDialog
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Отображать набор текста"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.showTextEditInDialog
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = false
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Звуковые эффекты"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.soundEffectsOn
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
            
            return cell
        case 8:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
                cell.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
                cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
                cell.pushSwitch.isHidden = false
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                cell.nameLabel.text = "Защита экрана паролем"
                cell.descriptionLabel.text = descriptions[index]
                if cell.descriptionLabel.text != "" {
                    cell.descriptionLabel.isHidden = false
                }
                cell.pushSwitch.isOn = passwordOn
                cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                
                cell.pushSwitch.setCurrentStateForVoiceOver(name: cell.nameLabel.text!, indexPath: indexPath)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                cell.backgroundColor = vkSingleton.shared.backColor
                
                cell.nameLabel.textColor = vkSingleton.shared.labelColor
                
                cell.simpleCheck.onTintColor = vkSingleton.shared.mainColor
                cell.simpleCheck.onCheckColor = vkSingleton.shared.mainColor
                
                cell.simpleCheck.on = touchID
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.simpleCheck.addTarget(self, action: #selector(self.checkboxClick(sender:)), for: .touchUpInside)
                cell.nameLabel.text = "Использовать TouchID / FaceID"
                cell.nameLabel.accessibilityLabel = "Использовать тач айди / фейс айди"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                cell.simpleCheck.setCurrentStateForVoiceOver(name: "Использовать тач айди", indexPath: indexPath)
                cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    cell.simpleCheck.on = !cell.simpleCheck.on
                    cell.nameLabel.setCurrentStateForVoiceOver(checkBox: cell.simpleCheck)
                    self.checkBoxValueChanged(sender: cell.simpleCheck)
                }
                cell.nameLabel.isUserInteractionEnabled = true
                cell.nameLabel.addGestureRecognizer(tap)
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = true
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Размер кэша приложения"
            cell.descriptionLabel.isHidden = false
            
            if sizeCacheText.isEmpty {
                cell.descriptionLabel.text = "Ошибка чтения кэша приложения в хранилище iPhone"
            } else {
                cell.descriptionLabel.text = sizeCacheText
                
                if sizeCacheText != "0 байт" {
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                        alertController.addAction(cancelAction)
                        
                        let action = UIAlertAction(title: "Очистить кэш приложения", style: .destructive){ action in
                            self.clearCachesDirectory()
                        }
                        alertController.addAction(action)
                
                        self.present(alertController, animated: true)
                    }
                    cell.isUserInteractionEnabled = true
                    cell.addGestureRecognizer(tap)
                }
            }
            
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            cell.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.backgroundColor = vkSingleton.shared.backColor
            cell.pushSwitch.onTintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.tintColor = vkSingleton.shared.mainColor
            cell.pushSwitch.isHidden = true
            
            cell.nameLabel.textColor = vkSingleton.shared.labelColor
            cell.descriptionLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            cell.nameLabel.text = "Токен устройства"
            cell.descriptionLabel.text = vkSingleton.shared.deviceToken
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            
            let tap = UITapGestureRecognizer()
            tap.add {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action = UIAlertAction(title: "Скопировать токен", style: .default){ action in
                    UIPasteboard.general.string = vkSingleton.shared.deviceToken
                    if let string = UIPasteboard.general.string {
                        self.showInfoMessage(title: "Скопированное сообщение:" , msg: string)
                    }
                }
                alertController.addAction(action)
        
                self.present(alertController, animated: true)
            }
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(tap)
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    @objc func valueChangedSwitch(sender: UISwitch) {
        
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            sender.setCurrentStateForVoiceOver(name: sender.accessibilityLabel!, indexPath: indexPath)
            
            if indexPath.section == 0 {
                if #available(iOS 13.0, *) {
                    autoMode = sender.isOn
                    tableView.reloadData()
                    
                    if AppConfig.shared.autoMode != sender.isOn {
                        showChangeModeMessage(title: "Внимание!", msg: "Чтобы сменить цветовую тему,\nпотребуется перезапустить приложение\n", indexPath: indexPath, newValue: sender.isOn)
                    }
                } else {
                    darkMode = sender.isOn
                    tableView.reloadData()
                    
                    if AppConfig.shared.darkMode != sender.isOn {
                        showChangeModeMessage(title: "Внимание!", msg: "Чтобы сменить цветовую тему,\nпотребуется перезапустить приложение\n", indexPath: indexPath, newValue: sender.isOn)
                    }
                }
            }
            
            if indexPath.section == 1 {
                AppConfig.shared.pushNotificationsOn = sender.isOn
                tableView.reloadData()
            }
            
            if indexPath.section == 2 {
                AppConfig.shared.showStartMessage = sender.isOn
            }
            
            if indexPath.section == 3 {
                AppConfig.shared.setOfflineStatus = sender.isOn
            }
            
            if indexPath.section == 4 {
                AppConfig.shared.checkUnreadMessageWhileStart = sender.isOn
            }
            
            if indexPath.section == 5 {
                AppConfig.shared.readMessageInDialog = sender.isOn
            }
            
            if indexPath.section == 6 {
                AppConfig.shared.showTextEditInDialog = sender.isOn
            }
            
            if indexPath.section == 7 {
                AppConfig.shared.soundEffectsOn = sender.isOn
            }
            
            if indexPath.section == 8 {
                passwordOn = sender.isOn
                tableView.reloadData()
                
                if passwordOn {
                    tableView.scrollToRow(at: IndexPath(row: 1, section: 8), at: .bottom, animated: true)
                } else {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 8), at: .bottom, animated: true)
                }
            }
            
        }
    }

    @objc func checkboxClick(sender: BEMCheckBox) {
        sender.on = !sender.on
    }
    
    @objc func checkBoxValueChanged(sender: BEMCheckBox) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            
            sender.setCurrentStateForVoiceOver(name: sender.accessibilityLabel!, indexPath: indexPath)
            
            if indexPath.section == 0 {
                darkMode = sender.on
                tableView.reloadData()
                if AppConfig.shared.darkMode != sender.on {
                    showChangeModeMessage(title: "Внимание!", msg: "Чтобы сменить цветовую тему,\nпотребуется перезапустить приложение\n", indexPath: indexPath, newValue: sender.on)
                }
            }
            
            if indexPath.section == 1 {
                switch indexPath.row {
                case 1:
                    AppConfig.shared.pushNewMessage = sender.on
                case 2:
                    AppConfig.shared.pushComment = sender.on
                case 3:
                    AppConfig.shared.pushNewFriends = sender.on
                case 4:
                    AppConfig.shared.pushNots = sender.on
                case 5:
                    AppConfig.shared.pushLikes = sender.on
                case 6:
                    AppConfig.shared.pushMentions = sender.on
                case 7:
                    AppConfig.shared.pushFromGroups = sender.on
                case 8:
                    AppConfig.shared.pushNewPosts = sender.on
                default:
                    break
                }
            }
            
            if indexPath.section == 8 && indexPath.row == 1 {
                touchID = sender.on
            }
            
            tableView.reloadData()
        }
    }
    
    func changePassword() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
        vc.state = "change"
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func touchAuthenticationAvailable() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func showChangeModeMessage(title: String, msg: String, indexPath: IndexPath, newValue: Bool) {
        
        OperationQueue.main.addOperation {
            var titleColor = UIColor.black
            var backColor = UIColor.white
            
            titleColor = vkSingleton.shared.labelColor
            backColor = vkSingleton.shared.backColor
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false,
                circleBackgroundColor: backColor,
                contentViewColor: backColor,
                titleColor: titleColor
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("Перезапустить приложение", action: {
                if indexPath.section == 0 && indexPath.row == 0 {
                    if #available(iOS 13.0, *) {
                        UserDefaults.standard.setValue(newValue, forKey: "vktotal_autoMode")
                        AppConfig.shared.autoMode = newValue
                    } else {
                        UserDefaults.standard.setValue(newValue, forKey: "vktotal_darkMode")
                        AppConfig.shared.darkMode = newValue
                    }
                } else if indexPath.section == 0 && indexPath.row == 1 {
                    UserDefaults.standard.setValue(newValue, forKey: "vktotal_darkMode")
                    AppConfig.shared.darkMode = newValue
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let window = UIApplication.shared.keyWindow
                
                if let controller  = storyboard.instantiateViewController(withIdentifier: "LoginFormController") as? LoginFormController {
                    
                    controller.view.backgroundColor = vkSingleton.shared.backColor
                    controller.changeAccount = true
                    
                    UIView.transition(with: window!, duration: 0.9, options: .transitionFlipFromLeft, animations: {
                        window?.rootViewController = controller
                        window?.makeKeyAndVisible()
                    }, completion: nil)
                }
            })
            
            alert.addButton("Отмена", action: {
                if indexPath.section == 0 && indexPath.row == 0 {
                    if #available(iOS 13.0, *) {
                        self.autoMode = !newValue
                    } else {
                        self.darkMode = !newValue
                    }
                } else if indexPath.section == 0 && indexPath.row == 1 {
                    self.darkMode = !newValue
                }
                
                self.tableView.reloadData()
            })
            
            alert.showInfo(title, subTitle: msg)
            self.playSoundEffect(vkSingleton.shared.errorSound)
        }
    }
    
    func getSizeOfCachesDirectory() -> String {
        
        let homeDir = NSHomeDirectory()
        
        var filesCount = 0
        var totalSize = 0
        var totalSizeText = ""
        
        do {
            let dir1 = homeDir.appending("/Library/Preferences")
            let files1 = try FileManager.default.contentsOfDirectory(atPath: dir1)
            
            for file in files1 {
                if file.contains(".plist.") {
                    filesCount += 1
                    let path = dir1.appending("/\(file)")
                    let folder = try FileManager.default.attributesOfItem(atPath: path)
                    
                    for (key, size) in folder {
                        if key == FileAttributeKey.size {
                            totalSize += (size as AnyObject).integerValue
                        }
                    }
                }
            }
            
            let dir2 = homeDir.appending("/Library/Cookies")
            let files2 = try FileManager.default.contentsOfDirectory(atPath: dir2)
            filesCount += files2.count
            
            for file in files2 {
                let path = dir2.appending("/\(file)")
                let folder = try FileManager.default.attributesOfItem(atPath: path)
                
                for (key, size) in folder {
                    if key == FileAttributeKey.size {
                        totalSize += (size as AnyObject).integerValue
                    }
                }
            }
            
            let dir3 = homeDir.appending("/Library/Caches/images")
            let files3 = try FileManager.default.contentsOfDirectory(atPath: dir3)
            filesCount += files3.count
            
            for file in files3 {
                let path = dir3.appending("/\(file)")
                let folder = try FileManager.default.attributesOfItem(atPath: path)
                
                for (key, size) in folder {
                    if key == FileAttributeKey.size {
                        totalSize += (size as AnyObject).integerValue
                    }
                }
            }
            
            let dir4 = homeDir.appending("/Library/Caches/Snik2003.VK-inThe-City/fsCachedData")
            let files4 = try FileManager.default.contentsOfDirectory(atPath: dir4)
            filesCount += files4.count
            
            for file in files4 {
                let path = dir4.appending("/\(file)")
                let folder = try FileManager.default.attributesOfItem(atPath: path)
                
                for (key, size) in folder {
                    if key == FileAttributeKey.size {
                        totalSize += (size as AnyObject).integerValue
                    }
                }
            }
        } catch {
            return ""
        }
        
        if totalSize == 0 {
            return "0 байт"
        } else if totalSize < 1024 {
            if filesCount > 1 {
                totalSizeText = "\(totalSize) байт (\(filesCount) файлов)"
            } else {
                totalSizeText = "\(totalSize) байт"
            }
        } else if totalSize < 1024 * 1024 {
            if filesCount > 1 {
                totalSizeText = "\(totalSize / 1024) КБ (\(filesCount) файлов)"
            } else {
                totalSizeText = "\(totalSize / 1024) КБ"
            }
        } else {
            if filesCount > 1 {
                totalSizeText = "\(totalSize / 1024 / 1024) МБ (\(filesCount) файлов)"
            } else {
                totalSizeText = "\(totalSize / 1024 / 1024) МБ"
            }
        }
        
        return "\(totalSizeText) - нажмите, чтобы очистить кэш приложения в хранилище iPhone"
    }
    
    func clearCachesDirectory() {
        
        ViewControllerUtils().showActivityIndicator(uiView: tableView)
        let homeDir = NSHomeDirectory()
        
        do {
            let dir1 = homeDir.appending("/Library/Preferences")
            let files1 = try FileManager.default.contentsOfDirectory(atPath: dir1)
            
            for file in files1 {
                if file.contains(".plist.") {
                    let path = dir1.appending("/\(file)")
                    try FileManager.default.removeItem(atPath: path)
                }
            }
            
            let dir2 = homeDir.appending("/Library/Cookies")
            let files2 = try FileManager.default.contentsOfDirectory(atPath: dir2)
            
            for file in files2 {
                let path = dir2.appending("/\(file)")
                try FileManager.default.removeItem(atPath: path)
            }
            
            let dir3 = homeDir.appending("/Library/Caches/images")
            let files3 = try FileManager.default.contentsOfDirectory(atPath: dir3)
            
            for file in files3 {
                let path = dir3.appending("/\(file)")
                try FileManager.default.removeItem(atPath: path)
            }
            
            let dir4 = homeDir.appending("/Library/Caches/Snik2003.VK-inThe-City/fsCachedData")
            let files4 = try FileManager.default.contentsOfDirectory(atPath: dir4)
            
            for file in files4 {
                let path = dir4.appending("/\(file)")
                try FileManager.default.removeItem(atPath: path)
            }
            
            ViewControllerUtils().hideActivityIndicator()
            showInfoMessage(title: "Внимание!", msg: "Кэш приложения удалён из хранилища iPhone", completion: {
                self.navigationController?.popViewController(animated: true)
            })
        } catch {
            ViewControllerUtils().hideActivityIndicator()
            showErrorMessage(title: "Внимание!", msg: "Ошибка удаления кэша приложения в хранилище iPhone")
        }
    }
}

extension UISwitch {
    func setCurrentStateForVoiceOver(name: String, indexPath: IndexPath) {
        self.isAccessibilityElement = true
        
        self.accessibilityLabel = name
        self.accessibilityIdentifier = "\(indexPath.section)-\(indexPath.row)"
    }
}

extension BEMCheckBox {
    func setCurrentStateForVoiceOver(name: String, indexPath: IndexPath) {
        self.isAccessibilityElement = true
        
        self.accessibilityLabel = name
        self.accessibilityIdentifier = "\(indexPath.section)-\(indexPath.row)"
        
        if self.on {
            self.accessibilityValue = "Включено"
            self.accessibilityHint = "Коснитесь дважды, чтобы выключить пуш-уведомления для \(name)"
        } else {
            self.accessibilityValue = "Выключено"
            self.accessibilityHint = "Коснитесь дважды, чтобы включить пуш-уведомления для \(name)"
        }
    }
}

extension UILabel {
    func setCurrentStateForVoiceOver(checkBox: BEMCheckBox) {
        self.isAccessibilityElement = true
        
        self.accessibilityTraits = [.button]
        
        if checkBox.on {
            self.accessibilityValue = "Включено"
            self.accessibilityHint = "Коснитесь дважды, чтобы выключить пуш-уведомления для \(checkBox.accessibilityLabel!)"
        } else {
            self.accessibilityValue = "Выключено"
            self.accessibilityHint = "Коснитесь дважды, чтобы включить пуш-уведомления для \(checkBox.accessibilityLabel!)"
        }
    }
}
