//
//  LoginViewController.swift
//  Park-Bark
//
//  Created by Yael on 14/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import GoogleSignIn
//import FBSDKLoginKit

class LoginViewController: UIViewController{//, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 15, y: view.frame.height - 100, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
//
//        let loginButton = FBSDKLoginButton()
//        
//        view.addSubview(loginButton)
//        loginButton.frame = CGRect(x: 15, y: view.frame.height - 100, width: view.frame.width - 32, height: 50)
//        
//        loginButton.delegate = self
//    }
//
//
//    
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        print("did logout")
//    }
//
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        if error != nil{
//            print("login error : \(error)")
//            return
//        }
//        print("login successfully")
//    }

}
