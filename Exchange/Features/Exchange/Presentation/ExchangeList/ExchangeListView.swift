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
    private let currencyDisplayProvider: any CurrencyDisplayProviding

    init(viewModel: VM,
         currencyDisplayProvider: any CurrencyDisplayProviding = CurrencyDisplayProvider()) {
        self.viewModel = viewModel
        self.currencyDisplayProvider = currencyDisplayProvider
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
            RateStatusBanner(text: rateSubtitle, isRealtime: viewModel.state.isRealtimeRates)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var amountCard: some View {
        ZStack {
            VStack(spacing: 0) {
                CurrencyAmountInputRow(
                    currencyCode: viewModel.state.topCurrency.code,
                    amountText: viewModel.state.topInputRaw,
                    isSelectableCurrency: viewModel.state.topCurrency.isUSDc == false,
                    onCurrencyTap: { viewModel.onTrigger(.currencyTapped(row: .top)) },
                    onAmountChanged: { viewModel.onTrigger(.topAmountChanged($0)) },
                    currencyDisplayProvider: currencyDisplayProvider)

                Divider()

                CurrencyAmountInputRow(
                    currencyCode: viewModel.state.bottomCurrency.code,
                    amountText: viewModel.state.bottomInputRaw,
                    isSelectableCurrency: viewModel.state.bottomCurrency.isUSDc == false,
                    onCurrencyTap: { viewModel.onTrigger(.currencyTapped(row: .bottom)) },
                    onAmountChanged: { viewModel.onTrigger(.bottomAmountChanged($0)) },
                    currencyDisplayProvider: currencyDisplayProvider)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
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
        CurrencyPickerView(
            viewModel: CurrencyPickerViewModel(
                initialState: CurrencyPickerState(
                    currencies: viewModel.state.availableCurrencies,
                    selectedCurrencyCode: pickerSelectedCode,
                    isLoading: viewModel.state.availableCurrencies.isEmpty),
                onSelectCurrency: { selectedCode in
                    viewModel.onTrigger(.currencySelected(selectedCode))
                },
                onClose: {
                    viewModel.onTrigger(.currencyPickerDismissed)
                }),
            currencyDisplayProvider: currencyDisplayProvider)
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
            HStack(spacing: UIConstants.Spacing.md) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                Button(L10n.Exchange.Action.retry) {
                    viewModel.onTrigger(.retryTapped)
                }
                .buttonStyle(.bordered)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var rateSubtitle: String {
        let statusPrefix = viewModel.state.isRealtimeRates
            ? L10n.Exchange.Status.live
            : L10n.Exchange.Status.notRealtime
        let updateText = freshnessText()
        let oneUnit = Decimal(integerLiteral: 1)
        let convertedRate = ConvertAmountUseCase().execute(
            amount: oneUnit,
            from: viewModel.state.topCurrency,
            to: viewModel.state.bottomCurrency,
            rates: viewModel.state.rates)

        guard let convertedRate else {
            return "\(statusPrefix) • \(updateText) • 1 \(currencyTitle(for: viewModel.state.topCurrency)) = -- \(viewModel.state.bottomCurrency.code)"
        }
        return "\(statusPrefix) • \(updateText) • 1 \(currencyTitle(for: viewModel.state.topCurrency)) = \(format(decimal: convertedRate)) \(viewModel.state.bottomCurrency.code)"
    }

    private func format(decimal: Decimal) -> String {
        LocalizedNumberFormatting.formatRate(decimal)
    }

    private func currencyTitle(for currency: Currency) -> String {
        currencyDisplayProvider.display(for: currency.code).title
    }

    private var pickerSelectedCode: String {
        switch viewModel.state.currencyPickerRow {
        case .top:
            return viewModel.state.topCurrency.code
        case .bottom, .none:
            return viewModel.state.bottomCurrency.code
        }
    }

    private func freshnessText() -> String {
        guard let updatedAt = viewModel.state.lastUpdatedAt else {
            return viewModel.state.isRealtimeRates
                ? L10n.Exchange.Status.updated
                : L10n.Exchange.Status.lastUpdated
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let relative = formatter.localizedString(for: updatedAt, relativeTo: Date())
        let prefix = viewModel.state.isRealtimeRates
            ? L10n.Exchange.Status.updated
            : L10n.Exchange.Status.lastUpdated
        return "\(prefix) \(relative)"
    }
}

typealias DefaultExchangeListView = ExchangeListView<ExchangeListViewModel>

#Preview("Exchange List Loaded") {
    ExchangeListView(
        viewModel: StaticViewModel(
            state: ExchangePreviewFixtures.exchangeListLoaded))
}

#Preview("Exchange List Loading") {
    ExchangeListView(
        viewModel: StaticViewModel(
            state: ExchangePreviewFixtures.exchangeListLoading))
}

#Preview("Exchange List Error") {
    ExchangeListView(
        viewModel: StaticViewModel(
            state: ExchangePreviewFixtures.exchangeListError))
}
