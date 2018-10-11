//
//  CurrencyCounterTests.swift
//  CurrencyCounterTests
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

@testable import CurrencyCounter
import XCTest

class CurrencyCounterTests: XCTestCase {
    func testViewTypes() {
        let locale = Locale(identifier: "en_US")
        let currencyCounter = CurrencyCounter(locale: locale, cents: 0)!

        XCTAssertEqual(
            currencyCounter.viewTypes(from: 0),
            [CurrencyCounter.ViewType.currencySymbol, .digit("0"), .decimalSeparator, .digit("0"), .digit("0")]
        )

        XCTAssertEqual(
            currencyCounter.viewTypes(from: 123_456),
            [CurrencyCounter.ViewType.currencySymbol, .digit("1"), .groupingSeparator, .digit("2"), .digit("3"), .digit("4"), .decimalSeparator, .digit("5"), .digit("6")]
        )

        XCTAssertEqual(
            currencyCounter.viewTypes(from: -1346),
            [.negativeSymbol, CurrencyCounter.ViewType.currencySymbol, .digit("1"), .digit("3"), .decimalSeparator, .digit("4"), .digit("6")]
        )
    }
}
