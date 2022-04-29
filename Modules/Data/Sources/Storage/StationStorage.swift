//
//  StationStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 17.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Domain
import Foundation
import Shared
import SQLite

public class StationStorage {
    enum StorageError: Error {
        case message(String?)
    }

    public static var lastUpdatedAt: Date?

    private static var _stations: [Station] = []
    public static var stations: [Station] {
        return _stations
    }
    public static var currentStation: Station?

    // SQLite properties
    private static let table = Table("station")
    private static let fileName = Constants.dbFilename
    fileprivate static let expressionId = Expression<Int>(Constants.JsonConstants.kId)
    fileprivate static let expressionCountry = Expression<String>(Constants.JsonConstants.kCountryName)
    fileprivate static let expressionTitle = Expression<String>(Constants.JsonConstants.kTitle)
    fileprivate static let expressionLat = Expression<Double>(Constants.JsonConstants.kLat)
    fileprivate static let expressionLon = Expression<Double>(Constants.JsonConstants.kLon)
    fileprivate static let expressionPhotographer = Expression<String?>(Constants.JsonConstants.kPhotographer)
    fileprivate static let expressionPhotographerUrl = Expression<String?>(Constants.JsonConstants.kPhotographerUrl)
    fileprivate static let expressionPhotoUrl = Expression<String?>(Constants.JsonConstants.kPhotoUrl)
    fileprivate static let expressionLicense = Expression<String?>(Constants.JsonConstants.kLicense)
    fileprivate static let expressionDS100 = Expression<String?>(Constants.JsonConstants.kDS100)

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
            table.column(expressionPhotographer)
            table.column(expressionPhotographerUrl)
            table.column(expressionPhotoUrl)
            table.column(expressionLicense)
            table.column(expressionDS100)
        })

        // return connection
        return db
    }

    // Remove all
    public static func removeAll() throws {
        let db = try openConnection()
        try db.run(table.delete())

        lastUpdatedAt = Date()
    }

    // Fetch all stations
    public static func fetchAll() throws {
        let db = try openConnection()

        _stations.removeAll()

        for station in try db.prepare(table) {
            let s = Station.from(row: station)
            _stations.append(s)
        }

        _stations = _stations.sorted { $0.name < $1.name }

        lastUpdatedAt = Date()
    }

    // Save a station
    public static func create(station: Station) throws {
        let db = try openConnection()

        try db.run(table.insert(or: .replace,
                                expressionId <- station.id,
                                expressionTitle <- station.name,
                                expressionCountry <- station.country,
                                expressionLat <- station.lat,
                                expressionLon <- station.lon,
                                expressionPhotographer <- station.photographer,
                                expressionPhotographerUrl <- station.photographerUrl,
                                expressionPhotoUrl <- station.photoUrl,
                                expressionLicense <- station.license,
                                expressionDS100 <- station.DS100
        ))

        if let stationIdToUpdate = _stations.firstIndex(where: { $0.id == station.id }) {
            _stations.remove(at: stationIdToUpdate)
            _stations.insert(station, at: stationIdToUpdate)
        } else {
            _stations.append(station)
            _stations = _stations.sorted { $0.name < $1.name }
        }

        lastUpdatedAt = Date()
    }

    // Save stations
    public static func create(stations: [Station], progressHandler: ((Int) -> Void)? = nil) throws {
        let db = try openConnection()

        try db.transaction {
            var counter = 0
            for station in stations {
                counter += 1
                progressHandler?(counter)
                try db.run(table.insert(or: .replace,
                                        expressionId <- station.id,
                                        expressionTitle <- station.name,
                                        expressionCountry <- station.country,
                                        expressionLat <- station.lat,
                                        expressionLon <- station.lon,
                                        expressionPhotographer <- station.photographer,
                                        expressionPhotographerUrl <- station.photographerUrl,
                                        expressionPhotoUrl <- station.photoUrl,
                                        expressionLicense <- station.license,
                                        expressionDS100 <- station.DS100
                ))

                if let stationIdToUpdate = _stations.firstIndex(where: { $0.id == station.id }) {
                    _stations.remove(at: stationIdToUpdate)
                    _stations.insert(station, at: stationIdToUpdate)
                } else {
                    _stations.append(station)
                }
            }
        }

        _stations = _stations.sorted { $0.name < $1.name }

        lastUpdatedAt = Date()
    }

    public static func delete(station: Station) throws {
        let db = try openConnection()

        let s = table.filter(expressionId == station.id)
        try db.run(s.delete())

        if let stationIdToDelete = _stations.firstIndex(where: { $0.id == station.id }) {
            _stations.remove(at: stationIdToDelete)
        }

        lastUpdatedAt = Date()
    }
}

// MARK: - Station extension
public extension Station {
    func save() throws {
        try StationStorage.create(station: self)
    }

    static func from(row: Row) -> Station {
        .init(
            id: try! row.get(StationStorage.expressionId),
            name: try! row.get(StationStorage.expressionTitle),
            country: try! row.get(StationStorage.expressionCountry),
            lat: try! row.get(StationStorage.expressionLat),
            lon: try! row.get(StationStorage.expressionLon),
            photographer: try! row.get(StationStorage.expressionPhotographer),
            photographerUrl: try! row.get(StationStorage.expressionPhotographerUrl),
            photoUrl: try! row.get(StationStorage.expressionPhotoUrl),
            license: try! row.get(StationStorage.expressionLicense),
            DS100: try! row.get(StationStorage.expressionDS100)
        )
    }
}
