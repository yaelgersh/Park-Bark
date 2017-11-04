//
//  Dog.swift
//  Park-Bark
//
//  Created by Yael on 22/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
import UIKit

class Dog{
    //static var counter : Int = 0
    var id : String?
    var name : String!
    var isMale : Bool! // true = male   false = female
    var year : Int!
    var mounth : Int!
    var day : Int!
    var race : String!
    var size : Int! // 0 = small    1 = small/medium    2 = big/medium  3 = big
    var urlImage : String?
    var ownerId : String?
    var inTheGarden : Bool = false
    
    init(name: String, isMale: Bool , year: Int , mounth: Int , day: Int , race: String, size: Int) {
        //id = Dog.counter
        //Dog.counter = Dog.counter + 1
        self.id = nil
        self.name = name
        self.isMale = isMale
        self.year = year
        self.mounth = mounth
        self.day = day
        self.race = race
        self.size = size
        
    }
    
    init(id: String, name: String, isMale: Bool , year: Int , mounth: Int , day: Int , race: String, size: Int, urlImage: String?) {
        self.id = id
        //Dog.counter = Dog.counter + 1
        
        self.name = name
        self.isMale = isMale
        self.year = year
        self.mounth = mounth
        self.day = day
        self.race = race
        self.size = size
        self.urlImage = urlImage
        
    }
    
    func setOwnerId(ownerId : String){
        self.ownerId = ownerId
    }
}
