//
//  HelpViewController.swift
//  PartyPrint
//
//  Created by TrongNK on 10/10/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    struct LocalizationKey {
        static let MenuShowHelp = "MenuShowHelp"
        static let Menu = "Menu"
    }

    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    //var webView: UIWebView?
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        // Do any additional setup after loading the view.

        super.viewDidLoad()
       
        //webView = UIWebView(frame: CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height))
        //view.addSubview(webView!)
        //testWebView?.autoresizingMask = UIViewAutoresizing(rawValue: UInt(18))
        self.automaticallyAdjustsScrollViewInsets = false
        webView?.setupLayout()
        webView?.loadHelpHtml()
        //testWebView?.scalesPageToFit = true
        webView?.backgroundColor = UIColor.clear
        setTextForAllSubView()
        
        setBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        //webView?.frame.size = view.frame.size
    }
    
    func setBackButton() {
        btnBack.titleLabel?.lineBreakMode = .byTruncatingTail
        btnBack.titleLabel?.textAlignment = .center
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setTextForAllSubView()  {
        lbTitle.text = LocalizationKey.MenuShowHelp.localized
        btnBack.setTitle(LocalizationKey.Menu.localized, for: .normal)
    }
    
    
    @IBAction func backToHome(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}

extension HelpViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("did finish load")
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("did start load")
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
//        self.loadLocalHelpHtml()
        print("did fail load")
    }
}

