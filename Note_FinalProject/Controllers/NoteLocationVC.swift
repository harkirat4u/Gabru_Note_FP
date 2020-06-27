//
//  NoteLocationVC.swift
//  Note_FinalProject
//
//  Created by Harkirat Singh on 2020-06-21.
//  Copyright © 2020 Harkirat Singh. All rights reserved.
//

import UIKit
import MapKit
import  CoreLocation
import CoreData

class NoteLocationVC: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var lat:Double?
    var long:Double?
    
    var locationmanager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 100
    
    @IBOutlet var myMapView: MKMapView!
    
    override func viewDidLoad() {
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
        
        myMapView.showsUserLocation = true
     
        let noteLocation = CLLocation(latitude: lat!, longitude: long!)
          super.viewDidLoad(); self.navigationController!.setNavigationBarHidden(false, animated: true)
        
        
        let coordinateRegion = MKCoordinateRegion(center: noteLocation.coordinate, latitudinalMeters: regionRadius * 5.0, longitudinalMeters: regionRadius * 5.0)
        self.myMapView.setRegion(coordinateRegion, animated: true)
    
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(noteLocation.coordinate.latitude, noteLocation.coordinate.longitude);
        myAnnotation.title = "NOTE Saved LOCATION"
        myAnnotation.subtitle = "\(String(describing: lat)),\(String(describing: long))"
        self.myMapView.addAnnotation(myAnnotation)
     
    }
    

   
}
