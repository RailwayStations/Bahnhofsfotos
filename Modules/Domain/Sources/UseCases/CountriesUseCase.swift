//
//  CountriesUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

@available(iOS 13.0, *)
public protocol FetchCountriesUseCase {
    func fetchCountries() -> AnyPublisher<[Country], Error>
}

@available(iOS 13.0, *)
public final class CountriesUseCase: FetchCountriesUseCase {
    private let countriesRepository: CountriesRepositoryType
    
    public init(countriesRepository: CountriesRepositoryType) {
        self.countriesRepository = countriesRepository
    }

    // MARK: - FetchCountriesUseCase

    public func fetchCountries() -> AnyPublisher<[Country], Error> {
        countriesRepository.fetchCountries()
    }
}
