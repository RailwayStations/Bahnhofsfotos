//
//  CountriesUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

final class CountriesUseCase {
  private let countriesRepository: CountriesRepositoryType

  init(countriesRepository: CountriesRepositoryType) {
    self.countriesRepository = countriesRepository
  }
}

// MARK: - FetchCountriesUseCase

protocol FetchCountriesUseCase {
  func fetchCountries() -> AnyPublisher<[Country], Error>
}

extension CountriesUseCase: FetchCountriesUseCase {
  func fetchCountries() -> AnyPublisher<[Country], Error> {
    countriesRepository.fetchCountries()
  }
}
