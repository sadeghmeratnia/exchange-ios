//
//  ExchangeRemoteDataSource.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeRemoteDataSourceProtocol

protocol ExchangeRemoteDataSourceProtocol {
    func fetchTickers(currencies: [String]) async throws -> [ExchangeTickerDTO]
    func fetchAvailableCurrencyCodes() async throws -> [String]
}

// MARK: - ExchangeRemoteDataSource

struct ExchangeRemoteDataSource: ExchangeRemoteDataSourceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func fetchTickers(currencies: [String]) async throws -> [ExchangeTickerDTO] {
        let endpoint = ExchangeEndpoints.tickers(currencies: currencies)
        return try await networkClient.request([ExchangeTickerDTO].self, endpoint: endpoint)
    }

    func fetchAvailableCurrencyCodes() async throws -> [String] {
        let endpoint = ExchangeEndpoints.tickerCurrencies()
        return try await networkClient.request([String].self, endpoint: endpoint)
    }
}
