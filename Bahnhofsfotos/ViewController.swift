//
//  ViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 16.12.16.
//  Copyright © 2016 MrHaitec. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireSwiftyJSON

class ViewController: UITableViewController {

    var bahnhoefe: [Bahnhof]?

    override func viewDidLoad() {
        super.viewDidLoad()

        bahnhoefe?.removeAll()
        bahnhoefe = []

        Alamofire.request(Constants.BAHNHOEFE_OHNE_PHOTO_URL).responseSwiftyJSON { response in
            guard let json = response.result.value?.array else { return }

            for bh in json {
                if let bahnhof = try! Bahnhof(json: bh) {
                    self.bahnhoefe?.append(bahnhof)
                }
            }

            self.sortBahnhoefe()
            self.showBahnhoefeOhneFoto()
        }
    }

    func sortBahnhoefe() {
        bahnhoefe?.sort(by: { (bahnhof1, bahnhof2) -> Bool in
            bahnhof1.title < bahnhof2.title
        })
    }

    func showBahnhoefeOhneFoto() {
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bahnhoefe?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()

        if let bahnhof = bahnhoefe?[indexPath.row] {
            cell.textLabel?.text = bahnhof.title
        }

        return cell
    }

}

