//
//  Photo.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 22.01.18.
//  Copyright © 2018 Railway-Stations. All rights reserved.
//

import Foundation

public class Photo {
    public var id: Int
    public var uploadedAt: Date?
    public var data: Data

    public init(data: Data, withId id: Int, uploadedAt: Date? = nil) {
        self.id = id
        self.data = data
        self.uploadedAt = uploadedAt
    }
}
