//
//  StartupHTML.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 21/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

enum HtmlType {
    case HelpWebView
    case StartupWebView
    case AgreementWebView
}

extension UIWebView {
    
    /* load local with view type, if startup web view: check connect or not connect, 
     if not exist resource on server, but connected, get startup local html */
    func loadLocalHtmlWithViewType(viewType: HtmlType, isConnected: Bool = false) {
        
        if viewType == .HelpWebView {
            //htmlパス
            let fileName = WebViewHelper.getFileNameWithViewType(htmlType: .HelpWebView)
            
            //load local html for resource
            var url = Bundle.main.url(forResource: fileName, withExtension: Constant.HTML_FILE_EXTENSION)
            //if not exist language supported, get dafault is English
            if url == nil {
                let helpFileName = Constant.HELP_HTML_FILENAME
                url = Bundle.main.url(forResource: helpFileName, withExtension: Constant.HTML_FILE_EXTENSION)
            }
            let request = URLRequest(url: url!)
            self.loadRequest(request)
            
        } else if viewType == .StartupWebView {
            
            var fileName = ""
            if isConnected {
                fileName = Constant.STARTUP_HTML_FILENAME

            } else {
                fileName = WebViewHelper.getFileNameWithViewType(htmlType: .StartupWebView, isStartupFileName: false)
            }
            
            var path = Bundle.main.path(forResource: fileName, ofType: Constant.HTML_FILE_EXTENSION)
            if path == nil {
                let fileName = Constant.NOTCONNECT_STARTUP_HTML_FILENAME
                path = Bundle.main.path(forResource: fileName, ofType: Constant.HTML_FILE_EXTENSION)
            }
            let fileData = NSData.init(contentsOfFile: path!)
            if fileData != nil {
                let encoding = fileData?.ftl_getEncording()
                let htmlString = NSString.init(data: fileData as! Data, encoding: encoding!)
                self.loadHTMLString(htmlString as! String, baseURL: URL(fileURLWithPath: path!))
            }
            
        } else {
            //agreement do nothing
        }
    }
    
    /*
     *
     *Load agreement web view
     *
     */
    func loadAgreementHtml() {

        let url = WebViewHelper.getUrlToLoadHtml(withHtmlType: .AgreementWebView)

        WebViewHelper.requestHtml(withHtmlType: .AgreementWebView, currentUrl: url) { (resultRequestHtml, urlChange, error) in
            
            if resultRequestHtml == .existHtml {
                
                let request = NSMutableURLRequest.init(url: URL(string: urlChange!)!, cachePolicy: .reloadIgnoringLocalCacheData,
                                                       timeoutInterval: TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT))
                request.timeoutInterval = TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT)
                self.loadRequest(request as URLRequest)
                
                //not exist default resource on server
            } else {
                //check connect or not connect to wifi, if connect:
                //load default startup.html in local
            }
        }
    }
    
    /*
     *
     *Load help web view
     *
     */
    func loadHelpHtml() {
        
        let url = WebViewHelper.getUrlToLoadHtml(withHtmlType: .HelpWebView)
        
        //get string by evaluating java script from web view from string "navigator.userAgent"
        WebViewHelper.requestHtml(withHtmlType: .HelpWebView, currentUrl: url) { (resultRequestHtml, changedUrl, error) in
            
            if resultRequestHtml == .notExistHtml {
                self.loadLocalHtmlWithViewType(viewType: .HelpWebView)
                
            } else {
                DispatchQueue.main.async {
                    let request = NSMutableURLRequest.init(url: URL(string: changedUrl!)!, cachePolicy: .reloadIgnoringLocalCacheData,
                                                           timeoutInterval: Double(Constant.STARTUP_URL_REQUEST_TIMEOUT))
                    let userAgent = self.stringByEvaluatingJavaScript(from: "navigator.userAgent")
                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                    self.loadRequest(request as URLRequest)
                }
            }
        }
    }
    
    /*
     *
     *Load start up web view
     *
     */
    
    func loadStartupHtml() {
        /*Request Html from server,
         --> if not exist Html from server, request Html,
         --> else: load default startup.html in local */
        
        let url = WebViewHelper.getUrlToLoadHtml(withHtmlType: .StartupWebView)
        
        //not exist resource on server (may be not exist supported language)
        
        WebViewHelper.requestHtml(withHtmlType: .StartupWebView, currentUrl: url, completion: { (resultRequestHtml, changedUrl, error) in
            if resultRequestHtml == .existHtml {
                let request = NSMutableURLRequest.init(url: URL(string: changedUrl!)!, cachePolicy: .reloadIgnoringLocalCacheData,
                                                       timeoutInterval: TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT))
                request.timeoutInterval = TimeInterval(Constant.STARTUP_URL_REQUEST_TIMEOUT)
                self.loadRequest(request as URLRequest)
                
                //not exist default resource on server
            } else {
                self.loadDefaultStartupHtml()
            }
        })
    }
    
    func loadDefaultStartupHtml() {
        let reachability = FTLNetowrkReachability()
        let isConnected = reachability.isWiFiAccessPointReacheable()
        
        if !isConnected {
            /*load local html: NOTCONNECT Html file*/
            loadLocalHtmlWithViewType(viewType: .StartupWebView, isConnected: false)
            
        } else {
            /*load local html: Startup Html file*/
            loadLocalHtmlWithViewType(viewType: .StartupWebView, isConnected: true)
        }
    }
    
    func setupLayout() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scalesPageToFit = true
    }
}
