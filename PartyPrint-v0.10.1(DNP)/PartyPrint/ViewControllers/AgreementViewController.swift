//
//  AgreementViewController.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 22/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

protocol AgreementViewControllerDelegate: class {
    func agreementViewController(agreementViewController: AgreementViewController)
    func cancelAgreementViewController(agreementViewController: AgreementViewController)
}

class AgreementViewController: UIViewController {
    weak var delegate: AgreementViewControllerDelegate?

    @IBOutlet weak var agreementWebView: UIWebView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dontAgressButton: UIButton!
    @IBOutlet weak var agreeButton: UIButton!
    var isExistHtmlResource = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        agreementWebView.setupLayout()
        agreementWebView.loadAgreementHtml()
        
        self.containerView.layer.cornerRadius = 10.0
        setTextForAllSubview()
        setAgreeButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    @IBAction func AgreeButtonClicked(_ sender: AnyObject) {
        delegate?.agreementViewController(agreementViewController: self)
        
    }
    @IBAction func DontAgreeButtonClicked(_ sender: AnyObject) {
        delegate?.cancelAgreementViewController(agreementViewController: self)
    }
    
    func setTextForAllSubview() {
        agreeButton.setTitle(Constant.CommonLocalizationKey.Agree.localized, for: .normal)
        dontAgressButton.setTitle(Constant.CommonLocalizationKey.NotAgree.localized, for: .normal)
    }
    
    func setAgreeButton() {
        agreeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dontAgressButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }

}
