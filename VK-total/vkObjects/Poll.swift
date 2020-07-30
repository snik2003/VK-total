//
//  Poll.swift
//  VK-total
//
//  Created by Сергей Никитин on 31.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Poll {
    var id = 0
    var ownerID = 0
    var created = 0
    var question = ""
    var votes = 0
    var answerIDs: [Int] = []
    var anonymous = 0
    var endDate = 0
    var closed = false
    var multiple = false
    var canVote = false
    var disableUnvote = false
    
    var answers: [PollAnswer] = []
    
    var photo = ""
    var color = ""
    var friendsIDs: [Int] = []
    
    init(json: JSON) {
        //print(json)
        
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.created = json["created"].intValue
        self.question = json["question"].stringValue
        self.votes = json["votes"].intValue
        self.answerIDs = json["answer_ids"].arrayValue.map({ $0.intValue })
        self.anonymous = json["anonymous"].intValue
        self.endDate = json["end_date"].intValue
        self.closed = json["closed"].boolValue
        self.multiple = json["multiple"].boolValue
        self.canVote = json["can_vote"].boolValue
        self.disableUnvote = json["disable_unvote"].boolValue
        
        self.answers = json["answers"].compactMap { PollAnswer(json: $0.1) }
        
        self.photo = json["photo"]["images"][0]["url"].stringValue
        self.color = json["photo"]["color"].stringValue
        
        self.friendsIDs = json["friends"].arrayValue.map({ $0["id"].intValue })
        //print("friends count = \(self.friendsIDs.count)")
    }
}

class PollAnswer {
    var id = 0
    var text = ""
    var votes = 0
    var rate: Double = 0.0
    var isSelect = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.text = json["text"].stringValue
        self.votes = json["votes"].intValue
        self.rate = json["rate"].doubleValue
    }
}
