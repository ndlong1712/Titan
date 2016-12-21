//
//  APIDefine.swift
//  PartyPrint
//
//  Created by LongND9 on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import Foundation


let SERVER_REQUEST_KEY_NAME_AUTHID = "AuthID"
let SERVER_REQUEST_KEY_NAME_CRYPT_MODE = "CryptoMode"
let SERVER_REQUEST_KEY_NAME_CRYPT_MODE_VALUE = "1"
let SERVER_REQUEST_KEY_NAME_IMAGE_FILE = "ImageFile"

typealias ServerResponse = (ResponsePackage?, ErrorServer?) -> Void

class ResponsePackage {
    
    var success = false
    var response: AnyObject? = nil
    var error: NSError? = nil
    
}

class ErrorServer {
    var code: Int = 0
    var error: String = ""
    var error_description: String = ""
    
    init(){
        
    }
    
    init(data: NSDictionary){
        code = data.object(forKey: "code") as! Int
        error = data.object(forKey: "error") as! String
        error_description = data.object(forKey: "error_description") as! String
    }
}

// Server
enum Enviroment {
	case dev
	case test
	case production
}

let enviroment = Enviroment.dev
//let enviroment = Enviroment.test
//let enviroment = Enviroment.production

let serverUrl: String = {
	return "http://"
}()

// MARK :- URL API
let urlUploadImage: String = "/uploadimage/upload"

