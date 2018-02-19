//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Zachary Rose on 12/22/17.
//  Copyright © 2017 Zachary Rose. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLabel: UILabel!
    
    // Variables
    var currentPins:[Pin] = []
    var editMode: Bool = false
    var gestureBegin: Bool = false
    
    // Core Data Code
    func getCoreDataStack() -> CoreDataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    // Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedPins = loadSavedPin()
        setBarButtonItem()
        
        if savedPins != nil {
            
            currentPins = savedPins!
            
            for pin in currentPins {
                
                let coord = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                addAnnotation(fromCoord: coord)
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPhotos" {
            
            let destination = segue.destination as! PhotosVC
            let coord = sender as! CLLocationCoordinate2D
            destination.coordinateSelected = coord
            
            for pin in currentPins {
                
                if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                    
                    destination.coreDataPin = pin
                    break
                }
            }
            
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        deleteLabel.isHidden = !editing
        editMode = editing
    }
    
    func setBarButtonItem() {
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        gestureBegin = true
        return true
    }
    
    @IBAction func responseTap(_ sender: Any) {
        if gestureBegin {
            
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            addAnnotation(fromPoint: gestureTouchLocation)
            gestureBegin = false
        }
    }
    
    // Fetch Results
    func fetchResults() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let stack = getCoreDataStack()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        request.sortDescriptors = []
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // Load Saved Pin
    func loadSavedPin() -> [Pin]? {
        
        do {
            
            var pinArray:[Pin] = []
            let fetchedResultsController = fetchResults()
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<pinCount {
                
                pinArray.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            
            return pinArray
            
        } catch {
            
            return nil
        }
    }
    
    // Add Pin
    func addAnnotation(fromPoint: CGPoint) {
        
        let coordToAdd = mapView.convert(fromPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordToAdd
        addData(of: annotation)
        mapView.addAnnotation(annotation)
        
    }
    
    func addAnnotation(fromCoord: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoord
        mapView.addAnnotation(annotation)
    }
    
    // MapView Function
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !editMode {
            
            performSegue(withIdentifier: "toPhotos", sender: view.annotation?.coordinate)
            
            mapView.deselectAnnotation(view.annotation, animated: false)
            
        } else {
            
            removeData(of: view.annotation!)
            
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    // Add Core Data
    func addData(of: MKAnnotation) {
        
        do {
            
            let coord = of.coordinate
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: getCoreDataStack().context)
            try getCoreDataStack().saveContext()
            currentPins.append(pin)
            
        } catch {
            
            print("There was a problem saving to Core Data")
        }
    }
    
    // Delete Core Data
    func removeData(of: MKAnnotation) {
        
        let coord = of.coordinate
        for pin in currentPins {
            
            if pin.latitude == coord.latitude && pin.longitude == coord.longitude {
                
                do {
                    
                    getCoreDataStack().context.delete(pin)
                    try getCoreDataStack().saveContext()
                    
                } catch {
                    
                    print("There was a problem removing from Core Data")
                }
                break
            }
        }
    }

}

