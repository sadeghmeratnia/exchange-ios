//
//  ExchangeCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeCoordinator

@MainActor
final class ExchangeCoordinator {
    let screenBuilder: ExchangeScreenBuilder

    init(screenBuilder: ExchangeScreenBuilder) {
        self.screenBuilder = screenBuilder
    }

    func handleNavigation() {
        // Navigations will be handled here from coordinator.
    }
}
