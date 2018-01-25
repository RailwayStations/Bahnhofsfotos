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

extension UserDefaults {
  subscript(key: DefaultsKey<License>) -> License {
    get { return unarchive(key) ?? License.cc0 }
    set { archive(key, newValue) }
  }

  subscript(key: DefaultsKey<AccountType>) -> AccountType {
    get { return unarchive(key) ?? AccountType.none }
    set { archive(key, newValue) }
  }
}

extension DefaultsKeys {
  static let country = DefaultsKey<String>("country")
  static let lastUpdate = DefaultsKey<Date?>("lastUpdate")
  static let dataComplete = DefaultsKey<Bool>("dataComplete")
  static let license = DefaultsKey<License>("license")
  static let photoOwner = DefaultsKey<Bool>("photoOwner")
  static let accountLinking = DefaultsKey<Bool>("accountLinking")
  static let accountType = DefaultsKey<AccountType>("accountType")
  static let accountName = DefaultsKey<String?>("accountName")
  static let accountNickname = DefaultsKey<String?>("accountNickname")
  static let accountEmail = DefaultsKey<String?>("accountEmail")
  static let chatNotificationsEnabled = DefaultsKey<Bool>("chatNotificationsEnabled")
  static let uploadToken = DefaultsKey<String?>("uploadToken")
  static let uploadTokenRequested = DefaultsKey<Date?>("uploadTokenRequested")
}
