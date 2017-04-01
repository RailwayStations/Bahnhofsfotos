//
//  Station.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Foundation
import SwiftyJSON

class Station {

    var id: Int             //Bahnhofsnummer
    var title: String       //Bahnhofsname
    var country: String
    var lat: Double
    var lon: Double

    init(id: Int, title: String, country: String, lat: Double, lon: Double) {
        self.id = id
        self.title = title
        self.country = country
        self.lat = lat
        self.lon = lon
    }

    init?(json: JSON) throws {
        guard
            let id = json[Constants.JsonConstants.kId].int,
            let title = json[Constants.JsonConstants.kTitle].string,
            let country = json[Constants.JsonConstants.kCountryName].string,
            let lat = json[Constants.JsonConstants.kLat].double,
            let lon = json[Constants.JsonConstants.kLon].double
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.country = country
        self.lat = lat
        self.lon = lon
    }

}
