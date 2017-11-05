//
//  MyFriendsViewController.swift
//  Park-Bark
//
//  Created by Yael on 03/11/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class MyFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var friendsTable: UITableView!
    var myFriends: [Dog] = FBDatabaseManagment.getInstance().getMyFriendsList()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //myFriends = FBDatabaseManagment.getInstance().getMyFriendsList()
        //friendsTable.reloadData()
        self.navigationItem.title = "חברים שלי"
        // Do any additional setup after loading the view.
    }

    deinit {
        print("\(self) My Freinds - dead")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! InGardenTableViewCell
        
        let dog: Dog = myFriends[indexPath.row]
        cell.initTheCell(dog: dog)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = friendsTable.cellForRow(at: indexPath) as! InGardenTableViewCell
        let alert = cell.cellWasClicked()
        
        self.present(alert, animated: true, completion: nil)
    }


}
