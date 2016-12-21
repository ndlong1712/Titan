//
//  ApiGettingInfo.swift
//  PartyPrint
//
//  Created by LongND9 on 10/20/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import Alamofire

let requestTimeOut = 9
let serviceName = "getsetting"


class ApiGettingInfo: NSObject, XMLParserDelegate {
    
    var isBeginPeriod = false
    var isEndPeriod = false
    var isNumberOfImages = false
    var beginPeriod = ""
    var endPeriod = ""
    var numberOfImage = defaultMaxImageSending
    var errorParseXml: Error?
    
    
    func getSettingInfo(completion: @escaping (_
        beginPeriod: String, _ endPeriod: String, _ numberOfImages: Int,_ error: Error?)-> Void) {
        let url = serviceUrl()
        resetParam()
        print("URL get setting infor: \(url)")
        let header = [
            FTL_JSESSIONID : ""
        ]
        var params: [String: Any] = [:]
        let authId = FTLAuthenticationInfo.sharedInstance().getHashedAuthenticationInfo()
        params["AuthID"] = authId
        
        NetworkManager.sharedInstance.request(url, method: HTTPMethod.post, parameters: params, encoding: URLEncoding.default, headers: header).response { [weak self] (response: DefaultDataResponse)  in
            print("\(response.error)")
            let data = response.data
            if response.error == nil && data != nil {
                
                let xmlParser = XMLParser(data: data!)
                xmlParser.delegate = self
                
                let isValid = xmlParser.parse()
                print("parse xml :\(isValid)")
                
                if !isValid {
                    let err = NSError(domain: "", code: 0, userInfo: [:])
                    completion((self?.beginPeriod)!, (self?.endPeriod)!, (self?.numberOfImage)!, err)
                } else {
                    if self?.errorParseXml != nil {
                        completion((self?.beginPeriod)!, (self?.endPeriod)!, (self?.numberOfImage)!, self?.errorParseXml)
                    } else {
                        completion((self?.beginPeriod)!, (self?.endPeriod)!, (self?.numberOfImage)!, nil)
                    }
                   
                }
                
            } else {
                let err = NSError(domain: "", code: 0, userInfo: [:])
                completion((self?.beginPeriod)!, (self?.endPeriod)!, (self?.numberOfImage)!, err)
            }
        }
        
    }
    
    func serviceUrl() -> String {
        return String(format: "http://%@:8080/uploadimage/%@", FTLUrlRequest.getHostAddress(), serviceName)
    }
    
    func resetParam() {
        beginPeriod = ""
        endPeriod = ""
        numberOfImage = defaultMaxImageSending
    }
    
    //MARK: Parse XML
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("element start: \(elementName)")
        switch elementName {
        case "TransferBeginningPeriod":
            isBeginPeriod = true
            break
        case "TransferEndingPeriod":
            isEndPeriod = true
            break
        case "NumberOfImages":
            isNumberOfImages = true
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parse Xml respone ERROR!")
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("element finish: \(elementName)")
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("\(string)")
        if string.components(separatedBy: ":")[0] == "ERROR" {
            let err = NSError(domain: "", code: 0, userInfo: [:])
            errorParseXml = err
            return
        }
        if isBeginPeriod {
            beginPeriod = string
            isBeginPeriod = false
        }
        if isEndPeriod {
            endPeriod = string
            isEndPeriod = false
        }
        if isNumberOfImages {
            isNumberOfImages = false
            numberOfImage = Int(string)!
        }
        
    }
    
    
}

class NetworkManager {
    
    var manager: SessionManager?
    static let sharedInstance: SessionManager = {
        // work
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(requestTimeOut)
        configuration.timeoutIntervalForResource = TimeInterval(requestTimeOut)
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
}
