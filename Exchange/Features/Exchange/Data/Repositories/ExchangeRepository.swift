//
//  ExchangeRepository.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeRepository

struct ExchangeRepository: ExchangeRepositoryProtocol {
    private let remoteDataSource: ExchangeRemoteDataSourceProtocol
    private let localCacheDataSource: ExchangeLocalCacheDataSourceProtocol
    private let seedFallbackCodes: [String]

    init(remoteDataSource: ExchangeRemoteDataSourceProtocol,
         localCacheDataSource: ExchangeLocalCacheDataSourceProtocol,
         fallbackCodes: [String] = ["MXN", "ARS", "BRL", "COP"]) {
        self.remoteDataSource = remoteDataSource
        self.localCacheDataSource = localCacheDataSource
        self.seedFallbackCodes = fallbackCodes
    }

    func fetchRates(for currencies: [String]) async throws -> ExchangeRatesSnapshot {
        do {
            let tickerDTOs = try await remoteDataSource.fetchTickers(currencies: currencies)
            let mappedRates = ExchangeTickerMapper.map(tickerDTOs)
            guard mappedRates.isEmpty == false else {
                throw ExchangeDomainError.invalidRemoteData
            }
            await localCacheDataSource.saveRates(mappedRates)
            return ExchangeRatesSnapshot(
                rates: mappedRates,
                isRealtime: true,
                updatedAt: mappedRates.map(\.timestamp).max())
        } catch {
            let cachedRates = await localCacheDataSource.getCachedRates()
            guard cachedRates.isEmpty == false else {
                throw ExchangeDomainError.ratesUnavailable
            }
            let lastSuccessfulUpdate = await localCacheDataSource.getLastSuccessfulUpdate()
            return ExchangeRatesSnapshot(
                rates: cachedRates,
                isRealtime: false,
                updatedAt: lastSuccessfulUpdate ?? cachedRates.map(\.timestamp).max())
        }
    }

    func fetchAvailableCurrencies() async -> [Currency] {
        do {
            let codes = try await remoteDataSource.fetchAvailableCurrencyCodes()
            if codes.isEmpty == false {
                await localCacheDataSource.saveCurrencyCodes(codes)
                return codes.map(Currency.init(code:))
            }
            let fallbackCodes = await fallbackCurrencyCodes()
            return fallbackCodes.map(Currency.init(code:))
        } catch {
            let fallbackCodes = await fallbackCurrencyCodes()
            return fallbackCodes.map(Currency.init(code:))
        }
    }

    private func fallbackCurrencyCodes() async -> [String] {
        let cachedCodes = await localCacheDataSource.getCachedCurrencyCodes()
        return cachedCodes.isEmpty ? seedFallbackCodes : cachedCodes
    }
}
