//
//  PhotographersRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine

protocol PhotographersRepositoryType {
  func fetchPhotographers() -> AnyPublisher<[String: Int], Error>
}

final class PhotographersRepository: PhotographersRepositoryType {
  func fetchPhotographers() -> AnyPublisher<[String: Int], Error> {
    Deferred {
      Future<[String: Int], Error> { promise in
        API.getPhotographers { photographers in

          if let photographers = photographers as? [String: Int] {
            let sortedPhotographers = photographers.sorted(by: { $0.value > $1.value })
            let sortedPhotographersAsDictionary = [String: Int](uniqueKeysWithValues: sortedPhotographers)
            promise(.success(sortedPhotographersAsDictionary))
          } else {
            promise(.success([:]))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
