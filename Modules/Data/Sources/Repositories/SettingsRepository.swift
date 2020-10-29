//
//  SettingsRepository.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 25.10.20.
//  Copyright © 2020 Railway-Stations. All rights reserved.
//

import Domain
import SwiftyUserDefaults

public final class SettingsRepository: SettingsRepositoryType {
    public init() {}

    public var isDataComplete: Bool { Defaults.dataComplete }
}
