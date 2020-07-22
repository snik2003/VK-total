//
//  MyMusicController.swift
//  VK-total
//
//  Created by Сергей Никитин on 22.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView
import AVFoundation
import SwiftMessages
import BEMCheckBox

class MyMusicController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: UIViewController!
    
    var ownerID = ""
    var music: [IMusic] = []
    var search: [IMusic] = []
    var source = ""
    
    var tableView: UITableView!
    var artistTextField: UITextField!
    var albumTextField: UITextField!
    var songTextField: UITextField!
    
    var player = AVPlayer()
    var isPlaying = false
    var playIndexPath: IndexPath!
    
    var repeatSong = false
    var repeatAll = false
    
    var navHeight: CGFloat {
           if #available(iOS 13.0, *) {
               return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           } else {
               return UIApplication.shared.statusBarFrame.size.height +
                   (self.navigationController?.navigationBar.frame.height ?? 0.0)
           }
       }
    var tabHeight: CGFloat = 49
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //repeatSong = UserDefaults.standard.bool(forKey: "Music_Itunes_repeatSong")
        //repeatAll = UserDefaults.standard.bool(forKey: "Music_Itunes_repeatAll")
        
        self.configureTableView()
        if self.source == "" {
            self.configureSearchView()
        }
        
        getMusicFromRealm()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
        self.tableView.reloadData()
        self.tableView.separatorStyle = .singleLine
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstAppear {
            firstAppear = false
            tabHeight = self.tabBarController?.tabBar.frame.height ?? 49.0
        }
    }
    
    @objc override func playerDidFinishPlaying(note: NSNotification) {
        
        if repeatSong {
            player.seek(to: CMTime.zero)
            player.play()
            
            if let indexPath = playIndexPath {
                var song = IMusic()
                if indexPath.section == 0 {
                    song = search[indexPath.row]
                } else {
                    song = music[indexPath.row]
                }
                
                showAudioPlayOnScreen(song: song, player: player)
            }
        } else if repeatAll {
            
        } else {
            if playIndexPath != nil {
                if let cell = tableView.cellForRow(at: playIndexPath) as? MyMusicCell {
                    cell.listenButton.imageView?.tintColor = vkSingleton.shared.mainColor
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func configureTableView() {
        tableView = UITableView()
        tableView.backgroundColor = vkSingleton.shared.backColor
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        
        tableView.register(MyMusicCell.self, forCellReuseIdentifier: "music")
        
        tableView.frame = CGRect(x: 0, y: navHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navHeight - tabHeight)
        self.view.addSubview(tableView)
    }
    
    func getMusicFromRealm() {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            
            let realm = try Realm(configuration: config)
            
            //let realmMusic = realm.objects(IMusic.self).filter("userID == %@", Int(ownerID)!).sorted(byKeyPath: "reserv1")
            let realmMusic = realm.objects(IMusic.self).sorted(byKeyPath: "reserv1")
            
            
            music = Array(realmMusic)
        } catch {
            showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
        }
    }
    
    func deleteSongFromRealm(songID: Int) -> Bool {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            
            let realm = try Realm(configuration: config)
            
            //let song = realm.objects(IMusic.self).filter("songID == %@ && userID == %@", songID, Int(ownerID)!)
            let song = realm.objects(IMusic.self).filter("songID == %@", songID)
            
            
            realm.beginWrite()
            realm.delete(song)
            try realm.commitWrite()
            return true
        } catch {
            showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
        }
        
        return false
    }
    
    func addSongToRealm(music: IMusic) -> Bool {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            config.schemaVersion = 1
            
            let realm = try Realm(configuration: config)
            
            realm.beginWrite()
            realm.add(music, update: .all)
            try realm.commitWrite()
            return true
        } catch {
            showErrorMessage(title: "База Данных Realm", msg: "Ошибка: \(error)")
        }
        
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return search.count
        } else {
            return music.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if search.count > 0 {
                return 18
            }
            return 0
        }
        return 18
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 18
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.separatorColor
        
        let titleLabel = UILabel()
        if section == 0 {
            if search.count > 0 {
                titleLabel.text = "Результаты поиска"
            }
        } else {
            titleLabel.text = "Избранное"
        }
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 14)!
        titleLabel.textColor = .black
        titleLabel.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 16)
        titleLabel.textColor = vkSingleton.shared.labelColor
        
        viewHeader.addSubview(titleLabel)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.separatorColor
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "music", for: indexPath) as! MyMusicCell
        
        if indexPath.section == 0 {
            let song = search[indexPath.row]
            
            cell.configureCell(song: song, indexPath: indexPath, cell: cell, tableView: self.tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 10)
            
            cell.listenButton.addTarget(self, action: #selector(self.tapListenButton(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            let song = music[indexPath.row]
            
            cell.configureCell(song: song, indexPath: indexPath, cell: cell, tableView: self.tableView)
            
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 10)
            
            cell.listenButton.addTarget(self, action: #selector(self.tapListenButton(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if source == "add_music" {
            let song = music[indexPath.row]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Вставить ссылку на страницу iTunes", style: .default){ action in
                
                if let vc = self.delegate as? NewRecordController {
                    vc.link = song.URL
                    vc.setAttachments()
                    vc.collectionView.reloadData()
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Вставить ссылку на превью песни", style: .default){ action in
                
                if let vc = self.delegate as? NewRecordController {
                    vc.link = song.reserv4
                    vc.setAttachments()
                    vc.startConfigureView()
                    vc.collectionView.reloadData()
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        } else if source == "add_comment_music" {
            let song = music[indexPath.row]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Вставить ссылку на страницу iTunes", style: .default){ action in
                
                let mention = "\(song.artist) \"\(song.song)\"\n\(song.URL)"
                if let vc = self.delegate as? NewCommentController {
                    vc.textView.insertText(mention)
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Вставить ссылку на превью песни", style: .default){ action in
                
                let mention = "\(song.artist) \"\(song.song)\"\n\(song.reserv4)"
                if let vc = self.delegate as? NewCommentController {
                    vc.textView.insertText(mention)
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        } else if source == "add_topic_music" {
            let song = music[indexPath.row]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Вставить ссылку на страницу iTunes", style: .default){ action in
                
                let mention = "\(song.artist) \"\(song.song)\"\n\(song.URL)"
                if let vc = self.delegate as? AddTopicController {
                    vc.textView.insertText(mention)
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Вставить ссылку на превью песни", style: .default){ action in
                
                let mention = "\(song.artist) \"\(song.song)\"\n\(song.reserv4)"
                if let vc = self.delegate as? AddTopicController {
                    vc.textView.insertText(mention)
                }
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action2)
            
            self.present(alertController, animated: true)
        } else {
            /*if playIndexPath != nil && playIndexPath != indexPath {
                if let oldCell = tableView.cellForRow(at: playIndexPath) as? MyMusicCell {
                    oldCell.listenButton.imageView?.tintColor = vkSingleton.shared.mainColor
                }
                SwiftMessages.hideAll()
                player.removeAllItems()
                isPlaying = false
            }*/
            
            var song: IMusic!
            if indexPath.section == 0 { song = search[indexPath.row] }
            else { song = music[indexPath.row] }
            
            let alertController = UIAlertController(title: "\(song.artist)\n«\(song.song)»", message: nil, preferredStyle: .actionSheet)
            
            if !song.reserv6.isEmpty {
                let action1 = UIAlertAction(title: "Открыть исполнителя в Apple Music", style: .default) { action in
                    
                    self.openBrowserControllerNoCheck(url: song.reserv6)
                }
                alertController.addAction(action1)
            }
            
            if indexPath.section == 0 {
                let action1 = UIAlertAction(title: "Сохранить песню в «Избранное»", style: .default) { action in
                    if self.addSongToRealm(music: song) {
                        self.search.remove(at: indexPath.row)
                        self.getMusicFromRealm()
                        self.tableView.reloadData()
                        self.showSuccessMessage(title: "Моя музыка iTunes", msg: "Песня «\(song.song)» успешно добавлена в «Избранное».")
                    }
                }
                alertController.addAction(action1)
            }
            
            let action2 = UIAlertAction(title: "Открыть песню в Apple Music", style: .default) { action in
            
                self.openBrowserControllerNoCheck(url: song.URL)
            }
            alertController.addAction(action2)
            
            let action3 = UIAlertAction(title: "Скопировать название", style: .default) { action in
                
                let link = "\(song.artist)\n«\(song.song)»"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Скопировано:" , msg: "\(string)")
                }
            }
            alertController.addAction(action3)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true)
        }
    }
    
    @objc func tapListenButton(sender: UIButton) {
        sender.buttonTouched(controller: self)
        
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        
        if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
            var song: IMusic!
            if indexPath.section == 0 {
                song = search[indexPath.row]
            } else {
                song = music[indexPath.row]
            }
            
            let cell = tableView.cellForRow(at: indexPath) as! MyMusicCell
            
            if playIndexPath != nil, playIndexPath != indexPath {
                if let oldCell = tableView.cellForRow(at: playIndexPath) as? MyMusicCell {
                    oldCell.listenButton.imageView?.tintColor = vkSingleton.shared.mainColor
                }
                SwiftMessages.hideAll()
                player.pause()
                isPlaying = false
            }
            
            if isPlaying {
                cell.listenButton.imageView?.tintColor = vkSingleton.shared.mainColor
                player.pause()
                SwiftMessages.hideAll()
                isPlaying = false
            } else {
                if let url = URL(string: song.reserv4) {
                    cell.listenButton.imageView?.tintColor = vkSingleton.shared.likeColor
                    
                    player = AVPlayer(url: url)
                    player.seek(to: CMTime.zero)
                    player.play()
                    self.showAudioPlayOnScreen(song: song, player: player)
                    
                    isPlaying = true
                    playIndexPath = indexPath
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section == 0 {
            let addAction = UITableViewRowAction(style: .normal, title: "Добавить в\n«Избранное»") { (rowAction, indexPath) in
                if self.addSongToRealm(music: self.search[indexPath.row]) {
                    let title = self.search[indexPath.row].song
                    self.search.remove(at: indexPath.row)
                    self.getMusicFromRealm()
                    self.tableView.reloadData()
                    self.showSuccessMessage(title: "Моя музыка iTunes", msg: "Песня «\(title)» успешно добавлена в «Избранное».")
                }
            }
            addAction.backgroundColor = vkSingleton.shared.mainColor
        
            return [addAction]
        } else {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить из\n«Избранное»") { (rowAction, indexPath) in
                let song = self.music[indexPath.row]
                
                let titleColor = vkSingleton.shared.labelColor
                let backColor = vkSingleton.shared.backColor
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleTop: 32.0,
                    kWindowWidth: UIScreen.main.bounds.width - 40,
                    kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                    kTextFont: UIFont(name: "Verdana", size: 13)!,
                    kButtonFont: UIFont(name: "Verdana", size: 14)!,
                    showCloseButton: false,
                    showCircularIcon: true,
                    circleBackgroundColor: backColor,
                    contentViewColor: backColor,
                    titleColor: titleColor
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                alertView.addButton("Да, я уверен") {
                    if self.deleteSongFromRealm(songID: song.songID) {
                        self.music.remove(at: indexPath.row)
                        self.tableView.reloadData()
                    }
                }
                
                alertView.addButton("Отмена, я передумал") {
                    
                }
                alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить песню «\(song.song)» из раздела «Избранное»?")
                
            }
            deleteAction.backgroundColor = vkSingleton.shared.likeColor
            
            return [deleteAction]
        }
    }
    
    func configureSearchView() {
        let searchView = UIView()
        
        var topY: CGFloat = 10.0

        artistTextField = UITextField()
        artistTextField.layer.sublayerTransform = CATransform3DMakeTranslation(4, 0, 0)
        artistTextField.placeholder = "Исполнитель:"
        artistTextField.clearButtonMode = .whileEditing
        artistTextField.textColor = artistTextField.tintColor
        artistTextField.layer.borderColor = vkSingleton.shared.labelColor.cgColor
        artistTextField.layer.borderWidth = 1
        artistTextField.layer.cornerRadius = 4
        artistTextField.contentMode = .center
        artistTextField.backgroundColor = vkSingleton.shared.backColor
        artistTextField.font = UIFont(name: "Verdana", size: 12)!
        artistTextField.text = ""
        artistTextField.textColor = vkSingleton.shared.secondaryLabelColor
        artistTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 25)
        artistTextField.changeKeyboardAppearanceMode()
        searchView.addSubview(artistTextField)
        topY += 25
        
        topY += 10
        
        albumTextField = UITextField()
        albumTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        albumTextField.placeholder = "Название альбома:"
        albumTextField.clearButtonMode = .whileEditing
        albumTextField.textColor = albumTextField.tintColor
        albumTextField.layer.borderColor = vkSingleton.shared.labelColor.cgColor
        albumTextField.layer.borderWidth = 1
        albumTextField.layer.cornerRadius = 5
        albumTextField.contentMode = .center
        albumTextField.backgroundColor = vkSingleton.shared.backColor
        albumTextField.font = UIFont(name: "Verdana", size: 12)!
        albumTextField.text = ""
        albumTextField.textColor = vkSingleton.shared.secondaryLabelColor
        albumTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 25)
        albumTextField.changeKeyboardAppearanceMode()
        searchView.addSubview(albumTextField)
        topY += 25
        
        topY += 10
        
        songTextField = UITextField()
        songTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        songTextField.placeholder = "Название песни:"
        songTextField.clearButtonMode = .whileEditing
        songTextField.textColor = songTextField.tintColor
        songTextField.layer.borderColor = vkSingleton.shared.labelColor.cgColor
        songTextField.layer.borderWidth = 1
        songTextField.layer.cornerRadius = 5
        songTextField.contentMode = .center
        songTextField.backgroundColor = vkSingleton.shared.backColor
        songTextField.font = UIFont(name: "Verdana", size: 12)!
        songTextField.text = ""
        songTextField.textColor = vkSingleton.shared.secondaryLabelColor
        songTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 25)
        songTextField.changeKeyboardAppearanceMode()
        searchView.addSubview(songTextField)
        topY += 25
        
        topY += 15
        
        let searchButton = UIButton()
        searchButton.layer.borderColor = UIColor.black.cgColor
        searchButton.layer.borderWidth = 0.6
        searchButton.layer.cornerRadius = 7
        searchButton.clipsToBounds = true
        searchButton.setTitle("Очистить поиск", for: .normal)
        searchButton.setTitleColor(UIColor.white, for: .normal)
        searchButton.backgroundColor = vkSingleton.shared.mainColor
        searchButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 11)!
        searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton.titleLabel?.minimumScaleFactor = 0.5
        searchButton.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width/2-45, height: 25)
        searchView.addSubview(searchButton)
        searchButton.addTarget(self, action: #selector(self.clearSearch(sender:)), for: .touchUpInside)
        
        let clearButton = UIButton()
        clearButton.layer.borderColor = UIColor.black.cgColor
        clearButton.layer.borderWidth = 0.6
        clearButton.layer.cornerRadius = 7
        clearButton.clipsToBounds = true
        clearButton.setTitle("Поиск в iTunes", for: .normal)
        clearButton.setTitleColor(UIColor.white, for: .normal)
        clearButton.backgroundColor = vkSingleton.shared.mainColor
        clearButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        clearButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clearButton.titleLabel?.minimumScaleFactor = 0.5
        clearButton.frame = CGRect(x: UIScreen.main.bounds.width/2+5, y: topY, width: UIScreen.main.bounds.width/2-45, height: 25)
        searchView.addSubview(clearButton)
        clearButton.addTarget(self, action: #selector(self.searchITunes(sender:)), for: .touchUpInside)
        topY += 25
        
        /*topY += 15
        
        let repeatSongCheck = BEMCheckBox()
        repeatSongCheck.onTintColor = vkSingleton.shared.mainColor
        repeatSongCheck.onCheckColor = vkSingleton.shared.mainColor
        repeatSongCheck.backgroundColor = .white
        repeatSongCheck.lineWidth = 2
        repeatSongCheck.on = self.repeatSong
        
        repeatSongCheck.frame = CGRect(x: 20, y: topY, width: 20, height: 20)
        searchView.addSubview(repeatSongCheck)
        
        let repeatSongLabel = UILabel()
        repeatSongLabel.textColor = .black
        repeatSongLabel.alpha = self.repeatSong ? 1.0 : 0.6
        repeatSongLabel.font = UIFont(name: "Verdana", size: 11)!
        repeatSongLabel.text = "Повторять песню"
        repeatSongLabel.adjustsFontSizeToFitWidth = true
        repeatSongLabel.minimumScaleFactor = 0.5
        repeatSongLabel.frame = CGRect(x: 50, y: topY, width: UIScreen.main.bounds.width/2 - 50, height: 20)
        searchView.addSubview(repeatSongLabel)
        
        
        let repeatAllCheck = BEMCheckBox()
        repeatAllCheck.onTintColor = vkSingleton.shared.mainColor
        repeatAllCheck.onCheckColor = vkSingleton.shared.mainColor
        repeatAllCheck.backgroundColor = .white
        repeatAllCheck.lineWidth = 2
        repeatAllCheck.on = self.repeatAll
        
        repeatAllCheck.frame = CGRect(x: UIScreen.main.bounds.width/2, y: topY, width: 20, height: 20)
        searchView.addSubview(repeatAllCheck)
        
        let repeatAllLabel = UILabel()
        repeatAllLabel.textColor = .black
        repeatAllLabel.alpha = self.repeatAll ? 1.0 : 0.6
        repeatAllLabel.font = UIFont(name: "Verdana", size: 11)!
        repeatAllLabel.text = "Повторять «Избранное»"
        repeatAllLabel.adjustsFontSizeToFitWidth = true
        repeatAllLabel.minimumScaleFactor = 0.5
        repeatAllLabel.frame = CGRect(x: UIScreen.main.bounds.width/2 + 30, y: topY, width: UIScreen.main.bounds.width/2 - 50, height: 20)
        searchView.addSubview(repeatAllLabel)
        
        repeatSongCheck.add(for: .valueChanged) {
            self.repeatSong = repeatSongCheck.on
            if self.repeatSong {
                repeatSongLabel.alpha = 1.0
                repeatAllLabel.alpha = 0.6
                repeatAllCheck.setOn(false, animated: true)
                self.repeatAll = false
            } else {
                repeatSongLabel.alpha = 0.6
            }
            UserDefaults.standard.set(self.repeatSong, forKey: "Music_Itunes_repeatSong")
            UserDefaults.standard.set(self.repeatAll, forKey: "Music_Itunes_repeatAll")
        }
        
        repeatAllCheck.add(for: .valueChanged) {
            self.repeatAll = repeatAllCheck.on
            if self.repeatAll {
                repeatAllLabel.alpha = 1.0
                repeatSongLabel.alpha = 0.6
                repeatSongCheck.setOn(false, animated: true)
                self.repeatSong = false
            } else {
                repeatAllLabel.alpha = 0.6
            }
            UserDefaults.standard.set(self.repeatSong, forKey: "Music_Itunes_repeatSong")
            UserDefaults.standard.set(self.repeatAll, forKey: "Music_Itunes_repeatAll")
        }
        
        topY += 20*/
        
        artistTextField.textColor = vkSingleton.shared.labelColor
        albumTextField.textColor = vkSingleton.shared.labelColor
        songTextField.textColor = vkSingleton.shared.labelColor
            
        artistTextField.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
        albumTextField.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
        songTextField.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
        
        searchView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topY + 10)
        tableView.tableHeaderView = searchView
    }
    
    @objc func searchITunes(sender: UIButton) {
        sender.buttonTouched(controller: self)
        
        artistTextField.resignFirstResponder()
        albumTextField.resignFirstResponder()
        songTextField.resignFirstResponder()
        
        let searchText = "\(songTextField.text!) \(artistTextField.text!) \(albumTextField.text!)"
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) != ""  {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            searchITunes(searchArtist: artistTextField.text!, searchAlbum: albumTextField.text!, searchSong: songTextField.text!) { music in
                self.search = music
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
        } else {
            showInfoMessage(title: "Поиск в iTunes", msg: "Введите хоть что-нибудь для начала поиска")
        }
    }
    
    @objc func clearSearch(sender:UIButton) {
        sender.buttonTouched(controller: self)
        
        artistTextField.text = ""
        albumTextField.text = ""
        songTextField.text = ""
        
        search.removeAll(keepingCapacity: false)
        tableView.reloadData()
    }
}
