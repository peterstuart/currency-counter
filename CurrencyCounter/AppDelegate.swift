//
//  AppDelegate.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let coordinator = AppCoordinator(window: window)

        self.window = window
        self.coordinator = coordinator

        return true
    }
}
