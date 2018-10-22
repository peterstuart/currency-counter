//
//  DigitTicker.swift
//  CurrencyCounter
//
//  Created by Peter Stuart on 10/10/18.
//  Copyright © 2018 Peter Stuart. All rights reserved.
//

import UIKit

class DigitTicker: UIView {
    enum AnimationDirection {
        case increasing
        case decreasing
    }

    private static let animationDuration: TimeInterval = 0.5

    private static let width: CGFloat = 28
    private static let height: CGFloat = 28

    private let strings: [String]
    private let stackView: UIStackView
    private let labels: [UILabel]
    private var currentLabelConstraints: [NSLayoutConstraint] = []
    private var currentDigit: String

    init(strings: [String]) {
        self.strings = strings

        currentDigit = strings[0]

        labels = strings.map { string in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 24)
            label.textAlignment = .center
            label.text = string

            return label
        }

        stackView = UIStackView(arrangedSubviews: labels)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        super.init(frame: CGRect(x: 0, y: 0, width: DigitTicker.width, height: DigitTicker.height))

        clipsToBounds = true

        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        layer.cornerRadius = 2

        let widthConstraint = widthAnchor.constraint(equalToConstant: DigitTicker.width)
        widthConstraint.priority = UILayoutPriority(999)
        widthConstraint.isActive = true

        let heightConstraint = heightAnchor.constraint(equalToConstant: DigitTicker.height)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true

        addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        for label in labels {
            label.widthAnchor.constraint(equalToConstant: DigitTicker.width).isActive = true
            label.heightAnchor.constraint(equalToConstant: DigitTicker.height).isActive = true
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDigit(string: String, animationDirection: AnimationDirection?) {
        guard string != currentDigit else {
            return
        }

        let index = strings.firstIndex(of: string)!
        let reversed: [String] = strings.reversed()

        let orderedStrings: [String]

        switch animationDirection {
        case .some(.increasing):
            orderedStrings = Array(reversed[(reversed.count - index - 1) ..< reversed.count] + reversed[0 ..< (reversed.count - index - 1)])
        default:
            // Decreasing or no animation
            orderedStrings = Array(reversed[(reversed.count - index) ..< reversed.count] + reversed[0 ..< (reversed.count - index)])
        }

        for (string, label) in zip(orderedStrings, labels) {
            label.text = string
        }

        let startIndex = orderedStrings.firstIndex(of: currentDigit)!
        let endIndex = orderedStrings.firstIndex(of: string)!

        if animationDirection != .none {
            makeCurrent(label: labels[startIndex])
            layoutIfNeeded()

            makeCurrent(label: labels[endIndex])

            UIView.animate(withDuration: DigitTicker.animationDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.layoutIfNeeded()
            }, completion: .none)
        } else {
            makeCurrent(label: labels[endIndex])
        }

        currentDigit = string
    }

    private func makeCurrent(label: UILabel) {
        NSLayoutConstraint.deactivate(currentLabelConstraints)

        currentLabelConstraints = [
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]

        NSLayoutConstraint.activate(currentLabelConstraints)
    }
}
