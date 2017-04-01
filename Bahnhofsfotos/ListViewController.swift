//
//  ListViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import Alamofire
import UIKit

class ListViewController: UIViewController {

  fileprivate let kCellIdentifier = "cell"

  @IBOutlet weak var tableView: UITableView!

  let searchController = UISearchController(searchResultsController: nil)

  var stationsUpdatedAt: Date?
  var gefilterteBahnhoefe: [Station]?

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    showStations()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self

    searchController.searchBar.placeholder = "Bahnhof finden"
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
  }

  @IBAction func showMenu(_ sender: Any) {
    sideMenuViewController?.presentLeftMenuViewController()
  }

  // Bahnhöfe anzeigen
  func showStations() {
    if StationStorage.lastUpdatedAt != stationsUpdatedAt {
      stationsUpdatedAt = StationStorage.lastUpdatedAt
      self.tableView.reloadData()
    }
  }

  // Bahnhöfe filtern
  func filterContentForSearchText(_ searchText: String) {
    gefilterteBahnhoefe = StationStorage.stationsWithoutPhoto.filter { station in
      return station.name.lowercased().contains(searchText.lowercased())
    }

    tableView.reloadData()
  }

}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    if StationStorage.stationsWithoutPhoto.count > 0 {
      tableView.tableHeaderView?.isHidden = false
      tableView.backgroundView = nil
      tableView.separatorStyle = .singleLine

      return 1
    } else {
      // Keine Bahnhöfe geladen. Bitte zuerst im Profil auf "Bahnhofsdaten aktualisieren" tippen.
      let emptyView = EmptyView()
      emptyView.messageLabel.text = "Keine Bahnhöfe geladen.\nBitte zuerst im Profil\n\"Bahnhofsdaten aktualisieren\"."
      tableView.tableHeaderView?.isHidden = true
      tableView.backgroundView = emptyView
      tableView.separatorStyle = .none

      return 0
    }
  }

  // TableView: Anzahl der anzeigbaren Bahnhöfe
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      return gefilterteBahnhoefe?.count ?? 0
    }
    return StationStorage.stationsWithoutPhoto.count
  }

  // TableView: Zelle
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: kCellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: kCellIdentifier)
  }

}

// MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {

  // TableView: station will be shown
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    var station: Station?
    if searchController.isActive && searchController.searchBar.text != "" {
      station = gefilterteBahnhoefe?[indexPath.row]
    } else {
      station = StationStorage.stationsWithoutPhoto[indexPath.row]
    }
    if station != nil {
      cell.textLabel?.text = station?.title
    }
  }

  // TableView: station selected
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    StationStorage.currentStation = StationStorage.stationsWithoutPhoto[indexPath.row]
    performSegue(withIdentifier: "showDetail", sender: nil)
  }

}

// MARK: - UISearchResultsUpdating
extension ListViewController: UISearchResultsUpdating {

  public func updateSearchResults(for searchController: UISearchController) {
    if let query = searchController.searchBar.text {
      filterContentForSearchText(query)
    }
  }

}
