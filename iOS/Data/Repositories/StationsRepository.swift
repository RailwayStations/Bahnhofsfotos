//
//  StationsRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 22.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Domain
import SwiftyUserDefaults

final class StationsRepository: StationsRepositoryType {
  func fetchStations() -> AnyPublisher<[Station], Error> {
    Deferred {
      Future<[Station], Error> { promise in
        API.getStations(withPhoto: nil) { stations in
          do {
            try PhotoStorage.removeAll()
            try StationStorage.removeAll()
            try StationStorage.create(stations: stations.map({ $0.toDomain() }))
            Defaults.dataComplete = true
            Defaults.lastUpdate = StationStorage.lastUpdatedAt
            try StationStorage.fetchAll()
          } catch {
            promise(.failure(error))
          }

          promise(.success(StationStorage.stations))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func readStations() throws {
    try StationStorage.fetchAll()
  }

  func getStations() -> [Station] {
    StationStorage.stations
  }
}
