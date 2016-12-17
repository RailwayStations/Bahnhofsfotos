//
//  BahnhofStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Alamofire
import AlamofireSwiftyJSON

class BahnhofStorage {

    static var bahnhoefeOhneFoto: [Bahnhof] = []
    static var currentBahnhof: Bahnhof?

    // Bahnhöfe ohne Foto auslesen
    static func loadBahnhoefeOhneFoto(completionHandler: @escaping (_ bahnhoefe: [Bahnhof]) -> Void) {

        self.bahnhoefeOhneFoto.removeAll()

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(Constants.BAHNHOEFE_OHNE_PHOTO_URL).responseSwiftyJSON { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let json = response.result.value?.array else { return }

            for bh in json {
                if let bahnhof = try! Bahnhof(json: bh) {
                    self.bahnhoefeOhneFoto.append(bahnhof)
                }
            }

            self.bahnhoefeOhneFoto = sortBahnhoefe(bahnhoefe: self.bahnhoefeOhneFoto)
            completionHandler(self.bahnhoefeOhneFoto)
        }
    }

    // Bahnhöfe sortieren
    private static func sortBahnhoefe(bahnhoefe: [Bahnhof]) -> [Bahnhof] {
        return bahnhoefe.sorted(by: { (bahnhof1, bahnhof2) -> Bool in
            bahnhof1.title < bahnhof2.title
        })
    }

}
