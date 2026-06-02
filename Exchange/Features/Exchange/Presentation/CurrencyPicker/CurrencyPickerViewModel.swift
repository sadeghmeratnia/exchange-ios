//
//  CurrencyPickerViewModel.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Combine
import Foundation

// MARK: - CurrencyPickerViewModelProtocol

@MainActor
protocol CurrencyPickerViewModelProtocol: ReducingStoreProtocol where State == CurrencyPickerState, Trigger == CurrencyPickerTrigger, Action == CurrencyPickerAction, Effect == CurrencyPickerEffect {}

// MARK: - CurrencyPickerViewModel

@MainActor
final class CurrencyPickerViewModel: CurrencyPickerViewModelProtocol {
    @Published private(set) var state: CurrencyPickerState

    private let reducer: CurrencyPickerReducer
    private let onSelectCurrency: (String) -> Void
    private let onClose: () -> Void
    private var effectTask: Task<Void, Never>?

    init(
        initialState: CurrencyPickerState,
        reducer: CurrencyPickerReducer = CurrencyPickerReducer(),
        onSelectCurrency: @escaping (String) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.state = initialState
        self.reducer = reducer
        self.onSelectCurrency = onSelectCurrency
        self.onClose = onClose
    }

    deinit {
        effectTask?.cancel()
    }

    func onTrigger(_ trigger: CurrencyPickerTrigger) {
        switch trigger {
        case let .currencyTapped(code):
            send(.selectCurrency(code))
        case .closeTapped:
            send(.close)
        }
    }

    func send(_ action: CurrencyPickerAction) {
        let output = reducer.reduce(state: state, action: action)
        state = output.state

        if let effect = output.effect {
            effectTask?.cancel()
            effectTask = Task { [weak self] in
                await self?.run(effect)
            }
        }
    }

    func run(_ effect: CurrencyPickerEffect) async {
        switch effect {
        case let .didSelect(code):
            onSelectCurrency(code)
        case .didClose:
            onClose()
        }
    }
}
