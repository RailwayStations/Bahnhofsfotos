//  This file was automatically generated and should not be edited.

import Apollo

public final class StationPhotoQuery: GraphQLQuery {
  public static let operationString =
    "query StationPhoto($number: Int!) {\n  stationWithStationNumber(stationNumber: $number) {\n    __typename\n    picture {\n      __typename\n      url\n    }\n  }\n}"

  public var number: Int

  public init(number: Int) {
    self.number = number
  }

  public var variables: GraphQLMap? {
    return ["number": number]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("stationWithStationNumber", arguments: ["stationNumber": GraphQLVariable("number")], type: .object(StationWithStationNumber.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(stationWithStationNumber: StationWithStationNumber? = nil) {
      self.init(snapshot: ["__typename": "Query", "stationWithStationNumber": stationWithStationNumber.flatMap { $0.snapshot }])
    }

    public var stationWithStationNumber: StationWithStationNumber? {
      get {
        return (snapshot["stationWithStationNumber"] as? Snapshot).flatMap { StationWithStationNumber(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "stationWithStationNumber")
      }
    }

    public struct StationWithStationNumber: GraphQLSelectionSet {
      public static let possibleTypes = ["Station"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("picture", type: .object(Picture.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(picture: Picture? = nil) {
        self.init(snapshot: ["__typename": "Station", "picture": picture.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var picture: Picture? {
        get {
          return (snapshot["picture"] as? Snapshot).flatMap { Picture(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "picture")
        }
      }

      public struct Picture: GraphQLSelectionSet {
        public static let possibleTypes = ["Picture"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(url: String) {
          self.init(snapshot: ["__typename": "Picture", "url": url])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var url: String {
          get {
            return snapshot["url"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "url")
          }
        }
      }
    }
  }
}