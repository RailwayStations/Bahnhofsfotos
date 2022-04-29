//
//  CountryStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 30.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import Domain
import Foundation
import Shared
import SQLite
import SwiftyUserDefaults

public class CountryStorage {
    enum CountryError: Error {
        case message(String?)
    }

    public static var lastUpdatedAt: Date?

    private static var _countries: [Country] = []
    public static var countries: [Country] {
        return _countries
    }
    public static var currentCountry: Country? {
        return CountryStorage.countries.first(where: { (country) -> Bool in
            country.code == Defaults.country
        })
    }

    // table name for "migration" ...
    private static let tableOldName = "country"
    private static let tableName = "country_3"

    // SQLite properties
    private static let fileName = Constants.dbFilename
    private static let tableOld = Table(tableOldName)
    private static let table = Table(tableName)
    fileprivate static let expressionCountryCode = Expression<String>(Constants.JsonConstants.kCountryCode)
    fileprivate static let expressionCountryName = Expression<String>(Constants.JsonConstants.kCountryName)
    fileprivate static let expressionMail = Expression<String?>(Constants.JsonConstants.kCountryEmail) // OLD
    fileprivate static let expressionEmail = Expression<String?>(Constants.JsonConstants.kCountryEmail)
    fileprivate static let expressionTwitterTags = Expression<String?>(Constants.JsonConstants.kCountryTwitterTags)
    fileprivate static let expressionTimetableUrlTemplate = Expression<String?>(Constants.JsonConstants.kCountryTimetableUrlTemplate)

    // Open connection to database
    private static func openConnection() throws -> Connection {

        // find path to SQLite database
        guard let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true)
                .first else {
            throw CountryError.message("Path not found.")
        }

        // open connection
        let db = try Connection("\(path)/\(fileName)")

        // delete old table if exists
        if tableOldName != tableName {
            try db.run(tableOld.drop(ifExists: true))
        }

        // create table if not exists
        try db.run(table.create(ifNotExists: true) { table in
            table.column(expressionCountryCode, primaryKey: true)
            table.column(expressionCountryName)
            table.column(expressionEmail)
            table.column(expressionTwitterTags)
            table.column(expressionTimetableUrlTemplate)
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

        _countries.removeAll()

        for country in try db.prepare(table) {
            let c = Country.from(row: country)
            _countries.append(c)
        }

        _countries = _countries.sorted { $0.name < $1.name }

        lastUpdatedAt = Date()
    }

    // Save a station
    public static func create(country: Country) throws {
        let db = try openConnection()

        try db.run(table.insert(expressionCountryName <- country.name,
                                expressionCountryCode <- country.code,
                                expressionEmail <- country.email,
                                expressionTwitterTags <- country.twitterTags,
                                expressionTimetableUrlTemplate <- country.timetableUrlTemplate
        ))

        _countries.append(country)

        _countries = _countries.sorted { $0.name < $1.name }

        lastUpdatedAt = Date()
    }
}

// MARK: - Country extension
public extension Country {
    func save() throws {
        try CountryStorage.create(country: self)
    }

    static func from(row: Row) -> Country {
        .init(
            name: try! row.get(CountryStorage.expressionCountryName),
            code: try! row.get(CountryStorage.expressionCountryCode),
            email: try! row.get(CountryStorage.expressionEmail),
            twitterTags: try! row.get(CountryStorage.expressionTwitterTags),
            timetableUrlTemplate: try! row.get(CountryStorage.expressionTimetableUrlTemplate)
        )
    }
}
