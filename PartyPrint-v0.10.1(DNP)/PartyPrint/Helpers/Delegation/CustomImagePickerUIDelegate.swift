//
//  CustomImagePickerUIDelegate.swift
//  PartyPrint
//
//  Created by TrongNK on 10/14/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ImagePickerSelectionDelegate {
//    func imagePickerController(_ imagePickerController: DKImagePickerController, didSelect asset: DKAsset)
//    func imagePickerController(_ imagePickerController: DKImagePickerController, didSelect assets: [DKAsset])
//    func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselect asset: DKAsset)
//    func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselect assets: [DKAsset])
//
//}
//
//class CustomImagePickerUIDelegate: DKImagePickerControllerDefaultUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    var selectionDelegate: ImagePickerSelectionDelegate?
//    
//    var didCancel: (() -> Void)?
//    var didFinishCapturingImage: ((_ image: UIImage) -> Void)?
//    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
//    
//    open override func imagePickerControllerCreateCamera(_ imagePickerController: DKImagePickerController,
//                                                         didCancel: @escaping (() -> Void),
//                                                         didFinishCapturingImage: @escaping ((_ image: UIImage) -> Void),
//                                                         didFinishCapturingVideo: @escaping ((_ videoURL: URL) -> Void)
//        ) -> UIViewController {
//        self.didCancel = didCancel
//        self.didFinishCapturingImage = didFinishCapturingImage
//        self.didFinishCapturingVideo = didFinishCapturingVideo
//        
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.sourceType = .camera
//        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
//        
//        return picker
//    }
//    
//    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
//        self.selectionDelegate?.imagePickerController(imagePickerController, didSelect: didSelectAsset)
//        self.updateDoneButtonTitle(self.doneButton)
//    }
//    
//    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
//        self.selectionDelegate?.imagePickerController(imagePickerController, didSelect: didSelectAssets)
//            self.updateDoneButtonTitle(self.doneButton)
//    }
//    
//    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
//        self.selectionDelegate?.imagePickerController(imagePickerController, didSelect: didDeselectAsset)
//        self.updateDoneButtonTitle(self.doneButton)
//    }
//    
//    open override func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
//        self.selectionDelegate?.imagePickerController(imagePickerController, didSelect: didDeselectAssets)
//        self.updateDoneButtonTitle(self.doneButton)
//    }
//    
//    // MARK: - UIImagePickerControllerDelegate methods
//    
//    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let mediaType = info[UIImagePickerControllerMediaType] as! String
//        
//        if mediaType == kUTTypeImage as String {
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            self.didFinishCapturingImage?(image)
//        } else if mediaType == kUTTypeMovie as String {
//            let videoURL = info[UIImagePickerControllerMediaURL] as! URL
//            self.didFinishCapturingVideo?(videoURL)
//        }
//    }
//    
//    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        self.didCancel?()
//    }

}
