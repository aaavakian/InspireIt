//
//  User.swift
//  InspireIt
//
//  Created by Armen Avakyan on 08.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class User
{
    var id: Int
    var name: String
    var surname: String
    var login: String
    var profileImageURL: URL?
    var interests: [Interest]?
    
    var token: String {
        return String(id)
    }
    
    init?(id: Int?, name: String?, surname: String?, login: String?, profileImage: String?, interests: [Interest]?) {
        if id != nil, name != nil, surname != nil, login != nil, let url = profileImage {
            self.id = id!
            self.name = name!
            self.surname = surname!
            self.login = login!
            self.interests = interests
            profileImageURL = URL(string: ApiURL.index.rawValue + url)
        } else {
            return nil
        }
    }
}
