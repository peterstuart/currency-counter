//
//  ViewController.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currencyCounter: CurrencyCounter!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        var counter = 0
        var cents = 6_306_45

        setUpViews(cents: cents)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if counter == 9 {
                cents += Int(arc4random_uniform(20_000_01)) - 10_000_00
                counter = 0
            } else {
                cents += 9
                counter += 1
            }
            self?.currencyCounter.set(cents: cents, animated: true)
        }
    }

    func setUpViews(cents: Int) {
        currencyCounter = CurrencyCounter(locale: Locale(identifier: "en_US"), cents: cents)
        currencyCounter.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currencyCounter)

        currencyCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currencyCounter.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
