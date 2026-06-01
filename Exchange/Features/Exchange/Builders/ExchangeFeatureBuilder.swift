//
//  ExchangeFeatureBuilder.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI
import Foundation

// MARK: - ExchangeFeatureBuilder

@MainActor
final class ExchangeFeatureBuilder {
    private let appContainer: AppContainer

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    func makeRootView() -> ExchangeListRootView {
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

        let coordinator = ExchangeListCoordinator(
            exchangeListBuilder: ExchangeListViewBuilder(viewModel: exchangeListViewModel))
        return coordinator.makeRootView()
    }
}

// MARK: - ExchangeListViewBuilder

private struct ExchangeListViewBuilder: ExchangeListBuilding {
    let viewModel: ExchangeListViewModel

    func makeView() -> DefaultExchangeListView {
        return DefaultExchangeListView(viewModel: viewModel)
    }
}
