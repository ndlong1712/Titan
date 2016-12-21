//
//  UIImageConvert.swift
//  PartyPrint
//
//  Created by LongND9 on 10/25/16.
//  Copyright © 2016 DNP. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {
    func dss_UIImageJPEGRepresentation(compressionQuality: CGFloat, exifInfo: NSDictionary) -> Data {
        let retImageData = NSMutableData()
        let data = UIImageJPEGRepresentation(self, compressionQuality)
        
        let cgImage = CGImageSourceCreateWithData(data as! CFData, nil)
        let dest = CGImageDestinationCreateWithData(retImageData as CFMutableData, CGImageSourceGetType(cgImage!)!, 1, nil)
        let properties = [String(kCGImagePropertyExifDictionary) : exifInfo]
        CGImageDestinationAddImageFromSource(dest!, cgImage!, 0, properties as CFDictionary?)
        CGImageDestinationFinalize(dest!)
        
        return retImageData as Data
    }
    
    func convertImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndPDFContext()
        
        return image!
    }
    
//    func toData() -> Data? {
//        let data = UIImageJPEGRepresentation(self, 1.0)
//        return data
//    }

}
