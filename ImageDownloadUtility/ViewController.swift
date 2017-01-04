//
//  ViewController.swift
//  ImageDownloadUtility
//
//  Created by Devarshi Kulshreshtha on 6/20/15.
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//

import Cocoa

/// Adding helpful methods to NSArrayController
extension NSArrayController {
    /// Method which can be binded in storyboard to remove all objects from array controller
    @IBAction func removeAllObjects(_ sender: AnyObject) {
        let range = NSMakeRange(0, (self.arrangedObjects as AnyObject).count)
        self.remove(atArrangedObjectIndexes: IndexSet(integersIn: range.toRange() ?? 0..<0))
    }
}

let downloadFolderPathKey = "downloadFolderPath"

class ViewController: NSViewController, PasteboardWatcherDelegate {
    // string constants
    fileprivate let isFinishedKey = "isFinished"
    fileprivate let fileUrlKey = "fileURL"

    // member properties
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    fileprivate let downloadManager = DownloadManager()
    fileprivate let imagePathCopiedWatcher = PasteboardWatcher(fileKinds: ["png","jpg","jpeg","gif"])
    
    //Outlets
    @IBOutlet weak var downloadFolderPathLabel: NSTextField!
    @IBOutlet var arrayController: NSArrayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        resetDownloadFolderPathIfFolderDoesNotExist()
        
        imagePathCopiedWatcher.delegate = self
        imagePathCopiedWatcher.startPolling()
    }

    /// On app launch this method checks if the folder previously selected currently exists or not, if it does not exist then it updates value for corresponding key in user defaults as nil
    fileprivate func resetDownloadFolderPathIfFolderDoesNotExist() {
        var isDir : ObjCBool = false
        
        if let dirPath = UserDefaults.standard.value(forKey: downloadFolderPathKey) as? String , FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
            // this block denotes that there is a value for key downloadFolderPathKey in user defaults
            // as well as file exists at that path
            // need to check if it is directory
            if isDir.boolValue {
                // no need to do any thing
            }
            else {
                // the path does not denote a directory so set corresponding key in user defaults as nil
                UserDefaults.standard.setValue(nil, forKey:downloadFolderPathKey)
            }
        }
        else {
            // either value for downloadFolderPathKey does not exist or folder/ file does not exist at corresponding path, in any case set corresponding key in user defaults as nil
            UserDefaults.standard.setValue(nil, forKey:downloadFolderPathKey)
        }
    }
    
    //MARK: - Methods used in bindings
    /// Provides option to select a folder to download files, saves the same in user defaults
    func selectDownloadFolder() {
        
        // open panel setup and configuration
        let downloadFolderSelectOpenPanel = NSOpenPanel()
        downloadFolderSelectOpenPanel.canChooseFiles = false
        downloadFolderSelectOpenPanel.canChooseDirectories = true
        downloadFolderSelectOpenPanel.canCreateDirectories = true
        
        // show sheet
        downloadFolderSelectOpenPanel.beginSheetModal(for: self.view.window!) { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                UserDefaults.standard.setValue(downloadFolderSelectOpenPanel.urls.last?.path, forKey:downloadFolderPathKey)
            }
        }
    }
    
    /// Initiates bulk download
    func downloadAll() {
        // this method can be called for each download but in that case it will be in-efficient hence calling it before starting the batch download
        checkTargetFolderAndCreateIfRequired()
        
        // start downloading each file
        for aDownloadingFile in arrayController.arrangedObjects as! [DownloadingFile] {
            downloadManager.download(aDownloadingFile)
        }
    }
    
    //MARK: - private methods
    /// Before starting download check if directory exists at selected path or not, if it does not exist then create the one
    fileprivate func checkTargetFolderAndCreateIfRequired() {
        
        let defaultFileManager = FileManager.default
        var isDir : ObjCBool = false
        
        if let currentDownloadPath = UserDefaults.standard.value(forKey: downloadFolderPathKey) as? String{
            // check if directory path exits or not
            if !defaultFileManager.fileExists(atPath: currentDownloadPath, isDirectory: &isDir) || !isDir.boolValue{
                // since directory does not exist at given path directory with sub directories
                do {
                    //TODO: handle if below method returns false
                    _ = try defaultFileManager.createDirectory(atPath: currentDownloadPath, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    //TODO: handle error
                }
            }
        }
        else {
            // ideally this case should never arise since we are enabling 'Download All' button only if value for that particular key is non nil
            // if we are not doing so, then something is broken, please do so
        }
    }
    
    //MARK: - PasteboardWatcherDelegate implementation
    func newlyCopiedUrlObtained(copiedUrl : URL) {
        // path copied so insert new managed object
        let downloadingFile = NSEntityDescription.insertNewObject(forEntityName: "DownloadingFile", into: appDelegate.managedObjectContext) as! DownloadingFile
        downloadingFile.fileUrl = copiedUrl.absoluteString
    }
}

