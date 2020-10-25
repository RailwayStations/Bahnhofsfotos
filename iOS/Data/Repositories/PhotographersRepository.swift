//
//  PhotographersRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Domain

final class PhotographersRepository: PhotographersRepositoryType {
  func fetchPhotographers() -> AnyPublisher<[(key: String, value: Int)], Error> {
    Deferred {
      Future<[(key: String, value: Int)], Error> { promise in
        API.getPhotographers { photographers in
          promise(.success(photographers.sorted(by: { $0.value > $1.value })))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
