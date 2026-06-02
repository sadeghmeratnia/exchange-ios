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
    var isRealtimeRates: Bool
    var lastUpdatedAt: Date?
    var errorMessage: String?
    /// Conversion rate for 1 unit of `topCurrency` in `bottomCurrency` terms; derived from rates.
    var unitQuoteRate: Decimal?

    static func initial() -> ExchangeListState {
        ExchangeListState(
            phase: .idle,
            topCurrency: Currency(code: "USDC"),
            bottomCurrency: Currency(code: "MXN"),
            topInputRaw: "1",
            bottomInputRaw: "",
            activeInput: .top,
            availableCurrencies: [],
            rates: [],
            isRealtimeRates: true,
            lastUpdatedAt: nil,
            errorMessage: nil,
            unitQuoteRate: nil)
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
              isRealtimeRates: Bool? = nil,
              lastUpdatedAt: Date?? = nil,
              errorMessage: String?? = nil,
              unitQuoteRate: Decimal?? = nil) -> ExchangeListState {
        ExchangeListState(
            phase: phase ?? self.phase,
            topCurrency: topCurrency ?? self.topCurrency,
            bottomCurrency: bottomCurrency ?? self.bottomCurrency,
            topInputRaw: topInputRaw ?? self.topInputRaw,
            bottomInputRaw: bottomInputRaw ?? self.bottomInputRaw,
            activeInput: activeInput ?? self.activeInput,
            availableCurrencies: availableCurrencies ?? self.availableCurrencies,
            rates: rates ?? self.rates,
            isRealtimeRates: isRealtimeRates ?? self.isRealtimeRates,
            lastUpdatedAt: lastUpdatedAt ?? self.lastUpdatedAt,
            errorMessage: errorMessage ?? self.errorMessage,
            unitQuoteRate: unitQuoteRate ?? self.unitQuoteRate)
    }

    func startingInitialLoad() -> ExchangeListState {
        with(phase: .loading(.initial), errorMessage: .some(nil))
    }

    func startingRefresh() -> ExchangeListState {
        with(phase: .loading(.refresh), errorMessage: .some(nil))
    }

    func applyingLoadFailure(error: ExchangeDomainError) -> ExchangeListState {
        let message = error.errorDescription ?? L10n.Exchange.Error.ratesUnavailable
        return with(phase: .error(message: message), errorMessage: .some(message))
    }
}
