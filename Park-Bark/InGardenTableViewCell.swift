//
//  InGardenTableViewCell.swift
//  Park-Bark
//
//  Created by admin on 31/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class InGardenTableViewCell: UITableViewCell {

    @IBOutlet weak var genderCircle: UIImageView!
    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var dogId : String!
    var ownerId : String!
    
    let sizes: [String] = ["קטן", "בינוני", "גדול", "גדול מאוד"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func likeClicked(_ sender: Any) {
        if(likeButton.currentImage?.isEqual((UIImage(named: "heartempty"))))!{
            likeButton.setImage(UIImage(named: "heartfull"), for: .normal)
            FBDatabaseManagment.getInstance().addFollowing(id: dogId, ownerId : ownerId)
            FBDatabaseManagment.getInstance().addFollowedBy(dogId: dogId, ownerId : ownerId, userId : UserApp.getInstance().id)
        }
        
        else{
            likeButton.setImage(UIImage(named: "heartempty"), for: .normal)
            FBDatabaseManagment.getInstance().removeFollowing(id: dogId)
            FBDatabaseManagment.getInstance().removeFollowedBy(dogId: dogId, ownerId : ownerId, userId : UserApp.getInstance().id)
        }
    }
    
    func initTheCell(dog: Dog){
        
        dogImage.layer.cornerRadius = dogImage.frame.height/2
        dogImage.clipsToBounds = true
        
        dogId = dog.id
        nameLabel.text = " שם: \(dog.name!)"
        
        if (dog.urlImage) != nil{
            let url = URL(string: dog.urlImage!)
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.dogImage.image = UIImage(data: data!)
                    
                }
            })
            task.resume()
        }
        
        var tempDate = DateComponents()
        tempDate.year = dog.year
        tempDate.month = dog.month
        tempDate.day = dog.day
        
        let now = Date()
        let calendar = Calendar.current
        let dogBirthday = calendar.date(from: tempDate)
        
        let yearComponents = calendar.dateComponents([.year], from: dogBirthday!, to: now)
        let monthComponents = calendar.dateComponents([.month], from: dogBirthday!, to: now)
        let months = Int((Double(Int(monthComponents.month!) % 12)/12)*10)
        let theAge = "\(yearComponents.year!).\(String(months))"
        
        ageLabel.text = " גיל:  \(theAge)"
        let size: String = sizes[dog.size]
        
        sizeLabel.text = " \(dog.race!), \(size)"
        if(UserApp.getInstance().following.contains(dog.id!)){
            likeButton.setImage(UIImage(named: "heartfull"), for: .normal)
        }
        if(dog.isMale!){
            genderCircle.image = #imageLiteral(resourceName: "bluecircle")
        }
        else{
            genderCircle.image = #imageLiteral(resourceName: "pinkcircle")
        }

        
        ownerId = dog.ownerId
    }
    
    func cellWasClicked() -> UIAlertController{
        let alert = UIAlertController(title:"\(nameLabel.text!)", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "חזרה", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addImage(image: dogImage.image!)
        alert.addAction(action)
        
        return alert
    }
    
}
