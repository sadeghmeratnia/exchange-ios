//
//  ExchangeLocalCacheDataSource.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeLocalCacheDataSourceProtocol

protocol ExchangeLocalCacheDataSourceProtocol: Sendable {
    func getCachedRates() async -> [ExchangeRate]
    func saveRates(_ rates: [ExchangeRate]) async
    func getLastSuccessfulUpdate() async -> Date?
    func getCachedCurrencyCodes() async -> [String]
    func saveCurrencyCodes(_ codes: [String]) async
}

// MARK: - ExchangeLocalCacheDataSource

actor ExchangeLocalCacheDataSource: ExchangeLocalCacheDataSourceProtocol {
    private enum Keys {
        static let lastSuccessfulRateUpdate = "exchange.lastSuccessfulRateUpdate"
        static let cachedCurrencyCodes = "exchange.cachedCurrencyCodes"
    }

    private var inMemoryRates: [ExchangeRate] = []
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let ratesFileURL: URL

    init(
        userDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        cacheDirectoryURL: URL? = nil
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        self.ratesFileURL = Self.makeRatesFileURL(
            fileManager: fileManager,
            cacheDirectoryURL: cacheDirectoryURL
        )
        self.inMemoryRates = Self.loadRates(from: ratesFileURL)
    }

    func getCachedRates() async -> [ExchangeRate] {
        inMemoryRates
    }

    func saveRates(_ rates: [ExchangeRate]) async {
        inMemoryRates = rates
        persistRates(rates)
        let latestTimestamp = rates.map(\.timestamp).max()
        userDefaults.set(latestTimestamp, forKey: Keys.lastSuccessfulRateUpdate)
    }

    func getLastSuccessfulUpdate() async -> Date? {
        userDefaults.object(forKey: Keys.lastSuccessfulRateUpdate) as? Date
    }

    func getCachedCurrencyCodes() async -> [String] {
        userDefaults.stringArray(forKey: Keys.cachedCurrencyCodes) ?? []
    }

    func saveCurrencyCodes(_ codes: [String]) async {
        let normalizedCodes = Array(Set(codes.map { $0.uppercased() })).sorted()
        userDefaults.set(normalizedCodes, forKey: Keys.cachedCurrencyCodes)
    }
}

private extension ExchangeLocalCacheDataSource {
    func persistRates(_ rates: [ExchangeRate]) {
        guard let data = try? JSONEncoder().encode(rates) else { return }
        let parentDirectory = ratesFileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        try? data.write(to: ratesFileURL, options: [.atomic])
    }

    static func loadRates(from fileURL: URL) -> [ExchangeRate] {
        guard let data = try? Data(contentsOf: fileURL),
              let rates = try? JSONDecoder().decode([ExchangeRate].self, from: data) else {
            return []
        }
        return rates
    }

    static func makeRatesFileURL(fileManager: FileManager, cacheDirectoryURL: URL?) -> URL {
        let baseURL = cacheDirectoryURL
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return baseURL.appendingPathComponent("exchange.cachedRates.json", isDirectory: false)
    }
}
