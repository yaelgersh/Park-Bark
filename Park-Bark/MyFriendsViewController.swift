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
    var myFriends: [Dog] = []
    let sizes: [String] = ["קטן", "בינוני", "גדול", "גדול מאוד"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        cell.dogImage.layer.cornerRadius = cell.dogImage.frame.height/2
        cell.dogImage.clipsToBounds = true
        
        
        let dog: Dog = myFriends[indexPath.row]
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
        if(dog.isMale!){
            cell.genderCircle.image = #imageLiteral(resourceName: "bluecircle")
        }
        else{
            cell.genderCircle.image = #imageLiteral(resourceName: "pinkcircle")
        }
        cell.ownerId = myFriends[indexPath.row].ownerId
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title:"\(myFriends[indexPath.row].name!)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "חזרה", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        let cell = friendsTable.cellForRow(at: indexPath) as! InGardenTableViewCell
        alert.addImage(image: cell.dogImage.image!)
        alert.addAction(action)
        
        //let imageView = UIImageView()
        //imageView.image = cell.dogImage.image
        //self.view.addSubview(imageView)
        self.present(alert, animated: true, completion: nil)
    }


}
