//
//  API.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 15.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import SwiftyUserDefaults

class API {

  enum APIError: Error {
    case message(String)
  }

  static var baseUrl: String {
    return Constants.baseUrl + "/" + Defaults[.country].lowercased()
  }

  // Get all countries
  static func getCountries(completionHandler: @escaping ([Country]) -> Void) {

    Alamofire.request(Constants.countriesUrl)
      .responseJSON { response in

        var countries = [Country]()

        guard let json = JSON(response.result.value as Any).array else {
          completionHandler(countries)
          return
        }

        do {
          countries = try json.map {
            guard let country = try Country(json: $0) else { throw APIError.message("JSON of country is invalid.") }
            return country
          }
        } catch {
          debugPrint(error)
        }

        completionHandler(countries)
    }
  }

  // Get all stations (or with/out photo)
  static func getStations(withPhoto hasPhoto: Bool?, completionHandler: @escaping ([Station]) -> Void) {

    Alamofire.request(API.baseUrl + "/stations",
                      method: .get,
                      parameters: hasPhoto != nil ? ["hasPhoto": hasPhoto!.description] : nil,
                      encoding: URLEncoding.default,
                      headers: nil)
      .responseJSON { response in

        var stations = [Station]()

        guard let json = JSON(response.result.value as Any).array else {
          completionHandler(stations)
          return
        }

        do {
          stations = try json.map {
            var jsonStation = $0
            jsonStation["hasPhoto"].bool = hasPhoto ?? false
            guard let station = try Station(json: jsonStation) else { throw APIError.message("JSON of station is invalid.") }
            return station
          }
        } catch {
          debugPrint(error)
        }

        completionHandler(stations)
      }
  }

}
