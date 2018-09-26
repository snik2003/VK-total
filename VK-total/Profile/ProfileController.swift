//
//  ProfileController.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ProfileController: UITableViewController {

    var userProfile = [UserProfileInfo]()
    var photos = [Photos]()
    var wall = [Wall]()
    var wallProfiles = [WallProfiles]()
    var wallGroups = [WallGroups]()
    
    var filterRecords = "owner"
    
    var estimatedHeightCache: [IndexPath: CGFloat] = [:]
    
    var userID = vkSingleton.shared.userID
    //var userID: String = "176257230"
    
    @IBOutlet weak var barItem: UIBarButtonItem!
    var countersSection = [InfoInProfile]()
    var photoX: [Int : CGFloat] = [:]
    
    var offset = 0
    let count = 25
    var isRefresh = false
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: UIControl.Event.valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)
        
        OperationQueue.main.addOperation {
            if self.userID == vkSingleton.shared.userID {
                self.barItem.isEnabled = false
                self.barItem.tintColor = UIColor.clear
            } else {
                self.barItem.isEnabled = true
                self.barItem.tintColor = UIColor.white
            }
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view.superview!)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.tableView.reloadData()
    }
    
    @objc func pullToRefresh() {
        offset = 0
        
        /*userProfile.removeAll(keepingCapacity: false)
        photos.removeAll(keepingCapacity: false)
        wall.removeAll(keepingCapacity: false)
        wallGroups.removeAll(keepingCapacity: false)
        wallProfiles.removeAll(keepingCapacity: false)
        tableView.reloadData()*/
        
        refresh()
    }
    
    func refresh() {
        let opq = OperationQueue()
        isRefresh = true
        
        let url1 = "/method/users.get"
        let parameters1 = [
            "user_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id, first_name, last_name, maiden_name, domain, sex, relation, bdate, home_town, has_photo, city, country, status, last_seen, online, photo_max_orig, photo_max, photo_id, followers_count, counters, deactivated, education, contacts,  connections, site, about, interests, activities, books, games, movies, music, tv, quotes, first_name_abl, first_name_gen, first_name_acc, can_send_friend_request, can_write_private_message, friend_status, is_favorite, blacklisted, blacklisted_by_me",
            "name_case": "nom",
            "v": vkSingleton.shared.version
            ]
        
        let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
        opq.addOperation(getServerDataOperation1)
        
        let parseUserProfile = ParseUserProfile()
        parseUserProfile.addDependency(getServerDataOperation1)
        opq.addOperation(parseUserProfile)
        
        // получаем объект с фотографиями с сервера ВК
        let url2 = "/method/photos.getAll"
        let parameters2 = [
            "owner_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "extended": "1",
            "count": "100",
            "photo_sizes": "0",
            "skip_hidden": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        // парсим объект с фотографиями
        let parsePhotos = ParsePhotosList()
        parsePhotos.addDependency(getServerDataOperation2)
        opq.addOperation(parsePhotos)
        
        // получаем объект с записями на стене пользователя с сервера ВК
        let url3 = "/method/wall.get"
        let parameters3 = [
            "owner_id": userID,
            "domain": "id\(userID)",
            "offset": "\(offset)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "\(count)",
            "filter": filterRecords,
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        opq.addOperation(getServerDataOperation3)
        
        // парсим объект с записями на стене
        let parseUserWall = ParseUserWall()
        parseUserWall.addDependency(getServerDataOperation3)
        opq.addOperation(parseUserWall)
        
        // обновляем данные на UI
        let reloadTableController = ReloadProfileController(controller: self)
        reloadTableController.addDependency(parsePhotos)
        reloadTableController.addDependency(parseUserWall)
        reloadTableController.addDependency(parseUserProfile)
        reloadTableController.completionBlock = {
            self.saveAccountToRealm()
        }
        OperationQueue.main.addOperation(reloadTableController)

        self.refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6 + wall.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 0:
            if userProfile.count > 0 {
                return 1
            }
        case 1:
            if userProfile.count > 0 {
                if userID == vkSingleton.shared.userID {
                    return 0
                }
                return 1
            }
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            if userProfile.count > 0 {
                if userProfile[0].deactivated != "" {
                    return 0
                }
                return 1
            }
            return 0
        default:
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section > 5 {
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell
                
                let height = cell.getRowHeight(record: wall[indexPath.section - 6])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if userProfile.count > 0 {
                let height = self.view.frame.height * 0.4
                return height
            }
            return 0
        case 1:
            if userProfile.count > 0 {
                return 50
            }
            return 0
        case 2:
            if userProfile.count > 0 {
                return 65
            }
            return 0
        case 3:
            if userProfile.count > 0 {
                if userProfile[0].photosCount > 0 {
                    return 25
                }
            }
            return 0
        case 4:
            if photos.count > 0 {
                return 100
            }
            return 0
        case 5:
            if userProfile.count > 0 {
                return 40
            }
            return 0
        default:
            if let height = estimatedHeightCache[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell") as! WallRecordCell
                
                let height = cell.getRowHeight(record: wall[indexPath.section - 6])
                estimatedHeightCache[indexPath] = height
                return height
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 5 {
            if userProfile.count > 0 {
                if userProfile[0].deactivated == "" {
                    return 10
                }
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            if userProfile.count > 0 {
                if userProfile[0].deactivated == "" {
                    return 10
                }
            }
        }
        
        if section > 5 {
            return 15
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell

            cell.configureCell(profile: userProfile[0], indexPath: indexPath, tableView: tableView, cell: cell)
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonsCell", for: indexPath) as! StatusButtonsCell
  
            cell.configureCell(profile: userProfile[0])
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "countersCell", for: indexPath) as! CountersCell
            
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            cell.collectionViewFrame()
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photosCountCell", for: indexPath)
            
            if userProfile.count > 0 {
                cell.textLabel?.text = "\(userProfile[0].photosCount) фото"
            }
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath) as! PhotosCell
            
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordsCell", for: indexPath) as! OwnerButtonsCell
            
            cell.configureCell(profile: userProfile[0])
            
            return cell
        case 6...(5 + wall.count):
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallRecordCell", for: indexPath) as! WallRecordCell
            
            cell.configureCell(record: wall[indexPath.section - 6], profiles: wallProfiles, groups: wallGroups, indexPath: indexPath, tableView: tableView, cell: cell, viewController: self)
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
            
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == 5 + offset {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if userProfile.count > 0 {
                let user = userProfile[0]
                
                if user.avatarID != "" {
                    let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                    
                    
                    let photos = Photos(json: JSON.null)
                    photos.uid = "\(user.uid)"
                    let comps = user.avatarID.components(separatedBy: "_")
                    if comps.count > 1 {
                        photos.pid = comps[1]
                        
                        for index in 0...self.photos.count - 1 {
                            if photos.pid == self.photos[index].pid {
                                photos.xxbigPhotoURL = self.photos[index].xxbigPhotoURL
                                photos.xbigPhotoURL = self.photos[index].xbigPhotoURL
                                photos.bigPhotoURL = self.photos[index].bigPhotoURL
                                photos.photoURL = self.photos[index].photoURL
                                photos.width = self.photos[index].width
                                photos.height = self.photos[index].height
                                
                                photoViewController.numPhoto = index
                                photoViewController.photos = self.photos
                            }
                        }
                        
                        if photos.width == 0 {
                            photos.xxbigPhotoURL = user.maxPhotoOrigURL
                            photos.xbigPhotoURL = user.maxPhotoOrigURL
                            photos.bigPhotoURL = user.maxPhotoOrigURL
                            photos.photoURL = user.maxPhotoOrigURL
                            photos.width = Int(UIScreen.main.bounds.width)
                            photos.height = Int(UIScreen.main.bounds.width)
                            
                            photoViewController.numPhoto = 0
                            photoViewController.photos.append(photos)
                        }
                            
                        
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                    }
                }
            }
        }
        
        if indexPath.section > 5 {
            let record = wall[indexPath.section - 6]
            
            if let visibleIndexPath = tableView.indexPathsForVisibleRows {
                for index in visibleIndexPath {
                    if index == indexPath {
                        let cell = tableView.cellForRow(at: indexPath) as! WallRecordCell
                    
                        let action = cell.getActionOnClickPosition(touch: cell.position, record: record)
                        
                        if action == "show_record" {
                            
                            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                        }
                        
                        if action == "show_repost_record" {
                            
                            self.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
                        }
                        
                        if action == "show_owner" {
                            
                            self.openProfileController(id: record.fromID, name: "")
                        }
                        
                        if action == "show_repost_owner" {
                            
                            self.openProfileController(id: record.repostOwnerID, name: "")
                        }
                        
                        for index in 0...9 {
                            if action == "show_photo_\(index)" {
                                let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                                
                                var newIndex = 0
                                for ind in 0...9 {
                                    if record.mediaType[ind] == "photo" {
                                        let photos = Photos(json: JSON.null)
                                        photos.uid = "\(record.photoOwnerID[ind])"
                                        photos.pid = "\(record.photoID[ind])"
                                        photos.xxbigPhotoURL = record.photoURL[ind]
                                        photos.xbigPhotoURL = record.photoURL[ind]
                                        photos.bigPhotoURL = record.photoURL[ind]
                                        photos.photoURL = record.photoURL[ind]
                                        photos.width = record.photoWidth[ind]
                                        photos.height = record.photoHeight[ind]
                                        photoViewController.photos.append(photos)
                                        if ind == index {
                                            photoViewController.numPhoto = newIndex
                                        }
                                        newIndex += 1
                                    }
                                }
                                
                                self.navigationController?.pushViewController(photoViewController, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goUserInfo" {
            if let destVC = segue.destination as? UserInfoTableViewController {
                destVC.users = userProfile
            }
        }
        
        if segue.identifier == "showUserPhotos" {
            if let destVC = segue.destination as? CountersInfoTableViewController {
                destVC.userID = userID
                destVC.userProfile = userProfile
                destVC.typeData = "photosCount"
            }
        }
    }
    
    func getCountCountersSection() -> Int {
        
        var count = 0
        
        countersSection.removeAll(keepingCapacity: false)
        
        if userProfile.count > 0 {
            var infoCounters: InfoInProfile
            
            let user = userProfile[0]
            
            if user.deactivated == "" {
                count += 1
                infoCounters = InfoInProfile("друзей", getCounterToString(user.friendsCount),"friendsCount")
                countersSection.append(infoCounters)
            
            
                if user.commonFriendsCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("общих",getCounterToString(user.commonFriendsCount), "commonFriendsCount")
                    countersSection.append(infoCounters)
                }
            
                if user.followersCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("подписчиков", getCounterToString(user.followersCount), "followersCount")
                    countersSection.append(infoCounters)
                }
            
                if user.groupsCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("групп", getCounterToString(user.groupsCount - user.pagesCount), "groupsCount")
                    countersSection.append(infoCounters)
                }
            
                if user.pagesCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("страниц", getCounterToString(user.pagesCount), "pagesCount")
                    countersSection.append(infoCounters)
                }
            
                if user.photosCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("фото", getCounterToString(user.photosCount), "photosCount")
                    countersSection.append(infoCounters)
                }

                if user.videosCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("видео", getCounterToString(user.videosCount), "videosCount")
                    countersSection.append(infoCounters)
                }
            
                if user.audiosCount > 0 {
                    count += 1
                    infoCounters = InfoInProfile("аудио", getCounterToString(user.audiosCount), "audiosCount")
                    countersSection.append(infoCounters)
                }
            }
        }
        
        return count
    }
}


extension ProfileController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 2 {
            return getCountCountersSection()
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if collectionView.tag == 2 {
            return 65
        }
        
        if collectionView.tag == 4 {
            return 100
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView.tag == 2 {
            if countersSection[indexPath.section].comment != "videosCount" && countersSection[indexPath.section].comment != "audiosCount" && countersSection[indexPath.section].comment != "friendsCount" &&
                countersSection[indexPath.section].comment != "commonFriendsCount" && countersSection[indexPath.section].comment != "followersCount" {
                let friendsViewController = self.storyboard?.instantiateViewController(withIdentifier: "CounterInfoViewController") as! CountersInfoTableViewController
            
                friendsViewController.userID = userID
                friendsViewController.userProfile = userProfile
                friendsViewController.typeData = countersSection[indexPath.section].comment
            
                self.navigationController?.pushViewController(friendsViewController, animated: true)
            }
            
            if countersSection[indexPath.section].comment == "friendsCount" {
                
                var title = "Друзья"
                if userProfile.count > 0 {
                    title = "Друзья \(userProfile[0].firstNameGen)"
                }
                self.openUsersController(uid: userID, title: title, type: "friends")
            }
            
            if countersSection[indexPath.section].comment == "commonFriendsCount" {
                
                let title = "Общие друзья"
                self.openUsersController(uid: userID, title: title, type: "commonFriends")
            }
            
            if countersSection[indexPath.section].comment == "followersCount" {
                
                var title = "Подписчики"
                if userProfile.count > 0 {
                    title = "Подписчики \(userProfile[0].firstNameGen)"
                }
                self.openUsersController(uid: userID, title: title, type: "followers")
            }
        }
        
        if collectionView.tag == 4 {
            let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                
            photoViewController.numPhoto = indexPath.section
            photoViewController.photos = photos

            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 4 {
            
            let photo = photos[indexPath.section]
            let widthThisCell = CGFloat(photo.width) / CGFloat(photo.height) * collectionView.bounds.height
            return CGSize(width: widthThisCell, height: collectionView.bounds.height)
        }
        
        return CGSize(width: 65, height: 65)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "counterCell", for: indexPath) as! CounterCell
            
            cell.countLabel.text = countersSection[indexPath.section].value
            cell.nameLabel.text = countersSection[indexPath.section].image
            
            cell.countLabel.frame = CGRect(x: 0, y: 10, width: cell.bounds.width, height: 22)
            cell.nameLabel.frame = CGRect(x: 0, y: 34, width: cell.bounds.width, height: 21)
            
            cell.countLabel.isHidden = false
            cell.nameLabel.isHidden = false
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
            
            let photo = photos[indexPath.section]
            
            cell.configureCell(photo: photo, indexPath: indexPath, cell: cell, collectionView: collectionView)
            
            /*let width = CGFloat(photo.width) / CGFloat(photo.height) * collectionView.bounds.height
            
            
            if indexPath.section == 0 {
                cell.imageView.frame = CGRect(x: 0, y: cell.imageView.frame.origin.y, width: width, height: cell.imageView.frame.height)
                photoX[indexPath.section] = width + 5
            } else {
                cell.imageView.frame = CGRect(x: photoX[indexPath.section - 1]!, y: cell.imageView.frame.origin.y, width: width, height: cell.imageView.frame.height)
                photoX[indexPath.section] = photoX[indexPath.section - 1]! + width + 5
            }*/
            
            return cell
        }
    }
    
    func getCounterToString(_ num: Int) -> String {
        var str = "\(num)"
        
        if num >= 10000 {
            str = "10K"
        } else {
            if num > 1000 {
                let num1 = lround(Double(num) / 100)
                str = "\(Double(num1) / 10)K"
            }
        }
        
        return str
    }
    
    @IBAction func readMoreButtonTap1(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if wall[(indexPath?.section)! - 6].readMore1 == 1 {
            wall[(indexPath?.section)! - 6].readMore1 = 0
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func readMoreButtonTap2(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if wall[(indexPath?.section)! - 6].readMore2 == 1 {
            wall[(indexPath?.section)! - 6].readMore2 = 0
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    @IBAction func addFriendButton() {
        if userProfile.count > 0 {
            
            let user = userProfile[0]
            
            // не является другом
            if user.friendStatus == 0 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Отправить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.add"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.userProfile[0].friendStatus = 1
                            self.userProfile[0].followersCount += 1
                            OperationQueue.main.addOperation {
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 2)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // отправлена заявка/подписка пользователю
            if user.friendStatus == 1 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Отменить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.delete"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.userProfile[0].friendStatus = 0
                            self.userProfile[0].followersCount -= 1
                            OperationQueue.main.addOperation {
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 2)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // имеется входящая заявка/подписка от пользователя
            if user.friendStatus == 2 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Одобрить заявку в друзья"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.add"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.userProfile[0].friendStatus = 3
                            self.userProfile[0].friendsCount += 1
                            OperationQueue.main.addOperation {
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 2)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
            
            // является другом
            if user.friendStatus == 3 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let title = "Удалить из друзей"
                let OKAction = UIAlertAction(title: title, style: .destructive) { action in
                    
                    let friendQueue = OperationQueue()
                    
                    let url = "/method/friends.delete"
                    
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "user_id": "\(self.userID)",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        
                        let error = ErrorJson(json: JSON.null)
                        error.errorCode = json["error"]["error_code"].intValue
                        error.errorMsg = json["error"]["error_msg"].stringValue
                        
                        if error.errorCode == 0 {
                            self.userProfile[0].friendStatus = 2
                            self.userProfile[0].friendsCount -= 1
                            OperationQueue.main.addOperation {
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1), IndexPath(row: 0, section: 2)], with: .automatic)
                                self.tableView.endUpdates()
                            }
                        } else {
                            self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    friendQueue.addOperation(request)
                }
                alertController.addAction(OKAction)
                present(alertController, animated: true)
            }
        }
    }
    
    @IBAction func tapCommentsButton(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section, index > 5 {
            let record = wall[index - 6]
            
            self.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
        }
    }
    
    @IBAction func likePost(sender: UIButton) {
        let buttonPosition: CGPoint = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        if let index = indexPath?.section, index > 5 {
            let record = wall[index - 6]
            
            if record.userLikes == 0 {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.add"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "post",
                    "owner_id": "\(record.ownerID)",
                    "item_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.wall[index - 6].countLikes += 1
                        self.wall[index - 6].userLikes = 1
                        OperationQueue.main.addOperation {
                            let cell = self.tableView.cellForRow(at: indexPath!) as! WallRecordCell
                            cell.setLikesButton(record: self.wall[index - 6])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                
                likeQueue.addOperation(request)
            } else {
                let likeQueue = OperationQueue()
                
                let url = "/method/likes.delete"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": "post",
                    "owner_id": "\(record.ownerID)",
                    "item_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        self.wall[index - 6].countLikes -= 1
                        self.wall[index - 6].userLikes = 0
                        OperationQueue.main.addOperation {
                            let cell = self.tableView.cellForRow(at: indexPath!) as! WallRecordCell
                            cell.setLikesButton(record: self.wall[index - 6])
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                
                likeQueue.addOperation(request)

            }
        }
    }
    
    func saveAccountToRealm() {
        
        if self.userID == vkSingleton.shared.userID {
            if userProfile.count > 0 {
                let account = AccountVK()
                let user = userProfile[0]
                
                account.userID = Int(self.userID)!
                account.token = vkSingleton.shared.accessToken
                account.firstName = user.firstName
                account.lastName = user.lastName
                account.screenName = user.domain
                account.lastSeen = user.lastSeen
                account.avatarURL = user.maxPhotoOrigURL
                self.updateAccountInRealm(account: account)
            }
        }
    }
    
    @IBAction func barButtonTouch(sender: UIBarButtonItem) {
        if userProfile.count > 0 {
            let user = userProfile[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if user.isFavorite == 1 {
                let action1 = UIAlertAction(title: "Удалить \(user.firstNameAcc) из избранных", style: .default) { action in
                    
                    let url = "/method/fave.removeUser"
                    let parameters = [
                        "user_id": "\(self.userID)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            user.isFavorite = 0
                            
                            var act = "удален"
                            if user.sex == 1 {
                                act = "удалена"
                            }
                            self.showSuccessMessage(title: "Избранные пользователи", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) из Ваших закладок.\n")
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            } else {
                let action1 = UIAlertAction(title: "Добавить \(user.firstNameAcc) в избранные", style: .default) { action in
                    
                    let url = "/method/fave.addUser"
                    let parameters = [
                        "user_id": "\(self.userID)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                        ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            user.isFavorite = 1
                            
                            var act = "добавлен"
                            if user.sex == 1 {
                                act = "добавлена"
                            }
                            self.showSuccessMessage(title: "Избранные пользователи", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) в Ваши закладки.\n")
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            }
            
            if user.blacklistedByMe == 1 {
                let action1 = UIAlertAction(title: "Удалить из черного списка", style: .destructive) { action in
                    
                    let url = "/method/account.unbanUser"
                    let parameters = [
                        "user_id": "\(self.userID)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            user.blacklistedByMe = 0
                            
                            var act = "удален"
                            if user.sex == 1 {
                                act = "удалена"
                            }
                            self.showSuccessMessage(title: "Черный список", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) из черного списка.\n")
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            } else {
                let action1 = UIAlertAction(title: "Добавить в черный список", style: .destructive) { action in
                    
                    let url = "/method/account.banUser"
                    let parameters = [
                        "user_id": "\(self.userID)",
                        "access_token": vkSingleton.shared.accessToken,
                        "v": vkSingleton.shared.version
                    ]
                    
                    let request = GetServerDataOperation(url: url, parameters: parameters)
                    request.completionBlock = {
                        guard let data = request.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let result = json["response"].intValue
                        
                        if result == 1 {
                            user.blacklistedByMe = 1
                            
                            var act = "добавлен"
                            if user.sex == 1 {
                                act = "добавлена"
                            }
                            self.showSuccessMessage(title: "Черный список", msg: "\n\(user.firstName) \(user.lastName) успешно \(act) в черный список.\n")
                        } else {
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json["error"]["error_code"].intValue
                            error.errorMsg = json["error"]["error_msg"].stringValue
                            print("#\(error.errorCode): \(error.errorMsg)")
                        }
                    }
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            }
            
            present(alertController, animated: true)
        }
    }
}

extension Date {
    var age: Int {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        let curDay = components.day!
        let curMonth = components.month!
        let curYear = components.year!
        
        components = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let day = curDay - components.day!
        let month = curMonth - components.month!
        let year = curYear - components.year!
        
        if month < 0 {
            return year - 1
        } else if month == 0 {
            if day < 0 {
                return year - 1
            } else {
                return year
            }
        } else {
            return year
        }
    }
}
