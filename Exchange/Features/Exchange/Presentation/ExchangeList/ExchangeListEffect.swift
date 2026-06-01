//
//  ExchangeListEffect.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListEffect

enum ExchangeListEffect: Equatable {
    case bootstrap(currencies: [String])
    case fetchRates(currencies: [String])
}
