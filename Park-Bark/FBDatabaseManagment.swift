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

protocol UpdateInGardenDelegate: class {
    func dbUpdated()
}

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
    
    weak var updateInGardenDelegate: UpdateInGardenDelegate?
    
    var firstRun: Bool = true
    
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
    }
    
    static func getInstance() -> FBDatabaseManagment{
        return instance
    }
    
    func readAccount(){
        usersHandler = ref?.child(CHILD_USERS).child(UserApp.getInstance().id).observe(.value, with:{ (snapshot) in
            if let item = snapshot.value as? [String : AnyObject]{
                //                print("## user name = \(item["name"] as! String) ")
                //                print("## user dog = \(item["dogs"]) ")
                //var id = 0
                if let dogs = item["dogs"] as? [String: [String : AnyObject]]{
                    for (id, dog) in dogs{
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
                            UserApp.getInstance().dogs.append(Dog(id: id, name: name, isMale: isMale, year: year, mounth: mounth, day: day, race: race, size: size, urlImage: urlImage!))
                            //id = id + 1
                        }
                    }
                }
                
                if let garden = item["Garden"] as? [String : AnyObject]{
                    let city : String = garden["City"] as! String
                    let name : String = garden["Name"] as! String
                    let lat : Double = garden["lat"] as! Double
                    let lng : Double = garden["lng"] as! Double
                    
                    if((UserApp.getInstance().garden != nil && name != UserApp.getInstance().garden?.name) || UserApp.getInstance().garden == nil){
                        UserApp.getInstance().garden = Garden(city: city, name: name, lat: lat, lng: lng)
                        self.getDogsInGardenFromFB()
                    }
                }
                
                if let following = item["Following"] as? [String : String]{
                    for dogId in following.keys{
                        if(!UserApp.getInstance().following.contains(dogId)){
                            UserApp.getInstance().following.append(dogId)
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
    
    private func createDog(dog : Dog){
        let dogDic : [String : AnyObject] = ["name" : dog.name as AnyObject,
                                             "isMale" : dog.isMale as AnyObject,
                                             "year" : dog.year as AnyObject,
                                             "mounth" : dog.mounth as AnyObject,
                                             "day" : dog.day as AnyObject,
                                             "race" : dog.race as AnyObject,
                                             "size" : dog.size as AnyObject,
                                             "urlImage" : dog.urlImage as AnyObject]
        
        ref.child(CHILD_USERS).child(UserApp.getInstance().id).child(CHILD_DOGS).child(dog.id!).setValue(dogDic)
    }
    
    func updateDog(dog: Dog){
        //let dog = UserApp.getInstance().dogs[index]
        let dogDic : [String : AnyObject] = ["name" : dog.name as AnyObject,
                                             "isMale" : dog.isMale as AnyObject,
                                             "year" : dog.year as AnyObject,
                                             "mounth" : dog.mounth as AnyObject,
                                             "day" : dog.day as AnyObject,
                                             "race" : dog.race as AnyObject,
                                             "size" : dog.size as AnyObject,
                                             "urlImage" : dog.urlImage as AnyObject]
        
        ref.child(CHILD_USERS).child(UserApp.getInstance().id).child(CHILD_DOGS).updateChildValues([dog.id! : dogDic])
        
    }
    
    func removeDog(id : String){
        let dog = ref.child(CHILD_USERS).child(UserApp.getInstance().id).child(CHILD_DOGS).child(id)
        
        let imageRef = Storage.storage().reference().child(UserApp.getInstance().id).child("\(id).png")
        imageRef.delete { (error) in
            if error != nil {
                print(error!)
                return
            } else {
                dog.ref.removeValue()
            }
        }
        
        
    }
    
    func saveGarden(garden : Garden, id : String){
        ref.child(CHILD_USERS).child(id).child("Garden").setValue(["City" : garden.city,
                                                                   "Name" : garden.name,
                                                                   "lat" : garden.lat,
                                                                   "lng" : garden.lng])
    }
    
    func saveImageToStorage(image: UIImage, dog: Dog) {
        let imageName = NSUUID().uuidString
        dog.id = imageName
        
        let storageRef = Storage.storage().reference().child(UserApp.getInstance().id).child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(image){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                dog.urlImage = metadata?.downloadURL()?.absoluteString
                self.createDog(dog: dog)
            })
        }
    }
    
    func updateImageInStorage(image: UIImage, dog: Dog){
        let storageRef = Storage.storage().reference().child(UserApp.getInstance().id).child("\(dog.id!).png")
        if let uploadData = UIImagePNGRepresentation(image){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                dog.urlImage = metadata?.downloadURL()?.absoluteString
                self.updateDog(dog: dog)
            })
        }

    }
    
    func getDogsInGardenFromFB()
    {
        self.dogInGardenHandler = ref?.child(CHILD_GARDENS).child((UserApp.getInstance().garden?.city)!).child((UserApp.getInstance().garden?.name)!).child(CHILD_DOGS).observe(.value, with: { (snapshot) in
            self.dogInGardenList.removeAll()
            if let dataDict = snapshot.value as? [String: [String: String]]
            {
                for (userId, dogs) in dataDict {
                    
                    for dogId in dogs.keys{
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
                                
                                self.updateInGardenDelegate?.dbUpdated()
                            }
                        })
                        
                    }
                    
                }
            }
            else{
                self.updateInGardenDelegate?.dbUpdated()
            }
        })
    }
    
    func stopObserverForInGarden()
    {
        ref?.child(CHILD_GARDENS).child((UserApp.getInstance().garden?.city)!).child((UserApp.getInstance().garden?.name)!).child(CHILD_DOGS).removeAllObservers()
    }
    
    func addFollowing(id : String, name : String){
        let post : [String : String] = [id : name]
        ref.child(CHILD_USERS).child(UserApp.getInstance().id).child("Following").updateChildValues(post)
    }
    
    func removeFollowing(id : String){
        let follow = ref.child(CHILD_USERS).child(UserApp.getInstance().id).child("Following").child(id)
        follow.ref.removeValue()
        if let index = UserApp.getInstance().following.index(of: id) {
            UserApp.getInstance().following.remove(at: index)
        }
    }
}
