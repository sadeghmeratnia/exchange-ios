//
//  ExchangeListViewModelTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeListViewModel")
@MainActor
struct ExchangeListViewModelTests {
    @Test("screen appeared loads rates and currencies")
    func screenAppearedLoadsInitialData() async throws {
        let repository = MockExchangeRepository()
        repository.fetchRatesHandler = { _ in [rate(quote: "MXN", ask: "18.41", bid: "18.39")] }
        repository.fetchAvailableCurrenciesHandler = { [Currency(code: "MXN"), Currency(code: "ARS")] }
        let sut = makeSUT(repository: repository)

        sut.onTrigger(.screenAppeared)
        try await Task.sleep(nanoseconds: 80_000_000)

        #expect(sut.state.phase == .loaded)
        #expect(sut.state.availableCurrencies == [Currency(code: "MXN"), Currency(code: "ARS")])
        #expect(sut.state.rates.first?.quoteCurrency.code == "MXN")
    }

    @Test("top input trigger updates bottom converted amount")
    func topInputTriggerConvertsBottom() async {
        let repository = MockExchangeRepository()
        let initialState = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")])
        let sut = makeSUT(repository: repository, initialState: initialState)

        sut.onTrigger(.topAmountChanged("10"))

        #expect(sut.state.topInputRaw == "10")
        #expect(sut.state.bottomInputRaw == "184.00")
    }

    @Test("currency picker triggers open and dismiss")
    func pickerOpenAndDismissTriggers() async {
        let sut = makeSUT(repository: MockExchangeRepository())

        sut.onTrigger(.currencyTapped)
        #expect(sut.state.isCurrencyPickerPresented == true)

        sut.onTrigger(.currencyPickerDismissed)
        #expect(sut.state.isCurrencyPickerPresented == false)
    }

    @Test("rates failure sets error phase")
    func ratesFailureSetsError() async throws {
        let repository = MockExchangeRepository()
        repository.fetchRatesHandler = { _ in throw TestError.sample }
        let sut = makeSUT(repository: repository)

        sut.onTrigger(.screenAppeared)
        try await Task.sleep(nanoseconds: 80_000_000)

        if case .error = sut.state.phase {
            #expect(sut.state.errorMessage?.isEmpty == false)
        } else {
            Issue.record("Expected error phase after rates failure.")
        }
    }

    @Test("new rate request cancels previous in-flight request")
    func newestRateRequestWins() async throws {
        let repository = MockExchangeRepository()
        repository.fetchRatesHandler = { currencies in
            let code = currencies.first ?? "MXN"
            if code == "MXN" {
                try await Task.sleep(nanoseconds: 250_000_000)
                return [rate(quote: "MXN", ask: "18.41", bid: "18.39")]
            } else {
                try await Task.sleep(nanoseconds: 20_000_000)
                return [rate(quote: "ARS", ask: "1551", bid: "1539")]
            }
        }
        let sut = makeSUT(repository: repository)

        sut.onTrigger(.currencySelected("MXN"))
        sut.onTrigger(.currencySelected("ARS"))
        try await Task.sleep(nanoseconds: 400_000_000)

        #expect(sut.state.bottomCurrency.code == "ARS")
        #expect(sut.state.rates.first?.quoteCurrency.code == "ARS")
    }
}

private extension ExchangeListViewModelTests {
    enum TestError: Error {
        case sample
    }

    func makeSUT(repository: MockExchangeRepository,
                 initialState: ExchangeListState = .initial()) -> ExchangeListViewModel {
        let getRatesUseCase = GetExchangeRatesUseCase(repository: repository)
        let getCurrenciesUseCase = GetAvailableCurrenciesUseCase(repository: repository)
        return ExchangeListViewModel(
            initialState: initialState,
            getExchangeRatesUseCase: getRatesUseCase,
            getAvailableCurrenciesUseCase: getCurrenciesUseCase)
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

private final class MockExchangeRepository: ExchangeRepositoryProtocol {
    var fetchRatesHandler: (([String]) async throws -> [ExchangeRate])?
    var fetchAvailableCurrenciesHandler: (() -> [Currency])?
    var cachedRates: [ExchangeRate] = []

    func fetchRates(for currencies: [String]) async throws -> [ExchangeRate] {
        if let fetchRatesHandler {
            return try await fetchRatesHandler(currencies)
        }
        return []
    }

    func fetchAvailableCurrencies() async -> [Currency] {
        fetchAvailableCurrenciesHandler?() ?? []
    }

    func getLastCachedRates() -> [ExchangeRate] {
        cachedRates
    }

    func saveRatesToCache(_ rates: [ExchangeRate]) {
        cachedRates = rates
    }
}
