//
//  CountriesRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Domain

public final class CountriesRepository: CountriesRepositoryType {
    public init() {}

    public func fetchCountries() -> AnyPublisher<[Country], Error> {
        Deferred {
            Future<[Country], Error> { promise in
                API.getCountries { countries in
                    do {
                        try CountryStorage.removeAll()

                        for country in countries.map({ $0.toDomain() }) {
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

    public func readCountries() throws {
        try CountryStorage.fetchAll()
    }
}
