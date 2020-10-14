//
//  Settings.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 29.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import SwiftyUserDefaults

enum License: String, DefaultsSerializable {
  case cc0
}

enum AccountType: String, DefaultsSerializable {
  case none = "Kein"
  case twitter = "Twitter"
  case facebook = "Facebook"
  case instagram = "Instagram"
  case snapchat = "Snapchat"
  case xing = "Xing"
  case web = "Web"
  case misc = "Sonstiges"
}

extension DefaultsKeys {
  var country: DefaultsKey<String> { .init("country", defaultValue: "") }
  var lastUpdate: DefaultsKey<Date?> { .init("lastUpdate") }
  var dataComplete: DefaultsKey<Bool> { .init("dataComplete", defaultValue: false) }
  var license: DefaultsKey<License> { .init("license", defaultValue: .cc0) }
  var photoOwner: DefaultsKey<Bool> { .init("photoOwner", defaultValue: true) }
  var accountLinking: DefaultsKey<Bool> { .init("accountLinking", defaultValue: false) }
  var accountType: DefaultsKey<AccountType> { .init("accountType", defaultValue: .none) }
  var accountName: DefaultsKey<String?> { .init("accountName") }
  var accountNickname: DefaultsKey<String?> { .init("accountNickname") }
  var accountEmail: DefaultsKey<String?> { .init("accountEmail") }
  var uploadToken: DefaultsKey<String?> { .init("uploadToken") }
  var uploadTokenRequested: DefaultsKey<Date?> { .init("uploadTokenRequested") }
}
