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
    var id : String!
    var name : String!
    var dogs : [Dog] = []
    var garden : Garden?
    
    private init() {}
    
    static func getInstance() -> UserApp{
        return instance
    }
    
    func addDog(name: String, isMale: Bool, year: Int , mounth : Int , day: Int, race: String, size: Int) -> Bool{
        for i in 0 ..< dogs.count {
            if dogs[i].name == name{
                return false
            }
        }
        let dog = Dog(name: name, isMale: isMale, year: year , mounth : mounth , day: day, race: race, size: size)
        FBDatabaseManagment.getInstance().createDog(dog: dog)
        //dogs.append(dog)
        return true
    }
}
