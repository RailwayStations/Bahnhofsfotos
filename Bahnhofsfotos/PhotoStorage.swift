//
//  PhotoStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.01.18.
//  Copyright © 2018 Railway-Stations. All rights reserved.
//

import SQLite

class PhotoStorage {

  private enum StorageError: Error {
    case message(String?)
  }

  // SQLite properties
  private static let table = Table("photos")
  private static let fileName = Constants.dbFilename
  private static let exId = Expression<Int>("id")
  private static let exUploadedAt = Expression<Date?>("uploadedAt")
  private static let exPhoto = Expression<Blob>("photo")

  // Open connection to database
  private static func openConnection() throws -> Connection {

    // find path to SQLite database
    guard let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask,  true)
      .first else {
        throw StorageError.message("Path not found.")
    }

    // open connection
    let db = try Connection("\(path)/\(fileName)")

    // create table if not exists
    try db.run(table.create(ifNotExists: true) { table in
      table.column(exId, primaryKey: .autoincrement)
      table.column(exUploadedAt)
      table.column(exPhoto)
    })

    // return connection
    return db
  }

  // Remove all
  static func removeAll() throws {
    let db = try openConnection()
    try db.run(table.delete())
  }

  // Save a photo
  static func save(_ photo: Photo) throws {
    let db = try openConnection()

    try db.run(table.insert(or: .replace,
                            exId <- photo.id,
                            exPhoto <- photo.data.datatypeValue
    ))
  }

  // Reads a photo
  static func fetch(id: Int) throws -> Photo? {
    let db = try openConnection()

    if let photo = try db.pluck(table.filter(exId == id)) {
      return Photo(data: Data.fromDatatypeValue(try photo.get(exPhoto)),
                   withId: try photo.get(exId),
                   uploadedAt: try photo.get(exUploadedAt))
    }

    return nil
  }

  // Delete a photo
  static func delete(_ photo: Photo) throws {
    let db = try openConnection()

    let p = table.filter(exId == photo.id)
    try db.run(p.delete())
  }

}
