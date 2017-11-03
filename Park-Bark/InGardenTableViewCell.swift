//
//  InGardenTableViewCell.swift
//  Park-Bark
//
//  Created by admin on 31/10/2017.
//  Copyright © 2017 park-bark. All rights reserved.
//

import UIKit

class InGardenTableViewCell: UITableViewCell {

    @IBOutlet weak var dogImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var dogId : String!
    
    
    
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
            FBDatabaseManagment.getInstance().addFollowing(id: dogId, name: nameLabel.text!)
        }
        
        else{
            likeButton.setImage(UIImage(named: "heartempty"), for: .normal)
            FBDatabaseManagment.getInstance().removeFollowing(id: dogId)
        }
    }
    
}
