//
//  OptionsController.swift
//  VK-total
//
//  Created by Сергей Никитин on 07.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox
import LocalAuthentication

class OptionsController: InnerTableViewController {

    var passwordOn = AppConfig.shared.passwordOn
    var passDigits = AppConfig.shared.passwordDigits
    var touchID = AppConfig.shared.touchID
    
    var changeStatus = false
    
    let descriptions: [String] = [
        "Вы можете установить пароль для доступа в приложение (простой пароль из 4 цифр)",
        "Чтобы получать уведомления о происходящих с вашим аакаунтом событиях, когда приложение закрыто, включите данный параметр.",
        "Передавать в пуш-уведомлении текст присланного сообщения.",
        "На каждый статус «онлайн», приложение будет сразу выставлять вам статус «оффлайн». Таким образом, ваш статус всегда будет «заходил только что».",
        "Если вы хотите оставаться в статусе «оффлайн» при запуске приложения, выключите этот параметр.",
        "Автоматически помечать сообщения как прочитанные при открытии конкретного диалога.",
        "Сообщать вашему собеседнику/группе о том, что вы набираете текст.",
        "Вы можете включить звуковые эффекты при появлении информационных сообщений или нажатии на кнопки.",
        "При активации опции автоматического переключения темы, приложение будет использовать цветовую тему системы. Для ручного управления цветовой темой отключите опцию автопереключения.\n\nДля изменения цветовой темы перезапустите приложение после сохранения настроек."
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        //self.navigationItem.hidesBackButton = true
        
        readAppConfig()
        
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        readAppConfig()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if #available(iOS 13.0, *) { return 9 }
        return 8
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if !AppConfig.shared.passwordOn && passwordOn {
            changePassword()
        } else {
            AppConfig.shared.passwordOn = passwordOn
            AppConfig.shared.passwordDigits = passDigits
            AppConfig.shared.touchID = touchID
            
            print("device token = \(vkSingleton.shared.deviceToken)")
            saveAppConfig()
            if AppConfig.shared.pushNotificationsOn {
                registerDeviceOnPush()
            } else {
                unregisterDeviceOnPush()
            }
        }
        self.navigationController?.popViewController(animated: true)
        playSoundEffect(vkSingleton.shared.infoSound)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if passwordOn && touchAuthenticationAvailable() {
                return 2
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
            if !AppConfig.shared.autoMode {
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell") as! SwitchCell
                
                if passwordOn {
                    return cell.getRowHeight(text: "", font: cell.descriptionLabel.font)
                } else {
                    return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
                }
            }
            return 40
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
                
                return cell.getRowHeight(text: descriptions[index], font: cell.descriptionLabel.font)
            }
            return 50
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        }
        if section == 1 {
            return 10
        }
        if section == 4 {
            return 0
        }
        if section == 3 || section == 5 || section == 7 || section == 8 {
            return 10
        }
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
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
                
                cell.nameLabel.text = "Защита экрана паролем"
                cell.descriptionLabel.text = descriptions[index]
                if cell.descriptionLabel.text != "" {
                    cell.descriptionLabel.isHidden = false
                }
                cell.pushSwitch.isOn = passwordOn
                cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = touchID
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Использовать TouchID"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
                
                cell.nameLabel.text = "Push-уведомления"
                cell.descriptionLabel.text = descriptions[index]
                if cell.descriptionLabel.text != "" {
                    cell.descriptionLabel.isHidden = false
                }
                cell.pushSwitch.isOn = AppConfig.shared.pushNotificationsOn
                cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNewMessage
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Новые сообщения"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushComment
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Новые комментарии"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNewFriends
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Заявки в друзья"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.animationDuration = 2
                cell.simpleCheck.on = AppConfig.shared.pushNots
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Ответы"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = AppConfig.shared.pushLikes
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Лайки"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 6:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = AppConfig.shared.pushMentions
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Упоминания"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 7:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = AppConfig.shared.pushFromGroups
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Уведомления от групп"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            case 8:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = AppConfig.shared.pushNewPosts
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Новые записи"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.text = "Передавать текст сообщения"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.showStartMessage
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.text = "Режим «Невидимка»"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.setOfflineStatus
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.adjustsFontSizeToFitWidth = true
            cell.nameLabel.minimumScaleFactor = 0.3
            cell.nameLabel.text = "Проверка сообщений"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.checkUnreadMessageWhileStart
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.text = "Читать сообщения"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.readMessageInDialog
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.text = "Отображать набор текста"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.showTextEditInDialog
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
            
            cell.nameLabel.text = "Звуковые эффекты"
            cell.descriptionLabel.text = descriptions[index]
            if cell.descriptionLabel.text != "" {
                cell.descriptionLabel.isHidden = false
            }
            cell.pushSwitch.isOn = AppConfig.shared.soundEffectsOn
            cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
            
            return cell
        case 8:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "pushCheckCell", for: indexPath) as! SwitchCell
                
                cell.nameLabel.text = "Автопереключение темы"
                cell.descriptionLabel.text = descriptions[index]
                
                if cell.descriptionLabel.text != "" {
                    cell.descriptionLabel.isHidden = false
                }
                
                cell.pushSwitch.isOn = AppConfig.shared.autoMode
                cell.pushSwitch.addTarget(self, action: #selector(self.valueChangedSwitch(sender:)), for: .valueChanged)
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath) as! SimpleCell
                
                cell.simpleCheck.on = AppConfig.shared.darkMode
                cell.simpleCheck.addTarget(self, action: #selector(self.checkBoxValueChanged(sender:)), for: .valueChanged)
                cell.nameLabel.text = "Тёмная тема"
                cell.nameLabel.isEnabled = cell.simpleCheck.on
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            return cell
        }
    }
    
    @objc func valueChangedSwitch(sender: UISwitch) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            
            if indexPath.section == 0 {
                passwordOn = sender.isOn
                tableView.reloadData()
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
                AppConfig.shared.autoMode = sender.isOn
                tableView.reloadData()
                if AppConfig.shared.autoMode {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 8), at: .bottom, animated: true)
                } else {
                    tableView.scrollToRow(at: IndexPath(row: 1, section: 8), at: .bottom, animated: true)
                }
            }
        }
    }

    @objc func checkBoxValueChanged(sender: BEMCheckBox) {
        let position = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: position) {
            if indexPath.section == 0 && indexPath.row == 1 {
                touchID = sender.on
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
            
            if indexPath.section == 8 {
                AppConfig.shared.darkMode = sender.on
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
}
