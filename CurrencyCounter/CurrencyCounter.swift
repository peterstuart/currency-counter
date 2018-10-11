//
//  CurrencyCounter.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

class CurrencyCounter: UIView {
    private static let animationDuration: TimeInterval = 0.5

    private let currencyFormatter: NumberFormatter
    private let currencySymbol: String
    private let groupingSeparator: String
    private let decimalSeparator: String
    private let negativeSymbol: String
    private let digitStrings: [String]
    private let stackView: UIStackView
    private var cents: Int

    enum ViewType: Equatable {
        case currencySymbol
        case groupingSeparator
        case decimalSeparator
        case negativeSymbol
        case digit(String)
    }

    public init?(locale: Locale, cents: Int) {
        self.cents = cents

        guard
            let currencySymbol = locale.currencySymbol,
            let groupingSeparator = locale.groupingSeparator,
            let decimalSeparator = locale.decimalSeparator
        else {
            return nil
        }

        currencyFormatter = NumberFormatter()
        currencyFormatter.locale = locale
        currencyFormatter.numberStyle = .currency

        self.currencySymbol = currencySymbol
        self.groupingSeparator = groupingSeparator
        self.decimalSeparator = decimalSeparator
        negativeSymbol = "-"

        let digitFormatter = NumberFormatter()
        digitFormatter.locale = locale
        digitFormatter.numberStyle = .decimal

        digitStrings = (0 ... 9).map { digit in
            let number = NSNumber(value: digit)
            return digitFormatter.string(from: number)!
        }

        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.spacing = 4

        super.init(frame: .zero)

        setUpViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        set(cents: cents, animated: false)
    }

    public func set(cents: Int, animated: Bool) {
        let animationDirection: DigitTicker.AnimationDirection = cents > self.cents ? .up : .down

        self.cents = cents

        let viewTypesForCents = viewTypes(from: cents)
        let removedViews = configureViews(for: viewTypesForCents, animationDirection: animated ? animationDirection : .none)

        func unhideViews() {
            for view in stackView.arrangedSubviews {
                // Adding the views as hidden and then animating un-hiding them uses the stack view's nice un-hiding animation
                view.isHidden = false
                view.alpha = 1
            }
        }

        if animated {
            // Take advantage of different stack view animation behavior depending on whether views have been removed
            if removedViews {
                UIView.animate(withDuration: CurrencyCounter.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    unhideViews()
                    self.layoutIfNeeded()
                }, completion: .none)
            } else {
                layoutIfNeeded()

                UIView.animate(withDuration: CurrencyCounter.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    unhideViews()
                }, completion: .none)
            }
        } else {
            unhideViews()
        }
    }

    func viewTypes(from cents: Int) -> [ViewType] {
        let decimal = Decimal(cents) / 100
        let decimalNumber = NSDecimalNumber(decimal: decimal)
        let formattedString = currencyFormatter.string(from: decimalNumber)!.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression) // Remove whitespace from the formatter string

        return viewTypes(from: formattedString)
    }

    private func viewTypes(from string: String) -> [ViewType] {
        if string.isEmpty {
            return []
        } else if string.hasPrefix(currencySymbol) {
            return [.currencySymbol]
                + viewTypes(from: String(string.dropFirst(currencySymbol.count)))
        } else if string.hasPrefix(groupingSeparator) {
            return [.groupingSeparator]
                + viewTypes(from: String(string.dropFirst(groupingSeparator.count)))
        } else if string.hasPrefix(decimalSeparator) {
            return [.decimalSeparator]
                + viewTypes(from: String(string.dropFirst(decimalSeparator.count)))
        } else if string.hasPrefix(negativeSymbol) {
            return [.negativeSymbol] + viewTypes(from: String(string.dropFirst()))
        } else {
            let char = string.first!
            return [.digit(String(char))] + viewTypes(from: String(string.dropFirst()))
        }
    }

    /// - Returns: Whether or not any views were removed from the stack view
    private func configureViews(for viewTypes: [ViewType], animationDirection: DigitTicker.AnimationDirection?) -> Bool {
        var digitTickers: [DigitTicker] = []
        var groupingSeparators: [UILabel] = []

        // Assumes that the locale's currency format has at most 1 currency symbol, 1 negative symbol, and 1 decimal separator
        var currencySymbolLabel: UILabel?
        var negativeSymbolLabel: UILabel?
        var decimalSeparatorLabel: UILabel?

        // Temporarily stop the stack view from arranging the views, saving some for reuse
        while let subview = stackView.arrangedSubviews.reversed().first {
            stackView.removeArrangedSubview(subview)

            if let digitTicker = subview as? DigitTicker {
                digitTickers.append(digitTicker)
            } else if let label = subview as? UILabel {
                if label.text == currencySymbol {
                    currencySymbolLabel = label
                } else if label.text == negativeSymbol {
                    negativeSymbolLabel = label
                } else if label.text == decimalSeparator {
                    decimalSeparatorLabel = label
                } else {
                    groupingSeparators.append(label)
                }
            }
        }

        var views: [UIView] = []

        // Order the views, creating new views if necessary
        for viewType in viewTypes.reversed() {
            switch viewType {
            case .currencySymbol:
                let label = currencySymbolLabel ?? CurrencyCounter.label(for: currencySymbol)
                views.append(label)

                currencySymbolLabel = .none
            case .groupingSeparator:
                if let label = groupingSeparators.first {
                    groupingSeparators = Array(groupingSeparators.dropFirst())
                    views.append(label)
                } else {
                    let label = CurrencyCounter.label(for: groupingSeparator)
                    label.isHidden = true
                    label.alpha = 0
                    views.append(label)
                }
            case .decimalSeparator:
                let label = decimalSeparatorLabel ?? CurrencyCounter.label(for: decimalSeparator)
                views.append(label)

                decimalSeparatorLabel = .none
            case .negativeSymbol:
                if let label = negativeSymbolLabel {
                    views.append(label)
                } else {
                    let label = negativeSymbolLabel ?? CurrencyCounter.label(for: negativeSymbol)
                    label.isHidden = true
                    label.alpha = 0
                    views.append(label)
                }

                negativeSymbolLabel = .none
            case let .digit(string):
                if let digitTicker = digitTickers.first {
                    digitTickers = Array(digitTickers.dropFirst())
                    digitTicker.setDigit(string: string, animationDirection: animationDirection)

                    views.append(digitTicker)
                } else {
                    let digitTicker = DigitTicker(strings: digitStrings)
                    digitTicker.translatesAutoresizingMaskIntoConstraints = false
                    digitTicker.setDigit(string: string, animationDirection: .none)
                    digitTicker.isHidden = true
                    digitTicker.alpha = 0

                    views.append(digitTicker)
                }
            }
        }

        // Remove unused views
        currencySymbolLabel?.removeFromSuperview()
        negativeSymbolLabel?.removeFromSuperview()
        decimalSeparatorLabel?.removeFromSuperview()

        for unusedDigitTicker in digitTickers {
            unusedDigitTicker.removeFromSuperview()
        }

        for unusedGroupingSeparator in groupingSeparators {
            unusedGroupingSeparator.removeFromSuperview()
        }

        // Return control to the stack view
        for view in views.reversed() {
            stackView.addArrangedSubview(view)
        }

        return !digitTickers.isEmpty || negativeSymbolLabel != .none
    }

    private static func label(for string: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center

        return label
    }
}
