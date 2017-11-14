//
//  ChatWrapperViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import FirebaseMessaging
import SwiftyUserDefaults
import UIKit

class ChatWrapperViewController: UIViewController {

  @IBOutlet weak var notificationButton: UIButton!

  @IBAction func showMenu(_ sender: Any) {
    sideMenuViewController?.presentLeftMenuViewController()
  }

  @IBAction func signOut(_ sender: Any) {
    Helper.signOut()
  }

  @IBAction func toggleNotification() {
    // TODO: https://developers.google.com/instance-id/reference/server#get_information_about_app_instances
    if Defaults[.chatNotificationsEnabled] {
      Messaging.messaging().unsubscribe(fromTopic: Constants.fcmTopic)
      Defaults[.chatNotificationsEnabled] = false
    } else {
      Messaging.messaging().subscribe(toTopic: Constants.fcmTopic)
      Defaults[.chatNotificationsEnabled] = true
    }

    showNotificationButton()
  }

  override func viewDidLoad() {
    showNotificationButton()
  }

  func showNotificationButton() {
    if Defaults[.chatNotificationsEnabled] {
      notificationButton.fa_setTitle(.fa_bell_slash, for: .normal)
    } else {
      notificationButton.fa_setTitle(.fa_bell, for: .normal)
    }

    notificationButton.titleLabel?.font = UIFont(fa_fontSize: 17)
  }

}
