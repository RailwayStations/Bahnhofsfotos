//
//  MenuItem.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 19.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

class MenuItem {
    
    typealias Action = (_ sender: Any?) -> Void
    
    private var _key: String
    var key: String {
        return _key
    }
    
    private var _title: String
    var title: String {
        return _title
    }
    
    let action: Action
    
    init(key: String, title: String, action: @escaping Action) {
        self._key = key
        self._title = title
        self.action = action
    }
}
