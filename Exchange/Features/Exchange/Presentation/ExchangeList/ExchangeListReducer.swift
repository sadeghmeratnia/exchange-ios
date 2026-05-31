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

    func reduce(state: ExchangeListState, action: ExchangeListAction) -> ReduceOutput {
        switch action {
        case .startLoad:
            let nextState = state.startingInitialLoad()
            let currencies = [state.bottomCurrency.code]
            return (nextState, .fetchRates(currencies: currencies))

        case let .ratesLoaded(.success(rates)):
            let nextState = state.with(phase: .loaded, rates: rates, errorMessage: .some(nil))
            return (nextState, nil)

        case let .ratesLoaded(.failure(error)):
            let nextState = state.applyingLoadFailure(message: error.localizedDescription)
            return (nextState, nil)

        case let .currenciesLoaded(currencies):
            let nextState = state.with(availableCurrencies: currencies)
            return (nextState, nil)

        case let .setTopInput(value):
            let nextState = state.with(topInputRaw: value, activeInput: .top)
            return (nextState, nil)

        case let .setBottomInput(value):
            let nextState = state.with(bottomInputRaw: value, activeInput: .bottom)
            return (nextState, nil)

        case .performSwap:
            let nextState = state.with(
                topCurrency: state.bottomCurrency,
                bottomCurrency: state.topCurrency,
                topInputRaw: state.bottomInputRaw,
                bottomInputRaw: state.topInputRaw)
            return (nextState, nil)

        case .openPicker:
            let nextState = state.with(isCurrencyPickerPresented: true)
            return (nextState, nil)

        case .closePicker:
            let nextState = state.with(isCurrencyPickerPresented: false)
            return (nextState, nil)

        case let .applyCurrency(code):
            let nextState = state.with(
                bottomCurrency: Currency(code: code),
                isCurrencyPickerPresented: false)
            return (nextState, .fetchRates(currencies: [code]))

        case .retry:
            let nextState = state.startingRefresh()
            return (nextState, .fetchRates(currencies: [state.bottomCurrency.code]))

        case .clearError:
            let nextState = state.with(errorMessage: .some(nil))
            return (nextState, nil)
        }
    }
}
