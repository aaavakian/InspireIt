//
//  Message.swift
//  InspireIt
//
//  Created by Armen Avakyan on 10.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import Foundation
import UIKit

class Message
{
    var id: Int?
    var fromId: Int?
    var content: String?
    var date: Date?
    
    var formattedDate: String? {
        guard let date = date else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM HH:mm"
        return dateFormatter.string(from: date)
    }
    
    var isCurrentUserMessage: Bool? {
        if let currentUserId = Int(UserDefaults.standard.userToken ?? "") {
            return fromId == currentUserId
        }
        return nil
    }
    
    init?(id: Int?, fromId: Int?, content: String?, date: String?) {
        if content != nil, date != nil {
            self.id = id
            self.fromId = fromId
            self.content = content
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.date = dateFormatter.date(from: date!)
        } else {
            return nil
        }
    }
    
    // For dialogs
    convenience init?(fromId: Int?, content: String?, date: String?) {
        self.init(id: nil, fromId: fromId, content: content, date: date)
    }
    
    // For new messages
    init?(fromId: Int?, content: String?, date: Date) {
        guard let fromId = fromId, let content = content else {
            return nil
        }
        
        self.fromId = fromId
        self.content = content
        self.date = date
    }
}
