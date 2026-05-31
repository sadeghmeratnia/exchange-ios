//
//  ExchangeListView.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import SwiftUI

// MARK: - ExchangeListView

struct ExchangeListView<VM: ViewModelProtocol>: View where VM.State == ExchangeListState, VM.Trigger == ExchangeListTrigger {
    @ObservedObject private var viewModel: VM

    init(viewModel: VM) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: UIConstants.Spacing.xl) {
            header
            amountCard
            phaseView
            Spacer()
        }
        .padding(UIConstants.Spacing.lg)
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear {
            viewModel.onTrigger(.screenAppeared)
        }
        .sheet(isPresented: pickerBinding) {
            currencyPickerSheet
                .presentationDetents([.fraction(0.52)])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.xs) {
            Text(L10n.Exchange.calculatorTitle)
                .font(.title3.weight(.semibold))
            RateStatusBanner(text: rateSubtitle, isRealtime: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var amountCard: some View {
        ZStack {
            VStack(spacing: 0) {
                CurrencyAmountInputRow(
                    currencyCode: viewModel.state.topCurrency.code,
                    amountText: viewModel.state.topInputRaw,
                    isSelectableCurrency: false,
                    onCurrencyTap: {},
                    onAmountChanged: { viewModel.onTrigger(.topAmountChanged($0)) })

                Divider()

                CurrencyAmountInputRow(
                    currencyCode: viewModel.state.bottomCurrency.code,
                    amountText: viewModel.state.bottomInputRaw,
                    isSelectableCurrency: true,
                    onCurrencyTap: { viewModel.onTrigger(.currencyTapped) },
                    onAmountChanged: { viewModel.onTrigger(.bottomAmountChanged($0)) })
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.CornerRadius.lg)
                    .stroke(Color(uiColor: .separator), lineWidth: 0.5))

            SwapButton {
                viewModel.onTrigger(.swapTapped)
            }
        }
    }

    private var currencyPickerSheet: some View {
        NavigationStack {
            List(currenciesForPicker, id: \.code) { currency in
                Button {
                    viewModel.onTrigger(.currencySelected(currency.code))
                } label: {
                    HStack(spacing: UIConstants.Spacing.md) {
                        Text(flag(for: currency.code))
                        Text(currency.code)
                            .foregroundStyle(.primary)
                        Spacer()
                        if currency.code == viewModel.state.bottomCurrency.code {
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
            .navigationTitle(L10n.Exchange.CurrencyPicker.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.onTrigger(.currencyPickerDismissed)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    private var currenciesForPicker: [Currency] {
        if viewModel.state.availableCurrencies.isEmpty {
            return [
                Currency(code: "ARS"),
                Currency(code: "BRL"),
                Currency(code: "COP"),
                Currency(code: "MXN"),
            ]
        }
        return viewModel.state.availableCurrencies
    }

    private var pickerBinding: Binding<Bool> {
        Binding(
            get: { viewModel.state.isCurrencyPickerPresented },
            set: { isPresented in
                if isPresented == false {
                    viewModel.onTrigger(.currencyPickerDismissed)
                }
            })
    }

    @ViewBuilder
    private var phaseView: some View {
        switch viewModel.state.phase {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .leading)
        case .loaded:
            EmptyView()
        case let .error(message):
            Text(message)
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var rateSubtitle: String {
        guard let quoteRate = viewModel.state.rates.first(where: {
            $0.baseCurrency.code == viewModel.state.topCurrency.code &&
                $0.quoteCurrency.code == viewModel.state.bottomCurrency.code
        }) else {
            return "1 \(currencyTitle(for: viewModel.state.topCurrency)) = -- \(viewModel.state.bottomCurrency.code)"
        }
        return "1 \(currencyTitle(for: viewModel.state.topCurrency)) = \(format(decimal: quoteRate.mid)) \(viewModel.state.bottomCurrency.code)"
    }

    private func format(decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 4
        return formatter.string(from: decimal as NSDecimalNumber) ?? "\(decimal)"
    }

    private func currencyTitle(for currency: Currency) -> String {
        currency.code == "USDC" ? "USDc" : currency.code
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

typealias DefaultExchangeListView = ExchangeListView<ExchangeListViewModel>

#Preview("Exchange List Idle") {
    ExchangeListView(
        viewModel: StaticViewModel(
            state: .initial().with(
                topInputRaw: "9,999",
                bottomInputRaw: "184,065.59",
                availableCurrencies: [
                    Currency(code: "ARS"),
                    Currency(code: "BRL"),
                    Currency(code: "COP"),
                    Currency(code: "MXN"),
                ],
                rates: [
                    ExchangeRate(
                        baseCurrency: Currency(code: "USDC"),
                        quoteCurrency: Currency(code: "MXN"),
                        ask: 18.41,
                        bid: 18.39,
                        timestamp: .now),
                ])))
}
