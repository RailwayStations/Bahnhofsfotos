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
    private static let table = Table("stations")
    private static let fileName = "db.sqlite3"
    fileprivate static let expressionId = Expression<Int>("id")
    fileprivate static let expressionCountry = Expression<String>("country")
    fileprivate static let expressionTitle = Expression<String>("title")
    fileprivate static let expressionLat = Expression<Double>("lat")
    fileprivate static let expressionLon = Expression<Double>("lon")
    fileprivate static let expressionHasPhoto = Expression<Bool>("hasPhoto")
    fileprivate static let expressionPhotographer = Expression<String?>("photographer")
    fileprivate static let expressionDate = Expression<Date?>("datum")

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
        try db.run(table.create(ifNotExists: true) { t in
            t.column(expressionId, primaryKey: .autoincrement)
            t.column(expressionCountry)
            t.column(expressionTitle)
            t.column(expressionLat)
            t.column(expressionLon)
            t.column(expressionHasPhoto)
            t.column(expressionPhotographer)
            t.column(expressionDate)
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
            expressionLon <- station.lon,
            expressionHasPhoto <- station.hasPhoto
        ))

        if let stationIdToUpdate = _stationsWithoutPhoto.index(where: { $0.id == station.id }) {
            _stationsWithoutPhoto.remove(at: stationIdToUpdate)
            _stationsWithoutPhoto.insert(station, at: stationIdToUpdate)
        }else {
            _stationsWithoutPhoto.append(station)
        }

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
                       lon: row.get(StationStorage.expressionLon),
                       hasPhoto: row.get(StationStorage.expressionHasPhoto)
                )
    }
    
}
