//
//  ExchangeListStatusSubtitleBuilderTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 02/06/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("ExchangeListStatusSubtitleBuilder")
struct ExchangeListStatusSubtitleBuilderTests {
    private let displayProvider = CurrencyDisplayProvider()
    private let fixedNow = Date(timeIntervalSince1970: 1_715_000_000)

    @Test("includes formatted unit quote when rate is available")
    func includesFormattedUnitQuote() {
        let state = ExchangeListState.initial().with(
            rates: [rate(quote: "MXN", ask: "18.41", bid: "18.39")],
            isRealtimeRates: true,
            lastUpdatedAt: .set(fixedNow.addingTimeInterval(-120)),
            unitQuoteRate: .set(decimal("18.400000")))

        let subtitle = ExchangeListStatusSubtitleBuilder.subtitle(
            for: state,
            currencyDisplayProvider: displayProvider,
            now: fixedNow)

        #expect(subtitle.contains("1 USDc = 18.40 MXN"))
        #expect(subtitle.contains(L10n.Exchange.Status.live))
    }

    @Test("shows placeholder when unit quote is unavailable")
    func showsPlaceholderWhenQuoteMissing() {
        let state = ExchangeListState.initial().with(unitQuoteRate: .set(nil))

        let subtitle = ExchangeListStatusSubtitleBuilder.subtitle(
            for: state,
            currencyDisplayProvider: displayProvider,
            now: fixedNow)

        #expect(subtitle.contains("1 USDc = -- MXN"))
    }
}

private extension ExchangeListStatusSubtitleBuilderTests {
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
