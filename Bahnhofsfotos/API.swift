//
//  API.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 15.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Alamofire
import Apollo
import Foundation
import SwiftyJSON
import SwiftyUserDefaults

class API {

  enum APIError: Error {
    case message(String)
  }

  static var baseUrl: String {
    return Constants.baseUrl
  }

  static let apollo: ApolloClient = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["Authorization": "Bearer " + Secret.dBDeveloperAuthorization]

    let url = URL(string: "https://api.deutschebahn.com/1bahnql/graphql")!

    return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
  }()

  // Get all countries
  static func getCountries(completionHandler: @escaping ([Country]) -> Void) {

    Alamofire.request(API.baseUrl + "/countries.json")
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

    var parameters = Parameters()
    parameters["country"] = Defaults[.country].lowercased()
    if let hasPhoto = hasPhoto {
      parameters["hasPhoto"] = hasPhoto.description
    }

    Alamofire.request(API.baseUrl + "/stations",
                      method: .get,
                      parameters: parameters,
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
            guard let station = try Station(json: $0) else { throw APIError.message("JSON of station is invalid.") }
            return station
          }
        } catch {
          debugPrint(error)
        }

        completionHandler(stations)
    }
  }

  // Get all photographers of given country
  static func getPhotographers(completionHandler: @escaping ([String: Any]) -> Void) {

    Alamofire.request(API.baseUrl + "/photographers",
                      method: .get,
                      parameters: ["country": Defaults[.country].lowercased()],
                      encoding: URLEncoding.default,
                      headers: nil)
      .responseJSON { response in

        guard let value = response.result.value, let json = JSON(value).dictionaryObject else {
          completionHandler([:])
          return
        }

        completionHandler(json)
    }
  }

  // Get photo of a given station
  static func getPhotoFromStation(station: Station, completionHandler: @escaping (Data?, Error?) -> Void) {
    self.apollo.fetch(query: StationPhotoQuery(number: station.id)) { (result, error) in
      // check if result has data
      guard let data = result?.data else {
        completionHandler(nil, error)
        return
      }

      // extract url of picture
      if let picture = data.stationWithStationNumber?.picture,
        let url = URL(string: picture.url) {
        do {
          let imageData = try Data(contentsOf: url)
          completionHandler(imageData, nil)
        } catch {
          completionHandler(nil, error)
        }
      }
    }
  }

}
