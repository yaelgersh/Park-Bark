//
//  ViewController.swift
//  Park-Bark
//
//  Created by Yael on 23/09/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet weak var pawImage: UIImageView!

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
            UNUserNotificationCenter.current().delegate = self
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
            UserApp.getInstance().logOut()
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
        let user = UserApp.getInstance()
        if user.dogs.count == 0{//no dog
            let alert = UIAlertController(title: "לא ניתן להתחבר לגינה", message: "על מנת להתחבר לגינה עליך להכניס את פרטי הכלב שלך", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "הוסף כלב", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profile") as! ProfileViewController
                self.navigationController?.pushViewController(controller, animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "לא עכשיו", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if user.garden == nil{//no gerden
            let alert = UIAlertController(title: "לא ניתן להתחבר לגינה", message:"על מנת להתחבר לגינה עליך להירשם תחילה לגינה", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "הירשם לגינה", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginGarden") as! GardenViewController
                self.navigationController?.pushViewController(controller, animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "לא עכשיו", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        //gerden check in
        if(pawImage.image?.isEqual((UIImage(named: "paw4"))))!{
            
            for i in 0 ..< UserApp.getInstance().dogs.count{
                FBDatabaseManagment.getInstance().signInGarden(dogIndex: i)
            }
            pawImage.image = UIImage(named: "paw3")
            
            //notification permission
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
            
            let answer1 = UNNotificationAction(identifier: "answer1", title: "this is a1", options: UNNotificationActionOptions.foreground)
            let answer2 = UNNotificationAction(identifier: "answer2", title: "this is a2", options: UNNotificationActionOptions.foreground)
            let category = UNNotificationCategory(identifier: "myCategory", actions: [answer1, answer2], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            //create the notification
            let content = UNMutableNotificationContent()
            content.title = "this is title"
            content.subtitle = "this is subtitle"
            content.body = "this is body"
            content.categoryIdentifier  = "myCategory"
            content.badge = 1
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        //garden check out
        else{
            for i in 0 ..< UserApp.getInstance().dogs.count{
                FBDatabaseManagment.getInstance().signOutGarden(dogIndex: i)
            }
            pawImage.image = UIImage(named: "paw4")
        }
    }
    
    @IBAction func gardeClicked(_ sender: Any) {
        if(UserApp.getInstance().garden == nil){
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginGarden") as! GardenViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HowIsInTheGarden") as! InGardenViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "answer1"{
            print("a1")
        }
        else{
            print("answer2")
        }
        
        completionHandler()
    }
}

