//
//  Interest.swift
//  InspireIt
//
//  Created by Armen Avakyan on 09.06.17.
//  Copyright © 2017 Armen Avakyan. All rights reserved.
//

import UIKit

class Interest
{
    var id: Int
    var interest: String
    
    init?(id: Int?, interest: String?) {
        if id != nil, interest != nil {
            self.id = id!
            self.interest = interest!
        } else {
            return nil
        }
    }
}
