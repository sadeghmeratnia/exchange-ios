//
//  ExchangeRootView.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - ExchangeRootView

struct ExchangeRootView: View {
    private let coordinator: ExchangeCoordinator

    init(coordinator: ExchangeCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack {
            coordinator.screenBuilder.makeExchangeListView()
        }
    }
}
