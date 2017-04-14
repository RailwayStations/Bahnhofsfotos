//
//  LeftMenuViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.03.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import AKSideMenu
import CPDAcknowledgements
import FontAwesomeKit_Swift
import SwiftyUserDefaults

class LeftMenuViewController: UIViewController {

  fileprivate let kCellIdentifier = "menuItemCell"

  let menu = [
    MenuItem(key: "update", title: "Bahnhofsdaten aktualisieren", action: LeftMenuViewController.loadData),
    MenuItem(key: "profile", title: "Deine Daten", action: LeftMenuViewController.openProfile),
    MenuItem(key: "map", title: "Karte", action: LeftMenuViewController.openMap),
    MenuItem(key: "list", title: "Bahnhöfe ohne Foto", action: LeftMenuViewController.openList),
    MenuItem(key: "infos", title: "Informationen", action: LeftMenuViewController.openInformations)
  ]

  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
  }

  // MARK: Helpers

  static func openProfile(_ sender: Any?) {
    Helper.showViewController(withIdentifier: "ProfileViewController")
  }

  static func loadData(_ sender: Any?) {
    let rowTitle = "Bahnhofsdaten aktualisieren"

    if let cell = sender as? UITableViewCell {

      if Helper.rootViewController != nil {
        Helper.setIsUserInteractionEnabled(in: Helper.rootViewController!, to: false)
        Helper.rootViewController?.view.makeToastActivity(.center)
      }

      cell.textLabel?.text = "Länderdaten herunterladen"
      cell.detailTextLabel?.text = nil

      Helper.loadCountries {
        cell.textLabel?.text = "Bahnhofsdaten herunterladen"

        Helper.loadStations(progressHandler: { progress, count in
          if progress < StationStorage.stationsWithoutPhoto.count {
            cell.textLabel?.text = "Bahnhof speichern: \(progress)/\(count)"
            cell.detailTextLabel?.text = "\(UInt(round(Float(progress) / Float(count) * 100)))%"
          }
        }) {
          cell.textLabel?.text = rowTitle
          if let lastUpdate = Defaults[.lastUpdate] {
            cell.detailTextLabel?.text = lastUpdate.relativeDateString
          }

          if Helper.rootViewController != nil {
            Helper.setIsUserInteractionEnabled(in: Helper.rootViewController!, to: true)
            Helper.rootViewController?.view.hideToastActivity()
          }
        }
      }
    }
  }

  static func openList(_ sender: Any?) {
    Helper.showViewController(withIdentifier: "ListViewController")
  }

  static func openMap(_ sender: Any?) {
    Helper.showViewController(withIdentifier: "MapViewController")
  }

  static func openInformations(_ sender: Any?) {
    let acknowledgementsViewController = CPDAcknowledgementsViewController()

    let leftItem = UIBarButtonItem(awesomeType: .fa_bars, size: 24, style: .done, target: acknowledgementsViewController, action: #selector(presentLeftMenuViewController))
    leftItem.tintColor = UIColor.white

    acknowledgementsViewController.navigationItem.leftBarButtonItem = leftItem
    acknowledgementsViewController.navigationItem.titleView?.tintColor = UIColor.white
    acknowledgementsViewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    acknowledgementsViewController.title = "Lizenzen"

    let navigationViewController = UINavigationController(rootViewController: acknowledgementsViewController)
    navigationViewController.navigationBar.isTranslucent = false
    navigationViewController.navigationBar.barTintColor = Helper.tintColor
    navigationViewController.navigationBar.tintColor = UIColor.white
    navigationViewController.navigationBar.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.white,
      NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 17) as Any
    ]

    Helper.show(viewController: navigationViewController)
  }

}

// MARK: - UITableViewDataSource
extension LeftMenuViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.count
  }
}

// MARK: - UITableViewDelegate
extension LeftMenuViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = menu[indexPath.row]
    item.action(tableView.cellForRow(at: indexPath))
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let item = menu[indexPath.row]
    cell.textLabel?.text = item.title

    if item.key == "update", let lastUpdate = Defaults[.lastUpdate] {
      cell.detailTextLabel?.text = lastUpdate.relativeDateString
    } else {
      cell.detailTextLabel?.text = nil
    }
  }

}
