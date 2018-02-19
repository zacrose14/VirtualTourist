//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 2/7/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
  
    // Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // Get Photos
    func initWithPhoto(_ photo: Photo) {
        
        if photo.photoData != nil {
            
            DispatchQueue.main.async {
                
                self.imageView.image = UIImage(data: photo.photoData! as Data)
                self.activityIndicator.stopAnimating()
            }
            
        } else {
            
            downloadImage(photo)
        }
    }
    
    // Download Photos
    func downloadImage(_ photo: Photo) {
        
        URLSession.shared.dataTask(with: URL(string: photo.photoURL!)!) { (data, response, error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                    self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
                }
            }
            
            }
            
            .resume()
    }
    
    // Save Photos
    func saveImageDataToCoreData(photo: Photo, imageData: NSData) {
        do {
            photo.photoData = imageData
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            try stack.saveContext()
        } catch {
            print("Saving Photo imageData Failed")
        }
    }
    
}
