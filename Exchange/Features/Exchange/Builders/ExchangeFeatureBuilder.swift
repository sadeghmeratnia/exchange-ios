//
//  ExchangeFeatureBuilder.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeFeatureBuilder

@MainActor
final class ExchangeFeatureBuilder {
    private let appContainer: AppContainer

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    func makeCoordinator() -> ExchangeCoordinator {
        ExchangeCoordinator(screenBuilder: makeScreenBuilder())
    }

    func makeScreenBuilder() -> ExchangeScreenBuilder {
        let remoteDataSource = ExchangeRemoteDataSource(networkClient: appContainer.networkClient)
        let localCacheDataSource = ExchangeLocalCacheDataSource()
        let repository = ExchangeRepository(
            remoteDataSource: remoteDataSource,
            localCacheDataSource: localCacheDataSource)

        let getRatesUseCase = GetExchangeRatesUseCase(repository: repository)
        let getCurrenciesUseCase = GetAvailableCurrenciesUseCase(repository: repository)

        let exchangeListViewModel = ExchangeListViewModel(
            getExchangeRatesUseCase: getRatesUseCase,
            getAvailableCurrenciesUseCase: getCurrenciesUseCase)

        return ExchangeScreenBuilder(exchangeListViewModel: exchangeListViewModel)
    }
}
