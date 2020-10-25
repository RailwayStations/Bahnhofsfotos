//
//  StationsRepositoryType.swift
//  
//
//  Created by Miguel Dönicke on 25.10.20.
//

import Combine

@available(iOS 13.0, *)
public protocol StationsRepositoryType {
    func fetchStations() -> AnyPublisher<[Station], Error>
    func readStations() throws
    func getStations() -> [Station]
}
