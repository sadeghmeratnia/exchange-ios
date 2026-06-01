//
//  ExchangeRepositoryProtocol.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeRepositoryProtocol

protocol ExchangeRepositoryProtocol {
    func fetchRates(for currencies: [String]) async throws -> ExchangeRatesSnapshot
    func fetchAvailableCurrencies() async -> [Currency]
    func getLastCachedRates() -> [ExchangeRate]
    func saveRatesToCache(_ rates: [ExchangeRate])
}
