//
//  DownloadingFile+CoreDataProperties.swift
//  ImageDownloadUtility
//
//  Created by Devarshi Kulshreshtha on 6/21/15.
//  Copyright © 2015 Devarshi Kulshreshtha. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension DownloadingFile {

    @NSManaged var fileUrl: String?
    @NSManaged var downloadStatus: NSNumber?

}
