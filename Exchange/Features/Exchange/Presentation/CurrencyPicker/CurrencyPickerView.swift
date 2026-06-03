//
//  CurrencyPickerView.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - CurrencyPickerView

struct CurrencyPickerView<VM: ViewModelProtocol>: View where VM.State == CurrencyPickerState, VM.Trigger == CurrencyPickerTrigger {
    @ObservedObject private var viewModel: VM
    private let currencyDisplayProvider: any CurrencyDisplayProviding

    init(viewModel: VM,
         currencyDisplayProvider: any CurrencyDisplayProviding = CurrencyDisplayProvider()) {
        self.viewModel = viewModel
        self.currencyDisplayProvider = currencyDisplayProvider
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state.isLoading {
                    ProgressView()
                } else if viewModel.state.currencies.isEmpty {
                    ProgressView()
                } else {
                    List(viewModel.state.currencies, id: \.code) { currency in
                        let display = currencyDisplayProvider.display(for: currency.code)
                        Button {
                            viewModel.onTrigger(.currencyTapped(currency.code))
                        } label: {
                            HStack(spacing: UIConstants.Spacing.md) {
                                CurrencyIconView(display: display)
                                Text(display.title)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if currency.code == viewModel.state.selectedCurrencyCode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Circle()
                                        .stroke(Color(uiColor: .systemGray3), lineWidth: 1.5)
                                        .frame(width: 18, height: 18)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle(L10n.Exchange.CurrencyPicker.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.onTrigger(.closeTapped)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

}

#Preview("Currency Picker Loaded") {
    CurrencyPickerView(
        viewModel: StaticViewModel(
            state: ExchangePreviewFixtures.currencyPickerLoaded))
}

#Preview("Currency Picker Loading") {
    CurrencyPickerView(
        viewModel: StaticViewModel(
            state: ExchangePreviewFixtures.currencyPickerLoading))
}
