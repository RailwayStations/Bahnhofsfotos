//
//  RootViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 14.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import AKSideMenu

class RootViewController: AKSideMenu {

  override public func awakeFromNib() {
    contentViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.listViewController)
    leftMenuViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.leftMenuViewController)
  }

}
