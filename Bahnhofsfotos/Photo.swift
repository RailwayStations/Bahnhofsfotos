//
//  Photo.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 22.01.18.
//  Copyright © 2018 Railway-Stations. All rights reserved.
//

import Foundation

class Photo {
  
  var id: Int
  var uploadedAt: Date?
  var data: Data
  
  init(data: Data, withId id: Int, uploadedAt: Date? = nil) {
    self.id = id
    self.data = data
    self.uploadedAt = uploadedAt
  }

}
