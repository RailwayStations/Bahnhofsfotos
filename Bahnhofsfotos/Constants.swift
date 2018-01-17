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
    public static let kId = "id"
    public static let kCountry = "country"
    public static let kTitle = "title"
    public static let kLat = "lat"
    public static let kLon = "lon"
    public static let kPhotographer = "photographer"
    public static let kPhotographerUrl = "photographerUrl"
    public static let kPhotoUrl = "photoUrl"
    public static let kLicense = "license"
    public static let kDS100 = "DS100"

    //Länderkonstanten
    public static let kCountryCode = "code"
    public static let kCountryName = "name"
    public static let kCountryEmail = "email"
    public static let kCountryTwitterTags = "twitterTags"
    public static let kCountryTimetableUrlTemplate = "timetableUrlTemplate"
  }

  public static let dbFilename = "db.sqlite3"

  // Links zusammenschrauben
  public static let baseUrl = "https://api.railway-stations.org"

  struct StoryboardIdentifiers {
    static let profileViewController = "SettingsViewController"
    static let listViewController = "ListViewController"
    static let mapViewController = "MapViewController"
    static let signInViewController = "SignInViewController"
    static let chatViewController = "ChatViewController"
    static let highScoreViewController = "HighScoreViewController"
  }

//  public static let fcmTopic = "for_tests"
  public static let fcmTopic = "friendly_engage"

  struct MessageFields {
    static let userId = "userId"
    static let name = "name"
    static let text = "text"
    static let photoURL = "photoUrl"
    static let chatTimeStamp = "chatTimeStamp"
  }

}
