//
//  HomeViewController.swift
//  PartyPrint
//
//  Created by TrongNK on 10/3/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD

let success:Int32 = 0
let fail:Int32 = 1
let timeThatThankYouAppear = 4

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    struct LocalizationKey {
        static let Version = "VERSION"
        static let MenuTakePhoto = "MenuTakePhoto"
        static let MenuSelectAlbum = "MenuSelectAlbum"
        static let MenuShowHelp = "MenuShowHelp"
        static let CannotDownloadPhotoTitle = "CannotDownloadPhotoTitle"
        static let CannotDownloadPhotoMessage = "CannotDownloadPhotoMessage"
    }
    

    var loadingSetting = false
    
    @IBOutlet weak var btnInfomation: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet var labelSucessfulyMessage: UILabel!
    @IBOutlet var viewCusscessfulyMessage: UIView!
    
    var apiGetSettingInfo = ApiGettingInfo()
    var defaultSelectImage = false // in case not connect to internet
    var appResignActive = false
    var showPrivacySettings = false // to prevent dismiss popup "privacy setting"
    var dismissFromPreviewPhoto = false // to prevent duplicate call api when "App did become active" and "view will appear"
    var isLoadingSetting = false
    var isDismissPopup = false //
    var isLoadingThaksful = false // to custom loading view at [Thanks] screen
    
    let textCellIdentifier = "TextCell"
    
    var pickerController = QBImagePickerController()
    var version = ""
    var menuArrayText = [String]()
    var menuArrayImage = [String]()
    var selectedAsset = NSMutableArray()
    var customWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set text and localized for text
        
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        lbVersion.text = "Ver: ".appending(version)
        // Do any additional setup after loading the view, typically from a nib.
        menuArrayImage = ["ic_camera", "ic_library", "ic_help"]
        
        setTextForAllSubView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.layoutIfNeeded()
        view.setNeedsLayout()
        
        let height = view.frame.size.height - menuTableView.frame.size.height - 64
        
        customWebView = UIWebView(frame: CGRect(x: 0, y: 64, width: viewCusscessfulyMessage.frame.size.width, height: height))
        view.addSubview(customWebView!)
        customWebView?.backgroundColor = UIColor.clear
        view.bringSubview(toFront: viewCusscessfulyMessage)
        setUpNotificationCenter()
        
        labelSucessfulyMessage.text = "ImageSendDone".localized
        viewCusscessfulyMessage.isHidden = true
        
        //set exclusive button
        btnInfomation.isExclusiveTouch = true
    }
    
    override func didReceiveMemoryWarning() {
        PopupUltilites.showPopup(title: "", message: "LessMemoryWarning".localized , titleCancelButton: "".localized, titleOkButton: "OK".localized, viewContain: self, okAction: { }, cancelAction: { })
        super.didReceiveMemoryWarning()
    }
    
    //MARK: NotificationCenter
    func setUpNotificationCenter() {
        //app did become active
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name(rawValue: Constant.Notification.applicationDidBecomeActive), object: nil)
        
        //noti when app did enter forceground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil)
        
        //noti when app will resign active
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name(rawValue: Constant.Notification.applicationWillResignActive), object: nil)
    }
    
    //MARK: view life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        navigationController?.setNavigationBarHidden(true, animated: false)
        if !dismissFromPreviewPhoto {
            DispatchQueue.main.async {
                if self.isDismissPopup {
                    self.loadSetting(isShowPopup: true)
                } else {
                   self.loadSetting(isShowPopup: false)
                }
            
            }
        } else {
            dismissFromPreviewPhoto = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        let height = view.frame.size.height - view.frame.size.height/4 - 64
        customWebView?.frame.size.width = view.frame.size.width
        customWebView?.frame.size.height = height
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
////        menuTableView.layoutIfNeeded()
////        menuTableView.setNeedsLayout()
//        let height = size.height - menuTableView.frame.size.height - 64
//        customWebView.frame.size.width = size.width
//        customWebView.frame.size.height = height
//    }
    
    func setTextForAllSubView() {
        let ver = LocalizationKey.Version.localized
        lbVersion.text = String(format: ver, version)
        menuArrayText = [LocalizationKey.MenuTakePhoto.localized, LocalizationKey.MenuSelectAlbum.localized, LocalizationKey.MenuShowHelp.localized]
    }
    
    //MARK: app life cycle
    func appDidEnterBackground() {
        if !(presentedViewController is PopupWaitingViewController) {
            self.dismiss(animated: false, completion: nil)
            selectedAsset = pickerController.selectedAssets
            isDismissPopup = true
        }
    
        appResignActive = false
    }
    
    func appDidBecomeActive() {
        if navigationController?.viewControllers.last is HelpViewController {
            isDismissPopup = false
            return
        }
        
        if !appResignActive {
            loadSetting(isShowPopup: true)
        }
    }
    
    func appWillResignActive() {
        appResignActive = true
    }
    
    func setUpViewForLoadSetting(isShowPopup: Bool) {
        
        if isShowPopup {
            let popup = PopupUltilites.initPopUp(identifier: "PopupWaitingViewController") as? PopupWaitingViewController
            popup?.modalPresentationStyle = .overCurrentContext
            present(popup!, animated: false, completion: nil)
        } else {
            if navigationController?.viewControllers.last is PreviewViewController {
                let preView = navigationController?.viewControllers.last
                //PopupUltilites.showLoading(inView: (preView?.view)!)
                MBProgressHUD.showAdded(to: (preView?.view)!, animated: true)
            } else {
                if isLoadingThaksful {
                    isLoadingThaksful = false
                    PopupUltilites.customLoadingForThanksScreen(inView: self.view)
                } else {
                    PopupUltilites.showLoading(inView: self.view)
                }
                //MBProgressHUD.showAdded(to: self.view, animated: true)
            }
        }
    }
    
    
    func loadSetting(isShowPopup: Bool) {
        customWebView?.setupLayout()
        
        if isLoadingSetting {
            return
        }
        
        isDismissPopup = false
        isLoadingSetting = true
        if !checkNetworkForLoadSetting() {
            enableButtonSentAtPreViewScreen()
            isLoadingSetting = false
            isLoadingThaksful = false
            setAppsetingToDefault() // max selected image = 1, start and end date = nil
            return
        }
        
        print("========================Load setting==============================")
        
        setUpViewForLoadSetting(isShowPopup: isShowPopup)
        FTLUrlRequest.resetHostAddress()
        HTTPCookieStorage.ftl_removeCookie(FTLUrlRequest.getHostAddress())
        
        callApiGetSetting { (error: Error?) in
            self.isLoadingSetting = false
            if error != nil {
                print("error != nil")
                self.customWebView?.loadLocalHtmlWithViewType(viewType: .StartupWebView, isConnected: false)
                if isShowPopup {
                    self.dismiss(animated: false, completion: nil)
                } else {
                    if self.navigationController?.viewControllers.last is PreviewViewController {
                        let preView = self.navigationController?.viewControllers.last
                        MBProgressHUD.hide(for: (preView?.view)!, animated: true)
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }
                self.checkStatusHomeView()
                
            } else {
                print("error == nil")
                self.customWebView?.loadStartupHtml()
                if isShowPopup {
                    self.dismiss(animated: false, completion: nil)
                } else {
                    if self.navigationController?.viewControllers.last is PreviewViewController {
                        let preView = self.navigationController?.viewControllers.last
                        MBProgressHUD.hide(for: (preView?.view)!, animated: true)
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                }
                
            }
            self.enableButtonSentAtPreViewScreen()
            
        }
        
    }
    
    func checkStatusHomeView() {
        // if current view is home view then show popup
            PopupUltilites.showPopup(title: "", message: "NetworkErrorMessage".localized , titleCancelButton: "CANCEL".localized, titleOkButton: "RETRY".localized, viewContain: self, okAction: {
                self.loadSetting(isShowPopup: false)
                }, cancelAction: {
                    self.dismiss(animated: true, completion: nil)
            })

    }
    
    func enableButtonSentAtPreViewScreen() {
        if (self.navigationController?.viewControllers.count)! >= 2 {
            if self.navigationController?.viewControllers[1] is PreviewViewController {
                let previewVC = self.navigationController?.viewControllers[1] as! PreviewViewController
                previewVC.enableSendButton()
            }
        }
    }
    
    func cancelAllConnection() {
        // 省電力化のため、通信中以外はアイドルタイマーを動かす。
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func moreInfoButtonClicked(_ sender: AnyObject) {
        let homeStoryboard = Constant.StoryBoard.main
        // init home view controller
        let infoViewController = homeStoryboard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.info)
        // init navigation with homeVC is rootViewController
        navigationController?.pushViewController(infoViewController, animated: true)
    }
    
    func checkPhotoServiceEnabled() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined || authStatus == .authorized {
            return true
        } else {
            return false
        }
    }
    
    func checkNetworkForLoadSetting() -> Bool {
        // check network
        if !Utilities.checkNetworkReachabiliy() {
            self.customWebView?.loadLocalHtmlWithViewType(viewType: .StartupWebView, isConnected: false)
            
            if navigationController?.viewControllers.last is PreviewViewController {
                let preView = navigationController?.viewControllers.last
                //PopupUltilites.showLoading(inView: (preView?.view)!)
                MBProgressHUD.showAdded(to: (preView?.view)!, animated: true)
            } else {
                PopupUltilites.showLoading(inView: self.view)
            }
            
            let deadlineTime = DispatchTime.now() + .milliseconds(600)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                if self.navigationController?.viewControllers.last is PreviewViewController {
                    let preView = self.navigationController?.viewControllers.last
                    MBProgressHUD.hide(for: (preView?.view)!, animated: false)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: false)
                }
            })
            return false
        }
        return true
    }
    
    func checkAllServiceEnabled() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var captureFlag = false
            var assetFlag = false
            let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            if authStatus == .notDetermined || authStatus == .authorized {
                captureFlag = true
            }
            
            assetFlag = checkPhotoServiceEnabled()
            
            if captureFlag == true && assetFlag == true {
                return true
            } else if captureFlag == false && assetFlag == true {
                showPrivacySettingsWarning("AVCaptureAccessDisable".localized)
                return false
            } else if captureFlag == true && assetFlag == false {
                showPrivacySettingsWarning("PhotoAccessDisable".localized)
                return false
            } else {
                showPrivacySettingsWarning("PhotoAndAVCaptureAccessDisable".localized)
                return false
            }
        } else {
            return false
        }
    }
    
    func takePhotoButtonTapped() {
        if !checkAllServiceEnabled() {
            return
        }
        
        showCamera()
    }
    
    func showPrivacySettingsWarning(_ message: String) {
        showPrivacySettings = true
        PopupUltilites.showPopup(title: "", message: message, titleCancelButton: "Settings".localized, titleOkButton: "OK".localized, viewContain: self, okAction: {
            self.dismiss(animated: false, completion: nil)
            self.showPrivacySettings = false
            }, cancelAction: {
                self.showPrivacySettings = false
                self.showApplicationSettings()
        })
    }
    
    func showCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        imagePicker.allowsEditing = false
        imagePicker.view.layoutIfNeeded()
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showApplicationSettings() {
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            switch status{
            case .notDetermined:
                DispatchQueue.main.async {
                    picker.dismiss(animated: false, completion: {
                    })
                }
            case .denied, .restricted, .authorized:
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            dismiss(animated: true, completion: {
                let message = String.init(format: "ImageSavedError".localized, error.code)
                PopupUltilites.showPopup(title: "", message: message, titleCancelButton: "", titleOkButton: "OK".localized, viewContain: self, okAction: {
                    
                }, cancelAction: {
                })
            })
        } else {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let previewVC = sb.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.preview) as! PreviewViewController
            previewVC.delegate = self
            previewVC.delegateFinishUpload = self
            previewVC.delegateBecomeActiveWithEmptyAsset = self
            previewVC.wasTakePicture = true
            previewVC.openFromCamera = true
            
            navigationController?.pushViewController(previewVC, animated: true)
            dismiss(animated: false, completion: nil)
        }
    }
    
    func photoLibraryButtonTapped() {
        if !checkPhotoServiceEnabled() {
            self.showPrivacySettingsWarning("PhotoAccessDisable".localized)
            return
        }
        
//        callApiGetSetting()
        pickerController = QBImagePickerController()
        pickerController.selectedAssets = selectedAsset
        self.showQBImagePicker(mediaType: QBImagePickerMediaType.image, allowMultiSelect: true)
    }
    
    func helpButtonTapped() {
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let helpViewController = mainStoryBoard.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.help)
        navigationController?.pushViewController(helpViewController, animated: true)
        
    }
    
    func showQBImagePicker(mediaType: QBImagePickerMediaType, allowMultiSelect: Bool) {
        pickerController.mediaType = mediaType
        pickerController.allowsMultipleSelection = allowMultiSelect
        pickerController.allowsImageSelectMultipleTimes = true
        pickerController.showsNumberOfSelectedAssets = true
        pickerController.includeMoments = true
        pickerController.delegate = self
        pickerController.assetCollectionSubtypes = [PHAssetCollectionSubtype.smartAlbumUserLibrary.rawValue,
                                                    PHAssetCollectionSubtype.albumMyPhotoStream.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumPanoramas.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumBursts.rawValue,
                                                    PHAssetCollectionSubtype.albumImported.rawValue,
                                                    PHAssetCollectionSubtype.albumSyncedAlbum.rawValue,
                                                    PHAssetCollectionSubtype.albumRegular.rawValue,
                                                    PHAssetCollectionSubtype.albumSyncedEvent.rawValue,
                                                    PHAssetCollectionSubtype.albumSyncedFaces.rawValue,
                                                    PHAssetCollectionSubtype.albumCloudShared.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumFavorites.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumAllHidden.rawValue,
                                                    //PHAssetCollectionSubtype.smartAlbumRecentlyAdded.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumSelfPortraits.rawValue,
                                                    PHAssetCollectionSubtype.smartAlbumScreenshots.rawValue]
        
        self.present(pickerController, animated: true, completion: nil)
    }
}

