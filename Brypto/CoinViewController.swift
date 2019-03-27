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

class CoinViewController: UIViewController {

  var chart = Chart()
  var coin: Coin?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white

    chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHeight)
    let series = ChartSeries([0, 6, 2, 8, 4, 7, 3, 10, 8])
    series.color = ChartColors.greenColor()
    chart.add(series)
    view.addSubview(chart)
  }

}
