//
//  CustomCell.swift
//  Titan
//
//  Created by LongND9 on 6/29/16.
//  Copyright © 2016 LongND9. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet var imgAvatar: UIImageView!
    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbCategories: UILabel!
    @IBOutlet var lbAdress: UILabel!
    @IBOutlet var imgRate: UIImageView!
    @IBOutlet var lbCountViews: UILabel!
    @IBOutlet var lbDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
