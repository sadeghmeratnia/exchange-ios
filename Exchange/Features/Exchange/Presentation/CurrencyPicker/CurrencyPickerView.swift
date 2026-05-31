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

    init(viewModel: VM) {
        self.viewModel = viewModel
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
                        Button {
                            viewModel.onTrigger(.currencyTapped(currency.code))
                        } label: {
                            HStack(spacing: UIConstants.Spacing.md) {
                                Text(flag(for: currency.code))
                                Text(currency.code)
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

    private func flag(for code: String) -> String {
        switch code {
        case "USDC":
            "🇺🇸"
        case "MXN":
            "🇲🇽"
        case "ARS":
            "🇦🇷"
        case "BRL":
            "🇧🇷"
        case "COP":
            "🇨🇴"
        default:
            "🏳️"
        }
    }
}
