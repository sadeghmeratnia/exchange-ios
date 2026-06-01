//
//  LocalizedNumberFormattingTests.swift
//  ExchangeTests
//
//  Created by Sadegh on 01/06/2026.
//

import Foundation
import Testing
@testable import Exchange

@Suite("LocalizedNumberFormatting")
struct LocalizedNumberFormattingTests {
    @Test("parses comma decimal with es locale")
    func parsesCommaDecimal() {
        let parsed = LocalizedNumberFormatting.parseDecimalInput("18,41", locale: Locale(identifier: "es_MX"))
        #expect(parsed == decimal("18.41"))
    }

    @Test("parses dot decimal with en locale")
    func parsesDotDecimal() {
        let parsed = LocalizedNumberFormatting.parseDecimalInput("18.41", locale: Locale(identifier: "en_US"))
        #expect(parsed == decimal("18.41"))
    }
}

private extension LocalizedNumberFormattingTests {
    func decimal(_ value: String) -> Decimal {
        Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) ?? .zero
    }
}
