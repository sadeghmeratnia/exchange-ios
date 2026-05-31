//
//  ExchangeCoordinator.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Combine
import SwiftUI

// MARK: - ExchangeCoordinator

@MainActor
final class ExchangeCoordinator: ObservableObject {
    enum Destination: Hashable {
        case detail(currencyCode: String)
    }

    @Published var navigationPath = NavigationPath()

    let screenBuilder: ExchangeScreenBuilder

    init(screenBuilder: ExchangeScreenBuilder) {
        self.screenBuilder = screenBuilder
    }

    func showDetail(currencyCode: String) {
        navigationPath.append(Destination.detail(currencyCode: currencyCode))
    }

    func dismissDetail() {
        guard navigationPath.isEmpty == false else { return }
        navigationPath.removeLast()
    }
}
