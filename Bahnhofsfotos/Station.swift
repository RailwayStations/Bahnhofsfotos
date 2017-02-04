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
            let id = json[Constants.DB_JSON_CONSTANTS.KEY_ID].int,
            let title = json[Constants.DB_JSON_CONSTANTS.KEY_TITLE].string,
            let country = json[Constants.DB_JSON_CONSTANTS.KEY_COUNTRYNAME].string,
            let lat = json[Constants.DB_JSON_CONSTANTS.KEY_LAT].double,
            let lon = json[Constants.DB_JSON_CONSTANTS.KEY_LON].double
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
