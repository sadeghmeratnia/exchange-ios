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
    private let logger: NetworkLogger

    init(
        userDefaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        cacheDirectoryURL: URL? = nil,
        logger: NetworkLogger = OSLogger(category: .cache)
    ) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        self.logger = logger
        self.ratesFileURL = Self.makeRatesFileURL(
            fileManager: fileManager,
            cacheDirectoryURL: cacheDirectoryURL
        )
        let loadedRates = Self.loadRates(from: ratesFileURL, logger: logger)
        self.inMemoryRates = loadedRates
    }

    func getCachedRates() async -> [ExchangeRate] {
        inMemoryRates
    }

    func saveRates(_ rates: [ExchangeRate]) async {
        inMemoryRates = rates
        switch persistRates(rates) {
        case .success:
            let latestTimestamp = rates.map(\.timestamp).max()
            userDefaults.set(latestTimestamp, forKey: Keys.lastSuccessfulRateUpdate)
        case let .failure(error):
            logger.log("Failed to persist exchange rates: \(error)", level: .warning)
        }
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

private enum ExchangeCachePersistenceError: Error {
    case encodingFailed
    case directoryCreationFailed(underlying: Error)
    case writeFailed(underlying: Error)
    case decodeFailed(underlying: Error)
    case readFailed(underlying: Error)
}

private extension ExchangeLocalCacheDataSource {
    func persistRates(_ rates: [ExchangeRate]) -> Result<Void, ExchangeCachePersistenceError> {
        let data: Data
        do {
            data = try JSONEncoder().encode(rates)
        } catch {
            return .failure(.encodingFailed)
        }

        let parentDirectory = ratesFileURL.deletingLastPathComponent()
        do {
            try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
        } catch {
            return .failure(.directoryCreationFailed(underlying: error))
        }

        do {
            try data.write(to: ratesFileURL, options: [.atomic])
        } catch {
            return .failure(.writeFailed(underlying: error))
        }

        return .success(())
    }

    static func loadRates(from fileURL: URL, logger: NetworkLogger) -> [ExchangeRate] {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            logger.log("Unable to read cached rates file: \(error)", level: .warning)
            return []
        }

        do {
            return try JSONDecoder().decode([ExchangeRate].self, from: data)
        } catch {
            logger.log("Unable to decode cached rates file: \(error)", level: .warning)
            return []
        }
    }

    static func makeRatesFileURL(fileManager: FileManager, cacheDirectoryURL: URL?) -> URL {
        let baseURL = cacheDirectoryURL
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return baseURL.appendingPathComponent("exchange.cachedRates.json", isDirectory: false)
    }
}
