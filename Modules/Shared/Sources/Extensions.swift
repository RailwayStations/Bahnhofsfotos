//
//  Extensions.swift
//  
//
//  Created by Miguel Dönicke on 29.04.22.
//

import Foundation
import SwiftyUserDefaults

/// https://github.com/sunshinejr/SwiftyUserDefaults/issues/285
/// Workaround for error: `Type '...' does not conform to protocol 'DefaultsSerializable'`.

public extension DefaultsSerializable where Self: Codable {
    typealias Bridge = DefaultsCodableBridge<Self>
    typealias ArrayBridge = DefaultsCodableBridge<[Self]>
}

public extension DefaultsSerializable where Self: RawRepresentable {
    typealias Bridge = DefaultsRawRepresentableBridge<Self>
    typealias ArrayBridge = DefaultsRawRepresentableArrayBridge<[Self]>
}
