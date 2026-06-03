//
//  AccessibilityID.swift
//  Exchange
//

import Foundation

enum AccessibilityID {
    static let exchangeListScreen = "exchangeListScreen"
    static let swapButton = "swapButton"

    static func amountField(currencyCode: String) -> String {
        "amountField_\(currencyCode)"
    }
}
