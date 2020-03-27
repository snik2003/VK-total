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

class MyMusicController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: UIViewController!
    
    var ownerID = ""
    var music: [IMusic] = []
    var search: [IMusic] = []
    var source = ""
    
    var tableView: UITableView!
    var artistTextField: UITextField!
    var albumTextField: UITextField!
    var songTextField: UITextField!
    
    var player = AVQueuePlayer()
    var isPlaying = false
    var playIndexPath: IndexPath!
    
    var navHeight: CGFloat = 64
    var tabHeight: CGFloat = 49
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        if UIScreen.main.nativeBounds.height == 2436 {
            self.navHeight = 88
            self.tabHeight = 83
        }
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            self.configureTableView()
            if self.source == "" {
                self.configureSearchView()
            }
        }
        
        getMusicFromRealm()
        
        OperationQueue.main.addOperation {
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
            ViewControllerUtils().hideActivityIndicator()
        }
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        if playIndexPath != nil {
            if let cell = tableView.cellForRow(at: playIndexPath) as? MyMusicCell {
                cell.listenButton.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func configureTableView() {
        tableView = UITableView()
        
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
            realm.add(music, update: true)
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
                return 20
            }
            return 0
        }
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        let titleLabel = UILabel()
        if section == 0 {
            if search.count > 0 {
                titleLabel.text = "Результаты поиска"
            }
        } else {
            titleLabel.text = "Избранное"
        }
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        titleLabel.textColor = UIColor.black
        titleLabel.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 20)
        viewHeader.addSubview(titleLabel)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
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
            if playIndexPath != nil {
                if let oldCell = tableView.cellForRow(at: playIndexPath) as? MyMusicCell {
                    oldCell.listenButton.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                }
                player.removeAllItems()
                isPlaying = false
            }
            
            var song: IMusic!
            if indexPath.section == 0 {
                song = search[indexPath.row]
            } else {
                song = music[indexPath.row]
            }
            
            self.openBrowserControllerNoCheck(url: song.URL)
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
                    oldCell.listenButton.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                }
                player.removeAllItems()
                isPlaying = false
            }
            
            if isPlaying {
                cell.listenButton.imageView?.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                
                player.removeAllItems()
                isPlaying = false
            } else {
                if let url = URL(string: song.reserv4) {
                    cell.listenButton.imageView?.tintColor = UIColor.red
                    
                    player.removeAllItems()
                    player.insert(AVPlayerItem(url: url), after: nil)
                    player.play()
                    
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
            let addAction = UITableViewRowAction(style: .normal, title: "Добавить") { (rowAction, indexPath) in
                if self.addSongToRealm(music: self.search[indexPath.row]) {
                    let title = self.search[indexPath.row].song
                    self.search.remove(at: indexPath.row)
                    self.getMusicFromRealm()
                    self.tableView.reloadData()
                    self.showSuccessMessage(title: "Моя музыка iTunes", msg: "Песня «\(title)» успешно добавлена в «Избранное».")
                }
            }
            addAction.backgroundColor = .green
        
            return [addAction]
        } else {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить") { (rowAction, indexPath) in
                let song = self.music[indexPath.row]
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleTop: 32.0,
                    kWindowWidth: UIScreen.main.bounds.width - 40,
                    kTitleFont: UIFont(name: "Verdana-Bold", size: 12)!,
                    kTextFont: UIFont(name: "Verdana", size: 13)!,
                    kButtonFont: UIFont(name: "Verdana", size: 14)!,
                    showCloseButton: false,
                    showCircularIcon: true
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
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
    }
    
    func configureSearchView() {
        let searchView = UIView()
        
        var topY: CGFloat = 10.0

        artistTextField = UITextField()
        artistTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        artistTextField.placeholder = "Исполнитель:"
        artistTextField.clearButtonMode = .whileEditing
        artistTextField.textColor = artistTextField.tintColor
        artistTextField.layer.borderColor = UIColor.black.cgColor
        artistTextField.layer.borderWidth = 1
        artistTextField.layer.cornerRadius = 5
        artistTextField.contentMode = .center
        artistTextField.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        artistTextField.font = UIFont(name: "Verdana", size: 12)!
        artistTextField.text = ""
        artistTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 22)
        searchView.addSubview(artistTextField)
        topY += 22
        
        topY += 10
        
        albumTextField = UITextField()
        albumTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        albumTextField.placeholder = "Название альбома:"
        albumTextField.clearButtonMode = .whileEditing
        albumTextField.textColor = albumTextField.tintColor
        albumTextField.layer.borderColor = UIColor.black.cgColor
        albumTextField.layer.borderWidth = 1
        albumTextField.layer.cornerRadius = 5
        albumTextField.contentMode = .center
        albumTextField.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        albumTextField.font = UIFont(name: "Verdana", size: 12)!
        albumTextField.text = ""
        albumTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 22)
        searchView.addSubview(albumTextField)
        topY += 22
        
        topY += 10
        
        songTextField = UITextField()
        songTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        songTextField.placeholder = "Название песни:"
        songTextField.clearButtonMode = .whileEditing
        songTextField.textColor = songTextField.tintColor
        songTextField.layer.borderColor = UIColor.black.cgColor
        songTextField.layer.borderWidth = 1
        songTextField.layer.cornerRadius = 5
        songTextField.contentMode = .center
        songTextField.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        songTextField.font = UIFont(name: "Verdana", size: 12)!
        songTextField.text = ""
        songTextField.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width - 80, height: 22)
        searchView.addSubview(songTextField)
        topY += 22
        
        topY += 15
        
        let searchButton = UIButton()
        searchButton.layer.borderColor = UIColor.black.cgColor
        searchButton.layer.borderWidth = 0.6
        searchButton.layer.cornerRadius = 7
        searchButton.clipsToBounds = true
        searchButton.setTitle("Очистить поиск", for: .normal)
        searchButton.setTitleColor(UIColor.white, for: .normal)
        searchButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        searchButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 11)!
        searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
        searchButton.titleLabel?.minimumScaleFactor = 0.5
        searchButton.frame = CGRect(x: 40, y: topY, width: UIScreen.main.bounds.width/2-45, height: 21)
        searchView.addSubview(searchButton)
        searchButton.addTarget(self, action: #selector(self.clearSearch(sender:)), for: .touchUpInside)
        
        let clearButton = UIButton()
        clearButton.layer.borderColor = UIColor.black.cgColor
        clearButton.layer.borderWidth = 0.6
        clearButton.layer.cornerRadius = 7
        clearButton.clipsToBounds = true
        clearButton.setTitle("Поиск в iTunes", for: .normal)
        clearButton.setTitleColor(UIColor.white, for: .normal)
        clearButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        clearButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        clearButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clearButton.titleLabel?.minimumScaleFactor = 0.5
        clearButton.frame = CGRect(x: UIScreen.main.bounds.width/2+5, y: topY, width: UIScreen.main.bounds.width/2-45, height: 21)
        searchView.addSubview(clearButton)
        clearButton.addTarget(self, action: #selector(self.searchITunes(sender:)), for: .touchUpInside)
        topY += 21
        
        //searchView.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
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
