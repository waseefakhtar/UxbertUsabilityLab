//
//  CustomTableViewCell.swift
//  UxbertUsabilityLab
//
//  Created by Waseef Akhtar on 9/10/17.
//  Copyright © 2017 Waseef Akhtar. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var movieLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    
    @IBOutlet var addToFavorites: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
