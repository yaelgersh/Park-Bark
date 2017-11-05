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

class ViewController: UIViewController, UNUserNotificationCenterDelegate, AnyDogInGardenDelegate {
    @IBOutlet weak var pawImage: UIImageView!
    
    static var inGarden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FBDatabaseManagment.getInstance().anyDogInGardenDelegate = self
        
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
                FBDatabaseManagment.getInstance().anyDogInGardenDelegate = self
                FBDatabaseManagment.getInstance().firstRun = false
            }
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    func dbUpdated(_ bool: Bool) {
        DispatchQueue.main.async{
            if bool{
                self.pawImage.image = UIImage(named: "paw3")
                ViewController.inGarden = true
            }
            else{
                self.pawImage.image = UIImage(named: "paw4")
                ViewController.inGarden = false
            }
            FBDatabaseManagment.getInstance().anyDogInGardenDelegate = nil
        }
    }
    

    @IBAction func signOutFromFB(_ sender: Any) {
        logout()
        self.pawImage.image = UIImage(named: "paw4")
        //moveToLogin()
    }
    
    func logout(){
        
        let firebaseAuth = Auth.auth()
        do {
            FBDatabaseManagment.getInstance().logOutFb()
            try firebaseAuth.signOut()
            
            UserApp.getInstance().logOut()
            
            FBDatabaseManagment.getInstance().firstRun = true
            moveToLogin()
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
            ViewController.inGarden = true
            for i in 0 ..< UserApp.getInstance().dogs.count{
                FBDatabaseManagment.getInstance().signInGarden(dogIndex: i)
            }
            pawImage.image = UIImage(named: "paw3")
            addNotification(timeInterval : 10)
            
        }
        //garden check out
        else{
            ViewController.inGarden = false
            /*
            for i in 0 ..< UserApp.getInstance().dogs.count{
                FBDatabaseManagment.getInstance().signOutGarden(dogIndex: i)
            }
             */
            FBDatabaseManagment.getInstance().signOutGarden()
            pawImage.image = UIImage(named: "paw4")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    
    @IBAction func gardeClicked(_ sender: Any) {
        if(UserApp.getInstance().garden == nil){
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginGarden") as! GardenViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WhoIsInTheGarden") as! InGardenViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func addNotification(timeInterval : Int){
        //notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized){
                self.buildNotification(timeInterval: 10)
            }
            else{
                self.alertToEncourageNotificationPermission()
            }
        }
    }
    
    func buildNotification(timeInterval : Int){
        let answerYes = UNNotificationAction(identifier: "yes", title: "Yes", options: [])
        let answerNo = UNNotificationAction(identifier: "no", title: "No", options: [])
        let category = UNNotificationCategory(identifier: "myCategory", actions: [answerYes, answerNo], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        //create the notification
        let content = UNMutableNotificationContent()
        content.title = "עדיין בגינה?"
        //content.subtitle = "this is subtitle"
        //content.body = "this is body"
        content.categoryIdentifier  = "myCategory"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        
        let request = UNNotificationRequest(identifier: "timer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "yes"{
            print("yes")
            addNotification(timeInterval: 10)
        }
        else if response.actionIdentifier == "no"{
            print("no")
            FBDatabaseManagment.getInstance().signOutGarden()
            pawImage.image = UIImage(named: "paw4")
        }
        completionHandler()
    }
    
    func alertToEncourageNotificationPermission()
    {
        //Photo Library not available - Alert
        let notificationUnavailableAlertController = UIAlertController (title: "התראות לא זמינות", message: "על מנת לתזכר אותך לגבי עזיבת הגינה - אנחנו צריכים הרשאה מימך לשלוח התראות", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "הגדרות", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "ביטול", style: .default, handler: nil)
        notificationUnavailableAlertController .addAction(settingsAction)
        notificationUnavailableAlertController .addAction(cancelAction)
        self.present(notificationUnavailableAlertController , animated: true, completion: nil)
    }
}

