//
//  CurrencyDisplayProviderTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 01/06/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("CurrencyDisplayProvider")
struct CurrencyDisplayProviderTests {
    @Test("known supported currency maps to configured display metadata")
    func knownCurrencyMetadata() {
        let display = CurrencyDisplayProvider.display(for: "MXN")

        #expect(display.code == "MXN")
        #expect(display.flagEmoji == "🇲🇽")
        #expect(display.fallbackSymbolName == nil)
        #expect(display.title == "MXN")
    }

    @Test("USDC uses product-specific title and representative flag")
    func usdcUsesProductPolicy() {
        let display = CurrencyDisplayProvider.display(for: "USDC")

        #expect(display.code == "USDC")
        #expect(display.title == "USDc")
        #expect(display.flagEmoji == "🇺🇸")
        #expect(display.fallbackSymbolName == nil)
    }

    @Test("unknown currency falls back to localized title and neutral icon")
    func unknownCurrencyFallback() {
        let display = CurrencyDisplayProvider.display(for: "ZZZ")

        #expect(display.code == "ZZZ")
        #expect(display.title == "ZZZ")
        #expect(display.flagEmoji == nil)
        #expect(display.fallbackSymbolName == "globe")
    }
}
