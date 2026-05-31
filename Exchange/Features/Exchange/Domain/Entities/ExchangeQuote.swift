//
//  ExchangeQuote.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeQuote

struct ExchangeQuote: Sendable {
    let fromCurrency: Currency
    let toCurrency: Currency
    let rate: Decimal
    let updatedAt: Date
    let isRealtime: Bool
}
