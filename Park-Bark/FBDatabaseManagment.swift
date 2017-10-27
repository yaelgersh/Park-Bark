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
    
    func readAccount(id : String){
        usersList.forEach {
            if ($0 == id) {
                _ = ref?.child(CHILD_USERS).child(id).observe(.childChanged, with:{ (snapshot) in
                    if let item = snapshot.value as? UserApp{
                        if(UserApp.getInstance().name == item.name){
                            UserApp.getInstance().name = item.name
                        }
                    }
                })
                return
            }
            
        }
        saveAccount(id: id)
    }
    
    func saveAccount(id : String){
        
        let post = ["name": UserApp.getInstance().name]
        ref.child(CHILD_USERS).child(id).setValue(post)
    }
    
    
}
