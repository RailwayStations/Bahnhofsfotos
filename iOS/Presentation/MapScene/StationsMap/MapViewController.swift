//
//  MapViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import CoreLocation
import Data
//import FBAnnotationClusteringSwift
import FontAwesomeKit_Swift
import MapKit
import SwiftyUserDefaults
import UIKit

class MapViewController: UIViewController {

  var locationManager: CLLocationManager?
  var stationsUpdatedAt: Date?
  var clusteringIsActive = true

//  lazy var clusteringManager: FBClusteringManager = {
//      let renderer = FBRenderer(animator: FBBounceAnimator())
//      return FBClusteringManager(algorithm: FBAllMapDistanceBasedClusteringAlgorithm(), renderer: renderer)
//  }()

//  fileprivate lazy var configuration: FBAnnotationClusterViewConfiguration = {
//    let color = Helper.tintColor
//
//    var smallTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), displayMode: .SolidColor(sideLength: 25, color: color))
//    smallTemplate.borderWidth = 2
//    smallTemplate.font = UIFont.boldSystemFont(ofSize: 13)
//
//    var mediumTemplate = FBAnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), displayMode: .SolidColor(sideLength: 35, color: color))
//    mediumTemplate.borderWidth = 3
//    mediumTemplate.font = UIFont.boldSystemFont(ofSize: 13)
//
//    var largeTemplate = FBAnnotationClusterTemplate(range: nil, displayMode: .SolidColor(sideLength: 45, color: color))
//    largeTemplate.borderWidth = 4
//    largeTemplate.font = UIFont.boldSystemFont(ofSize: 13)
//
//    return FBAnnotationClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
//  }()

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var trackingButton: UIButton!
  @IBOutlet weak var toggleClusteringButton: UIButton!

  @IBAction func followUser(_ sender: Any) {
    mapView.setUserTrackingMode(.follow, animated: true)
  }

  @IBAction func toggleClustering(_ sender: Any) {
//    view.makeToastActivity(.center)
//
//    if clusteringIsActive {
//      clusteringManager.removeAll(from: mapView)
//      mapView.addAnnotations(StationStorage.stations.map { StationAnnotation(station: $0) })
//      toggleClusteringButton.fa.setTitle(.mapMarker, for: .normal)
//    } else {
//      mapView.removeAnnotations(mapView.annotations)
//      clusteringManager.replace(annotations: StationStorage.stations.map { StationAnnotation(station: $0) }, in: mapView)
//      toggleClusteringButton.fa.setTitle(.mapPin, for: .normal)
//    }
//
//    clusteringIsActive = !clusteringIsActive
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
    
    showStations()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager?.requestWhenInUseAuthorization()
    locationManager?.startUpdatingLocation()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: true)
  }

  // Bahnhöfe anzeigen
  func showStations() {
//    if StationStorage.lastUpdatedAt != stationsUpdatedAt {
//      stationsUpdatedAt = StationStorage.lastUpdatedAt
//      clusteringManager.replace(annotations: StationStorage.stations.map { StationAnnotation(station: $0) }, in: mapView)
//    }
  }

}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//    clusteringManager.updateAnnotations(in: mapView)
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    guard let annotation = view.annotation as? FBAnnotationCluster else { return }
//
//    var region = annotation.region
//
//    // Make span a bit bigger so there are no points on the edges of the map
//    let smallSpan = region.span
//    region.span = MKCoordinateSpan(latitudeDelta: smallSpan.latitudeDelta * 1.3, longitudeDelta: smallSpan.longitudeDelta * 1.3)
//
//    mapView.setRegion(region, animated: true)
  }

//  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//    if annotation is MKUserLocation {
//      return nil
//    }
//
//    var reuseId = "Pin"
//
//    // check if cluster
//    if annotation is FBAnnotationCluster {
//      reuseId = "Cluster"
//      let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) ??
//        FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: configuration)
//      clusterView.annotation = annotation
//      return clusterView
//    }
//    
//    // button for detail view
//    let detailViewButton = UIButton(type: .system)
//    detailViewButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//    detailViewButton.fa.setTitle(.infoCircle, for: .normal)
//    detailViewButton.accessibilityIdentifier = "detail"
//
//    // button for navigation
//    let button = UIButton(type: .system)
//    button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//    button.fa.setTitle(.compass, for: .normal)
//    button.accessibilityIdentifier = "navigation"
//
//    // single station
//    let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView ??
//      MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//
//    pinView.annotation = annotation
//    pinView.isEnabled = true
//    pinView.canShowCallout = true
//    pinView.leftCalloutAccessoryView = detailViewButton
//    pinView.rightCalloutAccessoryView = button
//    pinView.pinTintColor = Helper.tintColor
//
//    if let annotation = annotation as? StationAnnotation {
//      if annotation.station.photographer != nil {
//        if Defaults.accountName != nil && annotation.station.photographer!.lowercased() == Defaults.accountName!.lowercased() {
//          pinView.pinTintColor = Helper.blueColor
//        } else {
//          pinView.pinTintColor = Helper.greenColor
//        }
//      }
//    }
//
//    return pinView
//  }

//  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//    // get station (of annotation)
//    if let annotation = view.annotation as? StationAnnotation {
//      StationStorage.currentStation = annotation.station
//    }
//    
//    // take action with station
//    guard let station = StationStorage.currentStation else { return }
//    
//    if (control.accessibilityIdentifier == "detail") {
//      performSegue(withIdentifier: "showDetail", sender: station)
//    } else if (control.accessibilityIdentifier == "navigation") {
//      Helper.openNavigation(to: station)
//    }
//  }

  func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
    UIView.animate(withDuration: 0.4, animations: {
      self.trackingButton.alpha = mode == .follow ? 0.0 : 1.0
    })
  }

  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    view.hideToastActivity()
  }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations _: [CLLocation]) {
    mapView.setUserTrackingMode(.follow, animated: true)
    manager.stopUpdatingLocation()
  }

}
