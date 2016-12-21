//
//  UploadImageHelper.swift
//  PartyPrint
//
//  Created by LongND9 on 10/16/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import DeviceKit

let defaultMaximumPixels: Float = 60000000

class UploadImageHelper: NSObject {
    
    static func getAssetThumbnail(asset: PHAsset) -> (image: UIImage, dict: [AnyHashable : Any]) {
        var dictInfo: [AnyHashable : Any] = [:]
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        
        let device = Device()
        let maximumPixels = maxPiexels(device: device.description)

        var thumbnail = UIImage()
        option.isSynchronous = true
        option.resizeMode = .exact
        
        let originalWidth = Float(asset.pixelWidth)
        let originalHeight = Float(asset.pixelHeight)
        
        let ratio = originalWidth / originalHeight
        let totalPixels = originalWidth * originalHeight
        var size = CGSize()
        
        if totalPixels > maximumPixels {
            size = resizeImageWithRatio(ratio: ratio, maxPixel: maximumPixels)
        } else {
            size = CGSize(width: CGFloat(originalWidth), height: CGFloat(originalHeight))
        }
    
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
            dictInfo = info!
        })
        return (thumbnail, dictInfo)
    }
    
    class func resizeImageWithRatio(ratio: Float, maxPixel: Float) -> CGSize {
        let height = sqrt(maxPixel / ratio)
        let roundHeight = floor(height)
        
        let width = sqrt(maxPixel * ratio)
        let roundWidth = floor(width)
        return CGSize(width: CGFloat(roundWidth), height: CGFloat(roundHeight))
    }
    
    class func maxPiexels(device: String) -> Float {
        if device == "" {
            return defaultMaximumPixels
        }
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
            let configDict = NSDictionary(contentsOfFile: path)
            if let dict = configDict {
                let dictPixels = dict.value(forKey: "MaxNumberOfPixels") as! NSDictionary
                if let val = dictPixels["\(device)"] {
                    return val as! Float
                }
            }
        }
        
        return defaultMaximumPixels
    }
    
    
    static var nowDateString: String?
    static var appendixCounter = 0
    class func getNextFileName() -> String {
        let prevDateString = nowDateString
        
        nowDateString = getDateString()
        var fileName = ""
        
        if nowDateString == prevDateString {
            appendixCounter += 1
            fileName = nowDateString!.appendingFormat("_%02d", appendixCounter)
            
        } else {
            fileName = nowDateString!
            appendixCounter = 0
        }
        //print("file name is: \(fileName)")
        return fileName
    }
    
    class func getDateString() -> String {
        let formatter = DateFormatter()
        let nowDate = Date()
        let nowDateStr = formatter.ftl_string(from: nowDate, timeZone: NSTimeZone.system , format: "YYYY-MM-dd-HH-mm-ss")
        return nowDateStr!
    }
    
}
