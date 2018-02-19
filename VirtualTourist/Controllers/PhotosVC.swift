//
//  PhotosVC.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 1/31/18.
//  Copyright © 2018 Zachary Rose. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newButton: UIButton!
    
    // Variables
    var coordinateSelected:CLLocationCoordinate2D!
    let totalCells:Int = 30
    var stack:CoreDataStack!
    var coreDataPin:Pin!
    var savedImages:[Photo] = []
    var selectedDelete:[Int] = [] {
        
        didSet {
            
            if selectedDelete.count > 0 {
                
                newButton.setTitle("Remove Selected Pictures", for: .normal)
                
            } else {
                
                newButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    // Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollection.delegate = self
        photoCollection.dataSource = self
        
        photoCollection.allowsMultipleSelection = true
        addAnnotation()
        
        let savedPhoto = loadPhoto()
        if savedPhoto != nil && savedPhoto?.count != 0 {
            savedImages = savedPhoto!
            savedResult()
            
        } else {
            
            showNewResult()
        }
    }
    
    // Add Annotation
    
    func addAnnotation() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateSelected
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    // Core Data Code
    func getCoreDataStack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    // Get Results
    func getFetchedResults() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [coreDataPin!])
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Saved Photo Loads
    func loadPhoto() -> [Photo]? {
        
        do {
            
            var photoArray:[Photo] = []
            let fetchedResults = getFetchedResults()
            try fetchedResults.performFetch()
            let photoCount = try fetchedResults.managedObjectContext.count(for: fetchedResults.fetchRequest)
            
            for index in 0..<photoCount {
                
                photoArray.append(fetchedResults.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            
            return photoArray.sorted(by: {$0.index < $1.index})
            
        } catch {
            
            return nil
        }
    }
    
    // Collection View Functions and Actions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = photoCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        

        cell.initWithPhoto(savedImages[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedDelete = selectedToDeleteIndex(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedDelete = selectedToDeleteIndex(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            
            cell?.contentView.alpha = 1
        }
    }
    
    func selectedToDeleteIndex(_ indexPathArray: [IndexPath]) -> [Int] {
        var selected:[Int] = []
        
        for indexPath in indexPathArray {
            
            selected.append(indexPath.row)
        }
        return selected
    }

    // Get New Collection Action
    @IBAction func newCollection(_ sender: Any) {
        if selectedDelete.count > 0 {
            
            removePhotos()
            unselectSelectedCollection()
            savedImages = loadPhoto()!
            savedResult()
            
        } else {
            
            showNewResult()
        }

    }
    
    // Saved Result
    func savedResult() {
        
        DispatchQueue.main.async {
            
            self.photoCollection.reloadData()
        }
    }
    
    //Show Result
    
    func showNewResult() {
        
        newButton.isEnabled = false
        
        deleteCoreDataPhoto()
        savedImages.removeAll()
        photoCollection.reloadData()
        
        getImages { (flickrImages) in
            
            if flickrImages != nil {
                
                DispatchQueue.main.async {
                    
                    self.addCoreData(flickrImages: flickrImages!, coreDataPin: self.coreDataPin)
                    self.savedImages = self.loadPhoto()!
                    self.savedResult()
                    self.newButton.isEnabled = true
                }
            }
        }
    }
    
    // Delete Photo
    
    func deleteCoreDataPhoto() {
        
        for image in savedImages {
            
            getCoreDataStack().context.delete(image)
        }
    }
    
    // Get Random Photos
    
    func getImages(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        Flickr.getFlickrImages(lat: coordinateSelected.latitude, lng: coordinateSelected.longitude) { (success, flickrImages) in
            if success {
                
                if flickrImages!.count > self.totalCells {
                    var randomArray:[Int] = []
                    
                    while randomArray.count < self.totalCells {
                        
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    
                    for random in randomArray {
                        
                        result.append(flickrImages![random])
                    }
                    
                    completion(result)
                    
                } else {
                    
                    completion(flickrImages!)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    // Add Core Data
    
    func addCoreData(flickrImages:[FlickrImage], coreDataPin:Pin) {
        
        for image in flickrImages {
            
            do {
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                let photo = Photo(index: flickrImages.index{$0 === image}!, imageURL: image.imageURLString(), imageData: nil, context: stack.context)
                photo.pin = coreDataPin
                try stack.saveContext()
                
            } catch {
                
                print("Add Core Data Failed")
            }
        }
    }
    
    
    func unselectSelectedCollection() {
        
        for indexPath in photoCollection.indexPathsForSelectedItems! {
            
            photoCollection.deselectItem(at: indexPath, animated: false)
            photoCollection.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    // Remove Photos
    
    func removePhotos() {
        
        for index in 0..<savedImages.count {
            
            if selectedDelete.contains(index) {
                
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            try getCoreDataStack().saveContext()
            
        } catch {
            
            print("Remove Core Data Photo Failed")
        }
        
        selectedDelete.removeAll()
    }
}
