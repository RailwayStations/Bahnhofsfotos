//
//  Country+Decoable.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 25.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Domain

// MARK: - Data Transfer Object (DTO)

struct CountryDTO: Decodable {
  let name: String
  let code: String
  let email: String?
  let twitterTags: String?
  let timetableUrlTemplate: String?
}

// MARK: - Mappings to Domain

extension CountryDTO {
  func toDomain() -> Country {
    .init(
      name: name,
      code: code,
      email: email,
      twitterTags: twitterTags,
      timetableUrlTemplate: timetableUrlTemplate)
  }
}
