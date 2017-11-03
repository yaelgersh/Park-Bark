//
//  InGardenViewController.swift
//  Park-Bark
//
//  Created by admin on 31/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class InGardenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateInGardenDelegate {
    
    @IBOutlet weak var dogsInGardenTable: UITableView!
    var dogsInGardenList = FBDatabaseManagment.getInstance().getDogsInGardenList()
    let sizes: [String] = ["קטן", "בינוני", "גדול", "גדול מאוד"]
    
    func dbUpdated() {
        DispatchQueue.global(qos: .background).async {
            self.dogsInGardenList = FBDatabaseManagment.getInstance().getDogsInGardenList()
            
            DispatchQueue.main.async {
                self.dogsInGardenTable.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        FBDatabaseManagment.getInstance().updateInGardenDelegate = self
    
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = UserApp.getInstance().garden?.name
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
        
        cell.dogImage.layer.cornerRadius = cell.dogImage.frame.height/2
        cell.dogImage.clipsToBounds = true
        
        
        let dog: Dog = dogsInGardenList[indexPath.row]
        cell.dogId = dog.id
        cell.nameLabel.text = " שם: \(dog.name!)"
        
        if (dog.urlImage) != nil{
            let url = URL(string: dog.urlImage!)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    cell.dogImage.image = UIImage(data: data!)
                    
                }
            })
            task.resume()
        }
        
        var tempDate = DateComponents()
        tempDate.year = dog.year
        tempDate.month = dog.mounth
        tempDate.day = dog.day
        
        let now = Date()
        let calendar = Calendar.current
        let dogBirthday = calendar.date(from: tempDate)
        
        let yearComponents = calendar.dateComponents([.year], from: dogBirthday!, to: now)
        let monthComponents = calendar.dateComponents([.month], from: dogBirthday!, to: now)
        let months = Int((Double(Int(monthComponents.month!) % 12)/12)*10)
        let theAge = "\(yearComponents.year!).\(String(months))"
        
        cell.ageLabel.text = " גיל:  \(theAge)"
        let size: String = sizes[dog.size]
        
        cell.sizeLabel.text = " \(dog.race!), \(size)"
        if(UserApp.getInstance().following.contains(dog.id!)){
            cell.likeButton.setImage(UIImage(named: "heartfull"), for: .normal)
        }
        
        return cell
    }
    
    deinit {
        print("\(self) InGarden - dead")
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title:"\(dogsInGardenList[indexPath.row].name!)", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "חזרה", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        dogsInGardenTable.cellForRow(at: IndexPath.row).
        self.present(alert, animated: true, completion: nil)
    }*/
    
}
