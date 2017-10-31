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
    @IBOutlet weak var likeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
