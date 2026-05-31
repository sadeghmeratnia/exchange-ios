//
//  ExchangeListAction.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListAction

enum ExchangeListAction {
    case startLoad
    case ratesLoaded(Result<[ExchangeRate], Error>)
    case currenciesLoaded([Currency])
    case setTopInput(String)
    case setBottomInput(String)
    case performSwap
    case openPicker
    case closePicker
    case applyCurrency(String)
    case retry
    case clearError
}
