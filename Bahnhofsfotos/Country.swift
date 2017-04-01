//
//  CountryData.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 30.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Foundation
import SwiftyJSON

class Country: Equatable {

    var country: String
    var countryflag: String
    var mail: String?
    var twitterTags: String?

    init(country: String, countryflag: String, mail: String?, twitterTags: String?) {
        self.country = country
        self.countryflag = countryflag
        self.mail = mail
        self.twitterTags = twitterTags
    }

    init?(json: JSON) throws {
        self.country = json[Constants.JsonConstants.kCountryName].stringValue
        self.countryflag = json[Constants.JsonConstants.kCountryShortcode].stringValue
        self.mail = json[Constants.JsonConstants.kEmail].string
        self.twitterTags = json[Constants.JsonConstants.kTwitterTags].string
    }

    public static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.countryflag == rhs.countryflag
    }

}
