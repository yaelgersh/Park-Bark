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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser == nil {
            self.moveToLogin()
        }
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if let user = user {
            UserApp.getInstance().name = user.displayName
            UserApp.getInstance().id = user.uid
            if FBDatabaseManagment.getInstance().firstRun{
                FBDatabaseManagment.getInstance().readAccount()
                FBDatabaseManagment.getInstance().firstRun = false
            }
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

    @IBAction func pawClicked(_ sender: Any) {
    }
}

