//
//  PreViewViewController.swift
//  PartyPrint
//
//  Created by Nguyen Thanh Thuc on 14/10/2016.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import Foundation
import MBProgressHUD

protocol PreviewViewControllerDelegate: class {
    func didSelectAlbumFromHomeController(previewController: PreviewViewController, didDeleteAssets atIndexArray: [PHAsset])
    func didTakePictureFromHomeController(previewController: PreviewViewController)
}

protocol PreviewControllerUploadDelegate: class {
    func preViewControllerUploadFinish(viewController: PreviewViewController)
}

protocol PreViewControllerFinishUpLoadDelegate: class {
    func preViewControllerHaveFinishedUploading(viewController: PreviewViewController)
}

protocol PreViewControllerDidBecomeActiveDelegate: class {
    func preViewControllerDidBecomeActiveWithEmptyAsset(viewController: PreviewViewController)
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class PreviewViewController: UIViewController {
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var lbTitle: UILabel!
    var openFromCamera = false
    
    struct IndexPathResource {
        var currentIndexPath: IndexPath!
        var lastIndexPathAnimated: IndexPath!
        var deletedAssetIndexPathArray: [PHAsset] = []
    }
    
    struct TransformCellValue {
        var wasTransformed = false
        let transformToBefore = CGAffineTransform(scaleX: 1, y: 1)
        let transformToCurrent = CGAffineTransform(scaleX: 1.4, y: 1)
        var isFirstTransform: [Int: Bool] = [:]
    }
    
    struct SizeForItemCollectionView {
        var widthSmall: CGFloat!
        var heightSmall: CGFloat!
        var spacingSmallItem: CGFloat!
        var spacingMainItem: CGFloat!
        
    }
    
    struct LocalizationKey {
        static let FotolusioSystemConnection = "FotolusioSystemConnection"
        static let SendImages = "SendImages"
        static let SelectedImageExists = "SelectedImageExists"
        static let PhotolusioDeviceNotReachable = "PhotolusioDeviceNotReachable"
        static let ConnectionError = "ConnectionError"
        static let Menu = "Menu"
    }
    
    weak var delegate: PreviewViewControllerDelegate?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var smallCollectionView: UICollectionView!
    
    let imageManager = PHCachingImageManager() // for small collection view
    let imageManagerMain = PHCachingImageManager() // for main collectionview
    fileprivate var previousPreheatRect = CGRect.zero
    var indexPathResource: IndexPathResource!
    var sizeForItem: SizeForItemCollectionView!
    var transformCellValue: TransformCellValue!
    
    var assets: [PHAsset] = []
    var wasTakePicture = false
    var finishSend = false //when all of the selected image have uploaded
    
    var fetchResult: PHFetchResult<PHAsset>!
    var apiRequest = APIRequest()
    
    var popupViewController: PopupProcessViewController?

    weak var delegateUpload: PreviewControllerUploadDelegate?
    weak var delegateFinishUpload: PreViewControllerFinishUpLoadDelegate?
    weak var delegateBecomeActiveWithEmptyAsset: PreViewControllerDidBecomeActiveDelegate?
    
    var flagCancel = false //cancel process upload image
    var loadWifiNameTimer: Timer!
    
    var isBackEvent = false

    var isDecelerating = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if wasTakePicture == true {
            let option = PHFetchOptions()
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let lastAsset = PHAsset.fetchAssets(with: .image, options: PHFetchOptions()).lastObject
            assets.append(lastAsset!)
        }
        
        //exclusive multi touch
        setExclusiveButton()
        
        //localized
        setTextForAllSubView()
        
        indexPathResource = IndexPathResource(currentIndexPath: IndexPath(row: 0, section: 0), lastIndexPathAnimated: IndexPath(row: 0, section: 0), deletedAssetIndexPathArray: [])
        sizeForItem = SizeForItemCollectionView(widthSmall: 60, heightSmall: 60, spacingSmallItem: 15, spacingMainItem: 0)
        transformCellValue = TransformCellValue(wasTransformed: false, isFirstTransform: [0 : false])
        initCollectionView()
        apiRequest.delegate = self
        
        configNavigationBar()
        setUpNotificationCenter()
        
        
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "10.0") {
            if #available(iOS 10.0, *) {
                mainCollectionView.isPrefetchingEnabled = false
            }
        }
        
    }
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
                                                              options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
    }
    
    //for hidden app event
    override func viewDidDisappear(_ animated: Bool) {
        
        //If not take picture, do not show view picker controller
        if !wasTakePicture {
            delegate?.didSelectAlbumFromHomeController(previewController: self, didDeleteAssets: assets)
        } else {
            delegate?.didTakePictureFromHomeController(previewController: self)
        }
        self.loadWifiNameTimer.invalidate()
    }

    
    deinit {
        print("deinit Preview screen")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constant.Notification.applicationDidBecomeActive), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadWifiNameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.loadWifiName), userInfo: nil, repeats: true)
        reloadCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let currentIndex = indexPathResource.currentIndexPath.row
        let currentPoint = CGPoint(x: size.width * CGFloat(currentIndex), y: 0)
        smallCollectionView.reloadData()
        print("view will transition")
        DispatchQueue.main.async {
            if !self.isDecelerating {
                self.mainCollectionView.setContentOffset(currentPoint, animated: false)
            }
        
            self.updateCollectionViewLayout(with: size)
            
        }

    }
    
    
    func updateCollectionViewLayout(with size: CGSize) {
        if let layout = mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSizeForPortraitMode = CGSize(width: size.width, height: mainCollectionView.frame.size.height)
//            layout.itemSize = (size.width < size.height) ? itemSizeForPortraitMode : itemSizeForLandscapeMode
            layout.itemSize = itemSizeForPortraitMode
            layout.invalidateLayout()
        }
    }
    
    
    //MARK: Notification center
    func setUpNotificationCenter() {
        //noti when app did enter forceground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil)
        
        // app did become active
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name(rawValue: Constant.Notification.applicationDidBecomeActive), object: nil)
    }
    
    func setTextForAllSubView() {
        //set wifi name:
        loadWifiName()
        updateTotalSelectedLabel()
        sendButton.setTitle(LocalizationKey.SendImages.localized, for: .normal)
        btnBack.setTitle(LocalizationKey.Menu.localized, for: .normal)
    }
    
    //handle multi touch every button in preview controller
    func setExclusiveButton() {
        sendButton.isExclusiveTouch = true
        buttonDelete.isExclusiveTouch = true
        btnBack.isExclusiveTouch = true
    }
    
    func updateTotalSelectedLabel() {
        let totalSelectedString = LocalizationKey.SelectedImageExists.localized
        totalLabel.text = String(format: totalSelectedString, assets.count)
    }
    
    //MARK: APP LIFE CYCLE
    
    func appDidEnterBackground() {
        flagCancel = true
        sendButton.isEnabled = false
    }
    
    func appDidBecomeActive() {
        if assets.isEmpty {
            print("[Asset] : empty!")
            delegateBecomeActiveWithEmptyAsset?.preViewControllerDidBecomeActiveWithEmptyAsset(viewController: self)
        }
    }
    
    func enableSendButton() {
        sendButton.isEnabled = true
    }
    
    func initCollectionView() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        smallCollectionView.delegate = self
        smallCollectionView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
