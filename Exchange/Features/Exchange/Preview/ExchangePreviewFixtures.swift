//
//  ExchangePreviewFixtures.swift
//  Exchange
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation

// MARK: - ExchangePreviewFixtures

enum ExchangePreviewFixtures {
    static let currencies: [Currency] = [
        Currency(code: "ARS"),
        Currency(code: "BRL"),
        Currency(code: "COP"),
        Currency(code: "MXN"),
    ]

    static let rates: [ExchangeRate] = [
        ExchangeRate(
            baseCurrency: Currency(code: "USDC"),
            quoteCurrency: Currency(code: "MXN"),
            ask: 18.41,
            bid: 18.39,
            timestamp: previewDate),
    ]

    static let exchangeListLoaded: ExchangeListState = .initial().with(
        phase: .loaded,
        topInputRaw: "9,999",
        bottomInputRaw: "184,065.59",
        availableCurrencies: currencies,
        rates: rates)

    static let exchangeListLoading: ExchangeListState = .initial().with(
        phase: .loading(.initial),
        topInputRaw: "9,999",
        bottomInputRaw: "")

    static let exchangeListError: ExchangeListState = .initial().with(
        phase: .error(message: "Unable to fetch latest rates."),
        topInputRaw: "9,999",
        bottomInputRaw: "",
        errorMessage: .some("Unable to fetch latest rates."))

    static let currencyPickerLoaded = CurrencyPickerState(
        currencies: currencies,
        selectedCurrencyCode: "MXN",
        isLoading: false)

    static let currencyPickerLoading = CurrencyPickerState(
        currencies: [],
        selectedCurrencyCode: "MXN",
        isLoading: true)

    static let exchangeDetail = ExchangeDetailState.initial(currencyCode: "MXN")
}

private extension ExchangePreviewFixtures {
    static var previewDate: Date {
        Date(timeIntervalSince1970: 1_715_000_000)
    }
}
