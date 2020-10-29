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

public final class PhotosRepository: PhotosRepositoryType {
    public init() {}

    public func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error> {
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
