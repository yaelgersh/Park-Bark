//
//  UserApp.swift
//  Park-Bark
//
//  Created by Yael on 17/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
class UserApp{
    
    private static var instance = UserApp()
    var name : String!
    var dogs : [Dog]!
    
    private init() {}
    
    static func getInstance() -> UserApp{
        return instance
    }
    
    func addDog(dog : Dog){
        dogs.append(dog)
    }
    
}
