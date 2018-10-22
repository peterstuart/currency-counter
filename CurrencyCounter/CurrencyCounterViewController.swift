//
//  ViewController.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

class CurrencyCounterViewController: UIViewController {
    var viewModel: CurrencyCounterViewModel {
        didSet {
            if oldValue != viewModel {
                currencyCounter.set(cents: viewModel.cents, animated: true)
            }
        }
    }

    private var currencyCounter: CurrencyCounter!

    init(viewModel: CurrencyCounterViewModel) {
        self.viewModel = viewModel

        super.init(nibName: .none, bundle: .none)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }

    private func setUpViews() {
        view.backgroundColor = .white

        currencyCounter = CurrencyCounter(locale: Locale(identifier: "en_US"), cents: viewModel.cents)
        currencyCounter.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currencyCounter)

        currencyCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        currencyCounter.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
