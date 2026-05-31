//
//  AppCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - AppCoordinator

struct AppCoordinator: View {
    private let exchangeRootView: ExchangeRootView

    init(appContainer: AppContainer) {
        let exchangeFeatureBuilder = ExchangeFeatureBuilder(appContainer: appContainer)
        self.exchangeRootView = ExchangeRootView(coordinator: exchangeFeatureBuilder.makeCoordinator())
    }

    var body: some View {
        exchangeRootView
    }
}
