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
    var twitter_tags: String?

    init(country: String, countryflag: String, mail: String?, twitter_tags: String?) {
        self.country = country
        self.countryflag = countryflag
        self.mail = mail
        self.twitter_tags = twitter_tags
    }

    init?(json: JSON) throws {
        self.country = json[Constants.DB_JSON_CONSTANTS.KEY_COUNTRYNAME].stringValue
        self.countryflag = json[Constants.DB_JSON_CONSTANTS.KEY_COUNTRYSHORTCODE].stringValue
        self.mail = json[Constants.DB_JSON_CONSTANTS.KEY_EMAIL].string
        self.twitter_tags = json[Constants.DB_JSON_CONSTANTS.KEY_TWITTERTAGS].string
    }

    public static func ==(lhs: Country, rhs: Country) -> Bool {
        return lhs.countryflag == rhs.countryflag
    }
    
}