//MARK: private function
extension HomeViewController {
    
    func checkResultSetting(beginDate: String, endDate: String, numberImg: Int) {
        if beginDate == "" {
            AppSetting.sharedInstance.startDateTime = nil
        } else {
            let dateBegin = DateFormatter().dateFromString(beginDate, timeZone: TimeZone(abbreviation: "GMT")!, format: "yyyyMMddHHmmss")
            AppSetting.sharedInstance.startDateTime = dateBegin
        }
        if endDate == "" {
            AppSetting.sharedInstance.endDateTime = nil
        } else {
            let dateEnd = DateFormatter().dateFromString(endDate, timeZone: TimeZone(abbreviation: "GMT")!, format: "yyyyMMddHHmmss")
            AppSetting.sharedInstance.endDateTime = dateEnd
        }
        if numberImg == 0 {
            AppSetting.sharedInstance.maxImageSending = defaultMaxImageSending
        } else {
            AppSetting.sharedInstance.maxImageSending = numberImg
        }
        
    }
    
    func checkExifInformation(asset :PHAsset) -> (isValidate: Bool, error: Int) {
        if AppSetting.sharedInstance.getEndDateTime() == nil && AppSetting.sharedInstance.getStartDateTime() == nil {
            return (true, 0)
        }
        
        if AppSetting.sharedInstance.getEndDateTime() == nil {
            if asset.creationDate == nil {
                if asset.modificationDate == nil {
                    return (false, 500)
                } else if (asset.modificationDate?.isGreaterThanDate(dateToCompare: AppSetting.sharedInstance.getStartDateTime()!))!
                    
                {
                    return (true, 0)
                }
            } else {
                if (asset.creationDate?.isGreaterThanDate(dateToCompare: AppSetting.sharedInstance.getStartDateTime()!))!
                {
                    return (true, 0)
                }
            }
        }
        
        if AppSetting.sharedInstance.getStartDateTime() == nil {
            if asset.creationDate == nil {
                if asset.modificationDate == nil {
                    return (false, 501)
                } else if (asset.modificationDate?.isLessThanDate(dateToCompare: AppSetting.sharedInstance.getEndDateTime()!))!
                {
                    return (true, 0)
                }
            } else {
                if (asset.creationDate?.isLessThanDate(dateToCompare: AppSetting.sharedInstance.getEndDateTime()!))!
                {
                    return (true, 0)
                }
            }
        }
        if asset.creationDate == nil {
            if asset.modificationDate == nil {
                return (false, 500)
            } else if (asset.modificationDate?.isGreaterThanDate(dateToCompare: AppSetting.sharedInstance.getStartDateTime()!))!
                && (asset.modificationDate?.isLessThanDate(dateToCompare: AppSetting.sharedInstance.getEndDateTime()!))!
            {
                return (true, 0)
            }
        } else {
            if (asset.creationDate?.isGreaterThanDate(dateToCompare: AppSetting.sharedInstance.getStartDateTime()!))!
                && (asset.creationDate?.isLessThanDate(dateToCompare: AppSetting.sharedInstance.getEndDateTime()!))!
            {
                return (true, 0)
            }
        }
        return (false, 501)
    }
    
    
    func showPreviewImageWithAssets(assets: [PHAsset]) {
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        
        let previewController = sb.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.preview) as! PreviewViewController
        previewController.assets = assets
        previewController.delegate = self
        previewController.delegateFinishUpload = self
        previewController.delegateBecomeActiveWithEmptyAsset = self
        navigationController?.pushViewController(previewController, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func handleCellTapAction(index: Int) {
        if index == 0 {
            takePhotoButtonTapped()
        } else if index == 1 {
            photoLibraryButtonTapped()
        } else {
            helpButtonTapped()
        }
    }
    
    func setAppsetingToDefault() {
        AppSetting.sharedInstance.startDateTime = nil
        AppSetting.sharedInstance.endDateTime = nil
        AppSetting.sharedInstance.maxImageSending = defaultMaxImageSending
    }
    
}

//MARK: API Delegate
extension HomeViewController{
    func callApiGetSetting(completion: @escaping (_ error: Error?)-> Void) {
        
        // check network
        if Utilities.checkNetworkReachabiliy() {
            
            self.apiGetSettingInfo.getSettingInfo(completion: { (beginDate: String, endDate: String, numberImg: Int, error: Error?) in
                //check error response
                if error == nil {
                    self.checkResultSetting(beginDate: beginDate, endDate: endDate, numberImg: numberImg)
                    completion(nil)
                } else {
                    self.setAppsetingToDefault() // max selected image = 1, start and end date = nil
                    let err = NSError(domain: "", code: 69, userInfo: [:])
                    completion(err)
                }
            })
        } else {
            
            setAppsetingToDefault() // max selected image = 1, start and end date = nil
            let err = NSError(domain: "", code: 69, userInfo: [:])
            completion(err)
            
        }
    }
    
