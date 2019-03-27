//
//  CryptoTableViewController.swift
//  Brypto
//
//  Created by Willie Johnson on 3/26/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit

class CryptoTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return CoinData.shared.coins.count
  }


  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()

    let coin = CoinData.shared.coins[indexPath.row]

    cell.textLabel?.text = coin.symbol
    cell.imageView?.image = coin.image


    return cell
  }


}
