//
//  FBDatabaseManagment.swift
//  Park-Bark
//
//  Created by Yael on 17/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FBDatabaseManagment{private static let instance : FBDatabaseManagment = FBDatabaseManagment()
    private let ref : DatabaseReference!
    private var usersHandler : DatabaseHandle!
    private var gardenHandler: DatabaseHandle!
    private var dogsHandler : DatabaseHandle!
    private var dogInGardenHandler : DatabaseHandle!
    private let CHILD_USERS : String = "Users"
    private let CHILD_GARDENS : String = "Gardens"
    private let CHILD_DOGS : String = "dogs"

    private var usersList : [String] = []
    private var gardensList = [String : [Garden]]()
    private var dogInGardenList = [Dog]()
    
    private init() {
        ref = Database.database().reference()
        usersHandler = ref?.child(CHILD_USERS).observe(.childAdded, with: { (snapshot) in
            self.usersList.append(snapshot.key)
        })
        
        gardenHandler = ref?.child(CHILD_GARDENS).observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String: AnyObject]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]! as! Double
                    lng = location["lng"]! as! Double
                    
                    if(self.gardensList[cityName] != nil){
                        self.gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                        self.gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
        })
        
        dogInGardenHandler = ref?.child(CHILD_GARDENS).child("כפר סבא").child("גן יקשטט").child(CHILD_DOGS).observe(.value, with: { (snapshot) in
            if let dataDict = snapshot.value as? [String: [String: Int]]{
            
                for (userId, dogs) in dataDict {
                    
                    for (_,dogId) in dogs{
                        _ = self.ref?.child(self.CHILD_USERS).child(userId).child(self.CHILD_DOGS).child(String(dogId)).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let dog = snapshot.value as? [String: AnyObject]{
                                let name : String = dog["name"] as! String
                                let isMale : Bool = dog["isMale"] as! Bool
                                let year : Int = dog["year"] as! Int
                                let mounth : Int = dog["mounth"] as! Int
                                let day : Int = dog["day"] as! Int
                                let race : String = dog["race"] as! String
                                let size : Int = dog["size"] as! Int
                                if let urlImage : String = dog["urlImage"] as? String{
                                    self.dogInGardenList.append(Dog(id: dogId, name: name, isMale: isMale, year: year, mounth: mounth, day: day, race: race, size: size, urlImage: urlImage))
                                }
                                else{
                                    self.dogInGardenList.append(Dog(id: dogId, name: name, isMale: isMale, year: year, mounth: mounth, day: day, race: race, size: size, urlImage: nil))
                                }
                                
                                
                                Dog.counter = Dog.counter - 1
                            }
                        })
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
//                        print("^^^^^^^^")
                        let name : String = dog["name"] as! String
                        let isMale : Bool = dog["isMale"] as! Bool
                        let year : Int = dog["year"] as! Int
                        let mounth : Int = dog["mounth"] as! Int
                        let day : Int = dog["day"] as! Int
                        let race : String = dog["race"] as! String
                        let size : Int = dog["size"] as! Int
                        let urlImage : String? = dog["urlImage"] as? String
                        if (!UserApp.getInstance().dogExists(name: name)){
                            UserApp.getInstance().dogs.append(Dog(id: Int(id), name: name, isMale: isMale, year: year, mounth: mounth, day: day, race: race, size: size, urlImage: urlImage!))
                            id = id + 1
                        }
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
    
    func getDogsInGardenList() -> [Dog]{
        return dogInGardenList
    }
    
    
    func saveAccount(id : String){
        let post : [String : String] = ["name": UserApp.getInstance().name]
        ref.child(CHILD_USERS).child(id).setValue(post)
    }
    
    func createDog(dog : Dog){
        let dogDic : [String : AnyObject] = ["name" : dog.name as AnyObject,
                                             "isMale" : dog.isMale as AnyObject,
                                             "year" : dog.year as AnyObject,
                                             "mounth" : dog.mounth as AnyObject,
                                             "day" : dog.day as AnyObject,
                                             "race" : dog.race as AnyObject,
                                             "size" : dog.size as AnyObject,
                                             "urlImage" : dog.urlImage as AnyObject]
        //let post : [String : AnyObject] = ["\(dog.id!)": dogDic]
        ref.child(CHILD_USERS).child(UserApp.getInstance().id).child(CHILD_DOGS).child(String(dog.id)).setValue(dogDic)
    }
    func saveGarden(garden : Garden, id : String){
        ref.child(CHILD_USERS).child(id).child("Garden").setValue(["City" : garden.city,
                                                                   "Name" : garden.name,
                                                                   "lat" : garden.lat,
                                                                   "lng" : garden.lng])
    }
    
    func saveImageToStorage(image: UIImage, dog: Dog) {
        let storageRef = Storage.storage().reference().child(UserApp.getInstance().id + String(dog.id) + ".png")
        if let uploadData = UIImagePNGRepresentation(image){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return //nil
                }
                dog.urlImage = metadata?.downloadURL()?.absoluteString
                self.createDog(dog: dog)
            })
        }
    }
    
    func getImageFromStorage(id : Int){
//        let url = URL(fileURLWithPath: UserApp.getInstance().dogs[id].urlImage)
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if error != nil{
//                print(error!)
//                return
//            }
//        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
