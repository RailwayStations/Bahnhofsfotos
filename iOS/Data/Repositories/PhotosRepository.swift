//
//  PhotosRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Domain
import Foundation

final class PhotosRepository: PhotosRepositoryType {
  func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error> {
    Deferred {
      Future { promise in
        API.uploadPhoto(imageData: photo, ofStation: station, inCountry: country) { result in
          do {
            try result()
            promise(.success(()))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
