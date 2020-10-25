//
//  Station.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import MapKit

public struct Station {
    public let id: Int             // Bahnhofsnummer
    public let name: String        // Bahnhofsname
    public let country: String
    public let lat: Double
    public let lon: Double
    public let photographer: String?
    public let photographerUrl: String?
    public let photoUrl: String?
    public let license: String?
    public let DS100: String?
    
    public var hasPhoto: Bool {
        return photoUrl != nil
    }

    public init(id: Int,
                name: String,
                country: String,
                lat: Double,
                lon: Double,
                photographer: String?,
                photographerUrl: String?,
                photoUrl: String?,
                license: String?,
                DS100: String?) {
        self.id = id
        self.name = name
        self.country = country
        self.lat = lat
        self.lon = lon
        self.photographer = photographer
        self.photographerUrl = photographerUrl
        self.photoUrl = photoUrl
        self.license = license
        self.DS100 = DS100
    }
}
