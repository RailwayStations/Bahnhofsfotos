//
//  PhotosUseCase.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Combine
import Foundation

final class PhotosUseCase {
  private let photosRepository: PhotosRepositoryType

  init(photosRepository: PhotosRepositoryType) {
    self.photosRepository = photosRepository
  }
}

// MARK: - UploadPhotoUseCase

protocol UploadPhotoUseCase {
  func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error>
}

extension PhotosUseCase: UploadPhotoUseCase {
  func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error> {
    photosRepository.uploadPhoto(photo, station: station, country: country)
  }
}
