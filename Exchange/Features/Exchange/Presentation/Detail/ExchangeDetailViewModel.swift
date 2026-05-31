//
//  ExchangeDetailViewModel.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Combine
import Foundation

// MARK: - ExchangeDetailViewModelProtocol

@MainActor
protocol ExchangeDetailViewModelProtocol: ReducingStoreProtocol where State == ExchangeDetailState, Trigger == ExchangeDetailTrigger, Action == ExchangeDetailAction, Effect == ExchangeDetailEffect {}

// MARK: - ExchangeDetailViewModel

@MainActor
final class ExchangeDetailViewModel: ExchangeDetailViewModelProtocol {
    @Published private(set) var state: ExchangeDetailState

    private let reducer: ExchangeDetailReducer

    init(initialState: ExchangeDetailState,
         reducer: ExchangeDetailReducer = ExchangeDetailReducer()) {
        self.state = initialState
        self.reducer = reducer
    }

    func onTrigger(_ trigger: ExchangeDetailTrigger) {
        switch trigger {
        case .screenAppeared:
            send(.screenAppeared)
        }
    }

    func send(_ action: ExchangeDetailAction) {
        let output = reducer.reduce(state: state, action: action)
        state = output.state
    }

    func run(_ effect: ExchangeDetailEffect) async {}
}
