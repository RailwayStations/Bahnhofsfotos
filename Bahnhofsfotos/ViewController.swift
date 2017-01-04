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

    var bahnhoefe: [Bahnhof]?
    var gefilterteBahnhoefe: [Bahnhof]?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchBar.placeholder = "Bahnhof finden"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        bahnhoefe?.removeAll()
        bahnhoefe = []

        showBahnhoefeOnheFoto()
    }

    // Bahnhöfe auslesen und anzeigen
    func showBahnhoefeOnheFoto() {
        BahnhofStorage.loadBahnhoefeOhneFoto { bahnhoefe in
            self.bahnhoefe = bahnhoefe
            self.tableView.reloadData()
        }
    }

    

    // Bahnhöfe filtern
    func filterContentForSearchText(_ searchText: String) {
        gefilterteBahnhoefe = bahnhoefe?.filter { bahnhof in
            return bahnhof.title.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }

    // TableView: Anzahl der anzeigbaren Bahnhöfe
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return gefilterteBahnhoefe?.count ?? 0
        }
        return bahnhoefe?.count ?? 0
    }

    // TableView: Zelle für spezifischen Bahnhof
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()

        var bahnhof: Bahnhof?
        if searchController.isActive && searchController.searchBar.text != "" {
            bahnhof = gefilterteBahnhoefe?[indexPath.row]
        } else {
            bahnhof = bahnhoefe?[indexPath.row]
        }
        if bahnhof != nil {
            cell.textLabel?.text = bahnhof?.title
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bahnhof = bahnhoefe?[indexPath.row] {
            BahnhofStorage.currentBahnhof = bahnhof
        }
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
