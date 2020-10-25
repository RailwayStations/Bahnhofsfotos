//
//  PhotosUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Foundation

@available(iOS 13.0, *)
public protocol UploadPhotoUseCase {
    func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error>
}

@available(iOS 13.0, *)
public final class PhotosUseCase: UploadPhotoUseCase {
    private let photosRepository: PhotosRepositoryType
    
    public init(photosRepository: PhotosRepositoryType) {
        self.photosRepository = photosRepository
    }

    // MARK: - UploadPhotoUseCase

    public func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error> {
        photosRepository.uploadPhoto(photo, station: station, country: country)
    }
}
