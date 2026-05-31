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

    func fetchRates(for currencies: [String]) async throws -> [ExchangeRate] {
        do {
            let tickerDTOs = try await remoteDataSource.fetchTickers(currencies: currencies)
            let mappedRates = ExchangeTickerMapper.map(tickerDTOs)
            guard mappedRates.isEmpty == false else {
                throw ExchangeDomainError.invalidRemoteData
            }
            localCacheDataSource.saveRates(mappedRates)
            return mappedRates
        } catch {
            let cachedRates = localCacheDataSource.getCachedRates()
            guard cachedRates.isEmpty == false else {
                throw ExchangeDomainError.ratesUnavailable
            }
            return cachedRates
        }
    }

    func fetchAvailableCurrencies() async -> [Currency] {
        do {
            let codes = try await remoteDataSource.fetchAvailableCurrencyCodes()
            if codes.isEmpty == false {
                localCacheDataSource.saveCurrencyCodes(codes)
                return codes.map(Currency.init(code:))
            }
            return fallbackCurrencyCodes().map(Currency.init(code:))
        } catch {
            return fallbackCurrencyCodes().map(Currency.init(code:))
        }
    }

    func getLastCachedRates() -> [ExchangeRate] {
        localCacheDataSource.getCachedRates()
    }

    func saveRatesToCache(_ rates: [ExchangeRate]) {
        localCacheDataSource.saveRates(rates)
    }

    private func fallbackCurrencyCodes() -> [String] {
        let cachedCodes = localCacheDataSource.getCachedCurrencyCodes()
        return cachedCodes.isEmpty ? seedFallbackCodes : cachedCodes
    }
}
