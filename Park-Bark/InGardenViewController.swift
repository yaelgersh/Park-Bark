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
        
        let dog: Dog = dogsInGardenList[indexPath.row]
        cell.initTheCell(dog: dog)
        
        return cell
    }
    
    deinit {
        print("\(self) InGarden - dead")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = dogsInGardenTable.cellForRow(at: indexPath) as! InGardenTableViewCell
        let alert = cell.cellWasClicked()
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func chengeGarden(_ sender: Any) {
        if ViewController.inGarden{
            let alert = UIAlertController(title: "לא ניתן להחליף גינה", message:" על מנת להחליף גינה עליך לצאת מהגינה הנוכחית בעמוד הראשי", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "חזרה לעמוד הבית", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
                _ = self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "ביטול", style: .default, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            return

        }
        else{
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginGarden") as! GardenViewController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
