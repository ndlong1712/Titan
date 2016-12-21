//
//  MainCollectionViewCell.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 14/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class SmallCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet var viewSelected: UIView!
    var assetLoaded: PHAsset!
    
    override func awakeFromNib() {
        setUpViewSelected()
    }
    
    func setUpViewSelected() {
        viewSelected.layer.borderWidth = 2.0
        viewSelected.layer.borderColor = UIColor(netHex: 0x237AE0).cgColor
    }
    
    func selectedCell(select: Bool) {
        if select {
            viewSelected.isHidden = false
        } else {
            viewSelected.isHidden = true
        }
    }
}
