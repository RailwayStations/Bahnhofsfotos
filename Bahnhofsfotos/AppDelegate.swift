//
//  AppDelegate.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import FirebaseAnalytics
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import SwiftyUserDefaults
import TwitterKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Get SQLite data
    try? CountryStorage.fetchAll()
    if Defaults[.dataComplete] {
      try? StationStorage.fetchAll()
    }

    // Use Firebase library to configure APIs
    FirebaseApp.configure()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    Messaging.messaging().delegate = self

    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
    }
    
    // Initialize TwitterKit
    TWTRTwitter.sharedInstance().start(withConsumerKey: Secret.twitterKey, consumerSecret: Secret.twitterSecret)

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
      return true
    }
    return application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
  }

  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.

    showAlert(withUserInfo: userInfo)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.

    showAlert(withUserInfo: userInfo)

    completionHandler(UIBackgroundFetchResult.newData)
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
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
        Defaults[.uploadToken] = token

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

  func showAlert(withUserInfo userInfo: [AnyHashable: Any]) {
//    let apsKey = "aps"
//    let gcmMessage = "alert"
//    let gcmLabel = "google.c.a.c_l"
//
//    if let aps = userInfo[apsKey] as? NSDictionary {
//      if let message = aps[gcmMessage] as? String {
//        DispatchQueue.main.async {
//          let alert = UIAlertController(title: userInfo[gcmLabel] as? String ?? "",
//                                        message: message, preferredStyle: .alert)
//          let dismissAction = UIAlertAction(title: "Schließen", style: .destructive, handler: nil)
//          alert.addAction(dismissAction)
//          Helper.rootViewController?.present(alert, animated: true, completion: nil)
//        }
//      }
//    }
  }

}

// MARK: - GIDSignInDelegate
extension AppDelegate: GIDSignInDelegate {

  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
    if let error = error {
      debugPrint("Error \(error)")
      return
    }

    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                      accessToken: authentication.accessToken)
    Auth.auth().signIn(with: credential) { _, error in
      if let error = error {
        debugPrint("Error \(error)")
        return
      }
    }
  }

}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {

  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    showAlert(withUserInfo: remoteMessage.appData)
  }

}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    showAlert(withUserInfo: userInfo)

    // Change this to your preferred presentation option
    completionHandler([])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    showAlert(withUserInfo: userInfo)

    completionHandler()
  }

}
