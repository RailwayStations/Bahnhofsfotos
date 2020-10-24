//
//  CountriesRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

final class CountriesRepository {}

// MARK: - CountriesRepositoryType

protocol CountriesRepositoryType {
  func fetchCountries() -> AnyPublisher<[Country], Error>
  func readCountries() throws
}

extension CountriesRepository: CountriesRepositoryType {
  func fetchCountries() -> AnyPublisher<[Country], Error> {
    Deferred {
      Future<[Country], Error> { promise in
        API.getCountries { countries in
            do {
              try CountryStorage.removeAll()

              for country in countries {
                try country.save()
              }

              try CountryStorage.fetchAll()
            } catch {
              promise(.failure(error))
            }

          promise(.success(CountryStorage.countries))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func readCountries() throws {
    try CountryStorage.fetchAll()
  }
}
