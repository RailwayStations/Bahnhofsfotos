//
//  PhotosRepositoryType.swift
//  
//
//  Created by Miguel Dönicke on 25.10.20.
//

import Combine
import Foundation

@available(iOS 13.0, *)
public protocol PhotosRepositoryType {
    func uploadPhoto(_ photo: Data, station: Station, country: Country) -> AnyPublisher<Void, Error>
}
