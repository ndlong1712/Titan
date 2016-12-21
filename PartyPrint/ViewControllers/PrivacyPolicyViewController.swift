//
//  PrivacyPolicyViewController.swift
//  PartyPrint
//
//  Created by TrongNK on 10/10/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    struct LocalizationKey {
        static let PrivacyPolicyAgreeMessage = "PrivacyPolicyAgreeMessage"
        static let Continue = "Continue"
        static let PrivacyPolicyDescription = "PrivacyPolicyDescription"
        static let AgreementViewTitle = "AgreementViewTitle"
        static let PrivacyPolicyMessage = "PrivacyPolicyMessage"
    }
    
    @IBOutlet weak var privacyPolicyDescriptionLabel: UILabel!
    @IBOutlet weak var copyrightTextView: UITextView!
    @IBOutlet weak var checkBoxLabel: UILabel!
    @IBOutlet weak var agreeCheckBox: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    var lastContentOffset: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        setTextForAllSubView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil)
    }
    
    func appDidEnterBackground() {
        lastContentOffset = copyrightTextView.contentOffset
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        if let contentOffset = lastContentOffset {
            copyrightTextView.setContentOffset(contentOffset, animated: false)
        } else {
            copyrightTextView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    func setTextForAllSubView() {
        privacyPolicyDescriptionLabel.text = LocalizationKey.PrivacyPolicyDescription.localized
        checkBoxLabel.text = LocalizationKey.PrivacyPolicyAgreeMessage.localized
        continueButton.setTitle(LocalizationKey.Continue.localized, for: .normal)
        navigationItem.title = LocalizationKey.AgreementViewTitle.localized
        copyrightTextView.text = LocalizationKey.PrivacyPolicyMessage.localized
    }
    
    @IBAction func agreeCheckBoxDidTouch(_ sender: AnyObject) {
        self.agreeCheckBox.isSelected = !self.agreeCheckBox.isSelected;
        self.continueButton.isEnabled = self.agreeCheckBox.isSelected;
    }
    
    @IBAction func continueButtonDidTouch(_ sender: AnyObject) {
        let mainStoryBoard = Constant.StoryBoard.main
        let homeViewController = mainStoryBoard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.home)
        self.navigationController?.setViewControllers([homeViewController], animated: true)
        
        AppSetting.sharedInstance.setAgreedPrivacyPolicyVersion(version: AppSetting.currentPrivacyPolicyVersion)
    }

}
