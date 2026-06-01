//
//  ExchangeLocalCacheDataSource.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeLocalCacheDataSourceProtocol

protocol ExchangeLocalCacheDataSourceProtocol {
    func getCachedRates() -> [ExchangeRate]
    func saveRates(_ rates: [ExchangeRate])
    func getLastSuccessfulUpdate() -> Date?
    func getCachedCurrencyCodes() -> [String]
    func saveCurrencyCodes(_ codes: [String])
}

// MARK: - ExchangeLocalCacheDataSource

final class ExchangeLocalCacheDataSource: ExchangeLocalCacheDataSourceProtocol {
    private enum Keys {
        static let lastSuccessfulRateUpdate = "exchange.lastSuccessfulRateUpdate"
        static let cachedCurrencyCodes = "exchange.cachedCurrencyCodes"
        static let cachedRates = "exchange.cachedRates"
    }

    private var inMemoryRates: [ExchangeRate] = []
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.inMemoryRates = Self.loadRates(from: userDefaults)
    }

    func getCachedRates() -> [ExchangeRate] {
        inMemoryRates
    }

    func saveRates(_ rates: [ExchangeRate]) {
        inMemoryRates = rates
        let latestTimestamp = rates.map(\.timestamp).max()
        userDefaults.set(latestTimestamp, forKey: Keys.lastSuccessfulRateUpdate)
        userDefaults.set(Self.encodeRates(rates), forKey: Keys.cachedRates)
    }

    func getLastSuccessfulUpdate() -> Date? {
        userDefaults.object(forKey: Keys.lastSuccessfulRateUpdate) as? Date
    }

    func getCachedCurrencyCodes() -> [String] {
        userDefaults.stringArray(forKey: Keys.cachedCurrencyCodes) ?? []
    }

    func saveCurrencyCodes(_ codes: [String]) {
        let normalizedCodes = Array(Set(codes.map { $0.uppercased() })).sorted()
        userDefaults.set(normalizedCodes, forKey: Keys.cachedCurrencyCodes)
    }
}

private extension ExchangeLocalCacheDataSource {
    static func encodeRates(_ rates: [ExchangeRate]) -> Data? {
        try? JSONEncoder().encode(rates)
    }

    static func loadRates(from userDefaults: UserDefaults) -> [ExchangeRate] {
        guard let data = userDefaults.data(forKey: Keys.cachedRates),
              let rates = try? JSONDecoder().decode([ExchangeRate].self, from: data) else {
            return []
        }
        return rates
    }
}
