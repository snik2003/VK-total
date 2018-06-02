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
    var answerID = 0
    var anonymous = 0
    var answers: [PollAnswer] = []
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.created = json["created"].intValue
        self.question = json["question"].stringValue
        self.votes = json["votes"].intValue
        self.answerID = json["answer_id"].intValue
        self.anonymous = json["anonymous"].intValue
        
        self.answers = json["answers"].compactMap { PollAnswer(json: $0.1) }
    }
}

class PollAnswer {
    var id = 0
    var text = ""
    var votes = 0
    var rate = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.text = json["text"].stringValue
        self.votes = json["votes"].intValue
        self.rate = json["rate"].intValue
    }
}
