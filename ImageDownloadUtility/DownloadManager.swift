//
//  DownloadManager.swift
//  ImageDownloadUtility
//
//  Created by Devarshi Kulshreshtha on 6/21/15.
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//

import Cocoa

/// Class handling download of an image
class DownloadManager : NSObject, URLSessionDelegate {
    
    // lazily loading
    fileprivate lazy var finalDownloadPath : String? = {
        return UserDefaults.standard.value(forKey: downloadFolderPathKey) as? String
    }()
    
    // lazily configuring default sesssion
    fileprivate lazy var defaultSession : URLSession = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 5
        sessionConfiguration.timeoutIntervalForResource = 30
        sessionConfiguration.timeoutIntervalForRequest = 30
        
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
        }()
    
    
    /// Method used to download an individuale image
    /// - Parameter downloadingFile: managed object representing downloading file
    func download(_ downloadingFile : DownloadingFile) {
        // an awesome link on how to 'Swift Guard' statements : http://ericcerney.com/swift-guard-statement/
        guard let downloadUrlString = downloadingFile.fileUrl , downloadingFile.downloadStatus?.int32Value == DownloadStatus.notStarted.rawValue else {
            return
        }
        
        // convering string to NSURL
        guard let downloadUrl = URL(string: downloadUrlString) else {
            // since string cannot be converted to a valid url object, return
            return
        }
        
        // update status as 'InProgress'
        downloadingFile.downloadStatus = NSNumber(value: DownloadStatus.inProgress.rawValue as Int32)
        
        /*
        // Obtain GUID to be added obatined image path, so that each downloaded image can be uniquely identified
        let uuid = NSUUID().UUIDString
*/
        let sessionDownloadTask = defaultSession.downloadTask(with: downloadUrl) { (obtainedLocation, obtainedResponse, obtainedError) in
            // proceed if image is successfully downloaded to the temp location
            if let downloadedLocation = obtainedLocation?.path , obtainedError == nil {
                // error not found that means download was successful :)
                
                // prepare complete final path for the image
                // let finalCompletePath = self.finalDownloadPath! + "/" + "\(uuid)_" + (downloadUrl.lastPathComponent)!
                let finalCompletePath = self.finalDownloadPath! + "/" + (downloadUrl.lastPathComponent)
                do {
                    // move image from downloaded path to complete final path
                    _ = try FileManager.default.moveItem(atPath: downloadedLocation, toPath: finalCompletePath)
                    
                    // update download status to complete
                    downloadingFile.downloadStatus = NSNumber(value: DownloadStatus.succeeded.rawValue)
                }
                catch {
                    //TODO: handle error
                    // since it is error, update manged object to failed state
                    downloadingFile.downloadStatus = NSNumber(value: DownloadStatus.failed.rawValue)
                }
            }
            else {
                // since it is error, update manged object to failed state
                downloadingFile.downloadStatus = NSNumber(value: DownloadStatus.failed.rawValue)
            }
        }
        
        sessionDownloadTask.resume()
    }
    
}
