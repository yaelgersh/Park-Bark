//
//  Garden.swift
//  Park-Bark
//
//  Created by Avi on 21/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
class Garden{
    var city : String
    var name : String
    var lat : Double
    var lng : Double
    
    init(city : String, name : String, lat : Double, lng : Double) {
        self.city = city
        self.name = name
        self.lat = lat
        self.lng = lng
    }

}
