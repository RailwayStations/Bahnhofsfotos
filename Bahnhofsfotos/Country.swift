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

  var name: String
  var code: String
  var mail: String?
  var twitterTags: String?
  var timetableUrlTemplate: String?

  init(country: String, countryflag: String, mail: String?, twitterTags: String?, timetableUrlTemplate: String?) {
    self.name = country
    self.code = countryflag
    self.mail = mail
    self.twitterTags = twitterTags
    self.timetableUrlTemplate = timetableUrlTemplate
  }

  init?(json: JSON) throws {
    self.name = json[Constants.JsonConstants.kCountryName].stringValue
    self.code = json[Constants.JsonConstants.kCountryCode].stringValue
    self.mail = json[Constants.JsonConstants.kCountryEmail].string
    self.twitterTags = json[Constants.JsonConstants.kCountryTwitterTags].string
    self.timetableUrlTemplate = json[Constants.JsonConstants.kCountryTimetableUrlTemplate].string
  }

  public static func == (lhs: Country, rhs: Country) -> Bool {
    return lhs.code == rhs.code
  }

}
