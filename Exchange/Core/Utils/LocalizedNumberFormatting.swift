//
//  LocalizedNumberFormatting.swift
//  Exchange
//
//  Created by Sadegh on 01/06/2026.
//

import Foundation

enum LocalizedNumberFormatting {
    static func parseDecimalInput(_ input: String, locale: Locale = .current) -> Decimal? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let currentSeparator = locale.decimalSeparator ?? "."
        let alternateSeparator = currentSeparator == "." ? "," : "."
        let normalized: String
        if trimmed.contains(currentSeparator) {
            normalized = trimmed
        } else {
            normalized = trimmed.replacingOccurrences(of: alternateSeparator, with: currentSeparator)
        }

        return decimalInputFormatter(locale: locale).number(from: normalized)?.decimalValue
    }

    static func formatAmount(_ value: Decimal,
                             locale: Locale = .current,
                             minimumFractionDigits: Int = 2,
                             maximumFractionDigits: Int = 6) -> String {
        let formatter = amountFormatter(
            locale: locale,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits)
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    static func formatRate(_ value: Decimal, locale: Locale = .current) -> String {
        formatAmount(
            value,
            locale: locale,
            minimumFractionDigits: 2,
            maximumFractionDigits: 4)
    }
}

private extension LocalizedNumberFormatting {
    static let formatterLock = NSLock()
    static var formatterCache: [String: NumberFormatter] = [:]

    static func decimalInputFormatter(locale: Locale) -> NumberFormatter {
        cachedFormatter(
            key: "input-\(locale.identifier)",
            locale: locale,
            minimumFractionDigits: 0,
            maximumFractionDigits: 10,
            isLenient: true)
    }

    static func amountFormatter(locale: Locale,
                                minimumFractionDigits: Int,
                                maximumFractionDigits: Int) -> NumberFormatter {
        cachedFormatter(
            key: "amount-\(locale.identifier)-\(minimumFractionDigits)-\(maximumFractionDigits)",
            locale: locale,
            minimumFractionDigits: minimumFractionDigits,
            maximumFractionDigits: maximumFractionDigits,
            isLenient: false)
    }

    static func cachedFormatter(key: String,
                                locale: Locale,
                                minimumFractionDigits: Int,
                                maximumFractionDigits: Int,
                                isLenient: Bool) -> NumberFormatter {
        formatterLock.lock()
        defer { formatterLock.unlock() }

        if let cached = formatterCache[key] {
            return cached
        }

        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.usesGroupingSeparator = true
        formatter.isLenient = isLenient
        formatterCache[key] = formatter
        return formatter
    }
}
