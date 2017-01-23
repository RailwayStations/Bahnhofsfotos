//
//  ViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)

    var stationsUpdatedAt: Date?
    var gefilterteBahnhoefe: [Station]?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showStations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchBar.placeholder = "Bahnhof finden"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    // Bahnhöfe anzeigen
    func showStations() {
        if StationStorage.lastUpdatedAt != stationsUpdatedAt {
            stationsUpdatedAt = StationStorage.lastUpdatedAt
            self.tableView.reloadData()
        }
        // Keine Bahnhöfe geladen. Bitte zuerst im Profil auf "Bahnhofsdaten aktualisieren" tippen.
    }


    // Bahnhöfe filtern
    func filterContentForSearchText(_ searchText: String) {
        gefilterteBahnhoefe = StationStorage.stationsWithoutPhoto.filter { station in
            return station.title.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController {

    // TableView: Anzahl der anzeigbaren Bahnhöfe
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return gefilterteBahnhoefe?.count ?? 0
        }
        return StationStorage.stationsWithoutPhoto.count
    }

    // TableView: Zelle für spezifischen Bahnhof
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()

        var station: Station?
        if searchController.isActive && searchController.searchBar.text != "" {
            station = gefilterteBahnhoefe?[indexPath.row]
        } else {
            station = StationStorage.stationsWithoutPhoto[indexPath.row]
        }
        if station != nil {
            cell.textLabel?.text = station?.title
        }

        return cell
    }

    // TableView: Bahnhof ausgewählt
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        StationStorage.currentStation = StationStorage.stationsWithoutPhoto[indexPath.row]
    }
}


// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return
        }
        filterContentForSearchText(query)
    }
}
