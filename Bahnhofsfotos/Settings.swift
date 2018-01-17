//
//  Settings.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 29.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import SwiftyUserDefaults

enum License: String {
  case cc0, cc40
  static let allValues = [cc0, cc40]
}

enum AccountType: String {
  case none = "Kein"
  case twitter = "Twitter"
  case facebook = "Facebook"
  case instagram = "Instagram"
  case snapchat = "Snapchat"
  case xing = "Xing"
  case web = "Web"
  case misc = "Sonstiges"
}

class Settings {

  static let shared = Settings()

  init() {
    if Defaults[.country] == "" {
      Defaults[.country] = "DE"
    }
    if Defaults[.accountType] == nil {
      Defaults[.accountType] = AccountType.none
    }
  }

}

extension UserDefaults {
  subscript(key: DefaultsKey<License?>) -> License? {
    get { return unarchive(key) }
    set { archive(key, newValue) }
  }

  subscript(key: DefaultsKey<AccountType?>) -> AccountType? {
    get { return unarchive(key) }
    set { archive(key, newValue) }
  }
}

extension DefaultsKeys {
  static let country = DefaultsKey<String>("country")
  static let lastUpdate = DefaultsKey<Date?>("lastUpdate")
  static let dataComplete = DefaultsKey<Bool>("dataComplete")
  static let license = DefaultsKey<License?>("license")
  static let accountLinking = DefaultsKey<Bool>("accountLinking")
  static let accountType = DefaultsKey<AccountType?>("accountType")
  static let accountName = DefaultsKey<String?>("accountName")
  static let chatNotificationsEnabled = DefaultsKey<Bool>("chatNotificationsEnabled")
}
