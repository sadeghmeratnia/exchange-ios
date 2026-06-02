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
        repository.fetchRatesHandler = { _ in
            ExchangeRatesSnapshot(
                rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
                isRealtime: true,
                updatedAt: Date(timeIntervalSince1970: 0))
        }
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

    @Test("rates failure sets error phase")
    func ratesFailureSetsError() async throws {
        let repository = MockExchangeRepository()
        repository.fetchRatesHandler = { _ in throw ExchangeDomainError.ratesUnavailable }
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
                return ExchangeRatesSnapshot(
                    rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
                    isRealtime: true,
                    updatedAt: Date(timeIntervalSince1970: 0))
            } else {
                try await Task.sleep(nanoseconds: 20_000_000)
                return ExchangeRatesSnapshot(
                    rates: [rate(quote: "ARS", ask: "1551", bid: "1539")],
                    isRealtime: true,
                    updatedAt: Date(timeIntervalSince1970: 0))
            }
        }
        let sut = makeSUT(repository: repository)

        sut.onTrigger(.currencySelected(row: .bottom, code: "MXN"))
        sut.onTrigger(.currencySelected(row: .bottom, code: "ARS"))
        try await Task.sleep(nanoseconds: 400_000_000)

        #expect(sut.state.bottomCurrency.code == "ARS")
        #expect(sut.state.rates.first?.quoteCurrency.code == "ARS")
    }

    @Test("dismiss error trigger clears error message")
    func dismissErrorClearsErrorMessage() async {
        let repository = MockExchangeRepository()
        let initialState = ExchangeListState.initial().with(errorMessage: .some("boom"))
        let sut = makeSUT(repository: repository, initialState: initialState)

        sut.onTrigger(.dismissError)

        #expect(sut.state.errorMessage == nil)
    }

    @Test("screen appeared can load from repository fallback rates")
    func screenAppearedLoadsFallbackRates() async throws {
        let repository = MockExchangeRepository()
        repository.cachedRates = [rate(quote: "MXN", ask: "18.41", bid: "18.39")]
        repository.fetchAvailableCurrenciesHandler = { [Currency(code: "MXN")] }
        let sut = makeSUT(repository: repository)

        sut.onTrigger(.screenAppeared)
        try await Task.sleep(nanoseconds: 80_000_000)

        #expect(sut.state.phase == .loaded)
        #expect(sut.state.rates == repository.cachedRates)
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
    var fetchRatesHandler: (([String]) async throws -> ExchangeRatesSnapshot)?
    var fetchAvailableCurrenciesHandler: (() -> [Currency])?
    var cachedRates: [ExchangeRate] = []

    func fetchRates(for currencies: [String]) async throws -> ExchangeRatesSnapshot {
        if let fetchRatesHandler {
            return try await fetchRatesHandler(currencies)
        }
        return ExchangeRatesSnapshot(
            rates: cachedRates,
            isRealtime: false,
            updatedAt: cachedRates.map(\.timestamp).max())
    }

    func fetchAvailableCurrencies() async -> [Currency] {
        fetchAvailableCurrenciesHandler?() ?? []
    }
}
