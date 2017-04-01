//
//  StationStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import SQLite
import SwiftyJSON

class StationStorage {

  enum StorageError: Error {
    case message(String?)
  }

  static var lastUpdatedAt: Date?

  private static var _stationsWithoutPhoto: [Station] = []
  static var stationsWithoutPhoto: [Station] {
    return _stationsWithoutPhoto
  }
  static var currentStation: Station?

  // SQLite properties
  private static let table = Table("station")
  private static let fileName = Constants.dbFilename
  fileprivate static let expressionId = Expression<Int>(Constants.JsonConstants.kId)
  fileprivate static let expressionCountry = Expression<String>(Constants.JsonConstants.kCountryName)
  fileprivate static let expressionTitle = Expression<String>(Constants.JsonConstants.kTitle)
  fileprivate static let expressionLat = Expression<Double>(Constants.JsonConstants.kLat)
  fileprivate static let expressionLon = Expression<Double>(Constants.JsonConstants.kLon)

  // Open connection to database
  private static func openConnection() throws -> Connection {

    // find path to SQLite database
    guard let path = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true)
      .first else {
        throw StorageError.message("Path not found.")
      }

    // open connection
    let db = try Connection("\(path)/\(fileName)")

    // create table if not exists
    try db.run(table.create(ifNotExists: true) { table in
      table.column(expressionId, primaryKey: .autoincrement)
      table.column(expressionCountry)
      table.column(expressionTitle)
      table.column(expressionLat)
      table.column(expressionLon)
    })

    // return connection
    return db
  }

  // Remove all
  static func removeAll() throws {
    let db = try openConnection()
    try db.run(table.delete())

    lastUpdatedAt = Date()
  }

  // Fetch all stations
  static func fetchAll() throws {
    let db = try openConnection()

    _stationsWithoutPhoto.removeAll()

    for station in try db.prepare(table) {
      let s = Station.from(row: station)
      _stationsWithoutPhoto.append(s)
    }

    _stationsWithoutPhoto = _stationsWithoutPhoto.sorted { $0.title < $1.title }

    lastUpdatedAt = Date()
  }

  // Save a station
  static func create(station: Station) throws {
    let db = try openConnection()

    try db.run(table.insert(or: .replace,
                            expressionId <- station.id,
                            expressionTitle <- station.title,
                            expressionCountry <- station.country,
                            expressionLat <- station.lat,
                            expressionLon <- station.lon
    ))

    if let stationIdToUpdate = _stationsWithoutPhoto.index(where: { $0.id == station.id }) {
      _stationsWithoutPhoto.remove(at: stationIdToUpdate)
      _stationsWithoutPhoto.insert(station, at: stationIdToUpdate)
    } else {
      _stationsWithoutPhoto.append(station)
      _stationsWithoutPhoto = _stationsWithoutPhoto.sorted { $0.title < $1.title }
    }

    lastUpdatedAt = Date()
  }

  // Save stations
  static func create(stations: [Station], progressHandler: ((Int) -> Void)? = nil) throws {
    let db = try openConnection()

    try db.transaction {
      var counter = 0
      for station in stations {
        counter += 1
        progressHandler?(counter)
        try db.run(table.insert(or: .replace,
                                expressionId <- station.id,
                                expressionTitle <- station.title,
                                expressionCountry <- station.country,
                                expressionLat <- station.lat,
                                expressionLon <- station.lon
        ))

        if let stationIdToUpdate = _stationsWithoutPhoto.index(where: { $0.id == station.id }) {
          _stationsWithoutPhoto.remove(at: stationIdToUpdate)
          _stationsWithoutPhoto.insert(station, at: stationIdToUpdate)
        } else {
          _stationsWithoutPhoto.append(station)
        }
      }
    }

    _stationsWithoutPhoto = _stationsWithoutPhoto.sorted { $0.title < $1.title }

    lastUpdatedAt = Date()
  }

  static func delete(station: Station) throws {
    let db = try openConnection()

    let s = table.filter(expressionId == station.id)
    try db.run(s.delete())

    if let stationIdToDelete = _stationsWithoutPhoto.index(where: { $0.id == station.id }) {
      _stationsWithoutPhoto.remove(at: stationIdToDelete)
    }

    lastUpdatedAt = Date()
  }

}

// MARK: - Station extension
extension Station {

  func save() throws {
    try StationStorage.create(station: self)
  }

  static func from(row: Row) -> Station {
    return Station(id: row.get(StationStorage.expressionId),
                   title: row.get(StationStorage.expressionTitle),
                   country: row.get(StationStorage.expressionCountry),
                   lat: row.get(StationStorage.expressionLat),
                   lon: row.get(StationStorage.expressionLon)
    )
  }

}
