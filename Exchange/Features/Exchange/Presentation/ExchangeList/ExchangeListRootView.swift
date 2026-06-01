//
//  ExchangeListRootView.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import SwiftUI

struct ExchangeListRootView: View {
    private let coordinator: ExchangeListCoordinator

    init(coordinator: ExchangeListCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack {
            coordinator.makeExchangeListView()
        }
    }
}
