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
    private let CHILD_USERS : String = "Users"
    private var usersList : [String] = []
    
    private init() {
        ref = Database.database().reference()
        usersHandler = ref?.child(CHILD_USERS).observe(.childAdded, with: { (snapshot) in
            //let item : String = snapshot.key {
              //  self.usersList.append(item)
            //}
            self.usersList.append(snapshot.key)
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
    
    func saveAccount(id : String, user : UserApp){
        
        let post = ["name": user.name]
        ref.child(CHILD_USERS).child(id).setValue(post)
    }
    
    
}
