//
//  SplashViewController.swift
//  PartyPrint
//
//  Created by KhoaND12 on 10/15/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var launchImage: UIImageView!
    var startTime = NSDate()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setUpImageForSplash()
        startInitialSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setUpImageForSplash()
    }
    
    func setUpImageForSplash() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isPortrait {
                launchImage.image = UIImage(named: "launch_image_ipad_port")
            } else {
                launchImage.image = UIImage(named: "launch_image_ipad_ori")
            }
        } else {
            launchImage.image = UIImage(named: "launch_image")
        }
    }
    
    func startInitialSetup() {
        // Set up time for delay about 3s at splash screen
        var delay = 3 + Int64(startTime.timeIntervalSinceNow)
        delay = delay > 0 ? delay : 0
        print("Delay: \(delay)")
        
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
           self.handleLoadingComplete()
        }
    }
    
    func showHome() {
        let homeStoryboard = Constant.StoryBoard.main
        // init home view controller
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.home)
        // init navigation with homeVC is rootViewController
        navigationController!.setViewControllers([homeVC], animated: true)
    }
    
    func handleLoadingComplete() {
        if AppSetting.sharedInstance.agreedPrivacyPolicyVersion() == AppSetting.currentPrivacyPolicyVersion {
            // If user agreed Privacy Policy then skip it
            showHome()
        } else {
            // If user has not yet agreed Privacy Policy then open Privacy Policy screen
            let mainStoryBoard = Constant.StoryBoard.main
            let privacyVC = mainStoryBoard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.privacy)
            navigationController!.pushViewController(privacyVC, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
