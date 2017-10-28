//
//  Dog.swift
//  Park-Bark
//
//  Created by Yael on 22/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation

class Dog{
    static var counter : Int = 0
    let id : Int!
    var name : String!
    var isMale : Bool! // true = male   false = female
    var year : Int!
    var mounth : Int!
    var day : Int!
    var race : String!
    var size : Int! // 0 = small    1 = small/medium    2 = big/medium  3 = big
    
    init(name : String, isMale : Bool , year: Int , mounth : Int , day: Int , race : String, size : Int) {
        id = Dog.counter
        Dog.counter = Dog.counter + 1
        
        self.name = name
        self.isMale = isMale
        self.year = year
        self.mounth = mounth
        self.day = day
        self.race = race
        self.size = size
        
    }
    
    init(id : Int, name : String, isMale : Bool , year: Int , mounth : Int , day: Int , race : String, size : Int) {
        self.id = id
        Dog.counter = Dog.counter + 1
        
        self.name = name
        self.isMale = isMale
        self.year = year
        self.mounth = mounth
        self.day = day
        self.race = race
        self.size = size
        
    }
    
}
