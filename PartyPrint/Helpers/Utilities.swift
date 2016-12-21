//
//  Utilities.swift
//  PartyPrint
//
//  Created by KhoaND12 on 10/14/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class Utilities: NSObject {
    class func designMenuButton(customButton: UIButton, title: String) {
        customButton.layer.cornerRadius = 8
        customButton.clipsToBounds = true
        customButton.layer.borderWidth = 1
        customButton.layer.backgroundColor = UIColor.white.cgColor
        customButton.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 85/255).cgColor
        
        customButton.setTitle(title, for: .normal)
        customButton.setTitleColor(UIColor.black, for: .normal)
        customButton.setTitleColor(UIColor.gray, for: .disabled)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        customButton.showsTouchWhenHighlighted = true
    }
    
    class func setUpNexupButton(button: UIButton) {
        // ボタンのタイトル色を設定(上から順に、タップ中の文字色、通常時の文字色、Disable時の文字色)

        button.setTitleColor(UIColor.white, for: .highlighted)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        
        // 進むボタンに画像を設定
        button.setTitleShadowColor(UIColor.gray, for: .normal)
        
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 85/255).cgColor
        
        // ボタン文言設定
        button.setTitle("Continue", for: .normal)
        
        // 初期表示時はDisable
        button.isEnabled = false
    }
    
    class func checkNetworkReachabiliy() -> Bool {
        let reachability = FTLNetowrkReachability.defaultsReachability() as! FTLNetowrkReachability
        
        if !reachability.isWiFiAccessPointReacheable(){
            print("cannot connect to server")
            return false
        }
        
        return true
    }
    
}
