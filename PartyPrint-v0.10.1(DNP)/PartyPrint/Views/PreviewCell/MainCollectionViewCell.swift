//
//  MainCollectionViewCell.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 14/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    var mainPhoto: UIImageView!
    
    @IBOutlet weak var contentViewCell: UIView!
    var myScrollView: SMScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateLayoutForMainCell(image: UIImage) {
        if contentViewCell.subviews.count > 0 {
            for v in contentViewCell.subviews{
                v.removeFromSuperview()
            }
        }
        
        mainPhoto = UIImageView(image: image)
        mainPhoto.contentMode = .scaleAspectFill
        mainPhoto.clipsToBounds = true
        
        myScrollView = SMScrollView(frame: contentViewCell.bounds)
        myScrollView.maximumZoomScale = 5.0
        myScrollView.delegate = self
        myScrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        myScrollView.contentSize = mainPhoto.frame.size
        myScrollView.alwaysBounceVertical = true
        myScrollView.alwaysBounceHorizontal = true
        myScrollView.stickToBounds = true
        myScrollView.add(forZooming: mainPhoto)
        myScrollView.scaleToFit()
        contentViewCell.addSubview(myScrollView)
    }
}

extension MainCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return myScrollView.viewForZooming
    }
}
