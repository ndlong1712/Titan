//
//  PopupWaitingViewController.swift
//  PartyPrint
//
//  Created by LongND9 on 10/30/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class PopupWaitingViewController: UIViewController {

    @IBOutlet var viewContain: UIView!
    @IBOutlet var labelWaiting: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpView() {
        viewContain.layer.cornerRadius = 5.0
        viewContain.layer.borderWidth = 0.5
        viewContain.layer.borderColor = UIColor.lightGray.cgColor
        labelWaiting.text = "AppRecoverMessage".localized
    }

}
