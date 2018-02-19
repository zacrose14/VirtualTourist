//
//  FlickrImages.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/14/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import UIKit
import CoreData

class FlickrImage {
    
    let id: String
    let secret: String
    let server: String
    let farm: Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}
