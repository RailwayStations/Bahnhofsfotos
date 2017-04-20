//
//  SignInViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 20.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import Firebase
import GoogleSignIn

class SignInViewController: UIViewController {

  @IBOutlet weak var signInButton: GIDSignInButton!
  var handle: FIRAuthStateDidChangeListenerHandle?

  @IBAction func showMenu(_ sender: Any) {
    sideMenuViewController?.presentLeftMenuViewController()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    GIDSignIn.sharedInstance().uiDelegate = self
    handle = FIRAuth.auth()?.addStateDidChangeListener { _, user in
      self.show(loading: false)
      if user != nil {
        Helper.showViewController(withIdentifier: Constants.StoryboardIdentifiers.chatViewController)
      }
    }
  }

  deinit {
    if let handle = handle {
      FIRAuth.auth()?.removeStateDidChangeListener(handle)
    }
  }

  func show(loading: Bool) {
    Helper.setIsUserInteractionEnabled(in: Helper.rootViewController!, to: !loading)
    if loading {
      Helper.rootViewController?.view.makeToastActivity(.center)
    } else {
      Helper.rootViewController?.view.hideToastActivity()
    }
  }

}

// MARK: - GIDSignInUIDelegate
extension SignInViewController: GIDSignInUIDelegate {

  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    show(loading: true)
  }

}
