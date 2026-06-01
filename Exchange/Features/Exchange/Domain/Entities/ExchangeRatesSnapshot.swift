//
//  ExchangeRatesSnapshot.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import Foundation

struct ExchangeRatesSnapshot: Equatable, Sendable {
    let rates: [ExchangeRate]
    let isRealtime: Bool
    let updatedAt: Date?
}
