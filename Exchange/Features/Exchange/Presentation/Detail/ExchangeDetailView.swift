//
//  ExchangeDetailView.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - ExchangeDetailView

struct ExchangeDetailView<VM: ViewModelProtocol>: View where VM.State == ExchangeDetailState, VM.Trigger == ExchangeDetailTrigger {
    @ObservedObject private var viewModel: VM

    init(viewModel: VM) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.md) {
            Text(viewModel.state.title)
                .font(.title3.weight(.semibold))
            Text(viewModel.state.currencyCode)
                .font(.headline)
            Spacer()
        }
        .padding(UIConstants.Spacing.lg)
        .onAppear {
            viewModel.onTrigger(.screenAppeared)
        }
    }
}

typealias DefaultExchangeDetailView = ExchangeDetailView<ExchangeDetailViewModel>
