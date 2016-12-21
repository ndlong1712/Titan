//
//  WebViewHelper.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 23/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

/*Note: if not exist: mean have 2 case: error happen and not exist Html from server*/
enum ResultRequestHtml {
    case existHtml
    case notExistHtml
}

class WebViewHelper: NSObject {
    
    class func getCurrentLanguage() -> String {
        let preferredLanguages = NSLocale.preferredLanguages
        let language = preferredLanguages[0]
        let index: String.Index = language.index(language.startIndex, offsetBy: 2)
        return language.substring(to: index)
    }
    
    class func getFileNameWithViewType(htmlType: HtmlType, isStartupFileName: Bool = false) -> String {
        var fileName = ""
        if htmlType == .HelpWebView {
            fileName = Constant.HELP_HTML_FILENAME
            
        } else if htmlType == .StartupWebView {
            
            if isStartupFileName {
                fileName = Constant.STARTUP_HTML_FILENAME
            } else {
                fileName = Constant.NOTCONNECT_STARTUP_HTML_FILENAME
            }
        } else {
            fileName = Constant.AGREEMENT_HTML_FILENAME
        }
        
        let setLanguage = WebViewHelper.getCurrentLanguage()
        let htmlName = "\(fileName)_\(setLanguage)"
        return htmlName
    }
    
    class func getUrlToLoadHtml(withHtmlType htmlType: HtmlType) -> String {
        
        var url = ""
        var fileName = ""
        let currentLanguage = WebViewHelper.getCurrentLanguage()
        let hostAddress = FTLUrlRequest.getHostAddress()
        
        if htmlType == .AgreementWebView {
            fileName = WebViewHelper.getFileNameWithViewType(htmlType: .AgreementWebView)
            fileName = String.init(format: "%@/%@", currentLanguage, fileName)
            url = String.init(format: Constant.AGREEMENTFILE_URL, hostAddress!, fileName)
            
        } else if htmlType == .HelpWebView {
            fileName = WebViewHelper.getFileNameWithViewType(htmlType: .HelpWebView)
            fileName = String.init(format: "%@/%@", currentLanguage, fileName)
            url = String.init(format: Constant.HELPFILE_URL, hostAddress!, fileName)
            
        } else {
            fileName = WebViewHelper.getFileNameWithViewType(htmlType: .StartupWebView, isStartupFileName: true)
            fileName = String.init(format: "%@/%@", currentLanguage, fileName)
            url = String.init(format: Constant.STARTUPFILE_URL, hostAddress!, fileName)
        }
        
        return url
    }
    
    class func requestHtmlOnServer(url: String, completion: @escaping (_ resultRequestHtml: ResultRequestHtml?,_ error: Error?) -> Void) {
        
        let request = NSMutableURLRequest.init(url: URL(string:url)!, cachePolicy: .reloadIgnoringLocalCacheData,
                                               timeoutInterval: TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT))
        request.timeoutInterval = TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, respond, error) in
            
            if error != nil {
                let err = NSError(domain: "Could not connect to the server", code: 6969, userInfo: nil)
                completion(.notExistHtml, err)
                
            } else if respond != nil {
                let respond = respond as! HTTPURLResponse
                if respond.statusCode >= 400 || respond.statusCode == 0 {
                    completion(.notExistHtml, nil)
                } else {
                    completion(.existHtml, nil)
                }
            }
        }
        task.resume()
    }
    
    class func requestHtml(withHtmlType htmlType: HtmlType, currentUrl: String, completion:
        @escaping (_ resultRequestHtml: ResultRequestHtml?, _ changedUrl: String?,_ error: Error?) -> Void)  {
        
        //////////////////////////////
        var url = currentUrl
        if (htmlType == .AgreementWebView || htmlType == .StartupWebView) {
            
            WebViewHelper.requestHtmlOnServer(url: url, completion: { (resultRequestHtml: ResultRequestHtml?, error: Error?) in
                if error != nil {
                    completion(resultRequestHtml, url, error)
                } else {
                    //////////////////////////////
                    if resultRequestHtml == .notExistHtml {
                        //Upload photo
                        if htmlType == .AgreementWebView {
                            url = String(format: Constant.AGREEMENTFILE_URL, FTLUrlRequest.getHostAddress(), Constant.AGREEMENT_HTML_FILENAME)
                        } else if htmlType == .StartupWebView {
                            url = String(format: Constant.STARTUPFILE_URL, FTLUrlRequest.getHostAddress(), Constant.STARTUP_HTML_FILENAME)
                        }
                        WebViewHelper.requestHtmlOnServer(url: url, completion: { (resultRequestHtml: ResultRequestHtml?, error: Error?) in
                            
                            if resultRequestHtml == .notExistHtml {
                                //upload photo
                                completion(.notExistHtml, url, nil)
                            } else {
                                //show agreement pop up
                                completion(.existHtml, url, nil)
                            }
                        })
                        
                    } else {
                        //show agreement pop up
                        completion(.existHtml, url, nil)
                    }
                }
                
            })
            
            
        } else if htmlType == .HelpWebView {
            WebViewHelper.requestHtmlOnServer(url: url, completion: { (resultRequestHtml: ResultRequestHtml?, error: Error?) in
                completion(resultRequestHtml, url, nil)
            })
        }
    }
    
}
