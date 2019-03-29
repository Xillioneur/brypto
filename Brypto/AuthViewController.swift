//
//  AuthViewController.swift
//  Brypto
//
//  Created by Willie Johnson on 3/28/19.
//  Copyright © 2019 Willie Johnson. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    presentAuth()
  }

  func presentAuth() {
    let context = LAContext()

    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Brypto protects you with biometrics") { (success, error) in
      if success {
        DispatchQueue.main.async {
          let cryptoTableVC = CryptoTableViewController()
          let navController = UINavigationController(rootViewController: cryptoTableVC)
          self.present(navController, animated: true, completion: nil)
        }
      } else {
        self.presentAuth()
      }
    }
  }
}
