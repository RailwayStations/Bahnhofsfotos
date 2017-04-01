//
//  CountryStorage.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 30.01.17.
//  Copyright © 2017 MrHaitec. All rights reserved.
//

import SQLite
import SwiftyJSON
import SwiftyUserDefaults

class CountryStorage {

    enum CountryError: Error {
        case message(String?)
    }

    static var lastUpdatedAt: Date?

    private static var _countries: [Country] = []
    static var countries: [Country] {
        return _countries
    }
    static var currentCountry: Country? {
        return CountryStorage.countries.first(where: { (country) -> Bool in
            country.countryflag == Defaults[.country]
        })
    }

    // SQLite properties
    private static let table = Table("country")
    private static let fileName = Constants.dbFilename
    fileprivate static let expressionCountryFlag = Expression<String>(Constants.JsonConstants.kCountryShortcode)
    fileprivate static let expressionCountry = Expression<String>(Constants.JsonConstants.kCountryName)
    fileprivate static let expressionMail = Expression<String?>(Constants.JsonConstants.kEmail)
    fileprivate static let expressionTwitterTags = Expression<String?>(Constants.JsonConstants.kTwitterTags)

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

        // create table if not exists
        try db.run(table.create(ifNotExists: true) { table in
            table.column(expressionCountryFlag, primaryKey: true)
            table.column(expressionCountry)
            table.column(expressionMail)
            table.column(expressionTwitterTags)
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

        _countries.removeAll()

        for country in try db.prepare(table) {
            let c = Country.from(row: country)
            _countries.append(c)
        }

        _countries = _countries.sorted { $0.country < $1.country }

        lastUpdatedAt = Date()
    }

    // Save a station
    static func create(country: Country) throws {
        let db = try openConnection()

        try db.run(table.insert(expressionCountry <- country.country,
                                expressionCountryFlag <- country.countryflag,
                                expressionMail <- country.mail,
                                expressionTwitterTags <- country.twitterTags
        ))

        _countries.append(country)

        _countries = _countries.sorted { $0.country < $1.country }

        lastUpdatedAt = Date()
    }

}

// MARK: - Station extension
extension Country {

    func save() throws {
        try CountryStorage.create(country: self)
    }

    static func from(row: Row) -> Country {
        return Country(country: row.get(CountryStorage.expressionCountry),
                       countryflag: row.get(CountryStorage.expressionCountryFlag),
                       mail: row.get(CountryStorage.expressionMail),
                       twitterTags: row.get(CountryStorage.expressionTwitterTags)
        )
    }

}
