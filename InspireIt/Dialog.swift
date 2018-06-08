//
//  Dialog.swift
//  InspireIt
//
//  Created by Armen Avakyan on 10.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class Dialog
{
    var id: Int?
    var firstUser: User?
    var secondUser: User?
    var interest: Interest?
    var lastMessage: Message?
    
    var chatPartner: User? {
        if let currentUserId = Int(UserDefaults.standard.userToken ?? "") {
            return firstUser?.id == currentUserId ? secondUser : firstUser
        }
        return nil
    }
    
    var chatPartnerImage: UIImage?
}
