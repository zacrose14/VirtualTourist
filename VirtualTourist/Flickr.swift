//
//  Flicker.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/7/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import Foundation

class Flickr {
    
    // Constants
    
    static let flickrAPI = "https://api.flickr.com/services/rest/"
    static let APIKey = "64d80d35e141054201f902bf7e748263"
    static let search = "flickr.photos.search"
    static let format = "json"
    static let searchRange = 10
    
    // Get Images
    static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(flickrAPI)?method=\(search)&format=\(format)&api_key=\(APIKey)&lat=\(lat)&lon=\(lng)&radius=\(searchRange)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                completion(false, nil)
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let photosMeta = json?["photos"] as? [String:Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var flickrImages:[FlickrImage] = []
                
                for photo in photos {
                    
                    if let flickrImage = photo as? [String:Any],
                        let id = flickrImage["id"] as? String,
                        let secret = flickrImage["secret"] as? String,
                        let server = flickrImage["server"] as? String,
                        let farm = flickrImage["farm"] as? Int {
                        flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                completion(true, flickrImages)
                
            } else {
                
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
}
