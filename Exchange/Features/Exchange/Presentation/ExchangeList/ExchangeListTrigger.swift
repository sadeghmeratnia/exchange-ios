//
//  ExchangeListTrigger.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListTrigger

enum ExchangeListTrigger: Equatable {
    enum CurrencyRow: Equatable {
        case top
        case bottom
    }

    case screenAppeared
    case topAmountChanged(String)
    case bottomAmountChanged(String)
    case swapTapped
    case currencyTapped(row: CurrencyRow)
    case currencySelected(String)
    case currencyPickerDismissed
    case retryTapped
    case dismissError
}
