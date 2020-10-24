//
//  StationsUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 22.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

final class StationsUseCase {
  private let stationsRepository: StationsRepositoryType

  init(stationsRepository: StationsRepositoryType) {
    self.stationsRepository = stationsRepository
  }
}

// MARK: - FetchStationsUseCase

protocol FetchStationsUseCase {
  func fetchStations() -> AnyPublisher<[Station], Error>
}

extension StationsUseCase: FetchStationsUseCase {
  func fetchStations() -> AnyPublisher<[Station], Error> {
    stationsRepository.fetchStations()
  }
}

// MARK: - GetStationsUseCase

protocol GetStationsUseCase {
  func getStations() -> [Station]
}

extension StationsUseCase: GetStationsUseCase {
  func getStations() -> [Station] {
    stationsRepository.getStations()
  }
}
