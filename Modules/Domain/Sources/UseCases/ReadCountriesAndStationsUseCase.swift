//
//  GetCountriesAndStationsUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

public protocol ReadCountriesAndStationsUseCaseType {
    func readStationsOfCountry()
}

@available(iOS 13.0, *)
public final class ReadCountriesAndStationsUseCase: ReadCountriesAndStationsUseCaseType {
    private let countriesRepository: CountriesRepositoryType
    private let stationsRepository: StationsRepositoryType
    private let settingsRepository: SettingsRepositoryType
    
    public init(countriesRepository: CountriesRepositoryType,
         stationsRepository: StationsRepositoryType,
         settingsRepository: SettingsRepositoryType) {
        self.countriesRepository = countriesRepository
        self.stationsRepository = stationsRepository
        self.settingsRepository = settingsRepository
    }
    
    // MARK: - ReadCountriesAndStationsUseCaseType
    
    public func readStationsOfCountry() {
        try? countriesRepository.readCountries()
        
        if settingsRepository.isDataComplete {
            try? stationsRepository.readStations()
        }
    }
}
