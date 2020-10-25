//
//  StationAnnotation.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 14.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import Domain
import FBAnnotationClusteringSwift

class StationAnnotation: FBAnnotation {
  var station: Station

  init(station: Station) {
    self.station = station
    super.init(
      coordinate: CLLocationCoordinate2D(
        latitude: station.lat,
        longitude: station.lon
      ),
      title: station.name,
      subtitle: nil)
  }

  required init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
    fatalError("init(coordinate:title:subtitle:) has not been implemented")
  }
}
