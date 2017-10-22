//
//  GardenViewController.swift
//  Park-Bark
//
//  Created by Avi on 21/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit
import Firebase

class GardenViewController: UIViewController {

    var ref: DatabaseReference!
    var refHandle: UInt!
    var gardensList	= [String : [Garden]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        refHandle = ref?.child("Gardens").observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String : Double]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]!
                    lng = location["lng"]!
                    
                    if(self.gardensList[cityName] != nil){                        self.gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                       self.gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
            print(self.gardensList)
        })

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildGardenList() -> [String : [Garden]]
    {
        var gardensList = [String : [Garden]]()
        ref = Database.database().reference()
        refHandle = ref?.child("Gardens").observe(.value, with: { (snapshot) in
            let dataDict = snapshot.value as! [String: [String: [String : Double]]]
            
            for (city, gardens) in dataDict {
                let cityName : String = city
                var gardenName : String
                var lat : Double
                var lng : Double
                for (garden, location) in gardens {
                    gardenName = garden
                    lat = location["lat"]!
                    lng = location["lng"]!
                    
                    if(gardensList[cityName] != nil){
                        gardensList[cityName]?.append(Garden(city: cityName, name: gardenName, lat: lat, lng: lng))
                    }
                    else{
                        gardensList[cityName] = [Garden(city: cityName, name: gardenName, lat: lat, lng: lng)]
                    }
                }
            }
            
        })
        
        return gardensList
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
