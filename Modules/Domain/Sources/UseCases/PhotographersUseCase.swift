//
//  PhotographersUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Foundation

@available(iOS 13.0, *)
public protocol FetchPhotographersUseCase {
    func fetchPhotographers() -> AnyPublisher<[String: Int], Error>
}

@available(iOS 13.0, *)
public final class PhotographersUseCase {
    private let photographersRepository: PhotographersRepositoryType
    
    public init(photographersRepository: PhotographersRepositoryType) {
        self.photographersRepository = photographersRepository
    }

    // MARK: - FetchPhotographersUseCase

    public func fetchPhotographers() -> AnyPublisher<[(key: String, value: Int)], Error> {
        photographersRepository.fetchPhotographers()
    }
}
