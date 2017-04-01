//
//  ProfileWrapperViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 30.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import UIKit

class ProfileWrapperViewController: UIViewController {

  @IBAction func showMenu(_ sender: Any) {
      sideMenuViewController?.presentLeftMenuViewController()
  }

}
