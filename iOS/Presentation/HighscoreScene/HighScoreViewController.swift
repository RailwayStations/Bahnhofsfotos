//
//  HighScoreViewController.swift
//  Bahnhofsfotos
//
//  Created by Miguel Dönicke on 18.05.17.
//  Copyright © 2017 Railway-Stations. All rights reserved.
//

import Combine
import Data
import Domain
import UIKit

let kCellIdentifier = "scoreCell"

class HighScoreViewController: UIViewController {

  private var photographers = [(key: String, value: Int)]()
  private var fetchCancellable: AnyCancellable?
  private lazy var photographersUseCase: PhotographersUseCase = {
    PhotographersUseCase(photographersRepository: PhotographersRepository())
  }()

  @IBOutlet weak var tableView: UITableView!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    loadData()
  }

  func loadData() {
    view.makeToastActivity(.center)

    fetchCancellable = photographersUseCase.fetchPhotographers()
      .replaceError(with: [])
      .sink(receiveValue: { photographers in
        self.photographers = photographers.map { $0 }
        self.tableView.reloadData()
        self.view.hideToastActivity()
      })
  }

}

// MARK: - UITableViewDataSource
extension HighScoreViewController: UITableViewDataSource {

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photographers.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
  }

}

// MARK: - UITableViewDataSource
extension HighScoreViewController: UITableViewDelegate {

  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    guard let scoreCell = cell as? HighScoreTableViewCell else { return }

    switch indexPath.row {
    case 0: // 1st place
      scoreCell.rankImageView?.image = #imageLiteral(resourceName: "CrownGold")
    case 1: // 2nd place
      scoreCell.rankImageView?.image = #imageLiteral(resourceName: "CrownSilver")
    case 2: // 3rd place
      scoreCell.rankImageView?.image = #imageLiteral(resourceName: "CrownBronze")
    default:
      scoreCell.rankImageView?.image = nil
    }

    scoreCell.rankLabel.text = "\(indexPath.row + 1). "
    scoreCell.nameLabel.text = "\(photographers[indexPath.row].key)"
    scoreCell.countLabel.text = "\(photographers[indexPath.row].value)"
  }

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.row {
    case 0: // 1st place
      return 60
    case 1: // 2nd place
      return 55
    case 2: // 3rd place
      return 50
    default:
      return 40
    }
  }

}
