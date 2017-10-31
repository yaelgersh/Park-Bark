//
//  FBDatabaseManagment.swift
//  Park-Bark
//
//  Created by Yael on 17/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FBDatabaseManagment{private static let instance : FBDatabaseManagment = FBDatabaseManagment()
    private let ref : DatabaseReference!
    private var usersHandler : DatabaseHandle!
    private var gardenHandler: DatabaseHandle!
    private var dogsHandler : DatabaseHandle!
    private let CHILD_USERS : String = "Users"
    private let CHILD_GARDENS : String = "Gardens"
    private let CHILD_DOGS : String = "dogs"

    private var usersList : [String] = []
    private var gardensList = [String : [Garden]]()
    
    private init() {
        ref = Database.database().reference()
        usersHandler = ref?.child(CHILD_USERS).observe(.childAdded, with: { (snapshot) in
            self.usersList.append(snapshot.key)
        })
        
        /*
         gardenHandler = ref?.child("Gardens").observe(.childAdded, with: { (snapshot) in
         let dataDict = snapshot.value as! [String: [String: Double]]
         let cityName : String = snapshot.key
         
         for (garden, location) in dataDict {
         var gardenName : String = garden
         var lat : Double = location["lat"]!
         var lng : Double = location["lng"]!
         
         if(self.gardensList[cityName] != nil){
         self.gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
         }
         else{
         self.gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
         }
         }
         })
         */
        
        gardenHandler = ref?.child(CHILD_GARDENS).observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String: Double]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]!
                    lng = location["lng"]!
                    
                    if(self.gardensList[cityName] != nil){
                        self.gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                        self.gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
        })
        
    }
    static func getInstance() -> FBDatabaseManagment{
        return instance
    }
    
    func readAccount(){
        usersHandler = ref?.child(CHILD_USERS).child(UserApp.getInstance().id).observe(.value, with:{ (snapshot) in
            if let item = snapshot.value as? [String : AnyObject]{
//                print("## user name = \(item["name"] as! String) ")
//                print("## user dog = \(item["dogs"]) ")
                var id = 0
                if let dogs = item["dogs"] as? [[String : AnyObject]]{
                    for dog in dogs{
                        print("^^^^^^^^")
                        let name : String = dog["name"] as! String
                        let isMale : Bool = dog["isMale"] as! Bool
                        let year : Int = dog["year"] as! Int
                        let mounth : Int = dog["mounth"] as! Int
                        let day : Int = dog["day"] as! Int
                        let race : String = dog["race"] as! String
                        let size : Int = dog["size"] as! Int
                        
                        UserApp.getInstance().dogs.append(Dog(id: Int(id), name: name, isMale: isMale, year: year, mounth: mounth, day: day, race: race, size: size))
                        id = id + 1
                        
                        
                    }
                }
                
            }
            else{
                self.saveAccount(id: UserApp.getInstance().id)
            }
        })

    }
    
    func getGardensList() -> [String : [Garden]]
    {
        return gardensList
    }
    
    
    func saveAccount(id : String){
        let post : [String : String] = ["name": UserApp.getInstance().name]
        ref.child(CHILD_USERS).child(id).setValue(post)
    }
    
    func saveGarden(garden : Garden, id : String){
        ref.child(CHILD_USERS).child(id).child("Garden").setValue(["City" : garden.city,
                                                                   "Name" : garden.name,
                                                                   "lat" : garden.lat,
                                                                   "lng" : garden.lng])
    }
}
