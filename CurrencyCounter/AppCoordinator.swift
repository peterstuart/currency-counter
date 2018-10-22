//
//  AppCoordinator.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/22/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

class AppCoordinator {
    let window: UIWindow
    let viewController: CurrencyCounterViewController

    init(window: UIWindow) {
        self.window = window

        let initialViewModel = CurrencyCounterViewModel(cents: 0)
        viewController = CurrencyCounterViewController(viewModel: initialViewModel)

        window.rootViewController = viewController
        window.makeKeyAndVisible()

        startTimer()
    }

    private func startTimer() {
        var cents = viewController.viewModel.cents

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            cents += Int(arc4random_uniform(2_000_001)) - 1_000_000
            strongSelf.viewController.viewModel = CurrencyCounterViewModel(cents: cents)
        }
    }
}
