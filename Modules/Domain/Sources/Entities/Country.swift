//
//  CountryData.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 30.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Foundation

public struct Country {
    public let name: String
    public let code: String
    public let email: String?
    public let twitterTags: String?
    public let timetableUrlTemplate: String?

    public init(name: String,
                code: String,
                email: String?,
                twitterTags: String?,
                timetableUrlTemplate: String?) {
        self.name = name
        self.code = code
        self.email = email
        self.twitterTags = twitterTags
        self.timetableUrlTemplate = timetableUrlTemplate
    }
}

extension Country: Equatable {
    public static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }
}
