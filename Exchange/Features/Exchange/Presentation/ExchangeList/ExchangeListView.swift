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
    @Environment(\.scenePhase) private var scenePhase
    @State private var presentedCurrencyRow: ExchangeCurrencyRow?
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
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.exchangeListScreen)
        .onAppear {
            viewModel.onTrigger(.screenAppeared)
        }
        .onDisappear {
            viewModel.onTrigger(.screenDisappeared)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.onTrigger(.appBecameActive)
            } else if newPhase == .inactive || newPhase == .background {
                viewModel.onTrigger(.appMovedToBackground)
            }
        }
        .sheet(item: $presentedCurrencyRow) { row in
            currencyPickerSheet(for: row)
                .presentationDetents([.fraction(0.52)])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.xs) {
            Text(L10n.Exchange.calculatorTitle)
                .font(.title3.weight(.semibold))
            RateStatusBanner(
                text: ExchangeListStatusSubtitleBuilder.subtitle(
                    for: viewModel.state,
                    currencyDisplayProvider: currencyDisplayProvider),
                isRealtime: viewModel.state.isRealtimeRates)
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
                    autoFocusOnAppear: true,
                    onCurrencyTap: {
                        presentedCurrencyRow = .top
                    },
                    onAmountChanged: { viewModel.onTrigger(.topAmountChanged($0)) },
                    currencyDisplayProvider: currencyDisplayProvider)

                Divider()

                CurrencyAmountInputRow(
                    currencyCode: viewModel.state.bottomCurrency.code,
                    amountText: viewModel.state.bottomInputRaw,
                    isSelectableCurrency: viewModel.state.bottomCurrency.isUSDc == false,
                    onCurrencyTap: {
                        presentedCurrencyRow = .bottom
                    },
                    onAmountChanged: { viewModel.onTrigger(.bottomAmountChanged($0)) },
                    currencyDisplayProvider: currencyDisplayProvider)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.CornerRadius.lg)
                    .stroke(Color(uiColor: .separator), lineWidth: 0.5))

            SwapButton {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.onTrigger(.swapTapped)
                }
            }
        }
    }

    private func currencyPickerSheet(for row: ExchangeCurrencyRow) -> some View {
        CurrencyPickerView(
            viewModel: CurrencyPickerViewModel(
                initialState: CurrencyPickerState(
                    currencies: viewModel.state.availableCurrencies,
                    selectedCurrencyCode: pickerSelectedCode(for: row),
                    isLoading: viewModel.state.availableCurrencies.isEmpty),
                onSelectCurrency: { selectedCode in
                    viewModel.onTrigger(.currencySelected(row: row, code: selectedCode))
                    presentedCurrencyRow = nil
                },
                onClose: {
                    presentedCurrencyRow = nil
                }),
            currencyDisplayProvider: currencyDisplayProvider)
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

    private func pickerSelectedCode(for row: ExchangeCurrencyRow) -> String {
        switch row {
        case .top:
            return viewModel.state.topCurrency.code
        case .bottom:
            return viewModel.state.bottomCurrency.code
        }
    }
}

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
