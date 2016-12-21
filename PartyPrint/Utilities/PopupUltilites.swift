//
//  PopupUltilites.swift
//  PartyPrint
//
//  Created by LongND9 on 10/19/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import MBProgressHUD

class PopupUltilites: NSObject {
    class func showPopup(title: String, message: String, titleCancelButton: String, titleOkButton: String, viewContain: UIViewController, okAction: @escaping ()-> Void, cancelAction: @escaping ()-> Void ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if titleOkButton != "" {
            alert.addAction(UIAlertAction(title: titleOkButton, style: .default, handler: { (UIAlertAction) in
                okAction()
            }))
        }
        if titleCancelButton != "" {
            alert.addAction(UIAlertAction(title: titleCancelButton, style: .cancel, handler: { (UIAlertAction) in
                cancelAction()
            }))

        }
        
        viewContain.present(alert, animated: true, completion: nil)
    }
    
    class func initPopUp(identifier: String) -> UIViewController{
        let sb = NFCStoryboard.popupStoryboard
        let vc = sb.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    
    class func showLoading(inView: UIView) {
        let spinnerActivity = MBProgressHUD.showAdded(to: inView, animated: true)
        spinnerActivity.bezelView.style = .solidColor
        spinnerActivity.bezelView.color = .clear
    }
    
    class func customLoadingForThanksScreen(inView: UIView) {
        let spinnerActivity = MBProgressHUD.showAdded(to: inView, animated: true)
        spinnerActivity.bezelView.isHidden = true
        spinnerActivity.backgroundView.color = UIColor.black
        spinnerActivity.backgroundView.alpha = 0.5
    }
}

struct NFCStoryboard {
    static let popupStoryboard = UIStoryboard(name: "Main", bundle: nil)
}
