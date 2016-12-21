//
//  Constant.swift
//  PartyPrint
//
//  Created by TrongNK on 10/11/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class Constant {
    
    enum StoryBoard {
        static let main = UIStoryboard(name: "Main", bundle: nil)
    }
    
    enum ViewControllerIdentifier {
        static let home = "HomeViewController"
        static let privacy = "PrivacyPolicyViewController"
        static let preview = "PreviewViewController"
        static let help = "HelpViewController"
        static let info = "InfoAppViewController"
        static let license = "SourceLicenseViewController"
        static let navigationController = "MainNavigationController"
        static let agreementController = "AgreementViewController"
    }
    
    enum Notification {
        static let applicationDidBecomeActive = "ApplicationDidBecomeActive"
        static let applicationDidEnterBackground = "ApplicationDidEnterBackground"
        static let applicationWillResignActive = "ApplicationWillResignActive"
    }
    
    static let dateTimeFormatForGeneratingFileName = "yyyy-MM-dd-HH-mm-ss"
    static let dateTimeFormatForConverting = "yyyyMMddHHmmss"

    //Web view
    static let STARTUPFILE_URL = "http://%@:8080/uploadimage/specialmessage/%@.html" //スタートアップで使用するURL
    static let HELPFILE_URL = "http://%@:8080/uploadimage/help/%@.html" //ヘルプで使用するURL
    static let AGREEMENTFILE_URL = "http://%@:8080/uploadimage/agreement/%@.html" //スタートアップとヘルプで共通で使用するURL
    static let STARTUP_URL_REQUEST_TIMEOUT = 3
    static let HTML_FILE_EXTENSION = "html"
    static let NOTCONNECT_STARTUP_HTML_FILENAME = "Notconnect"
    static let HELP_HTML_FILENAME = "Help_iPhone"
    static let STARTUP_HTML_FILENAME = "Startup"
    static let AGREEMENT_HTML_FILENAME = "Agreement"
    
    //Alert
    static let agreementTitle = "Agreement"
    static let actionOkTitle = "OK"
    static let actionCanceltitle = "Cancel"

    enum ErrorTag {
        // --- FTLImageUploadRequest ---
        static let IMAGE_UPLOAD_AUTHID_CREATE =              5101
        static let IMAGE_UPLOAD_NOT_HTTP_RESPONSE =          5102
        static let IMAGE_UPLOAD_NOT_HTTP_STATUS_CODE =       5103
        
        // --- FTLImageUploadResponse ---
        static let IMAGE_UPLOAD_RESPONSE_PARAMETER =        5201
        static let IMAGE_UPLOAD_RESPONSE_SESSION =          5202
        static let IMAGE_UPLOAD_RESPONSE_DECRYPT =          5203
        static let IMAGE_UPLOAD_RESPONSE_SYSTEM =           5204
        
        // --- FTLAuthenticationRequest ---
        static let AUTHENTICATION_AUTHID_CREATE = 5301
        static let AUTHENTICATION_NOT_HTTP_RESPONSE = 5302
        static let AUTHENTICATION_NOT_HTTP_STATUS_CODE = 5303
        
        // --- FTLAuthenticationResponse ---
        static let AUTHENTICATION_RESPONSE_PARAMETER = 5401
        static let AUTHENTICATION_RESPONSE_ORDERKEY = 5402
        static let AUTHENTICATION_RESPONSE_AUTH = 5403
        static let AUTHENTICATION_RESPONSE_SYSTEM = 5404
        
        // --- FTLSupportSecurityModeRequest ---
        static let SUPPORT_SECURITY_MODE_AUTHID_CREATE = 5501
        static let SUPPORT_SECURITY_MODE_NOT_HTTP_RESPONSE = 5502
        static let SUPPORT_SECURITY_MODE_NOT_HTTP_STATUS_CODE = 5503
        static let SUPPORT_SECURITY_MODE_AUTHID_CREATE_SYNCRO = 5504
        
        // --- FTLSupportSecurityModeResponse ---
        static let ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_PARAMETER = 5601
        static let ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_AUTH = 5602
        static let ERROR_CODE_NETWORK_SUPPORT_SECURITY_MODE_RESPONSE_SYSTEM = 5603
        
        // --- FTLSettingDataRequest ---
        static let ERROR_CODE_NETWORK_SETTING_DATA_AUTHID_CREATE = 5701
        static let ERROR_CODE_NETWORK_SETTING_DATA_NOT_HTTP_RESPONSE = 5702
        static let ERROR_CODE_NETWORK_SETTING_DATA_NOT_HTTP_STATUS_CODE = 5703
        static let ERROR_CODE_NETWORK_SETTING_DATA_AUTHID_CREATE_SYNCRO = 5704
        
        // --- FTLSettingDataRequestResponse ---
        static let ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_PARAMETER = 5801
        static let ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_AUTH = 5802
        static let ERROR_CODE_NETWORK_SETTING_DATA_RESPONSE_SYSTEM = 5803
    }
    
    enum ServerResponseErrorCode {
        static let imageUploadAuthIdCreate = 5101
        static let imageUploadNotHttpResponse = 5102
        static let imageUploadNotHttpStatusCode = 5103
        
        static let imageUploadResponseParameter = 5201
        static let imageUploadResponseSession = 5202
        static let imageUploadResponseDecrypt = 5203
        static let imageUploadResponseSystem = 5299
        
        static let settingDataNotHttpResponse = 5702
        static let settingNotHttpStatusCode = 5703
    }
    
    static let defaultErrorDomain = "FTLErrorDomain"
    
    struct CommonLocalizationKey {
        static let Agree = "AGREE"
        static let NotAgree = "NotAgree"
        static let Yes = "YES"
        static let No = "NO"
        static let Ok = "OK"
        static let Done = "Done"
        static let Cancel = "Cancel"
        static let Menu = "Back"
    }
}
