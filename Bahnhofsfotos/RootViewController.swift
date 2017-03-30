//
//  RootViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 14.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import AKSideMenu

class RootViewController: AKSideMenu {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override public func awakeFromNib() {
        contentViewController = storyboard?.instantiateViewController(withIdentifier: "ListViewController")
        leftMenuViewController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuViewController")
    }
    
}
