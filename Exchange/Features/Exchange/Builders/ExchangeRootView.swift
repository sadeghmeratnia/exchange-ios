//
//  ExchangeRootView.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - ExchangeRootView

struct ExchangeRootView: View {
    @StateObject private var coordinator: ExchangeCoordinator

    init(coordinator: ExchangeCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            coordinator.screenBuilder.makeExchangeListView()
                .navigationDestination(for: ExchangeCoordinator.Destination.self) { destination in
                    switch destination {
                    case let .detail(currencyCode):
                        coordinator.screenBuilder.makeExchangeDetailView(currencyCode: currencyCode)
                    }
                }
        }
    }
}
