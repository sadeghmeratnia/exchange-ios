//
//  ExchangeListReducerTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeListReducer")
struct ExchangeListReducerTests {
    private let sut = ExchangeListReducer()

    @Test("startLoad sets initial loading and fetches non-USDc currencies")
    func startLoadTransitionsToLoading() {
        let state = ExchangeListState.initial()

        let output = sut.reduce(state: state, action: .startLoad)

        #expect(output.state.phase == .loading(.initial))
        #expect(output.effect == .bootstrap(currencies: ["MXN"]))
    }

    @Test("ratesLoaded success updates rates and recalculates opposite amount")
    func ratesLoadedSuccessRecalculates() throws {
        let state = ExchangeListState.initial().with(topInputRaw: "2", activeInput: .top)

        let output = sut.reduce(
            state: state,
            action: .ratesLoaded(.success(
                ExchangeRatesSnapshot(
                    rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
                    isRealtime: true,
                    updatedAt: Date(timeIntervalSince1970: 0)))))

        #expect(output.state.phase == .loaded)
        #expect(output.state.rates.count == 1)
        #expect(output.state.bottomInputRaw == "36.80")
        #expect(output.state.isRealtimeRates == true)
        #expect(output.state.unitQuoteRate == decimal("18.400000"))
        #expect(output.effect == nil)
    }

    @Test("ratesLoaded failure sets error phase")
    func ratesLoadedFailureSetsError() {
        let output = sut.reduce(
            state: .initial(),
            action: .ratesLoaded(.failure(.ratesUnavailable)))

        let message = ExchangeDomainError.ratesUnavailable.errorDescription ?? ""
        #expect(output.state.phase == .error(message: message))
        #expect(output.state.errorMessage == message)
        #expect(output.effect == nil)
    }

    @Test("setTopInput recalculates bottom field")
    func setTopInputRecalculatesBottom() {
        let state = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])

        let output = sut.reduce(state: state, action: .setTopInput("10"))

        #expect(output.state.activeInput == .top)
        #expect(output.state.topInputRaw == "10")
        #expect(output.state.bottomInputRaw == "184.00")
        #expect(output.effect == nil)
    }

    @Test("setBottomInput recalculates top field")
    func setBottomInputRecalculatesTop() {
        let state = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])

        let output = sut.reduce(state: state, action: .setBottomInput("184"))

        #expect(output.state.activeInput == .bottom)
        #expect(output.state.bottomInputRaw == "184")
        #expect(output.state.topInputRaw == "10.00")
        #expect(output.effect == nil)
    }

    @Test("performSwap flips currencies without unnecessary fetch when currency set is unchanged")
    func performSwapFlipsCurrencies() {
        let state = ExchangeListState.initial().with(
            topInputRaw: "10",
            bottomInputRaw: "184",
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])

        let output = sut.reduce(state: state, action: .performSwap)

        #expect(output.state.topCurrency.code == "MXN")
        #expect(output.state.bottomCurrency.code == "USDC")
        #expect(output.state.topInputRaw == "184.00")
        #expect(output.state.bottomInputRaw == "10")
        #expect(output.effect == nil)
    }

    @Test("refreshIfNeeded fetches when last update is stale")
    func refreshIfNeededFetchesWhenStale() {
        let staleDate = Date().addingTimeInterval(-(ExchangeListRefreshPolicy.ratesRefreshInterval + 1))
        let state = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
            lastUpdatedAt: .some(staleDate)
        )

        let output = sut.reduce(state: state, action: .refreshIfNeeded)

        #expect(output.effect == .fetchRates(currencies: ["MXN"]))
    }

    @Test("refreshIfNeeded skips fetch when rates are fresh")
    func refreshIfNeededSkipsWhenFresh() {
        let freshDate = Date().addingTimeInterval(-10)
        let state = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
            lastUpdatedAt: .some(freshDate)
        )

        let output = sut.reduce(state: state, action: .refreshIfNeeded)

        #expect(output.effect == nil)
    }

    @Test("applyCurrency updates bottom currency and fetches rates")
    func applyCurrencyUpdatesSelection() {
        let state = ExchangeListState.initial().with(
            topInputRaw: "1",
            rates: [rate(quote: "ARS", ask: "1551", bid: "1539")])

        let output = sut.reduce(state: state, action: .applyCurrency(row: .bottom, code: "ARS"))

        #expect(output.state.bottomCurrency.code == "ARS")
        #expect(LocalizedNumberFormatting.parseDecimalInput(output.state.bottomInputRaw) == decimal("1545"))
        #expect(output.effect == .fetchRates(currencies: ["ARS"]))
    }

    @Test("applyCurrency updates top currency when picker row is top")
    func applyCurrencyUpdatesTopSelection() {
        let state = ExchangeListState.initial().with(
            topCurrency: Currency(code: "MXN"),
            bottomCurrency: Currency(code: "USDC"),
            bottomInputRaw: "10",
            activeInput: .bottom,
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])

        let output = sut.reduce(state: state, action: .applyCurrency(row: .top, code: "ARS"))

        #expect(output.state.topCurrency.code == "ARS")
        #expect(output.effect == .fetchRates(currencies: ["ARS"]))
    }

    @Test("retry sets refresh loading and emits fetch effect")
    func retryEmitsFetch() {
        let state = ExchangeListState.initial().with(phase: .error(message: "error"))

        let output = sut.reduce(state: state, action: .retry)

        #expect(output.state.phase == .loading(.refresh))
        #expect(output.effect == .fetchRates(currencies: ["MXN"]))
    }

    @Test("currenciesLoaded stores available currencies")
    func currenciesLoadedStoresValues() {
        let currencies = [Currency(code: "MXN"), Currency(code: "ARS")]

        let output = sut.reduce(state: .initial(), action: .currenciesLoaded(currencies))

        #expect(output.state.availableCurrencies == currencies)
        #expect(output.effect == nil)
    }

    @Test("clearError removes error message only")
    func clearErrorClearsMessage() {
        let state = ExchangeListState.initial().with(errorMessage: .some("boom"))

        let output = sut.reduce(state: state, action: .clearError)

        #expect(output.state.errorMessage == nil)
        #expect(output.effect == nil)
    }

    @Test("invalid top input clears bottom value")
    func invalidTopInputClearsBottom() {
        let state = ExchangeListState.initial().with(
            bottomInputRaw: "100.00",
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])

        let output = sut.reduce(state: state, action: .setTopInput("abc"))

        #expect(output.state.topInputRaw == "abc")
        #expect(output.state.bottomInputRaw == "")
        #expect(output.effect == nil)
    }

    @Test("currency apply on USDC does not request any non-USDC rate")
    func applyCurrencyToUSDCRequestsNoRate() {
        let output = sut.reduce(state: .initial(), action: .applyCurrency(row: .bottom, code: "USDC"))

        #expect(output.state.bottomCurrency.code == "USDC")
        #expect(output.effect == .fetchRates(currencies: []))
    }
}

private extension ExchangeListReducerTests {
    enum TestError: Error {
        case sample
    }

    func rate(quote: String, ask: String, bid: String) -> ExchangeRate {
        ExchangeRate(
            baseCurrency: Currency(code: "USDC"),
            quoteCurrency: Currency(code: quote),
            ask: decimal(ask),
            bid: decimal(bid),
            timestamp: Date(timeIntervalSince1970: 0))
    }

    func decimal(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
    }
}
