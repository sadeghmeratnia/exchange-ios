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
    private let convertAmountUseCase = ConvertAmountUseCase()

    func reduce(state: ExchangeListState, action: ExchangeListAction) -> ReduceOutput {
        switch action {
        case .startLoad:
            let nextState = state.startingInitialLoad()
            return (nextState, .bootstrap(currencies: requestedCurrencyCodes(from: nextState)))

        case let .ratesLoaded(.success(snapshot)):
            let loadedState = state.with(
                phase: .loaded,
                rates: snapshot.rates,
                isRealtimeRates: snapshot.isRealtime,
                lastUpdatedAt: .some(snapshot.updatedAt),
                errorMessage: .some(nil))
            let nextState = recalculateOppositeAmount(from: loadedState)
            return (nextState, nil)

        case let .ratesLoaded(.failure(error)):
            let nextState = state.applyingLoadFailure(message: error.localizedDescription)
            return (nextState, nil)

        case let .currenciesLoaded(currencies):
            let nextState = state.with(availableCurrencies: currencies)
            return (nextState, nil)

        case let .setTopInput(value):
            let editingState = state.with(topInputRaw: value, activeInput: .top)
            let nextState = recalculateOppositeAmount(from: editingState)
            return (nextState, nil)

        case let .setBottomInput(value):
            let editingState = state.with(bottomInputRaw: value, activeInput: .bottom)
            let nextState = recalculateOppositeAmount(from: editingState)
            return (nextState, nil)

        case .performSwap:
            let swappedState = state.with(
                topCurrency: state.bottomCurrency,
                bottomCurrency: state.topCurrency,
                topInputRaw: state.bottomInputRaw,
                bottomInputRaw: state.topInputRaw,
                activeInput: state.activeInput == .top ? .bottom : .top)
            let nextState = recalculateOppositeAmount(from: swappedState)
            return (nextState, .fetchRates(currencies: requestedCurrencyCodes(from: nextState)))

        case let .applyCurrency(row, code):
            let selectedState = state.withCurrencySelection(row: row, code: code)
            let nextState = recalculateOppositeAmount(from: selectedState)
            return (nextState, .fetchRates(currencies: requestedCurrencyCodes(from: nextState)))

        case .retry:
            let nextState = state.startingRefresh()
            return (nextState, .fetchRates(currencies: requestedCurrencyCodes(from: nextState)))

        case .clearError:
            let nextState = state.with(errorMessage: .some(nil))
            return (nextState, nil)
        }
    }
}

// MARK: - Helpers

private extension ExchangeListReducer {
    func requestedCurrencyCodes(from state: ExchangeListState) -> [String] {
        let codes = [state.topCurrency.code, state.bottomCurrency.code]
            .filter { $0.uppercased() != "USDC" }
        return Array(Set(codes)).sorted()
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
