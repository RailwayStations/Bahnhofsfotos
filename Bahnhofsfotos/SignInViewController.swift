//
//  SignInViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 20.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import FirebaseAuth
import GoogleSignIn

class SignInViewController: UIViewController {

  @IBOutlet weak var signInButton: GIDSignInButton!
  var handle: AuthStateDidChangeListenerHandle?

  override func viewDidLoad() {
    super.viewDidLoad()

    GIDSignIn.sharedInstance().uiDelegate = self
    handle = Auth.auth().addStateDidChangeListener { _, user in
      self.show(loading: false)
      if user != nil {
        self.navigationController?.pushViewController(Helper.viewController(withIdentifier: Constants.StoryboardIdentifiers.chatViewController), animated: true)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  deinit {
    if let handle = handle {
      Auth.auth().removeStateDidChangeListener(handle)
    }
  }

  func show(loading: Bool) {
    Helper.setIsUserInteractionEnabled(in: self, to: !loading)
    if loading {
      view.makeToastActivity(.center)
    } else {
      view.hideToastActivity()
    }
  }

}

// MARK: - GIDSignInUIDelegate
extension SignInViewController: GIDSignInUIDelegate {

  func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
    show(loading: true)
  }

}
