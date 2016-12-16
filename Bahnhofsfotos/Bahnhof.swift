//
//  Bahnhof.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Foundation
import SwiftyJSON

class Bahnhof {

    var id: Int             //Bahnhofsnummer
    var title: String       //Bahnhofsname
    var lat: Double
    var lon: Double
    private var datum: Int?          // not used in the database
    private var photoflag: String?   // not used in the database

    init(id: Int, title: String, lat: Double, lon: Double) {
        self.id = id
        self.title = title
        self.lat = lat
        self.lon = lon
    }

    init?(json: JSON) throws {
        guard
            let id = json["id"].int,
            let title = json["title"].string,
            let lat = json["lat"].double,
            let lon = json["lon"].double
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.lat = lat
        self.lon = lon
    }

}