//MARK:  delete selected image
    func didTapDeleteImageButton() {
        if !assets.isEmpty {
            mainCollectionView.alpha = 0
            
            var newIndex = IndexPath(row: 0, section: 0)
            let currentRow = indexPathResource.currentIndexPath.row
            let totalRow = smallCollectionView.numberOfItems(inSection: 0)
            
            indexPathResource!.deletedAssetIndexPathArray.append(assets[currentRow])
            assets.remove(at: (indexPathResource?.currentIndexPath.row)!)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionFlipFromTop, animations: {
                self.mainCollectionView.alpha = 1
            }, completion: nil)
            
            
            if assets.count == 0 {
                //reset indexpath after remove last item
                indexPathResource.currentIndexPath = newIndex
                indexPathResource.lastIndexPathAnimated = newIndex
                
            } else if totalRow > 0 && currentRow == totalRow - 1 {
                
               newIndex =  IndexPath(row: currentRow - 1, section: 0)
            } else {
                
              newIndex = IndexPath(row: currentRow , section: 0)
            }
            
            print("new index \(newIndex)")
            indexPathResource.lastIndexPathAnimated = IndexPath(row: 0 , section: 0)
            indexPathResource.currentIndexPath = newIndex
            
            reloadCollectionView()
            
//            if newIndex.row != 0 {
//              smallCollectionView.scrollToItem(at: indexPathResource.currentIndexPath, at: .centeredVertically, animated: true)
//            }
            
            //update cache image
            self.updateCachedAssets(collectionView: self.smallCollectionView, targetSize: self.targetSizeSmallCollectionView)
            self.updateCachedAssets(collectionView: self.mainCollectionView, targetSize: self.targetSizeMainCollectionView)
            
            updateTotalSelectedLabel()
        }
        
    }
    
    func loadWifiName() {
        let format = LocalizationKey.FotolusioSystemConnection.localized
        let reachability = FTLNetowrkReachability.defaultsReachability() as! FTLNetowrkReachability
        let wifiName = reachability.ssidForFotolusioSystem() ?? "NOTCONFIGURED".localized
        
        let title = String.init(format: format, wifiName)
        
        lbTitle.text = title
    }
    
    func configNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDeleteImageButton))
    }
    
    
    @IBAction func backToHome(_ sender: AnyObject) {
        isBackEvent = true
        let homeView = navigationController?.viewControllers[0] as! HomeViewController
        if openFromCamera {
            homeView.selectedAsset = []
        }
        delegateBecomeActiveWithEmptyAsset?.preViewControllerDidBecomeActiveWithEmptyAsset(viewController: self)
//        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteItem(_ sender: AnyObject) {
        didTapDeleteImageButton()
    }
    
    @IBAction func sentButton(_ sender: UIButton) {
        flagCancel = false
        if assets.count > 0 {
            //PopupUltilites.showLoading(inView: self.view)
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let recha = FTLNetowrkReachability()
            let isConnected = recha.isWiFiAccessPointReacheable()
            
            let url = WebViewHelper.getUrlToLoadHtml(withHtmlType: .AgreementWebView)
            
            if isConnected {
                WebViewHelper.requestHtml(withHtmlType: .AgreementWebView, currentUrl: url, completion: { (resultRequestHtml, changedUrl, error) in
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    if error == nil {
                        if resultRequestHtml == .existHtml {
                            self.showAgreementAlert()
                        } else {
                            DispatchQueue.main.async {
                                self.uploadPhoto()
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            PopupUltilites.showPopup(title: "", message: LocalizationKey.PhotolusioDeviceNotReachable.localized, titleCancelButton: "", titleOkButton: Constant.CommonLocalizationKey.Ok.localized, viewContain: self, okAction: {}, cancelAction: {})
                        }
                    }
                })
                
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
                PopupUltilites.showPopup(title: "", message: LocalizationKey.PhotolusioDeviceNotReachable.localized, titleCancelButton: "", titleOkButton: Constant.CommonLocalizationKey.Ok.localized, viewContain: self, okAction: {}, cancelAction: {})
            }
            
            
        }
    }
    
    func showAgreementAlert() {
        let sb = Constant.StoryBoard.main
        let agreementVC = sb.instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.agreementController) as! AgreementViewController
        agreementVC.delegate = self
        agreementVC.modalPresentationStyle = .overCurrentContext
        DispatchQueue.main.async {
            
            self.present(agreementVC, animated: false, completion: nil)
        }
    
    }
    
    func uploadPhoto() {
        //to do: calcu progress
        showPopupProcess(animation: false)
        print("--------------------UPLOADING------------------------")
        //
        //getSetting()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        uploadingImage()
    }
    
    var targetSizeSmallCollectionView: CGSize {
        
        let scale = UIScreen.main.scale
        let cellSize = (smallCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        return thumbnailSize
    }
    
    var targetSizeMainCollectionView: CGSize {
        let scale = UIScreen.main.scale
        let cellSize = (mainCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)

        return thumbnailSize
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        imageManagerMain.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets(collectionView: UICollectionView, targetSize: CGSize) {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets[indexPath.item] }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in assets[indexPath.item] }
        
        // Update the assets the PHCachingImageManager is caching.
        
        var imgManager = imageManager
        if (collectionView == mainCollectionView) {
            imgManager = imageManagerMain
        }
        imgManager.startCachingImages(for: addedAssets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
        imgManager.stopCachingImages(for: removedAssets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

extension PreviewViewController: AgreementViewControllerDelegate {
    func agreementViewController(agreementViewController: AgreementViewController) {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            self.uploadPhoto()
        }
    }
    
    func cancelAgreementViewController(agreementViewController: AgreementViewController) {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.smallCollectionView {
            return CGSize(width: smallCollectionView.frame.size.height, height: smallCollectionView.frame.size.height)
        } else {
            return CGSize(width: mainCollectionView.frame.size.width, height: mainCollectionView.frame.size.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.smallCollectionView {
            return sizeForItem.spacingSmallItem
        } else {
            return sizeForItem.spacingMainItem
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.smallCollectionView {
            return UIEdgeInsets(top: 0, left: view.bounds.width/2 - smallCollectionView.frame.size.height/2, bottom: 0, right: view.bounds.width/2 - smallCollectionView.frame.size.height/2)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    
    
}

extension PreviewViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.smallCollectionView {
            
            if indexPath != indexPathResource.currentIndexPath {
                //update last index path
                indexPathResource.lastIndexPathAnimated = indexPathResource.currentIndexPath
                
                //get indexPath main cell
                indexPathResource?.currentIndexPath = indexPath
                
                //scroll to center
                mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                smallCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.buttonDelete.isEnabled = true
                }
                reloadCellSelected()
  
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        if scrollView == self.mainCollectionView {
            isDecelerating = true
            buttonDelete.isEnabled = false
        }        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         if scrollView == self.mainCollectionView {
            isDecelerating = false
            updateCurrentAndLastIndexPath()
        
            //prevent free test
           enableButtonDelete()
         }
    }
    
    ///Cache
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == smallCollectionView {
            updateCachedAssets(collectionView: smallCollectionView, targetSize: targetSizeSmallCollectionView)
        } else {
            updateCachedAssets(collectionView: mainCollectionView, targetSize: targetSizeMainCollectionView)
        }
    }
    
    func enableButtonDelete() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.buttonDelete.isEnabled = true
        }
    }
    
    func updateCurrentAndLastIndexPath() {

        let currentRow = Int(mainCollectionView.contentOffset.x / mainCollectionView.frame.size.width)
        //reloadPreviousCell(indexPath: IndexPath(row: currentRow, section: 0))
        
        if !assets.isEmpty && currentRow != indexPathResource.currentIndexPath.row {
            let newIndex = IndexPath(row: currentRow, section: 0)
            
            indexPathResource?.lastIndexPathAnimated = indexPathResource?.currentIndexPath
            indexPathResource?.currentIndexPath = newIndex
            smallCollectionView.scrollToItem(at: newIndex, at: .centeredHorizontally, animated: true)
            
            reloadCellSelected()
        }

    }
    
    func reloadCellSelected() {
        print("current index Path: \(indexPathResource.currentIndexPath)")
        print("last index Path: \(indexPathResource.lastIndexPathAnimated)")
        smallCollectionView.reloadItems(at: [indexPathResource.currentIndexPath,indexPathResource.lastIndexPathAnimated])
        let currentPoint = CGPoint(x: mainCollectionView.frame.size.width * CGFloat(indexPathResource.currentIndexPath.row), y: 0)
        
        mainCollectionView.setContentOffset(currentPoint, animated: false)
    
    }
}

extension PreviewViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assets.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == smallCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SmallCollectionViewCell
            let asset = assets[indexPath.row]
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
            option.deliveryMode = .highQualityFormat
            
            imageManager.requestImage(for: asset, targetSize: targetSizeSmallCollectionView, contentMode: .aspectFill, options: option, resultHandler: { (image, info) in
                cell.photo.image = image
            })
            
            if indexPathResource.currentIndexPath == indexPath {
                cell.selectedCell(select: true)
            } else {
                cell.selectedCell(select: false)
            }
        
            return cell
            
        } else {
            
            //get indexPath main cell
            
            //indexPathResource.lastIndexPathAnimated = indexPathResource.currentIndexPath

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! MainCollectionViewCell
            let asset = assets[indexPath.row]
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
            
            imageManagerMain.requestImage(for: asset, targetSize: targetSizeMainCollectionView, contentMode: .aspectFit, options: option, resultHandler: { (image, info) in
                //cell.mainPhoto.image = image
                cell.updateLayoutForMainCell(image: image!)
            })
            
           
            cell.myScrollView.setZoomScale(1, animated: false)
            return cell
        }
    }
}

