//
//  UserApp.swift
//  Park-Bark
//
//  Created by Yael on 17/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import Foundation
import UIKit

class UserApp{
    
    private static var instance = UserApp()
    var id : String!
    var name : String!
    var dogs : [Dog] = []
    var garden : Garden?
    var following: [String] = []
    
    private init() {}
    
    static func getInstance() -> UserApp{
        return instance
    }
    
    func addDog(name: String, isMale: Bool, year: Int , month : Int , day: Int, race: String, size: Int, dogPic: UIImage) -> Bool{
        if !dogExists(name: name){
            let dog = Dog(name: name, isMale: isMale, year: year , month : month , day: day, race: race, size: size)
            FBDatabaseManagment.getInstance().saveImageToStorage(image: dogPic, dog: dog)
            
            return true
        }
        
        return false
    }
    
    func updateDog(index : Int, image: UIImage){
        FBDatabaseManagment.getInstance().updateImageInStorage(image: image, dog: dogs[index])
        //FBDatabaseManagment.getInstance().updateDog(index: index)
    }
    
    func removeDog(dog: Dog, index: Int){
        dogs.remove(at: index)
        FBDatabaseManagment.getInstance().removeDog(id: dog.id!)
    }
    
    func dogExists(name : String) -> Bool{
        for i in 0 ..< dogs.count {
            if dogs[i].name == name{
                return true
            }
        }
        return false
    }
    func findDogById(id: String) -> Dog?{
        for dog in dogs{
            if dog.id == id{
                return dog
            }
        }
        return nil
    }
    
    func logOut(){
        id = ""
        name = ""
        dogs = []
        garden = nil
        following = []
    }
}
