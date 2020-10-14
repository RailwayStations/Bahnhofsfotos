//
//  Station.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import MapKit
import SwiftyJSON

class Station: NSObject {

  var id: Int             // Bahnhofsnummer
  var name: String        // Bahnhofsname
  var country: String
  var lat: Double
  var lon: Double
  var photographer: String?
  var photographerUrl: String?
  var photoUrl: String?
  var license: String?
  var DS100: String?

  var hasPhoto: Bool {
    return photoUrl != nil
  }

  init(id: Int, title: String, country: String, lat: Double, lon: Double, photographer: String?, photographerUrl: String?, photoUrl: String?, license: String?, DS100: String?) {
    self.id = id
    self.name = title
    self.country = country
    self.lat = lat
    self.lon = lon
    self.photographer = photographer
    self.photographerUrl = photographerUrl
    self.photoUrl = photoUrl
    self.license = license
    self.DS100 = DS100
  }

  init?(json: JSON) throws {
    guard let id = json[Constants.JsonConstants.kId].int,
      let title = json[Constants.JsonConstants.kTitle].string,
      let country = json[Constants.JsonConstants.kCountry].string,
      let lat = json[Constants.JsonConstants.kLat].double,
      let lon = json[Constants.JsonConstants.kLon].double
      else {
        return nil
    }

    self.id = id
    self.name = title
    self.country = country
    self.lat = lat
    self.lon = lon
    self.photographer = json[Constants.JsonConstants.kPhotographer].string
    self.photographerUrl = json[Constants.JsonConstants.kPhotographerUrl].string
    self.photoUrl = json[Constants.JsonConstants.kPhotoUrl].string
    self.license = json[Constants.JsonConstants.kLicense].string
    self.DS100 = json[Constants.JsonConstants.kDS100].string
  }

}

// MAKR: - MKAnnotation
extension Station: MKAnnotation {

  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: lat, longitude: lon)
  }

  var title: String? {
    return name
  }

}
