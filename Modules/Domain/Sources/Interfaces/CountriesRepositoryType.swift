//
//  CountriesRepositoryType.swift
//  
//
//  Created by Miguel Dönicke on 25.10.20.
//

import Combine

@available(iOS 13.0, *)
public protocol CountriesRepositoryType {
    func fetchCountries() -> AnyPublisher<[Country], Error>
    func readCountries() throws
}
