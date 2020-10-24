//
//  PhotographersUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Foundation

final class PhotographersUseCase {
  private let photographersRepository: PhotographersRepositoryType

  init(photographersRepository: PhotographersRepositoryType) {
    self.photographersRepository = photographersRepository
  }
}

// MARK: - FetchPhotographersUseCase

protocol FetchPhotographersUseCase {
  func fetchPhotographers() -> AnyPublisher<[String: Int], Error>
}

extension PhotographersUseCase: FetchPhotographersUseCase {
  func fetchPhotographers() -> AnyPublisher<[String: Int], Error> {
    photographersRepository.fetchPhotographers()
  }
}
