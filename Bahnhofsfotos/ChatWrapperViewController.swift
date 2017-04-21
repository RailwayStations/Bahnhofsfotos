//
//  ChatWrapperViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 21.04.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import UIKit

class ChatWrapperViewController: UIViewController {

  @IBAction func showMenu(_ sender: Any) {
    sideMenuViewController?.presentLeftMenuViewController()
  }

  @IBAction func signOut(_ sender: Any) {
    Helper.signOut()
  }

}
