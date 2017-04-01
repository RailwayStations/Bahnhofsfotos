//
//  MapViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import CoreLocation
import FontAwesomeKit_Swift
import MapKit
import UIKit

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

  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    mapView.removeAnnotations(mapView.annotations)
  }

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
      mapView.addAnnotation(station)
    }
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }

    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
    annotationView.isEnabled = true
    annotationView.canShowCallout = true

    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
    button.fa_setTitle(.fa_compass, for: .normal)

    annotationView.rightCalloutAccessoryView = button

    return annotationView
  }

  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let station = view.annotation as? Station {
      Helper.openNavigation(to: station)
    }
  }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location else { return }

    let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    mapView.setRegion(region, animated: false)
    manager.stopUpdatingLocation()
  }

}
