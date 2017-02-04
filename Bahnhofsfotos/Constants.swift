//
//  Constants.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

public class Constants {

    public final class DB_JSON_CONSTANTS {

        //Bahnhofs-Konstanten
        public static let KEY_ROWID = "rowid"
        public static let KEY_ID = "id"
        public static let KEY_TITLE = "title"
        public static let KEY_LAT = "lat"
        public static let KEY_LON = "lon"
        public static let KEY_DATE = "datum"
        public static let KEY_PHOTOFLAG = "photoflag"
        public static let KEY_PHOTOGRAPHER = "photographer"

        //Länderkonstanten
        public static let KEY_COUNTRYNAME = "country"
        public static let KEY_COUNTRYSHORTCODE = "countryflag"
        public static let KEY_EMAIL = "mail"
        public static let KEY_TWITTERTAGS = "twitter_tags"
        public static let KEY_ROWID_COUNTRIES = "rowidcountries"
    }

    public static let DB_FILENAME = "db.sqlite3"

    // Links zusammenschrauben
    public static let BASE_URL = "https://api.railway-stations.org"
    public static let COUNTRIES_URL = "https://railway-stations.org/laenderdaten.json"

}
