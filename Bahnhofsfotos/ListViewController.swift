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
  var filteredStations: [String: [Station]]?
  var filteredSectionTitles: [String]?

  var stations = [String: [Station]]()
  var sectionTitles = [String]()

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

  @IBAction func toggleEditing(_ sender: Any) {
    tableView.setEditing(!tableView.isEditing, animated: true)
  }

  // Bahnhöfe anzeigen
  func showStations() {
    if StationStorage.lastUpdatedAt != stationsUpdatedAt {
      stationsUpdatedAt = StationStorage.lastUpdatedAt

      stations = createSections(of: StationStorage.stations.filter({ !$0.hasPhoto }))
      sectionTitles = Array(stations.keys).sorted()

      tableView.reloadData()
    }
  }

  func createSections(of stations: [Station]) -> [String: [Station]] {
    var result = [String: [Station]]()

    for station in stations.sorted(by: { $0.name.compare($1.name) == .orderedAscending }) {
      let name = station.name
      let key = name.substring(to: name.index(after: name.startIndex))

      if result[key] != nil {
        result[key]?.append(station)
      } else {
        result[key] = [station]
      }
    }

    return result
  }

  // Bahnhöfe filtern
  func filterContentForSearchText(_ searchText: String) {
    let filtered = StationStorage.stations.filter { station in
      return !station.hasPhoto && station.name.lowercased().contains(searchText.lowercased())
    }

    filteredStations = createSections(of: filtered)
    if let filteredStations = filteredStations {
      filteredSectionTitles = Array(filteredStations.keys).sorted()
    }

    tableView.reloadData()
  }

}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    if StationStorage.stations.count > 0 {
      tableView.tableHeaderView?.isHidden = false
      tableView.backgroundView = nil
      tableView.separatorStyle = .singleLine

      if searchController.isActive && searchController.searchBar.text != "" {
        return filteredSectionTitles?.count ?? 0
      }
      return sectionTitles.count
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

  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    if searchController.isActive && searchController.searchBar.text != "" {
      return filteredSectionTitles
    }
    return sectionTitles
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if searchController.isActive && searchController.searchBar.text != "" {
      return filteredSectionTitles?[section]
    }
    return sectionTitles[section]
  }

  // TableView: Anzahl der anzeigbaren Bahnhöfe
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      if let sectionTitle = filteredSectionTitles?[section] {
        return filteredStations?[sectionTitle]?.count ?? 0
      } else {
        return 0
      }
    }
    let sectionTitle = sectionTitles[section]
    return stations[sectionTitle]?.count ?? 0
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
      if let sectionTitle = filteredSectionTitles?[indexPath.section] {
        station = filteredStations?[sectionTitle]?[indexPath.row]
      }
    } else {
      let sectionTitle = sectionTitles[indexPath.section]
      station = stations[sectionTitle]?[indexPath.row]
    }
    if station != nil {
      cell.textLabel?.text = station?.title
    }
  }

  // TableView: station selected
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if searchController.isActive && searchController.searchBar.text != "" {
      if let sectionTitle = filteredSectionTitles?[indexPath.section] {
        StationStorage.currentStation = filteredStations?[sectionTitle]?[indexPath.row]
      }
    } else {
      let sectionTitle = sectionTitles[indexPath.section]
      StationStorage.currentStation = stations[sectionTitle]?[indexPath.row]
    }
    performSegue(withIdentifier: "showDetail", sender: nil)
  }

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return [UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Entfernen") { _, indexPath in
      var station: Station?

      if self.searchController.isActive && self.searchController.searchBar.text != "" {
        if let sectionTitle = self.filteredSectionTitles?[indexPath.section] {
          station = self.filteredStations?[sectionTitle]?[indexPath.row]
        }
      } else {
        let sectionTitle = self.sectionTitles[indexPath.section]
        station = self.stations[sectionTitle]?[indexPath.row]
      }
      guard station != nil else { return }
      do {
        try StationStorage.delete(station: station!)
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
          if let sectionTitle = self.filteredSectionTitles?[indexPath.section] {
            self.filteredStations?[sectionTitle]?.remove(at: indexPath.row)
          }
        } else {
          let sectionTitle = self.sectionTitles[indexPath.section]
          self.stations[sectionTitle]?.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
      } catch {
        let alert = UIAlertController(title: "Fehler", message: "Löschen war nicht erfolgreich", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    }]
  }

}

// MARK: - UISearchResultsUpdating
extension ListViewController: UISearchResultsUpdating {

  public func updateSearchResults(for searchController: UISearchController) {
    if let query = searchController.searchBar.text {
      filterContentForSearchText(query)
      if !searchController.isActive {
        showStations()
      }
    }
  }

}
