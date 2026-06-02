//
//  ExchangeListTrigger.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

enum ExchangeCurrencyRow: String, Equatable, Hashable, Identifiable {
    case top
    case bottom

    var id: String { rawValue }
}

// MARK: - ExchangeListTrigger

enum ExchangeListTrigger: Equatable {
    case screenAppeared
    case screenDisappeared
    case appBecameActive
    case appMovedToBackground
    case topAmountChanged(String)
    case bottomAmountChanged(String)
    case swapTapped
    case currencySelected(row: ExchangeCurrencyRow, code: String)
    case retryTapped
    case dismissError
}
