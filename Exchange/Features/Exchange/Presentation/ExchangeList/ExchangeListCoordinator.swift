//
//  ExchangeListCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import SwiftUI

// MARK: - ExchangeListBuilding

protocol ExchangeListBuilding {
    func makeView() -> DefaultExchangeListView
}

// MARK: - ExchangeListCoordinator

@MainActor
final class ExchangeListCoordinator: CoordinatorProtocol {
    typealias RootView = ExchangeListRootView

    private let exchangeListBuilder: ExchangeListBuilding

    init(exchangeListBuilder: ExchangeListBuilding) {
        self.exchangeListBuilder = exchangeListBuilder
    }

    func makeRootView() -> ExchangeListRootView {
        ExchangeListRootView(coordinator: self)
    }

    func makeExchangeListView() -> DefaultExchangeListView {
        exchangeListBuilder.makeView()
    }
}