//MARK: PRIVATE FUNCTIOn
extension PreviewViewController {
    func uploadingImage() {
        if assets.count == 0 {
            print("[Asset] : empty!")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                // your code here
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dismiss(animated: false, completion: nil)
                self.popupViewController?.preViewController = nil
                self.popupViewController = nil;
                self.delegateFinishUpload?.preViewControllerHaveFinishedUploading(viewController: self)
                print("fisnihhhh-----------------")
            }
            UIApplication.shared.isIdleTimerDisabled = false
            return
        }
        
        if flagCancel {
            print("process upload was canceled...!")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            UIApplication.shared.isIdleTimerDisabled = false
            
            flagCancel = false
            return
        }
    
        let image = UploadImageHelper.getAssetThumbnail(asset: (assets[0]))
        let data = image.image.dss_UIImageJPEGRepresentation(compressionQuality: 1.0, exifInfo: image.dict as NSDictionary)
        let dataEnCrypt = SecurityHelper.encryptData(data)

        let authId = FTLAuthenticationInfo.sharedInstance().getHashedAuthenticationInfo()
        apiRequest.uploadImage(cryptoMode: SERVER_REQUEST_KEY_NAME_CRYPT_MODE_VALUE, authId: authId!, dataImage: dataEnCrypt!)
    }
    
    func showPopupProcess(animation: Bool){
        popupViewController = PopupUltilites.initPopUp(identifier: "PopupProcessViewController") as? PopupProcessViewController
        popupViewController?.delegate = self
        popupViewController?.preViewController = self
        popupViewController?.totalImages = Float(assets.count)
        popupViewController?.modalPresentationStyle = .overCurrentContext
        present(popupViewController!, animated: animation, completion: nil)
    }
    
    func reloadCollectionView() {
        
        mainCollectionView.reloadData()
        smallCollectionView.reloadData()
        
        
    }

}

