//
//  ViewController.swift
//  Park-Bark
//
//  Created by Yael on 23/09/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var currentUser : UserApp!
    var userId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            self.moveToLogin()
        }
        
        //UINavigationBar.appearance().setBackgroundImage(UIImage(named:"header"), for: .default)
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "header"))
        //self.navigationItem.titleView?.contentMode = UIViewContentMode.scaleAspectFit
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            currentUser = UserApp(name: user.displayName!)
            userId = user.uid
            FBDatabaseManagment.getInstance().readAccount(id: userId, user: currentUser)
        }
    }

    @IBAction func signOutFromFB(_ sender: Any) {
        logout()
        moveToLogin()
    }
    
    func logout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func moveToLogin(){
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView") as! MyLoginViewController
        self.present(controller, animated: true, completion: nil)
        
    }

}

