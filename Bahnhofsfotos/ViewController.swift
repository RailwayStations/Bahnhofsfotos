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
    }


    // Bahnhöfe filtern
    func filterContentForSearchText(_ searchText: String) {
        gefilterteBahnhoefe = StationStorage.stationsWithoutPhoto.filter { station in
            return station.title.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }

}

// MARK: - Segue
extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // show only back arrow
        navigationItem.backBarButtonItem = backItem
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return gefilterteBahnhoefe?.count ?? 0
        }
        return StationStorage.stationsWithoutPhoto.count
    }

    // TableView: Zelle
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
    }

    // TableView: Zelle für spezifischen Bahnhof
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
