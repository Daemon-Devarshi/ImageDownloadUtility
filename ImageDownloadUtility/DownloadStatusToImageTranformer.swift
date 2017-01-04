//
//  DownloadStatusToImageTranformer.swift
//  ImageDownloadUtility
//
//  Created by Devarshi Kulshreshtha on 6/21/15.
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//

import Cocoa

class DownloadStatusToImageTranformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSImage.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        let valueInt = Int32((value as! NSNumber).intValue)
        let downloadStatus = DownloadStatus(rawValue: valueInt)
        return downloadStatus!.image()
    }
}
