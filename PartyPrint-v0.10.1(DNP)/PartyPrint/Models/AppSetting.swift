//
//  AppSetting.swift
//  PartyPrint
//
//  Created by TrongNK on 10/11/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

let defaultMaxImageSending = 1
let defaultMaxImageSize = 80.0; // in megabyte (MB)

class AppSetting: NSObject {
    
    private enum SettingKey {
        static let agreedPrivacyPolicyVersion = "agreedPolicyVersion"
    }
    
    static let currentPrivacyPolicyVersion = "0.9.8"
    
    static let sharedInstance = AppSetting()
    
    var startDateTime: Date?
    var endDateTime: Date?
    var maxImageSending = defaultMaxImageSending //default
    var maxImageSize = defaultMaxImageSize
    
    func setAgreedPrivacyPolicyVersion(version: String) {
        UserDefaults.standard.setValue(version, forKey: SettingKey.agreedPrivacyPolicyVersion)
        UserDefaults.standard.synchronize()
    }
    
    func agreedPrivacyPolicyVersion() -> String? {
        return UserDefaults.standard.value(forKey: SettingKey.agreedPrivacyPolicyVersion) as? String
    }
    
    func getStartDateTime() -> Date? {
        return self.startDateTime?.gmtDate()
    }
    
    func getEndDateTime() -> Date? {
        return self.endDateTime?.gmtDate()
    }
    
    func getMaxImageSending() -> Int? {
        return self.maxImageSending
    }
    
    func getMaxImageSize() -> Double {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            let configDict = NSDictionary(contentsOfFile: path)
            if let dict = configDict {
                maxImageSize = dict.value(forKey: "MaxImageSize") as! Double
            }
        }
        
        return maxImageSize
    }
}
