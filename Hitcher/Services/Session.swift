//
//  Session.swift
//  Hitcher
//
//  Created by Kelvin Fok on 15/2/18.
//  Copyright © 2018 Kelvin Fok. All rights reserved.
//

import Foundation

enum UserType {
    case DRIVER
    case PASSENGER
}

class Session {
    
    static let instance = Session()
 
    var userType: UserType?
    
    
    
    
}
