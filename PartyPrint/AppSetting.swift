//
//  AppSetting.swift
//  PartyPrint
//
//  Created by TrongNK on 10/11/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

let defaultMaxImageSending = 1

class AppSetting: NSObject {
    
    private enum SettingKey {
        static let agreedPrivacyPolicyVersion = "agreedPolicyVersion"
    }
    
    static let currentPrivacyPolicyVersion = "2.0.0"
    
    static let sharedInstance = AppSetting()
    
    var startDateTime: Date?
    var endDateTime: Date?
    var maxImageSending = defaultMaxImageSending //default
    
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
}
