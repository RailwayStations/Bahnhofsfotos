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

  enum Error: Swift.Error {
    case message(String)
  }

  static var baseUrl: String {
    return Constants.baseUrl
  }

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
            guard let country = try Country(json: $0) else { throw Error.message("JSON of country is invalid.") }
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
    if Defaults[.country].count > 0 {
      parameters["country"] = Defaults[.country].lowercased()
    }
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
            guard let station = try Station(json: $0) else { throw Error.message("JSON of station is invalid.") }
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

    var parameters = Parameters()
    if Defaults[.country].count > 0 {
      parameters["country"] = Defaults[.country].lowercased()
    }

    Alamofire.request(API.baseUrl + "/photographers",
                      method: .get,
                      parameters: parameters,
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
  
  // Register user
  static func register(completionHandler: @escaping (Bool) -> Void) {
    let parameters: Parameters = [
      "nickname": Defaults[.accountNickname]!,
      "email": Defaults[.accountEmail]!,
      "license": "CC0",
      "photoOwner": Defaults[.photoOwner],
      "linking": Defaults[.accountLinking] ? Defaults[.accountType].rawValue : "NO",
      "link": Defaults[.accountName]!
    ]
    
    let headers: HTTPHeaders = [
      "API-Key": Secret.apiKey
    ]

    Alamofire.request(API.baseUrl + "/registration",
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: headers).response { dataResponse in
      // 202 = registration accepted
      completionHandler(dataResponse.response?.statusCode == 202)
    }
  }

  // Upload photo
  static func uploadPhoto(imageData: Data,
                          ofStation station: Station,
                          inCountry country: Country,
                          progressHandler: ((Double) -> Void)? = nil,
                          completionHandler: @escaping (() throws -> Void) -> Void) {
    // 202 - upload successful
    // 400 - wrong request
    // 401 - wrong token
    // 402 - wrong apiKey
    // 409 - photo already exists
    // 413 - image too large (maximum 20 MB)
    guard
      let token = Defaults[.uploadToken],
      let nickname = Defaults[.accountNickname],
      let email = Defaults[.accountEmail]
      else {
        completionHandler { throw Error.message("Fehlerhafte Daten in Einstellungen überprüfen") }
        return
    }

    let headers: HTTPHeaders = [
      "API-Key": Secret.apiKey,
      "Upload-Token": token,
      "Nickname": nickname,
      "Email": email,
      "Station-Id": "\(station.id)",
      "Country": country.code,      // country code
      "Content-Type": "image/jpeg"  // "image/png" or "image/jpeg"
    ]

    let request = Alamofire.upload(imageData,
                                   to: API.baseUrl + "/photoUpload",
                                   method: .post,
                                   headers: headers)

    if let progressHandler = progressHandler {
      request.uploadProgress { progress in
        progressHandler(progress.fractionCompleted)
      }
    }

    request.response { dataResponse in
      guard let response = dataResponse.response else {
        completionHandler { throw Error.message("Fehler beim Upload, bitte später erneut versuchen") }
        return
      }

      switch response.statusCode {
      case 400, 402:
        completionHandler { throw Error.message("Upload nicht möglich") }
      case 401:
        completionHandler { throw Error.message("Token ungültig") }
      case 409:
        completionHandler { throw Error.message("Foto bereits vorhanden") }
      case 413:
        completionHandler { throw Error.message("Foto ist zu groß (max. 20 MB)") }
      default:
        completionHandler { return }
      }
    }
  }

}
