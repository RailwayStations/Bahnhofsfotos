//
//  MapViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        for bahnhof in BahnhofStorage.bahnhoefeOhneFoto {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: bahnhof.lat, longitude: bahnhof.lon)
            annotation.title = bahnhof.title
            mapView.addAnnotation(annotation)
        }
    }

}
