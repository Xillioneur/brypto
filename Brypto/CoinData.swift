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

  func html() -> String {
    var html = "<h1>My Brypto Report</h1>"
    html += "<h2>Net Worth: \(netWorthAsString())</h2>"
    html += "<ul>"
    for coin in coins {
      if coin.amount != 0.0 {
        html += "<li>\(coin.symbol) - I won: \(coin.amount) - Valued at: \(doubleToMoneyString(double: coin.amount * coin.price))</li>"
      }
    }
    html += "/<ul>"
    return html
  }

  func netWorthAsString() -> String {
    var netWorth = 0.0
    for coin in coins {
      netWorth += coin.amount * coin.price
    }

    return doubleToMoneyString(double: netWorth)
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
      guard let json = response.result.value as? [String: Any] else { return }
      for coin in self.coins {
        guard let coinJSON = json[coin.symbol] as? [String: Double] else { return }
        guard let price = coinJSON["USD"] else { return }

        coin.price = price
        UserDefaults.standard.set(price, forKey: coin.symbol)
      }
      self.delegate?.newPrices?()
    }
  }

  func doubleToMoneyString(double: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.numberStyle = .currency

    guard let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) else { return "ERROR" }

    return fancyPrice
  }

}

/// Delegate methods for accessing coin data.
@objc protocol CoinDataDelegate: class {
  @objc optional func newPrices()
  @objc optional func newHistory()
}

/// Crypto coin model.
class Coin {
  /// The coin's symbol as String ex. BTC, LTH, ETH.
  var symbol = ""
  /// The coin's icon.
  var image = UIImage()
  /// The coin's current price on the market.
  var price = 0.0
  /// How much you own of the coin.
  var amount = 0.0
  /// The coin's historical data as an array of prices as doubles.
  var historicalData = [Double]()

  /// Initialize coin with symbol string.
  init(symbol: String) {
    self.symbol = symbol
    if let image = UIImage(named: symbol) {
      self.image = image
    }
    self.price = UserDefaults.standard.double(forKey: symbol)
    self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
    if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double] {
      self.historicalData = history
    }
  }
}

/// MARK: - Coin Methods
extension Coin {
  /// Grab the coin's historical data from API as
  func getHistoricalData() {
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
          UserDefaults.standard.set(self.historicalData, forKey: self.symbol + "history")
        }
      }
    }
  }

  /// Return the coin's price as String.
  func priceAsString() -> String {
    if price == 0.0 {
      return "Loading..."
    }

    return CoinData.shared.doubleToMoneyString(double: price)
  }

  /// Return the amount you own of the coin as String.
  func amountAsString() -> String {
    return CoinData.shared.doubleToMoneyString(double: amount * price)
  }
}
