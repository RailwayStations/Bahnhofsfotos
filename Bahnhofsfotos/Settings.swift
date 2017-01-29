//
//  Settings.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 29.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import SwiftyUserDefaults

enum License: String {
    case cc0, cc4_0
}

enum AccountType: String {
    case none
    case twitter
    case facebook
    case instagram
    case snapchat
    case xing
    case web
    case misc
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
    static let dataComplete = DefaultsKey<Bool>("dataComplete")
    static let lastUpdate = DefaultsKey<Date?>("lastUpdate")
    static let license = DefaultsKey<License?>("license")
    static let accountType = DefaultsKey<AccountType?>("accountType")
    static let accountLink = DefaultsKey<String>("accountLink")
}

