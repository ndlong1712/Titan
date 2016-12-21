//
//  SourceLicenseViewController.swift
//  PartyPrint
//
//  Created by KhoaND12 on 10/22/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class SourceLicenseViewController: UIViewController {
    
    struct LocalizationKey {
        static let OpenSource = "OpenSource"
        static let Menu = "Menu"
    }
        
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var titleNaviLabel: UILabel!
    @IBOutlet weak var licenseWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //licenseWebView.scrollView.bounces = false
        loadLocalHelpHtml()
        setTextForAllSubView()
        //licenseWebView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backNavigationButtonClicked(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setTextForAllSubView() {
        titleNaviLabel.text = LocalizationKey.OpenSource.localized
        btnBack.setTitle(LocalizationKey.Menu.localized, for: .normal)
    }
    
    
    func loadLocalHelpHtml() {
        //htmlパス
        let fileName = "software_licenses"
        let fileType = "html"
        
        //html表示
        //NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:fileType];
        let url = Bundle.main.url(forResource: fileName, withExtension:fileType)
        //NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        let request = URLRequest(url: url!)
        //        let htmlFile = Bundle.main.path(forResource: fileName, ofType: fileType)
        //        let htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        licenseWebView.loadRequest(request)
    }

}

extension SourceLicenseViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let contentSize = licenseWebView.scrollView.contentSize;
        let viewSize = licenseWebView.bounds.size;
        
        let rw = viewSize.width / contentSize.width;
        
        licenseWebView.scrollView.minimumZoomScale = rw;
        licenseWebView.scrollView.maximumZoomScale = rw;
        licenseWebView.scrollView.zoomScale = rw;
    }
}
