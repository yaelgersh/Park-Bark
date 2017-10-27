//
//  FBDatabaseManagment.swift
//  Park-Bark
//
//  Created by Yael on 17/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FBDatabaseManagment{
    private static let instance : FBDatabaseManagment = FBDatabaseManagment()
    private let ref : DatabaseReference!
    private var usersHandler : DatabaseHandle!
    private var gardenHandler: DatabaseHandle!
    private let CHILD_USERS : String = "Users"
    private var usersList : [String] = []
    private var gardensList = [String : [Garden]]()
    
    private init() {
        ref = Database.database().reference()
        usersHandler = ref?.child(CHILD_USERS).observe(.childAdded, with: { (snapshot) in
            //let item : String = snapshot.key {
              //  self.usersList.append(item)
            //}
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
        
        gardenHandler = ref?.child("Gardens").observe(.value, with: { (snapshot) in
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
    
    func readAccount(id : String, user : UserApp){
        usersList.forEach {
            if ($0 == id) {
                _ = ref?.child(CHILD_USERS).child(id).observe(.childChanged, with:{ (snapshot) in
                    if let item = snapshot.value as? UserApp{
                        if(user.name == item.name){
                            user.name = item.name
                        }
                    }
                })
                return
            }
            
        }
        saveAccount(id: id, user: user)
    }
    
    func getGardensList() -> [String : [Garden]]
    {
        return gardensList
    }
    
    
    func saveAccount(id : String, user : UserApp){
        
        let post = ["name": user.name]
        ref.child(CHILD_USERS).child(id).setValue(post)
    }
    
    
}
