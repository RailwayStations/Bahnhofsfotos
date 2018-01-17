//
//  ChatWrapperViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import FirebaseMessaging
import FontAwesomeKit_Swift
import SwiftyUserDefaults
import UIKit
import UserNotifications

class ChatWrapperViewController: UIViewController {

  @objc func signOut() {
    if Helper.signOut() {
      navigationController?.popViewController(animated: true)
    }
  }

  @objc func toggleNotification() {
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    if #available(iOS 10.0, *) {
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
    } else {
      let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
    }
    UIApplication.shared.registerForRemoteNotifications()
    
    // TODO: https://developers.google.com/instance-id/reference/server#get_information_about_app_instances
    if Defaults[.chatNotificationsEnabled] {
      Messaging.messaging().unsubscribe(fromTopic: Constants.fcmTopic)
      Defaults[.chatNotificationsEnabled] = false
    } else {
      Messaging.messaging().subscribe(toTopic: Constants.fcmTopic)
      Defaults[.chatNotificationsEnabled] = true
    }

    showNavigationButtons()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Chat"
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    navigationItem.hidesBackButton = true
    
    showNavigationButtons()
  }

  func showNavigationButtons() {
    let signOutButton = UIBarButtonItem(awesomeType: .fa_sign_out, size: 18, style: .plain, target: self, action: #selector(signOut))
    let notificationButton = UIBarButtonItem(awesomeType: (Defaults[.chatNotificationsEnabled] ? .fa_bell_slash : .fa_bell), size: 18, style: .plain, target: self, action: #selector(toggleNotification))
    
    navigationItem.rightBarButtonItems = [signOutButton, notificationButton]
  }

}
