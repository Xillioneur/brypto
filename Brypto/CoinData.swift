//
//  CoinData.swift
//  Brypto
//
//  Created by Willie Johnson on 3/26/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit
import Alamofire

class CoinData {
  static let shared = CoinData()
  var coins = [Coin]()
  weak var delegate: CoinDataDelegate?

  private init() {
    let symbols = ["BTC", "ETH", "LTC"]

    for symbol in symbols {
      let coin = Coin(symbol: symbol)
      coins.append(coin)
    }
  }

  /// Grab crpyto prices from cryptocompare API.
  func getPrices() {
    var listOfSymbols = ""
    for coin in coins {
      listOfSymbols += coin.symbol
      if coin.symbol != coins.last?.symbol {
        listOfSymbols += ","
      }
    }

    AF.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymbols)&tsyms=USD&api_key=3c8aafbac23bdca28210a68eb91ccf44ba94034b4ec388b1a032c6517bb47e0e").responseJSON { (response) in
      if let json = response.result.value as? [String: Any] {
        for coin in self.coins {
          if let coinJSON = json[coin.symbol] as? [String: Double] {
            if let price = coinJSON["USD"] {
              coin.price = price
            }
          }
        }
        self.delegate?.newPrices?()
      }
    }
  }

  func doubleToMoneyString(double: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .currency
    if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
      return fancyPrice
    } else {
      return "ERROR"
    }
  }
}

@objc protocol CoinDataDelegate: class {
  @objc optional func newPrices()
  @objc optional func newHistory()
}

/// Crypto coin model.
class Coin {
  var symbol = ""
  var image = UIImage()
  var price = 0.0
  var amount = 0.0
  var historicalData = [Double]()

  init(symbol: String) {
    self.symbol = symbol
    if let image = UIImage(named: symbol) {
      self.image = image
    }
  }

  func getHistoricalDta() {
    AF.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30&api_key=3c8aafbac23bdca28210a68eb91ccf44ba94034b4ec388b1a032c6517bb47e0e").responseJSON { (response) in
      if let json = response.result.value as? [String: Any] {
        if let pricesJSON = json["Data"] as? [[String:Double]] {
          self.historicalData = []
          for priceJSON in pricesJSON {
            if let closePrice = priceJSON["close"] {
              self.historicalData.append(closePrice)
            }
          }
          CoinData.shared.delegate?.newHistory?()

        }
      }
    }
  }

  func priceAsString() -> String {
    if price == 0.0 {
      return "Loading..."
    }

    return CoinData.shared.doubleToMoneyString(double: price)
  }

  func amountAsString() -> String {
    return CoinData.shared.doubleToMoneyString(double: amount * price)
  }
}
