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

        //Länderkonstanten
        public static let KEY_COUNTRYNAME = "country"
        public static let KEY_COUNTRYSHORTCODE = "countryflag"
        public static let KEY_EMAIL = "mail"
        public static let KEY_TWITTERTAGS = "twitter_tags"
        public static let KEY_ROWID_COUNTRIES = "rowidcountries"
    }

    public static let BAHNHOEFE_OHNE_PHOTO_URL = "http://fotouebersicht.xn--deutschlands-bahnhfe-lbc.de/bahnhoefe-withoutPhoto.json"
    //public static let BAHNHOEFE_OHNE_PHOTO_URL = "http://fotouebersicht.xn--deutschlands-bahnhfe-lbc.de/de/bahnhoefe?hasPhoto=false"
    public static let INTERNATIONALE_BAHNHOEFE_OHNE_PHOTO_URL = "http://www.flying-snail.de/transit-train_station.json"
    public static let BAHNHOEFE_MIT_PHOTO_URL =  "http://fotouebersicht.xn--deutschlands-bahnhfe-lbc.de/bahnhoefe-withPhoto.json"
    //public static let BAHNHOEFE_MIT_PHOTO_URL =  "http://fotouebersicht.xn--deutschlands-bahnhfe-lbc.de/de/bahnhoefe?hasPhoto=true"

    // Links zusammenschrauben
    public static let BAHNHOEFE_START_URL = "http://fotouebersicht.xn--deutschlands-bahnhfe-lbc.de"
    public static let BAHNHOEFE_END_URL = "bahnhoefe?hasPhoto="
    public static let LAENDERDATEN_URL = "http://www.deutschlands-bahnhoefe.org/laenderdaten.json"

}
