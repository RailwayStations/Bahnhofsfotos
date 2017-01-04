//
//  BahnhofStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Alamofire
import SwiftyJSON

class BahnhofStorage {

    static var bahnhoefeOhneFoto: [Bahnhof] = []
    static var currentBahnhof: Bahnhof?

    // Bahnhöfe auslesen
    static func getStations(withPhoto hasPhoto: Bool, completionHandler: @escaping (_ bahnhoefe: [Bahnhof]) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(Constants.BASE_URL + "/stations", method: .get, parameters: ["hasPhoto": hasPhoto], encoding: URLEncoding.default, headers: nil).responseJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let json = JSON(response.result.value as Any).array else { return }

            self.bahnhoefeOhneFoto = sortBahnhoefe(bahnhoefe: json.map { try! Bahnhof(json: $0)! })

            completionHandler(self.bahnhoefeOhneFoto)
        }
    }

    // Bahnhöfe sortieren
    private static func sortBahnhoefe(bahnhoefe: [Bahnhof]) -> [Bahnhof] {
        return bahnhoefe.sorted { $0.title < $1.title }
    }

}
