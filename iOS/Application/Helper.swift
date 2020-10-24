//
//  Helper.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 24.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import MapKit
import SwiftyUserDefaults
import UIKit

class Helper {

  static var tintColor: UIColor {
    return UIColor(red: 167.0/255.0, green: 58.0/255.0, blue: 88/255.0, alpha: 1.0)
  }

  static var greenColor: UIColor {
    return UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
  }

  static var blueColor: UIColor {
    return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
  }

  static var alternativeTintColor: UIColor {
    return UIColor(red: 212/255.0, green: 222/255.0, blue: 59/255.0, alpha: 1.0)
  }

  static func viewController(withIdentifier identifier: String) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
    return viewController
  }

  // Disables the view for user interaction
  static func setIsUserInteractionEnabled(in viewController: UIViewController, to enabled: Bool) {
    viewController.view.isUserInteractionEnabled = enabled
    viewController.navigationController?.view.isUserInteractionEnabled = enabled
  }

  static func openNavigation(to station: Station) {
    let placemark = MKPlacemark(coordinate: station.coordinate, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = station.name
    mapItem.openInMaps(launchOptions: [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
      MKLaunchOptionsShowsTrafficKey: true
      ])
  }

}

extension Date {

  // Get date string based on (to)day
  var relativeDateString: String {
    if Calendar.current.isDateInToday(self) {
      return DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
    } else {
      return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }
  }

}
