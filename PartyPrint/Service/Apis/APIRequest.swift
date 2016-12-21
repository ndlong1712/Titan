//
//  APIRequest.swift
//  PartyPrint
//
//  Created by LongND9 on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//


import Foundation
import Alamofire

let serviceUpload = "upload"

enum statusUpLoad: String{
    case success = "1"
    case failure = "0"
}

enum ServerResponseCode {
    static let success = 0
    static let errorParameter = 101
    static let errorOrderKey = 201
    static let errorAuth = 202
    static let errorDecrypt = 701
    static let errorSession = 801
    static let errorSystem = 999
}

let serverReponseResultSuccess = 1


protocol APIRequestDelegate: class {
    func uploadImageDidFinish(status: statusUpLoad, error: NSError?)
}


class APIRequest: NSObject {
    
    weak var delegate: APIRequestDelegate?
    
    func uploadImage(cryptoMode: String, authId: String, dataImage: Data) {
        let url = serviceUrl()
        print("URL upload image: \(url)")
        let header = [
            FTL_JSESSIONID : ""
        ]
        //check authID = nil
        
        let fileName = "\(UploadImageHelper.getNextFileName()).jpeg"
        
        Alamofire.upload(multipartFormData: { (multipartForm: MultipartFormData) in
            multipartForm.append(dataImage, withName: fileName, fileName: fileName, mimeType: "image/jpeg")
            multipartForm.append(authId.data(using: .utf8)! , withName: SERVER_REQUEST_KEY_NAME_AUTHID)
            multipartForm.append(SERVER_REQUEST_KEY_NAME_CRYPT_MODE_VALUE.data(using: .utf8)! , withName: SERVER_REQUEST_KEY_NAME_CRYPT_MODE)
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: HTTPMethod.post , headers: header) { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
        
                upload.responseData(completionHandler: { (dataResponse: DataResponse<Data>) in
                    let strRes = String.init(data: dataResponse.data!, encoding: String.Encoding.utf8)
                    print(strRes!)
                    
                    var responseCode: Int
                    
                    let arrayResponse = strRes?.components(separatedBy: "&")
                    
                    if let arrayResponse = arrayResponse {
                        
                        if arrayResponse.count < 1 {
                            responseCode = ServerResponseCode.errorSystem
                        }
                    
                        let arrayElement = arrayResponse[0].components(separatedBy: "=")
                        
                        if arrayElement.count < 1 {
                            responseCode = ServerResponseCode.errorSystem
                        }
                        
                        if arrayElement[0] == "Result" && Int(arrayElement[1]) == serverReponseResultSuccess {
                            responseCode = ServerResponseCode.success
                        } else {
                            if arrayResponse[0] == "" {
                                responseCode = ServerResponseCode.errorSystem
                            } else {
                                let arrayError = arrayResponse[1].components(separatedBy: "=")
                                responseCode = Int(arrayError[1])!
                            }
                            
                        }
                    } else {
                        // Fail
                        responseCode = ServerResponseCode.errorSystem
                    }
                    
                    if responseCode == ServerResponseCode.success {
                        self.delegate?.uploadImageDidFinish(status: .success, error: nil)
                    } else {
                        let errorCode = self.normalizeErrorCode(responseCode)
                        let error = NSError.init(domain: Constant.defaultErrorDomain, code: errorCode, userInfo: nil)
                        self.delegate?.uploadImageDidFinish(status: .failure, error: error)
                    }
                    
                })
            case .failure(let encodingError):
                print(encodingError)
                self.delegate?.uploadImageDidFinish(status: .failure, error: encodingError as NSError?)
            }
            
        }
    }
    
    func serviceUrl() -> String {
        return String(format: "http://%@:8080/uploadimage/%@", FTLUrlRequest.getHostAddress(), serviceUpload)
    }
    
    private func normalizeErrorCode(_ errorCode: Int) -> Int {
        switch errorCode {
        case ServerResponseCode.errorParameter:
            return Constant.ServerResponseErrorCode.imageUploadResponseParameter
        case ServerResponseCode.errorSession:
            return Constant.ServerResponseErrorCode.imageUploadResponseSession
        case ServerResponseCode.errorDecrypt:
            return Constant.ServerResponseErrorCode.imageUploadResponseDecrypt
        default:
            return Constant.ServerResponseErrorCode.imageUploadResponseSystem
        }
    }
    
}


