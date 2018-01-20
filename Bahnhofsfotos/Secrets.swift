//
//  Secrets.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 20.01.18.
//  Copyright © 2018 Railway-Stations. All rights reserved.
//

import Foundation

fileprivate enum SecretsError: Error {
  case message(String)
}

class Secret {
  static var dBDeveloperAuthorization: String {
    return try! self.value(forKey: "DBDeveloperAuthorization")
  }

  private static func value(forKey key: String) throws -> String {
    do {
      guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else { throw SecretsError.message("Secrets.plist not found!") }
      guard let keys = NSDictionary(contentsOfFile: path) else { throw SecretsError.message("Error reading 'Secrets.plist'") }
      guard let value = keys.value(forKey: key) as? String else { throw SecretsError.message("Value of '" + key + "' not found!") }
      return value
    } catch {
      debugPrint(error)
    }

    return key
  }
}
