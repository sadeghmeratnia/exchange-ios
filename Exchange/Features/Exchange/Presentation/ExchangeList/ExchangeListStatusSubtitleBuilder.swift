//
//  ExchangeListStatusSubtitleBuilder.swift
//  Exchange
//
//  Created by Sadegh on 02/06/2026.
//

import Foundation

// MARK: - ExchangeListStatusSubtitleBuilder

enum ExchangeListStatusSubtitleBuilder {
    static func subtitle(
        for state: ExchangeListState,
        currencyDisplayProvider: any CurrencyDisplayProviding,
        now: Date = Date()
    ) -> String {
        let statusPrefix = state.isRealtimeRates
            ? L10n.Exchange.Status.live
            : L10n.Exchange.Status.notRealtime
        let updateText = freshnessText(for: state, now: now)
        let topTitle = currencyDisplayProvider.display(for: state.topCurrency.code).title
        let bottomCode = state.bottomCurrency.code

        guard let unitQuoteRate = state.unitQuoteRate else {
            return "\(statusPrefix) • \(updateText) • 1 \(topTitle) = -- \(bottomCode)"
        }

        let formattedRate = LocalizedNumberFormatting.formatRate(unitQuoteRate)
        return "\(statusPrefix) • \(updateText) • 1 \(topTitle) = \(formattedRate) \(bottomCode)"
    }
}

private extension ExchangeListStatusSubtitleBuilder {
    static func freshnessText(for state: ExchangeListState, now: Date) -> String {
        guard let updatedAt = state.lastUpdatedAt else {
            return state.isRealtimeRates
                ? L10n.Exchange.Status.updated
                : L10n.Exchange.Status.lastUpdated
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let relative = formatter.localizedString(for: updatedAt, relativeTo: now)
        let prefix = state.isRealtimeRates
            ? L10n.Exchange.Status.updated
            : L10n.Exchange.Status.lastUpdated
        return "\(prefix) \(relative)"
    }
}
