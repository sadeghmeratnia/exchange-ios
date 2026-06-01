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
    case ratesLoaded(Result<ExchangeRatesSnapshot, Error>)
    case currenciesLoaded([Currency])
    case setTopInput(String)
    case setBottomInput(String)
    case performSwap
    case openPicker(row: ExchangeListTrigger.CurrencyRow)
    case closePicker
    case applyCurrency(String)
    case retry
    case clearError
}
