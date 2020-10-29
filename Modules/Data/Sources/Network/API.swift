//
//  API.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 15.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Alamofire
import Domain
import Foundation
import Shared
import SwiftyUserDefaults

public class API {
    public enum Error: Swift.Error {
        case message(String)
    }

    static var baseUrl: String {
        return Constants.baseUrl
    }

    // Get all countries
    public static func getCountries(completionHandler: @escaping ([CountryDTO]) -> Void) {
        AF.request(API.baseUrl + "/countries.json")
            .responseJSON { response in
                guard let data = response.data else { return completionHandler([]) }
                let countries = try? JSONDecoder().decode([CountryDTO].self, from: data)
                completionHandler(countries ?? [])
            }
    }

    // Get all stations (or with/out photo)
    public static func getStations(withPhoto hasPhoto: Bool?, completionHandler: @escaping ([StationDTO]) -> Void) {
        var parameters = Parameters()
        if Defaults.country.count > 0 {
            parameters["country"] = Defaults.country.lowercased()
        }

        if let hasPhoto = hasPhoto {
            parameters["hasPhoto"] = hasPhoto.description
        }

        AF.request(API.baseUrl + "/stations",
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: nil)
            .responseJSON { response in
                guard let data = response.data else { return completionHandler([]) }
                do {
                    let stations = try JSONDecoder().decode([StationDTO].self, from: data)
                    completionHandler(stations)
                } catch {
                    debugPrint(error.localizedDescription)
                    completionHandler([])
                }
            }
    }

    // Get all photographers of given country
    public static func getPhotographers(completionHandler: @escaping ([String: Int]) -> Void) {
        var parameters = Parameters()
        if Defaults.country.count > 0 {
            parameters["country"] = Defaults.country.lowercased()
        }

        AF.request(API.baseUrl + "/photographers",
                   parameters: parameters,
                   encoding: URLEncoding.default,
                   headers: nil)
            .responseJSON { response in
                guard let data = response.data else { return completionHandler([:]) }
                do {
                    let photographers = try JSONDecoder().decode([String: Int].self, from: data)
                    completionHandler(photographers)
                } catch {
                    debugPrint(error.localizedDescription)
                    completionHandler([:])
                }
            }
    }

    // Register user
    public static func register(completionHandler: @escaping (Bool) -> Void) {
        let parameters: Parameters = [
            "nickname": Defaults.accountNickname ?? "",
            "email": Defaults.accountEmail ?? "",
            "license": "CC0",
            "photoOwner": Defaults.photoOwner,
            "linking": Defaults.accountType.rawValue,
            "link": Defaults.accountName ?? ""
        ]

        AF.request(API.baseUrl + "/registration",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).response { dataResponse in
                    // 202 = registration accepted
                    completionHandler(dataResponse.response?.statusCode == 202)
                   }
    }

    // Upload photo
    public static func uploadPhoto(imageData: Data,
                            ofStation station: Station,
                            inCountry country: Country,
                            progressHandler: ((Double) -> Void)? = nil,
                            completionHandler: @escaping (() throws -> Void) -> Void) {
        // 202 - upload successful
        // 400 - wrong request
        // 401 - wrong token
        // 409 - photo already exists
        // 413 - image too large (maximum 20 MB)
        guard
            let token = Defaults.uploadToken,
            let nickname = Defaults.accountNickname,
            let email = Defaults.accountEmail
        else {
            completionHandler { throw Error.message("Fehlerhafte Daten in Einstellungen überprüfen") }
            return
        }

        let headers: HTTPHeaders = [
            "Upload-Token": token,
            "Nickname": nickname,
            "Email": email,
            "Station-Id": "\(station.id)",
            "Country": country.code,      // country code
            "Content-Type": "image/jpeg"  // "image/png" or "image/jpeg"
        ]

        let request = AF.upload(imageData,
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
