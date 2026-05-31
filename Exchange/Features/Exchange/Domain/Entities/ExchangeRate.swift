//
//  ExchangeRate.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeRate

struct ExchangeRate: Equatable, Sendable {
    let baseCurrency: Currency
    let quoteCurrency: Currency
    let ask: Decimal
    let bid: Decimal
    let timestamp: Date

    var mid: Decimal {
        (ask + bid) / 2
    }
}
