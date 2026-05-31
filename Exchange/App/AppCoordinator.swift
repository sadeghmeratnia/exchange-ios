//
//  AppCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - AppCoordinator

struct AppCoordinator: View {
    @StateObject private var viewModel: ExchangeListViewModel

    init(appContainer: AppContainer) {
        let remoteDataSource = ExchangeRemoteDataSource(networkClient: appContainer.networkClient)
        let localCacheDataSource = ExchangeLocalCacheDataSource()
        let repository = ExchangeRepository(
            remoteDataSource: remoteDataSource,
            localCacheDataSource: localCacheDataSource)
        let getRatesUseCase = GetExchangeRatesUseCase(repository: repository)
        let getCurrenciesUseCase = GetAvailableCurrenciesUseCase(repository: repository)

        _viewModel = StateObject(
            wrappedValue: ExchangeListViewModel(
                getExchangeRatesUseCase: getRatesUseCase,
                getAvailableCurrenciesUseCase: getCurrenciesUseCase))
    }

    var body: some View {
        ExchangeListView(viewModel: viewModel)
    }
}
