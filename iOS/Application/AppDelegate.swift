//
//  AppDelegate.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Data
import Domain
import Shared
import SwiftyUserDefaults
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    ReadCountriesAndStationsUseCase(
      countriesRepository: CountriesRepository(),
      stationsRepository: StationsRepository(),
      settingsRepository: SettingsRepository()
    ).readStationsOfCountry()

    return true
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      if let webURL = userActivity.webpageURL {
        if !present(url: webURL) {
          UIApplication.shared.openURL(webURL)
        }
      }
    }

    return true
  }

  private func present(url: URL) -> Bool {
    if let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
      // railway-stations.org/uploadToken/*
      guard components.host == "railway-stations.org" && url.pathComponents.count > 2 else { return false }

      switch (url.pathComponents[0], url.pathComponents[1], url.pathComponents[2]) {
      case ("/", "uploadToken", let token):
        // set upload token
        Defaults.uploadToken = token

        if let rootViewController = window?.rootViewController {
          // find and show settings view controller
          if let tabBarController = rootViewController as? UITabBarController {
            let index = tabBarController.childViewControllers.index { viewController -> Bool in
              return viewController.restorationIdentifier == Constants.StoryboardIdentifiers.settingsViewController
            }
            if let index = index {
              tabBarController.selectedIndex = index
            }
          }

          // show user success message
          let alert = UIAlertController(title: "Upload Token", message: "Der Upload Token wurde erfolgreich übertragen.", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
          rootViewController.present(alert, animated: true, completion: nil)
        }

        return true
      default:
        return false
      }
    }

    return false
  }

}
