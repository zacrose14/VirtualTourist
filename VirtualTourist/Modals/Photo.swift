//
//  Photo.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/7/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import Foundation
import CoreData

public class Photo: NSManagedObject {
    
    convenience init(index:Int, imageURL: String, imageData: NSData?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.index = Int16(index)
            self.photoURL = imageURL
            self.photoData = imageData
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
        }
    }
    
}
