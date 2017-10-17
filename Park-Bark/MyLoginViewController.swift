//
//  LoginViewController.swift
//  Park-Bark
//
//  Created by Yael on 14/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import Firebase

class MyLoginViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
                let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 15, y: view.frame.height - 100, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 15, y: view.frame.height - 166, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
       
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    



    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did logout")
   }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print("login error : \(error)")
            return
        }
        showAddress()
    }
    
    func showAddress(){
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil{
                print("something went wrong with our FB user - \(error)")
                return
            }
            print("Successfully loged in with our FB user: \(user)")
            
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email"]).start{(connection, result, err) in
            if err != nil{
                print("fail : \(err)")
                return
            }
            print("result: \(result)")
            
//            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! ViewController
//            self.present(loginVC, animated: true, completion: nil)

            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "navigationToMain") as! UINavigationController
            self.present(nextViewController, animated:true, completion:nil)
        }
    }

}
