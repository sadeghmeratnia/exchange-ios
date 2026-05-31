//
//  ExchangeScreenBuilder.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - ExchangeScreenBuilder

@MainActor
final class ExchangeScreenBuilder {
    private let exchangeListViewModel: ExchangeListViewModel

    init(exchangeListViewModel: ExchangeListViewModel) {
        self.exchangeListViewModel = exchangeListViewModel
    }

    func makeExchangeListView(onItemSelected: @escaping (String) -> Void) -> DefaultExchangeListView {
        DefaultExchangeListView(
            viewModel: exchangeListViewModel,
            onItemSelected: onItemSelected)
    }

    func makeExchangeDetailView(currencyCode: String) -> DefaultExchangeDetailView {
        let viewModel = ExchangeDetailViewModel(initialState: .initial(currencyCode: currencyCode))
        return DefaultExchangeDetailView(viewModel: viewModel)
    }
}
