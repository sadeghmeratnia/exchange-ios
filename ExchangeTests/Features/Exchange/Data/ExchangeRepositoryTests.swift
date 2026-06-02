//
//  ExchangeRepositoryTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeRepository")
struct ExchangeRepositoryTests {
    @Test("fetchRates returns mapped remote rates and caches them")
    func fetchRatesSuccessCachesMappedRates() async throws {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.tickersResult = .success([
            ExchangeTickerDTO(
                ask: "18.4105",
                bid: "18.4069",
                book: "usdc_mxn",
                date: "2025-10-20T20:14:57.361483956"),
        ])
        let sut = makeSUT(remote: remote, local: local)

        let snapshot = try await sut.fetchRates(for: ["MXN"])

        #expect(snapshot.rates.count == 1)
        #expect(snapshot.rates.first?.quoteCurrency.code == "MXN")
        #expect(snapshot.isRealtime == true)
        #expect(local.savedRates.count == 1)
    }

    @Test("fetchRates falls back to cache when remote fails")
    func fetchRatesFallbackToCache() async throws {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.tickersResult = .failure(TestError.sample)
        local.cachedRates = [
            ExchangeRate(
                baseCurrency: Currency(code: "USDC"),
                quoteCurrency: Currency(code: "MXN"),
                ask: 18.41,
                bid: 18.39,
                timestamp: Date(timeIntervalSince1970: 0)),
        ]
        let sut = makeSUT(remote: remote, local: local)

        let snapshot = try await sut.fetchRates(for: ["MXN"])

        #expect(snapshot.rates == local.cachedRates)
        #expect(snapshot.isRealtime == false)
    }

    @Test("fetchRates throws when remote fails and cache is empty")
    func fetchRatesThrowsWhenUnavailable() async {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.tickersResult = .failure(TestError.sample)
        local.cachedRates = []
        let sut = makeSUT(remote: remote, local: local)

        do {
            _ = try await sut.fetchRates(for: ["MXN"])
            Issue.record("Expected ratesUnavailable error.")
        } catch let error as ExchangeDomainError {
            switch error {
            case .ratesUnavailable:
                #expect(Bool(true))
            default:
                Issue.record("Unexpected domain error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("fetchAvailableCurrencies uses remote and caches currency codes")
    func fetchAvailableCurrenciesSuccessCachesCodes() async {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.currencyCodesResult = .success(["MXN", "ARS", "COP"])
        let sut = makeSUT(remote: remote, local: local)

        let currencies = await sut.fetchAvailableCurrencies()

        #expect(currencies.map(\.code) == ["MXN", "ARS", "COP"])
        #expect(local.savedCurrencyCodes == ["MXN", "ARS", "COP"])
    }

    @Test("fetchAvailableCurrencies uses cached codes when remote fails")
    func fetchAvailableCurrenciesUsesCachedCodesFallback() async {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.currencyCodesResult = .failure(TestError.sample)
        local.cachedCurrencyCodes = ["BRL", "COP"]
        let sut = makeSUT(remote: remote, local: local)

        let currencies = await sut.fetchAvailableCurrencies()

        #expect(currencies.map(\.code) == ["BRL", "COP"])
    }

    @Test("fetchAvailableCurrencies uses seed fallback on first-run failure")
    func fetchAvailableCurrenciesUsesSeedFallback() async {
        let remote = MockRemoteDataSource()
        let local = MockLocalCacheDataSource()
        remote.currencyCodesResult = .failure(TestError.sample)
        local.cachedCurrencyCodes = []
        let sut = makeSUT(remote: remote, local: local)

        let currencies = await sut.fetchAvailableCurrencies()

        #expect(currencies.map(\.code) == ["MXN", "ARS", "BRL", "COP"])
    }
}

private extension ExchangeRepositoryTests {
    enum TestError: Error {
        case sample
    }

    func makeSUT(remote: MockRemoteDataSource,
                 local: MockLocalCacheDataSource) -> ExchangeRepository {
        ExchangeRepository(
            remoteDataSource: remote,
            localCacheDataSource: local)
    }
}

private final class MockRemoteDataSource: ExchangeRemoteDataSourceProtocol {
    var tickersResult: Result<[ExchangeTickerDTO], Error> = .success([])
    var currencyCodesResult: Result<[String], Error> = .success([])

    func fetchTickers(currencies: [String]) async throws -> [ExchangeTickerDTO] {
        try tickersResult.get()
    }

    func fetchAvailableCurrencyCodes() async throws -> [String] {
        try currencyCodesResult.get()
    }
}

private final class MockLocalCacheDataSource: ExchangeLocalCacheDataSourceProtocol, @unchecked Sendable {
    var cachedRates: [ExchangeRate] = []
    var savedRates: [ExchangeRate] = []
    var cachedCurrencyCodes: [String] = []
    var savedCurrencyCodes: [String] = []

    func getCachedRates() async -> [ExchangeRate] {
        cachedRates
    }

    func saveRates(_ rates: [ExchangeRate]) async {
        savedRates = rates
        cachedRates = rates
    }

    func getLastSuccessfulUpdate() async -> Date? {
        nil
    }

    func getCachedCurrencyCodes() async -> [String] {
        cachedCurrencyCodes
    }

    func saveCurrencyCodes(_ codes: [String]) async {
        savedCurrencyCodes = codes
        cachedCurrencyCodes = codes
    }
}
