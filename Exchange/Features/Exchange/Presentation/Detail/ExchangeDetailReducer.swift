//
//  ExchangeDetailReducer.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeDetailReducer

struct ExchangeDetailReducer {
    typealias ReduceOutput = (state: ExchangeDetailState, effect: ExchangeDetailEffect?)

    func reduce(state: ExchangeDetailState, action: ExchangeDetailAction) -> ReduceOutput {
        switch action {
        case .screenAppeared:
            return (state, .none)
        }
    }
}
