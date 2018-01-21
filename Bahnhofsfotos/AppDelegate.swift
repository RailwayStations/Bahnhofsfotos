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
    connectToFcm()

    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
    }

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
    // or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    Messaging.messaging().disconnect()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
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

  func application(application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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

  func connectToFcm() {
    // Won't connect since there is no token
    guard Messaging.messaging().apnsToken != nil else {
      return
    }

    // Disconnect previous FCM connection if it exists.
    Messaging.messaging().disconnect()

    Messaging.messaging().connect { error in
      if error != nil {
        debugPrint("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
      } else {
        debugPrint("Connected to FCM.")
      }
    }
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
