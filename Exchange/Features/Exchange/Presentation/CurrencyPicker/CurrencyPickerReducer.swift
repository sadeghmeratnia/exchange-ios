//
//  CurrencyPickerReducer.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - CurrencyPickerReducer

struct CurrencyPickerReducer {
    typealias ReduceOutput = (state: CurrencyPickerState, effect: CurrencyPickerEffect?)

    func reduce(state: CurrencyPickerState, action: CurrencyPickerAction) -> ReduceOutput {
        switch action {
        case let .selectCurrency(code):
            let nextState = CurrencyPickerState(
                currencies: state.currencies,
                selectedCurrencyCode: code,
                isLoading: state.isLoading)
            return (nextState, .didSelect(code))

        case .close:
            return (state, .didClose)
        }
    }
}
