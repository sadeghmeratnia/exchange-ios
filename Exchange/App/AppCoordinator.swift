//
//  AppCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - AppCoordinator

struct AppCoordinator: View {
    private let appContainer: AppContainer

    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }

    var body: some View {
        ExchangeListView(
            viewModel: StaticViewModel(
                state: .initial().with(
                    topInputRaw: "1.00",
                    bottomInputRaw: "18.40",
                    availableCurrencies: [
                        Currency(code: "MXN"),
                        Currency(code: "ARS"),
                        Currency(code: "BRL"),
                        Currency(code: "COP"),
                    ])))
    }
}
