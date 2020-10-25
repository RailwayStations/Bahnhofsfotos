//
//  Station+Decodable.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 25.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Domain

// MARK: - Data Transfer Object (DTO)

struct StationDTO: Decodable {
  let id: Int             // Bahnhofsnummer
  let title: String       // Bahnhofsname
  let country: String
  let lat: Double
  let lon: Double
  let photographer: String?
  let photographerUrl: String?
  let photoUrl: String?
  let license: String?
  let DS100: String?
}

// MARK: - Mappings to Domain

extension StationDTO {
  func toDomain() -> Station {
    .init(
      id: id,
      name: title,
      country: country,
      lat: lat,
      lon: lon,
      photographer: photographer,
      photographerUrl: photographerUrl,
      photoUrl: photoUrl,
      license: license,
      DS100: DS100)
  }
}
