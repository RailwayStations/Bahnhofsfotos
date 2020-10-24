//
//  GetCountriesAndStationsUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import SwiftyUserDefaults

final class ReadCountriesAndStationsUseCase {
  private let countriesRepository: CountriesRepositoryType
  private let stationsRepository: StationsRepositoryType

  init(countriesRepository: CountriesRepositoryType,
       stationsRepository: StationsRepositoryType) {
    self.countriesRepository = countriesRepository
    self.stationsRepository = stationsRepository
  }
}

// MARK: - ReadCountriesAndStationsUseCaseType

protocol ReadCountriesAndStationsUseCaseType {
  func readStationsOfCountry()
}

extension ReadCountriesAndStationsUseCase: ReadCountriesAndStationsUseCaseType {
  func readStationsOfCountry() {
    try? countriesRepository.readCountries()

    if Defaults.dataComplete {
      try? stationsRepository.readStations()
    }
  }
}
