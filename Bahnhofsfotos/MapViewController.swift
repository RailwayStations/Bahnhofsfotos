//
//  MapViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var locationManager: CLLocationManager?
    var mapViewDidFinishRenderingMap = false

    @IBOutlet weak var mapView: MKMapView!

    @IBAction func showMenu(_ sender: Any) {
        sideMenuViewController?.presentLeftMenuViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        mapViewDidFinishRenderingMap = true
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard mapViewDidFinishRenderingMap else {
            return
        }

        let latHalf = mapView.region.span.latitudeDelta / 2
        let lngHalf = mapView.region.span.longitudeDelta / 2

        let lat = (start: mapView.region.center.latitude - latHalf, end: mapView.region.center.latitude + latHalf)
        let lng = (start: mapView.region.center.longitude - lngHalf, end: mapView.region.center.longitude + lngHalf)

        let stationsInRegion = StationStorage.stationsWithoutPhoto.filter {
            ($0.lat >= lat.start && $0.lat <= lat.end) && ($0.lon >= lng.start && $0.lon <= lng.end)
        }

        mapView.removeAnnotations(mapView.annotations)

        for station in stationsInRegion {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: station.lat, longitude: station.lon)
            annotation.title = station.title
            mapView.addAnnotation(annotation)
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }

        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }

}
