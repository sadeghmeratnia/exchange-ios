//
//  ConvertAmountUseCaseTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 31/05/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ConvertAmountUseCase")
struct ConvertAmountUseCaseTests {
    private let sut = ConvertAmountUseCase()
    private let usdc = Currency(code: "USDC")
    private let mxn = Currency(code: "MXN")
    private let ars = Currency(code: "ARS")

    @Test("USDC to quote uses midpoint")
    func convertsUSDcToQuote() {
        let result = sut.execute(
            amount: Decimal(10),
            from: usdc,
            to: mxn,
            rates: [rate(ask: "18.41", bid: "18.39", quote: "MXN")])

        #expect(result == decimal("184.000000"))
    }

    @Test("Quote to USDC divides by midpoint")
    func convertsQuoteToUSDc() {
        let result = sut.execute(
            amount: Decimal(184),
            from: mxn,
            to: usdc,
            rates: [rate(ask: "18.41", bid: "18.39", quote: "MXN")])

        #expect(result == decimal("10.000000"))
    }

    @Test("Quote to quote converts through USDC")
    func convertsQuoteToQuoteViaUSDc() {
        let rates = [
            rate(ask: "18.41", bid: "18.39", quote: "MXN"),
            rate(ask: "1551", bid: "1539", quote: "ARS"),
        ]
        let result = sut.execute(
            amount: Decimal(184),
            from: mxn,
            to: ars,
            rates: rates)

        #expect(result == decimal("15450.000000"))
    }

    @Test("Same currency keeps amount")
    func keepsAmountForSameCurrency() {
        let result = sut.execute(
            amount: decimal("123.456789"),
            from: mxn,
            to: mxn,
            rates: [])

        #expect(result == decimal("123.456789"))
    }

    @Test("Returns nil when required rate is missing")
    func returnsNilWhenRateMissing() {
        let result = sut.execute(
            amount: Decimal(10),
            from: usdc,
            to: ars,
            rates: [])

        #expect(result == nil)
    }

    @Test("Conversion uses midpoint of ask and bid")
    func conversionUsesMidpoint() {
        let result = sut.execute(
            amount: Decimal(1),
            from: usdc,
            to: mxn,
            rates: [rate(ask: "20.00", bid: "18.00", quote: "MXN")])

        #expect(result == decimal("19.000000"))
    }

    @Test("Returns nil when ask and bid are both zero")
    func returnsNilWhenAskAndBidAreZero() {
        let result = sut.execute(
            amount: Decimal(100),
            from: mxn,
            to: usdc,
            rates: [rate(ask: "0", bid: "0", quote: "MXN")])

        #expect(result == nil)
    }
}

private extension ConvertAmountUseCaseTests {
    func rate(ask: String, bid: String, quote: String) -> ExchangeRate {
        ExchangeRate(
            baseCurrency: usdc,
            quoteCurrency: Currency(code: quote),
            ask: decimal(ask),
            bid: decimal(bid),
            timestamp: Date(timeIntervalSince1970: 0))
    }

    func decimal(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
    }
}
