//
//  Pin.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/7/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import Foundation
import CoreData

public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude   = latitude
            self.longitude  = longitude
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
        }
    }
    
}
