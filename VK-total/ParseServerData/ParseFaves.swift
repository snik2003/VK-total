//
//  ParseFaves.swift
//  VK-total
//
//  Created by Сергей Никитин on 28.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseFaves: Operation {
    
    var wall: [Wall] = []
    var profiles: [WallProfiles] = []
    var groups: [WallGroups] = []
    
    var profiles2: [NewsProfiles] = []
    var groups2: [NewsGroups] = []
    
    var photos: [Photos] = []
    var videos: [Videos] = []
    var users: [NewsProfiles] = []
    var links: [FaveLinks] = []
    var pages: [FavePages] = []
    
    var conversations: [Conversation] = []
    var dialogs: [Message] = []
    var dialogsUsers: [DialogsUsers] = []
    
    var nextFrom: String = ""
    
    private var source: String
    
    override func main() {
        guard let getServerDataOperation = dependencies.first as? GetServerDataOperation, let data = getServerDataOperation.data else { return }
        
        if source == "post" {
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let newsData = json["response"]["items"].compactMap { Wall(json: $0.1) }
            let profilesData = json["response"]["profiles"].compactMap { WallProfiles(json: $0.1) }
            let groupsData = json["response"]["groups"].compactMap { WallGroups(json: $0.1) }
            let newFrom = json["response"]["next_from"].stringValue
            
            nextFrom = newFrom
            wall = newsData
            profiles = profilesData
            groups = groupsData
            
        } else if source == "important dialogs" {
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            conversations = json["response"][0]["items"].compactMap({ Conversation(json: $0.1) })
            dialogs = json["response"][1]["items"].compactMap { Message(json: $0.1, conversations: conversations) }
            
            dialogsUsers = json["response"][1]["profiles"].compactMap { DialogsUsers(json: $0.1) }
            let groups = json["response"][1]["groups"].compactMap { GroupProfile(json: $0.1) }
            for group in groups {
                let newGroup = DialogsUsers(json: JSON.null)
                newGroup.uid = "-\(group.gid)"
                newGroup.firstName = group.name
                newGroup.photo100 = group.photo100
                dialogsUsers.append(newGroup)
            }
            
        } else if source == "photo" {
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let photoData = json["response"]["items"].compactMap { Photos(json: $0.1) }
            
            photos = photoData
        } else if source == "video" {
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let videoData = json["response"]["items"].compactMap { Videos(json: $0.1) }
            let profilesData = json["response"]["profiles"].compactMap { NewsProfiles(json: $0.1) }
            let groupsData = json["response"]["groups"].compactMap { NewsGroups(json: $0.1) }
            
            videos = videoData
            profiles2 = profilesData
            groups2 = groupsData
        } else if source == "groups" {
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let pagesData = json["response"]["items"].compactMap { FavePages(json: $0.1) }
            
            pages = pagesData
        } else if source == "links" {
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let linksData = json["response"]["items"].compactMap { FaveLinks(json: $0.1) }
            
            links = linksData
        } else if source == "users" {
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let usersData = json["response"]["items"].compactMap { NewsProfiles(json: $0.1) }
            
            users = usersData
        } else if source == "banned" {
            guard let json = try? JSON(data: data) else { print("json error"); return }
                   
            var usersData = json["response"]["profiles"].compactMap { NewsProfiles(json: $0.1) }
            
            let groupsData = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            for group in groupsData {
                let user = NewsProfiles(json: JSON.null)
                user.uid = -1 * group.gid
                user.photoURL = group.photo200
                user.firstName = group.name
                usersData.append(user)
            }
            
            users = usersData
        }
    }
    
    init(type: String) {
        self.source = type
    }
}
