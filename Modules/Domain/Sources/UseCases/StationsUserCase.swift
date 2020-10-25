//
//  StationsUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 22.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

@available(iOS 13.0, *)
public protocol FetchStationsUseCase {
    func fetchStations() -> AnyPublisher<[Station], Error>
}

public protocol GetStationsUseCase {
    func getStations() -> [Station]
}

@available(iOS 13.0, *)
public final class StationsUseCase {
    private let stationsRepository: StationsRepositoryType

    public init(stationsRepository: StationsRepositoryType) {
        self.stationsRepository = stationsRepository
    }

    // MARK: - FetchStationsUseCase

    public func fetchStations() -> AnyPublisher<[Station], Error> {
        stationsRepository.fetchStations()
    }

    // MARK: - GetStationsUseCase

    public func getStations() -> [Station] {
        stationsRepository.getStations()
    }
}
