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

    func makeRootView() -> some View {
        let remote = ExchangeRemoteDataSource(networkClient: appContainer.networkClient)
        let cache = ExchangeLocalCacheDataSource()
        let repository = ExchangeRepository(
            remoteDataSource: remote,
            localCacheDataSource: cache)

        let viewModel = ExchangeListViewModel(
            getExchangeRatesUseCase: GetExchangeRatesUseCase(repository: repository),
            getAvailableCurrenciesUseCase: GetAvailableCurrenciesUseCase(repository: repository))

        return NavigationStack {
            ExchangeListView(
                viewModel: viewModel,
                currencyDisplayProvider: CurrencyDisplayProvider())
        }
    }
}
