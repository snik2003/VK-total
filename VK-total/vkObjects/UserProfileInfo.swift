//
//  UserProfileInfo.swift
//  VK-total
//
//  Created by Сергей Никитин on 18.01.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserProfileInfo {
    var uid: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var maidenName: String = "" // девичья фамилия
    var sex: Int = 0
    var domain: String = ""
    var relation: Int = 0
    var birthDate: String = ""
    var homeTown: String = ""
    var hasPhoto: Int = 0
    var countryId: String = ""
    var countryName: String = ""
    var cityId: String = ""
    var cityName: String = ""
    var status: String = ""
    var lastSeen: Int = 0
    var platform: Int = 0
    var onlineStatus: Int = 0
    var onlineMobile: Int = 0
    var maxPhotoURL: String = ""
    var maxPhotoOrigURL: String = ""
    var avatarID: String = ""
    var followersCount: Int = 0
    var friendsCount: Int = 0
    var commonFriendsCount: Int = 0
    var groupsCount: Int = 0
    var photosCount: Int = 0
    var videosCount: Int = 0
    var audiosCount: Int = 0
    var pagesCount: Int = 0
    var notesCount: Int = 0
    var deactivated: String = ""
    var universityName: String = ""
    var universityGraduation: Int = 0
    var facultyName: String = ""
    var mobilePhone: String = ""
    var site: String = ""
    var skype: String = ""
    var facebook: String = ""
    var twitter: String = ""
    var instagram: String = ""
    var about: String = "" //  О себе
    var interests: String = "" // Интересы
    var activities: String = "" // Деятельность
    var books: String = "" // Любимые книги
    var games: String = "" // Любимые игры
    var movies: String = "" // Любимые фильмы
    var music: String = "" // Любимая музыка
    var tv: String = "" // Любимые телешоу
    var quotes: String = "" // Любимые цитаты
    var firstNameAbl: String = "" // Имя в предложном падеже (О Ком?)
    var firstNameGen: String = "" // Имя в родительном падеже (Чей?)
    var firstNameDat: String = "" // Имя в дательном падеже (Кому?)
    var firstNameAcc: String = "" // Имя в винительном падеже (Кому?)
    var canSendFriendRequest: Int = 0
    var canWritePrivateMessage: Int = 0
    var canPost: Int = 0
    var friendStatus: Int = 0
    var isFavorite: Int = 0
    var blacklisted: Int = 0
    var blacklistedByMe: Int = 0
    var cropPhotoURL: String = ""
    var cropX1: Double = 0
    var cropY1: Double = 0
    var cropX2: Double = 0
    var cropY2: Double = 0
    var rectX1: Double = 0
    var rectY1: Double = 0
    var rectX2: Double = 0
    var rectY2: Double = 0
    var photoWidth: Int = 0
    var photoHeight: Int = 0
    var isHiddenFromFeed: Int = 0
    var wallDefault = ""
    var persPolitical = 0
    var persReligion = ""
    var persInspired = ""
    var persPeopleMain = 0
    var persLifeMain = 0
    var persSmoking = 0
    var persAlcohol = 0
    var relatives: [Relatives] = []
    
    init(json: JSON) {
        self.uid = json["id"].stringValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.maidenName = json["maiden_name"].stringValue
        self.sex = json["sex"].intValue
        self.relation = json["relation"].intValue
        self.domain = json["domain"].stringValue
        self.birthDate = json["bdate"].stringValue
        self.hasPhoto = json["has_photo"].intValue
        self.homeTown = json["home_town"].stringValue
        self.countryId = json["country"]["id"].stringValue
        self.countryName = json["country"]["title"].stringValue
        self.cityId = json["city"]["id"].stringValue
        self.cityName = json["city"]["title"].stringValue
        self.status = json["status"].stringValue
        self.lastSeen = json["last_seen"]["time"].intValue
        self.platform = json["last_seen"]["platform"].intValue
        self.onlineStatus = json["online"].intValue
        self.onlineMobile = json["online_mobile"].intValue
        self.maxPhotoURL = json["photo_max"].stringValue
        self.maxPhotoOrigURL = json["photo_max_orig"].stringValue
        self.avatarID = json["photo_id"].stringValue
        self.followersCount = json["counters"]["followers"].intValue
        self.friendsCount = json["counters"]["friends"].intValue
        self.commonFriendsCount = json["counters"]["mutual_friends"].intValue
        self.groupsCount = json["counters"]["groups"].intValue
        self.photosCount = json["counters"]["photos"].intValue
        self.videosCount = json["counters"]["videos"].intValue
        self.audiosCount = json["counters"]["audios"].intValue
        self.pagesCount = json["counters"]["pages"].intValue
        self.notesCount = json["counters"]["notes"].intValue
        self.deactivated = json["deactivated"].stringValue
        self.universityName = json["university_name"].stringValue
        self.universityGraduation = json["graduation"].intValue
        self.facultyName = json["faculty_name"].stringValue
        self.mobilePhone = json["mobile_phone"].stringValue
        self.site = json["site"].stringValue
        self.skype = json["skype"].stringValue
        self.facebook = json["facebook"].stringValue
        self.twitter = json["twitter"].stringValue
        self.instagram = json["instagram"].stringValue
        self.about = json["about"].stringValue
        self.interests = json["interests"].stringValue
        self.activities = json["activities"].stringValue
        self.books = json["books"].stringValue
        self.games = json["games"].stringValue
        self.movies = json["movies"].stringValue
        self.music = json["music"].stringValue
        self.tv = json["tv"].stringValue
        self.quotes = json["quotes"].stringValue
        self.firstNameAbl = json["first_name_abl"].stringValue
        self.firstNameGen = json["first_name_gen"].stringValue
        self.firstNameDat = json["first_name_dat"].stringValue
        self.firstNameAcc = json["first_name_acc"].stringValue
        self.canSendFriendRequest = json["can_send_friend_request"].intValue
        self.canWritePrivateMessage = json["can_write_private_message"].intValue
        self.canPost = json["can_post"].intValue
        self.friendStatus = json["friend_status"].intValue
        self.isFavorite = json["is_favorite"].intValue
        self.blacklisted = json["blacklisted"].intValue
        self.blacklistedByMe = json["blacklisted_by_me"].intValue
        self.cropX1 = json["crop_photo"]["crop"]["x"].doubleValue
        self.cropY1 = json["crop_photo"]["crop"]["y"].doubleValue
        self.cropX2 = json["crop_photo"]["crop"]["x2"].doubleValue
        self.cropY2 = json["crop_photo"]["crop"]["y2"].doubleValue
        self.rectX1 = json["crop_photo"]["rect"]["x"].doubleValue
        self.rectY1 = json["crop_photo"]["rect"]["y"].doubleValue
        self.rectX2 = json["crop_photo"]["rect"]["x2"].doubleValue
        self.rectY2 = json["crop_photo"]["rect"]["y2"].doubleValue
        self.photoWidth = json["crop_photo"]["photo"]["width"].intValue
        self.photoHeight = json["crop_photo"]["photo"]["height"].intValue
        self.isHiddenFromFeed = json["is_hidden_from_feed"].intValue
        self.wallDefault = json["wall_default"].stringValue
        
        self.cropPhotoURL = json["crop_photo"]["photo"]["photo_1280"].stringValue
        if self.cropPhotoURL == "" {
            self.cropPhotoURL = json["crop_photo"]["photo"]["photo_807"].stringValue
            if self.cropPhotoURL == "" {
                self.cropPhotoURL = json["crop_photo"]["photo"]["photo_604"].stringValue
                if self.cropPhotoURL == "" {
                    self.cropPhotoURL = json["crop_photo"]["photo"]["photo_130"].stringValue
                }
            }
        }
        self.persPolitical = json["personal"]["political"].intValue
        self.persReligion = json["personal"]["religion"].stringValue
        self.persInspired = json["personal"]["inspired_by"].stringValue
        self.persPeopleMain = json["personal"]["people_main"].intValue
        self.persLifeMain = json["personal"]["life_main"].intValue
        self.persSmoking = json["personal"]["smoking"].intValue
        self.persAlcohol = json["personal"]["alcohol"].intValue
        
        for index in 0...19 {
            var rel = Relatives()
            rel.id = json["relatives"][index]["id"].intValue
            rel.name = json["relatives"][index]["name"].stringValue
            rel.type = json["relatives"][index]["type"].stringValue
            if rel.id > 0 {
                self.relatives.append(rel)
            }
        }
    }
    
    var inLove: Bool {
        
        if vkSingleton.shared.userID == "34051891" && uid == "451439315" && friendStatus == 3 {
            return true
        }
        
        if vkSingleton.shared.userID == "451439315" && uid == "34051891" && friendStatus == 3 {
            return true
        }
        
        return false
    }
}

struct Relatives {
    var id = 0
    var name = ""
    var type = ""
}