//MARK: API delegate
extension PreviewViewController: APIRequestDelegate {
    func uploadImageDidFinish(status: statusUpLoad, error: NSError?) {
        if status == .success {
            print("Upload image success")
            
            let indexPath = IndexPath(row: 0, section: 0)
            
            //update current indexpath in case the index = last
            if assets.count > 0 && indexPathResource.currentIndexPath.row == assets.count - 1 {
                indexPathResource.currentIndexPath = IndexPath(row: assets.count - 2, section: 0)
            }
            
            indexPathResource!.deletedAssetIndexPathArray.append(assets[indexPath.row])
            assets.removeFirst()
            
            updateTotalSelectedLabel()
            reloadCollectionView()
            
            delegateUpload?.preViewControllerUploadFinish(viewController: self)
            
            if assets.count == 0 {
                finishSend = true
            }
            
            //continuous upload
            uploadingImage()
        } else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dismiss(animated: false, completion: {
                    PopupUltilites.showPopup(title: "", message: String(format: LocalizationKey.ConnectionError.localized , error!.code),
                                             titleCancelButton: "", titleOkButton: Constant.CommonLocalizationKey.Ok.localized, viewContain: self, okAction: {}, cancelAction: {})
                    print("Upload image fail with error code \(error?.code)")
                })
            }
            
            self.popupViewController?.preViewController = nil
            self.popupViewController = nil;
        }
    }
}


//MARK: popup process DELEGATE
extension PreviewViewController: PopupProcessViewControllerDelegate{
    func cancelProgress(viewController: PopupProcessViewController) {
        dismiss(animated: false, completion: nil)
        //PopupUltilites.showLoading(inView: self.view)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        viewController.preViewController = nil
        
        print("Did tap cancel upload button.")
        
        if assets.count > 0 {
            flagCancel = true
        }
        
    }
}

