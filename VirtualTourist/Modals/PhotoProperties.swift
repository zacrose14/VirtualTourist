//
//  PhotoProperties.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/14/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        
        return NSFetchRequest<Photo>(entityName: "Photo");
    }
    
    @NSManaged public var photoData: NSData?
    @NSManaged public var photoURL: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: Pin?
    
}
