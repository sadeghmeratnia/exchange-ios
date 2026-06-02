//
//  ExchangeLocalCacheDataSourceTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 02/06/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeLocalCacheDataSource")
struct ExchangeLocalCacheDataSourceTests {
    @Test("init logs when cached rates file cannot be decoded")
    func initLogsWhenCachedFileIsInvalid() throws {
        let logStore = RecordingLogStore()
        let logger = MockLogger.recording(logStore)
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        let ratesFileURL = cacheDirectory.appendingPathComponent("exchange.cachedRates.json")
        try Data("{".utf8).write(to: ratesFileURL)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        _ = ExchangeLocalCacheDataSource(
            fileManager: .default,
            cacheDirectoryURL: cacheDirectory,
            logger: logger)

        #expect(logStore.entries.contains(where: {
            $0.level == .warning && $0.message.localizedCaseInsensitiveContains("decode")
        }))
    }

    @Test("saveRates updates last successful timestamp only after disk persistence succeeds")
    func saveRatesUpdatesTimestampOnSuccessfulPersistence() async throws {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sut = ExchangeLocalCacheDataSource(
            fileManager: .default,
            cacheDirectoryURL: cacheDirectory)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let timestamp = Date(timeIntervalSince1970: 1_715_000_000)
        let rates = [
            ExchangeRate(
                baseCurrency: Currency(code: "USDC"),
                quoteCurrency: Currency(code: "MXN"),
                ask: 1,
                bid: 1,
                timestamp: timestamp),
        ]

        await sut.saveRates(rates)

        let lastUpdate = await sut.getLastSuccessfulUpdate()
        #expect(lastUpdate == timestamp)
        let cached = await sut.getCachedRates()
        #expect(cached == rates)
    }
}