    func callApiToCheckConnection(completion: @escaping (_ error: Error?)-> Void) {
        // check network
        if Utilities.checkNetworkReachabiliy() {
            
            self.apiGetSettingInfo.getSettingInfo(completion: { (beginDate: String, endDate: String, numberImg: Int, error: Error?) in
                //check error response
                if error == nil {
                    completion(nil)
                } else {
                    let err = NSError(domain: "", code: 69, userInfo: [:])
                    completion(err)
                }
            })
        } else {

            let err = NSError(domain: "", code: 69, userInfo: [:])
            completion(err)
            
        }
    }
}

extension HomeViewController: QBImagePickerControllerDelegate {
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, asset: PHAsset!, completion: CheckShouldSelectResultHandler!) {
        //check number image
        let isValid = checkNumberSelectedImage(imagePickerController: imagePickerController, asset: asset)
        if isValid {
            
            let option = PHImageRequestOptions()
            option.isNetworkAccessAllowed = true
            
            MBProgressHUD.showAdded(to: imagePickerController.view, animated: true)
            PHImageManager.default().requestImageData(for: asset, options: option) { (data, string, orientation, object) in
                MBProgressHUD.hide(for: imagePickerController.view, animated: true)
                guard let data = data else {
                    //if data is nil, display message
                    PopupUltilites.showPopup(title: LocalizationKey.CannotDownloadPhotoTitle.localized, message: LocalizationKey.CannotDownloadPhotoMessage.localized, titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                    completion(false)
                    return
                }
                
                let sizeInMB = Double(data.count) / 1024 / 1024
                let maxImageSize = AppSetting.sharedInstance.getMaxImageSize()
                if sizeInMB > maxImageSize {
                    PopupUltilites.showPopup(title: "", message: String(format: "MaxImageSizeWarning".localized , Int(maxImageSize)) , titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                    completion(false)
                } else {
                    //PopupUltilites.showLoading(inView: imagePickerController.view)
                    MBProgressHUD.showAdded(to: imagePickerController.view, animated: true)
                    self.callApiToCheckConnection { (error: Error?) in
                        
                        MBProgressHUD.hide(for: imagePickerController.view, animated: true)
                        
                        
                        if error != nil {
                            print("error != nil")
                            completion(true)
                            
                        } else {
                            
                            print("([] selected: \(imagePickerController.selectedAssets.count)")
                            print("creation date: \(asset.creationDate)")
                            print("modification date: \(asset.modificationDate)")
                            
                            if AppSetting.sharedInstance.endDateTime == nil &&
                                AppSetting.sharedInstance.startDateTime == nil &&
                                AppSetting.sharedInstance.maxImageSending == defaultMaxImageSending
                            {
                                //default selected image = 1
                                if imagePickerController.selectedAssets.count == 0 {
                                    self.defaultSelectImage = true
                                } else {
                                    PopupUltilites.showPopup(title: "", message: String(format: "MaxImageSelectWarning".localized , AppSetting.sharedInstance.maxImageSending) , titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                                return
                            }
                            
                            if AppSetting.sharedInstance.maxImageSending == defaultMaxImageSending {
                                self.defaultSelectImage = true
                            }
                            
                            let checkExifInfo = self.checkExifInformation(asset: asset)
                            let overSelectedImage = imagePickerController.selectedAssets.count >= AppSetting.sharedInstance.getMaxImageSending()!
                            
                            if overSelectedImage {
                                PopupUltilites.showPopup(title: "", message: String(format: "MaxImageSelectWarning".localized , AppSetting.sharedInstance.maxImageSending), titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                                completion(false)
                                return
                            }
                            
                            if !checkExifInfo.isValidate {
                                if checkExifInfo.error == 500 {
                                    PopupUltilites.showPopup(title: "", message: "ImageCreationDateUnknown".localized, titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                                    
                                } else if checkExifInfo.error == 501 {
                                    let format = "SendingPeriodDateFormat".localized + " " + "SendingPeriodTimeFormat".localized
                                    let dateBeginFormat = AppSetting.sharedInstance.startDateTime?.gmtStringWithFormat(format)
                                    let dateEndFormat = AppSetting.sharedInstance.endDateTime?.gmtStringWithFormat(format)
                                    PopupUltilites.showPopup(title: "",
                                                             message: String(format: "ImageSendingPeriodError".localized , dateBeginFormat!, dateEndFormat!),
                                                             titleCancelButton: "",
                                                             titleOkButton: "OK".localized,
                                                             viewContain: imagePickerController,
                                                             okAction: {},
                                                             cancelAction: {})
                                }
                                
                                completion(false)
                                return
                            }
                            completion(checkExifInfo.isValidate)
                        }
                    }
                }
                
            }
        } else {
            completion(false)
        }

    }

    func checkNumberSelectedImage(imagePickerController: QBImagePickerController, asset: PHAsset!) -> Bool {
        print("error != nil")
        if AppSetting.sharedInstance.maxImageSending == defaultMaxImageSending {
            //default selected image = 1
            if imagePickerController.selectedAssets.count == 0 {
                self.defaultSelectImage = true
            } else {
                PopupUltilites.showPopup(title: "", message: String(format: "MaxImageSelectWarning".localized , AppSetting.sharedInstance.maxImageSending) , titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
                return false
            }
            return true
        }
        if AppSetting.sharedInstance.maxImageSending == defaultMaxImageSending {
            self.defaultSelectImage = true
        }
        let overSelectedImage = imagePickerController.selectedAssets.count >= AppSetting.sharedInstance.getMaxImageSending()!
        if overSelectedImage {
            PopupUltilites.showPopup(title: "", message: String(format: "MaxImageSelectWarning".localized , AppSetting.sharedInstance.maxImageSending), titleCancelButton: "", titleOkButton: "OK".localized, viewContain: imagePickerController, okAction: {}, cancelAction: {})
            return false
        }
        return true
    }
//    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, shouldSelect asset: PHAsset!) -> Bool {
//        print("useless delegate")
//       return false
//    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
        if defaultSelectImage {
            defaultSelectImage = false
            showPreviewImageWithAssets(assets: [asset])
        }
        print("Did selected asset")
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        print("Select success")
        showPreviewImageWithAssets(assets: assets as! [PHAsset])
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        print("Cancel select")
        self.selectedAsset = imagePickerController.selectedAssets
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: Preview controller delegate

extension HomeViewController: PreviewViewControllerDelegate, PreViewControllerFinishUpLoadDelegate, PreViewControllerDidBecomeActiveDelegate {
    
    func didSelectAlbumFromHomeController(previewController: PreviewViewController, didDeleteAssets atIndexArray: [PHAsset]) {
        if pickerController.selectedAssets.count != 0 {
            let arr = NSMutableArray()
            arr.addObjects(from: atIndexArray)
            pickerController.selectedAssets.removeAllObjects()
            pickerController.selectedAssets = arr
            print("count ---------------- \(pickerController.selectedAssets.count)")
        }
        if !previewController.finishSend {
            
            if previewController.isBackEvent {//back event
                showQBImagePicker(mediaType: QBImagePickerMediaType.image, allowMultiSelect: true)
            } else { //hidden event
                //
            }
        }
    }
    
    func didTakePictureFromHomeController(previewController: PreviewViewController) {
        if !previewController.finishSend {
           viewCusscessfulyMessage.isHidden = true
        }
    }
    
    func preViewControllerHaveFinishedUploading(viewController: PreviewViewController) {
        viewCusscessfulyMessage.isHidden = false
        _ = navigationController?.popViewController(animated: false)
        isLoadingThaksful = true
        unowned let unownedSelf = self
        let deadlineTime = DispatchTime.now() + .seconds(timeThatThankYouAppear)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.viewCusscessfulyMessage.isHidden = true
        })
    }
    
    func preViewControllerDidBecomeActiveWithEmptyAsset(viewController: PreviewViewController) {
        dismissFromPreviewPhoto = true
        _ = navigationController?.popViewController(animated: false)
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Int(menuTableView.frame.size.height/3))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        menuTableView.deselectRow(at: indexPath, animated: false)
        handleCellTapAction(index: indexPath.row)
    }
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = menuArrayText[row]
        cell.imageView?.image = UIImage(named: menuArrayImage[row])
        cell.imageView?.contentMode = .scaleAspectFit
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}





