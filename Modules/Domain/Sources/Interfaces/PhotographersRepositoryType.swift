//
//  PhotographersRepositoryType.swift
//  
//
//  Created by Miguel Dönicke on 25.10.20.
//

import Combine

@available(iOS 13.0, *)
public protocol PhotographersRepositoryType {
    func fetchPhotographers() -> AnyPublisher<[(key: String, value: Int)], Error>
}
