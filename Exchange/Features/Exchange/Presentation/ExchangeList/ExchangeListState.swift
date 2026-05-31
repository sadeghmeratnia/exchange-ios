//
//  ExchangeListState.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangeListState

struct ExchangeListState: Equatable {
    enum Phase: Equatable {
        case idle
        case loading(LoadingKind)
        case loaded
        case error(message: String)
    }

    enum LoadingKind: Equatable {
        case initial
        case refresh
    }

    enum ActiveInput: Equatable {
        case top
        case bottom
    }

    var phase: Phase
    var topCurrency: Currency
    var bottomCurrency: Currency
    var topInputRaw: String
    var bottomInputRaw: String
    var activeInput: ActiveInput
    var availableCurrencies: [Currency]
    var rates: [ExchangeRate]
    var isCurrencyPickerPresented: Bool
    var errorMessage: String?

    static func initial() -> ExchangeListState {
        ExchangeListState(
            phase: .idle,
            topCurrency: Currency(code: "USDC"),
            bottomCurrency: Currency(code: "MXN"),
            topInputRaw: "",
            bottomInputRaw: "",
            activeInput: .top,
            availableCurrencies: [],
            rates: [],
            isCurrencyPickerPresented: false,
            errorMessage: nil)
    }
}

// MARK: - Semantic Updates

extension ExchangeListState {
    func with(phase: Phase? = nil,
              topCurrency: Currency? = nil,
              bottomCurrency: Currency? = nil,
              topInputRaw: String? = nil,
              bottomInputRaw: String? = nil,
              activeInput: ActiveInput? = nil,
              availableCurrencies: [Currency]? = nil,
              rates: [ExchangeRate]? = nil,
              isCurrencyPickerPresented: Bool? = nil,
              errorMessage: String?? = nil) -> ExchangeListState {
        ExchangeListState(
            phase: phase ?? self.phase,
            topCurrency: topCurrency ?? self.topCurrency,
            bottomCurrency: bottomCurrency ?? self.bottomCurrency,
            topInputRaw: topInputRaw ?? self.topInputRaw,
            bottomInputRaw: bottomInputRaw ?? self.bottomInputRaw,
            activeInput: activeInput ?? self.activeInput,
            availableCurrencies: availableCurrencies ?? self.availableCurrencies,
            rates: rates ?? self.rates,
            isCurrencyPickerPresented: isCurrencyPickerPresented ?? self.isCurrencyPickerPresented,
            errorMessage: errorMessage ?? self.errorMessage)
    }

    func startingInitialLoad() -> ExchangeListState {
        with(phase: .loading(.initial), errorMessage: .some(nil))
    }

    func startingRefresh() -> ExchangeListState {
        with(phase: .loading(.refresh), errorMessage: .some(nil))
    }

    func applyingLoadSuccess(rates: [ExchangeRate], availableCurrencies: [Currency]) -> ExchangeListState {
        with(
            phase: .loaded,
            availableCurrencies: availableCurrencies,
            rates: rates,
            errorMessage: .some(nil))
    }

    func applyingLoadFailure(message: String) -> ExchangeListState {
        with(phase: .error(message: message), errorMessage: .some(message))
    }
}
