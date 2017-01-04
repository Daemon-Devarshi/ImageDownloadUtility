//
//  DownloadingFile.swift
//  ImageDownloadUtility
//
//  Created by Devarshi Kulshreshtha on 6/21/15.
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//

import Cocoa
import CoreData


enum DownloadStatus : Int32 {
    case notStarted, inProgress, succeeded, failed
    
    func image() -> NSImage {
        switch self {
        case .notStarted:
            return NSImage(named: NSImageNameStatusNone)!
        case .inProgress:
            return NSImage(named: NSImageNameStatusPartiallyAvailable)!
        case .succeeded:
            return NSImage(named: NSImageNameStatusAvailable)!
        case .failed:
            return NSImage(named: NSImageNameStatusUnavailable)!
        }
    }
}
// commented below line as resolution of crash issue: Swift + Core Data : Unable to add managed object after generating its subclass in swift (http://stackoverflow.com/questions/30958061/swift-core-data-unable-to-add-managed-object-after-generating-its-subclass-i)
//@objc(DownloadingFile)
class DownloadingFile: NSManagedObject {

}
