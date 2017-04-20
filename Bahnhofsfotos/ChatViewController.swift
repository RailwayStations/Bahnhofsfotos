//
//  ChatViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 20.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import FirebaseAuth
import UIKit

class ChatViewController: UIViewController {

  @IBAction func showMenu(_ sender: Any) {
    sideMenuViewController?.presentLeftMenuViewController()
  }

  @IBAction func signOut(_ sender: Any) {
    let firebaseAuth = FIRAuth.auth()
    do {
      try firebaseAuth?.signOut()
      Helper.showViewController(withIdentifier: Constants.StoryboardIdentifiers.signInViewController)
    } catch let signOutError as NSError {
      print ("Error signing out: \(signOutError.localizedDescription)")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    guard FIRAuth.auth()?.currentUser != nil else {
      Helper.showViewController(withIdentifier: Constants.StoryboardIdentifiers.signInViewController)
      return
    }
  }

}
