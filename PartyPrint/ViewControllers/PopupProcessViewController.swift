//
//  PopupProcessViewController.swift
//  PartyPrint
//
//  Created by LongND9 on 10/19/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit

protocol PopupProcessViewControllerDelegate: class {
    func cancelProgress(viewController : PopupProcessViewController)
}

class PopupProcessViewController: UIViewController {

    @IBOutlet weak var progressTextLabel: UILabel!
    @IBOutlet var labelImageBeingTransder: UILabel!
    
    @IBOutlet var buttonCancel: UIButton!
    @IBOutlet var labelStatusTransferred: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var viewContain: UIView!
    var totalImages: Float = 0
    var progress: Float = 0
    weak var delegate: PopupProcessViewControllerDelegate?
    weak var preViewController: PreviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preViewController?.delegateUpload = self
        setUpView()
        setTextForAllSubView()
    }

    
    deinit {
        print("deinit popup progress")
    }
    
    func setUpView() {
        viewContain.layer.cornerRadius = 5.0
        viewContain.layer.borderWidth = 0.5
        viewContain.layer.borderColor = UIColor.lightGray.cgColor
        let total = String(format: "%.f", totalImages)
        labelStatusTransferred.text = "0 / \(total)"
        labelImageBeingTransder.text = "Uploading".localized
    }
    
    func setTextForAllSubView() {
        buttonCancel.setTitle("CANCEL".localized, for: .normal)
    }

    @IBAction func didTapCancel(_ sender: AnyObject) {
        delegate?.cancelProgress(viewController: self)
        preViewController = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PopupProcessViewController: PreviewControllerUploadDelegate{
     func preViewControllerHaveFinishedUploading(viewController: PreviewViewController) {
        
    }

    func preViewControllerUploadFinish(viewController: PreviewViewController) {
        if totalImages > 0 {
            progress += 1
//            DispatchQueue.main.async {
                if self.progress == self.totalImages {
                    let total = String(format: "%.f", self.totalImages)
                    self.labelStatusTransferred.text = "\(total) / \(total)"
                    self.progressBar.setProgress(1, animated: true)
                } else {
                    let total = String(format: "%.f", self.totalImages)
                    let progres = String(format: "%.f", self.progress)
                    self.labelStatusTransferred.text = "\(progres) / \(total)"
                    self.progressBar.setProgress(self.progress/self.totalImages, animated: true)
                }
            }
           
            
//        }
    }
}
