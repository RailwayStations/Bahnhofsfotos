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
    var hasPhoto: Bool
    var datum: Int?
    var photoflag: String?

    init(id: Int, title: String, country: String, lat: Double, lon: Double, hasPhoto: Bool) {
        self.id = id
        self.title = title
        self.country = country
        self.lat = lat
        self.lon = lon
        self.hasPhoto = hasPhoto
    }

    init?(json: JSON) throws {
        guard
            let id = json["id"].int,
            let title = json["title"].string,
            let country = json["country"].string,
            let lat = json["lat"].double,
            let lon = json["lon"].double,
            let hasPhoto = json["hasPhoto"].bool
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.country = country
        self.lat = lat
        self.lon = lon
        self.hasPhoto = hasPhoto
    }

}
