//
//  ExchangeListReducer.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListReducer

struct ExchangeListReducer {
    typealias ReduceOutput = (state: ExchangeListState, effect: ExchangeListEffect?)
    private let convertAmountUseCase: ConvertAmountUseCase
    private let refreshInterval: TimeInterval

    init(convertAmountUseCase: ConvertAmountUseCase = ConvertAmountUseCase(),
         refreshInterval: TimeInterval = ExchangeListRefreshPolicy.ratesRefreshInterval) {
        self.convertAmountUseCase = convertAmountUseCase
        self.refreshInterval = refreshInterval
    }

    func reduce(state: ExchangeListState, action: ExchangeListAction) -> ReduceOutput {
        switch action {
        case .startLoad:
            let nextState = state.startingInitialLoad()
            return (nextState, .bootstrap(currencies: requestedCurrencyCodes(from: nextState)))

        case .refreshIfNeeded:
            guard shouldRefreshRates(for: state) else {
                return (state, nil)
            }
            return (state, .fetchRates(currencies: requestedCurrencyCodes(from: state)))

        case let .ratesLoaded(.success(snapshot)):
            let loadedState = state.with(
                phase: .loaded,
                rates: snapshot.rates,
                isRealtimeRates: snapshot.isRealtime,
                lastUpdatedAt: .set(snapshot.updatedAt),
                errorMessage: .set(nil))
            let nextState = applyConversions(from: loadedState)
            return (nextState, nil)

        case let .ratesLoaded(.failure(error)):
            let nextState = state.applyingLoadFailure(error: error)
            return (nextState, nil)

        case let .currenciesLoaded(currencies):
            let nextState = state.with(availableCurrencies: currencies)
            return (nextState, nil)

        case let .setTopInput(value):
            let editingState = state.with(topInputRaw: value, activeInput: .top)
            let nextState = applyConversions(from: editingState)
            return (nextState, nil)

        case let .setBottomInput(value):
            let editingState = state.with(bottomInputRaw: value, activeInput: .bottom)
            let nextState = applyConversions(from: editingState)
            return (nextState, nil)

        case .performSwap:
            let previousRequestedCodes = requestedCurrencyCodes(from: state)
            let swappedState = state.with(
                topCurrency: state.bottomCurrency,
                bottomCurrency: state.topCurrency,
                topInputRaw: state.bottomInputRaw,
                bottomInputRaw: state.topInputRaw,
                activeInput: state.activeInput == .top ? .bottom : .top)
            let nextState = applyConversions(from: swappedState)
            let nextRequestedCodes = requestedCurrencyCodes(from: nextState)
            let effect: ExchangeListEffect? = previousRequestedCodes == nextRequestedCodes
                ? nil
                : .fetchRates(currencies: nextRequestedCodes)
            return (nextState, effect)

        case let .applyCurrency(row, code):
            let selectedState = state.withCurrencySelection(row: row, code: code)
            let nextState = applyConversions(from: selectedState)
            return (nextState, .fetchRates(currencies: requestedCurrencyCodes(from: nextState)))

        case .retry:
            let nextState = state.startingRefresh()
            return (nextState, .fetchRates(currencies: requestedCurrencyCodes(from: nextState)))

        case .clearError:
            let nextState = state.with(errorMessage: .set(nil))
            return (nextState, nil)
        }
    }
}

// MARK: - Helpers

private extension ExchangeListReducer {
    func shouldRefreshRates(for state: ExchangeListState) -> Bool {
        if case .loading = state.phase {
            return false
        }

        if state.rates.isEmpty {
            return true
        }

        guard let lastUpdatedAt = state.lastUpdatedAt else {
            return true
        }

        return Date().timeIntervalSince(lastUpdatedAt) >= refreshInterval
    }

    func requestedCurrencyCodes(from state: ExchangeListState) -> [String] {
        let codes = [state.topCurrency.code, state.bottomCurrency.code]
            .filter { $0.uppercased() != "USDC" }
        return Array(Set(codes)).sorted()
    }

    func applyConversions(from state: ExchangeListState) -> ExchangeListState {
        let withAmounts = recalculateOppositeAmount(from: state)
        return withAmounts.with(unitQuoteRate: .set(unitQuoteRate(from: withAmounts)))
    }

    func unitQuoteRate(from state: ExchangeListState) -> Decimal? {
        convertAmountUseCase.execute(
            amount: Decimal(integerLiteral: 1),
            from: state.topCurrency,
            to: state.bottomCurrency,
            rates: state.rates)
    }

    func recalculateOppositeAmount(from state: ExchangeListState) -> ExchangeListState {
        switch state.activeInput {
        case .top:
            guard let amount = decimal(from: state.topInputRaw) else {
                return state.with(bottomInputRaw: "")
            }
            let converted = convertAmountUseCase.execute(
                amount: amount,
                from: state.topCurrency,
                to: state.bottomCurrency,
                rates: state.rates)
            return state.with(bottomInputRaw: converted.map(format(decimal:)) ?? "")

        case .bottom:
            guard let amount = decimal(from: state.bottomInputRaw) else {
                return state.with(topInputRaw: "")
            }
            let converted = convertAmountUseCase.execute(
                amount: amount,
                from: state.bottomCurrency,
                to: state.topCurrency,
                rates: state.rates)
            return state.with(topInputRaw: converted.map(format(decimal:)) ?? "")
        }
    }

    func decimal(from rawValue: String) -> Decimal? {
        LocalizedNumberFormatting.parseDecimalInput(rawValue)
    }

    func format(decimal: Decimal) -> String {
        LocalizedNumberFormatting.formatAmount(decimal)
    }
}

private extension ExchangeListState {
    func withCurrencySelection(row: ExchangeCurrencyRow, code: String) -> ExchangeListState {
        let selectedCurrency = Currency(code: code)
        switch row {
        case .top:
            return with(topCurrency: selectedCurrency)
        case .bottom:
            return with(bottomCurrency: selectedCurrency)
        }
    }
}
