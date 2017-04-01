//
//  Constants.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

public class Constants {

    public final class JsonConstants {

        //Bahnhofs-Konstanten
        public static let kRowId = "rowid"
        public static let kId = "id"
        public static let kTitle = "title"
        public static let kLat = "lat"
        public static let kLon = "lon"
        public static let kDate = "datum"
        public static let kPhotoflag = "photoflag"
        public static let kPhotohrapher = "photographer"

        //Länderkonstanten
        public static let kCountryName = "country"
        public static let kCountryShortcode = "countryflag"
        public static let kEmail = "mail"
        public static let kTwitterTags = "twitter_tags"
        public static let kRowIdContries = "rowidcountries"
    }

    public static let dbFilename = "db.sqlite3"

    // Links zusammenschrauben
    public static let baseUrl = "https://api.railway-stations.org"
    public static let countriesUrl = "https://railway-stations.org/laenderdaten.json"

}
