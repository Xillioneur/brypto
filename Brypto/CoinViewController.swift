//
//  CoinViewController.swift
//  Brypto
//
//  Created by Willie Johnson on 3/27/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHeight: CGFloat = 300.0
private let imageSize: CGFloat = 100.0
private let priceLabelHeight: CGFloat = 25.0

class CoinViewController: UIViewController, CoinDataDelegate {

  var chart = Chart()
  var coin: Coin?
  var priceLabel = UILabel()
  var youOwnLabel = UILabel()
  var worthLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    CoinData.shared.delegate = self
    guard let coin = coin else { return }

    edgesForExtendedLayout = []
    view.backgroundColor = UIColor.white

    chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
    chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1)}
    chart.xLabels = [30, 25, 20, 15, 10, 5, 0]
    chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
    view.addSubview(chart)

    let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHeight, width: imageSize, height: imageSize))
    imageView.image = coin.image
    view.addSubview(imageView)

    priceLabel.frame = CGRect(x: 0, y: chartHeight + imageSize, width: view.frame.size.width, height: priceLabelHeight)
    priceLabel.textAlignment = .center
    view.addSubview(priceLabel)

    youOwnLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 2, width: view.frame.size.width, height: priceLabelHeight)
    youOwnLabel.textAlignment = .center
    youOwnLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    view.addSubview(youOwnLabel)

    worthLabel.frame = CGRect(x: 0, y: chartHeight + imageSize + priceLabelHeight * 3, width: view.frame.size.width, height: priceLabelHeight)
    worthLabel.textAlignment = .center
    worthLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
    view.addSubview(worthLabel)

    coin.getHistoricalDta()
    newPrices()
  }

  func newHistory() {
    if let coin = coin{
      let series = ChartSeries(coin.historicalData)
      series.area = true
      //      series.color = ChartColors.greenColor()
      chart.add(series)
    }
  }

  func newPrices() {
    guard let coin = coin else { return }
    priceLabel.text = coin.priceAsString()
    worthLabel.text = coin.amountAsString()
    youOwnLabel.text = "You own: \(coin.amount) \(coin.symbol)"
  }

}
