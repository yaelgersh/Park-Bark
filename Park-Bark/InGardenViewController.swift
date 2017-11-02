//
//  InGardenViewController.swift
//  Park-Bark
//
//  Created by admin on 31/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class InGardenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateInGardenDelegate {
    
    func dbUpdated() {
        DispatchQueue.global(qos: .background).async {
            self.dogsInGardenList = FBDatabaseManagment.getInstance().getDogsInGardenList()
            
            DispatchQueue.main.async {
                self.dogsInGardenTable.reloadData()
            }
        }
    }

    var dogsInGardenList = FBDatabaseManagment.getInstance().getDogsInGardenList()
    
    @IBOutlet weak var dogsInGardenTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogsInGardenList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! InGardenTableViewCell
        
        cell.nameLabel.text = dogsInGardenList[indexPath.row].name
        cell.ageLabel.text = "\(dogsInGardenList[indexPath.row].day!)/\(dogsInGardenList[indexPath.row].mounth!)/\(dogsInGardenList[indexPath.row].year!)"
        cell.sizeLabel.text = dogsInGardenList[indexPath.row].race
        
        return cell
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
